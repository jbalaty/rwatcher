# encoding:UTF-8
require 'uri'
require 'pathname'

require_relative 'config/environment.rb'
require_relative 'lib/workers/http_tool.rb'
require_relative 'lib/workers/sreality.rb'

dt_start = Time.now
requests_per_second = 100
dt = DateTime.now - 0.minutes
@http_tool = HttpTool.new

def puts_divider
  puts '-----------------------------------------------------------------'
end

def update_ad(ad)
  changed = false
  page = @agent.get(ad.url)
  sreality = Sreality.new
  detail = sreality.extract_detail_page_data ad.url, page
  #puts detail
  ad.title = detail['Název']
  ad.price = detail['Celková cena'] || detail['Zlevněno']
  ad.description = detail['Popis']
  ad.externid = detail['ExternId']
  # if something changed, create new AdChange object
  if ad.updatedAt != detail['Datum aktualizace']
    changed = true
  else
  end
  ad.updatedAt = detail['Datum aktualizace']
  ad.externsource = 'sreality.cz'
  ad.lastCheckAt = DateTime.now
  ad.lastCheckResponseStatus = '200'
  changed
end

def ad_changed?(ai, new_values_hash)
  #if ai.title != new_values_hash['title'] || ai.price != new_values_hash['price']
  #  || ai.imageUrl != new_values_hash['imageUrl']
  if ai.shortInfoHtml != new_values_hash['shortInfoHtml']
    return true
  end
  return false
end

def update_search_info(si, sreality)
  changed = false
  extractedsi = sreality.extract_search_page_info(si.urlNormalized)
  ads = extractedsi['ads']
  if si.resultsCount != ads.length or si.lastExternId != ads.first['externid']
    changed = true
  end
  # old_ad_infos_arr = si.ad_infos.clone.to_a
  # update all ads watched resources
  hit_last_extern_id = false
  last_extern_ids_changes_count = 0
  ads.each do |ad_hash|
    #tmp = ad_hash.select { |k| !['imageUrl'].include?(k)  }
    tmp = ad_hash
    tmp['lastCheckAt'] = DateTime.now
    ai = AdInfo.find_by_externId ad_hash['externId']
    unless ai
      puts "Creating new AdInfo"
      ai = AdInfo.create! tmp
    else
      #if ai.price != tmp['price']
      #  # Ad change
      #  puts "Creating new change - new ad (siid=#{si.id} and aiid=#{ai.id}) - ad change"
      #  change = Change.new(changeType: 'search_info', changeSubtype: 'change_ad',
      #                      dataBefore: ai.price, dataAfter: tmp['price'])
      #  change.search_info_id = si.id
      #  change.ad_info_id = ai.id
      #  change.save!
      #end

      # check if we hit the last externId and stop generating changes, limit this to 10 else if the last externId ad
      # was already removed, we will generate checks for the whole array
      if !hit_last_extern_id && last_extern_ids_changes_count <= 50
        last_extern_ids_changes_count += 1 #changes counter
        if ai.externId == si.lastExternId
          hit_last_extern_id = true
        else
          if ad_changed? ai, ad_hash
            puts "Creating new change - new ad (siid=#{si.id} and aiid=#{ai.id})"
            change = Change.new(changeType: 'search_info', changeSubtype: 'updated_ad')
            change.search_info_id = si.id
            change.ad_info_id = ai.id
            change.save!
          end
        end
      end
      ai.update! tmp
    end
    # update links between search info resource and all ads in the search
    unless si.ad_infos.include? ai
      puts "Creating new link between SearchInfo and AdInfo - siid=#{si.id} and aiid=#{ai.id} - new ad"
      # create
      unless si.new_record?
        # track this change
        puts "Creating new change - new ad (siid=#{si.id} and aiid=#{ai.id})"
        change = Change.new(changeType: 'search_info', changeSubtype: 'new_ad')
        change.search_info_id = si.id
        change.ad_info_id = ai.id
        change.save!
      end
      si.ad_infos << ai
      #if old_ad_infos_arr.find_index ai
      #  old_ad_infos_arr.delete ai
      #end
    end
  end
  # remove all AdIds, that left in stored old collection
  #puts "#{old_ad_infos_arr.length} links between SearchInfos and Ads left"
  #old_ad_infos_arr.each do |ai|
  #  puts "Removing link between SearchInfo and AdInfo - siid=#{si.id} and aiid=#{ai.id}"
  #  # todo: create change record
  #  si.ad_infos.delete ai.id
  #end

  #only for debug
  #si.ad_infos.delete si.ad_infos.first
  #si.ad_infos.delete si.ad_infos.second
  #si.ad_infos.delete si.ad_infos.third
  si.lastExternId=ads.any? && ads[0]['externId']
  si.resultsCount = ads.length
  si.lastCheckAt = DateTime.now
  changed
end

puts_divider
puts "Processing new requests"
puts_divider
requests = Request.where('processed = :p AND state=:state', {p: false, state: 'active'})
requests.each do |r|
  begin
    puts r.inspect
    sreality = Sreality.new @http_tool
    type = sreality.get_url_type r.url
    if type == :search
      urln = sreality.normalize_search_page_url(r.url).to_s
      #si = WatchedResource.where('externid=:eid', eid: urln).first
      si = SearchInfo.find_by_urlNormalized urln
      unless si
        puts 'Creating new SearchInfo'
        si = SearchInfo.new
        si.urlNormalized = urln
        update_search_info si, sreality
        si.save!
      end
      # check if we have watched resource is associated with this request
      unless r.search_infos.include?(si)
        puts 'Associating new Search info to request'
        r.search_infos << si
      end
    elsif type == :detail
      puts 'Type Ad is not implemented yet'
      #externid = sreality.extract_detail_page_externid r.url
      #ad = Ad.find_by_externid externid
      #unless ad
      #  puts 'Creating new ad'
      #  ad = Ad.new()
      #  ad.url = sreality.normalize_detail_page_url(r.url).to_s
      #  update_ad ad
      #  ad.save!
      #end
      #unless r.ads.include?(ad)
      #  puts "Associating existing ad to this request"
      #  r.ads << ad
      #end
    else
      raise 'Unknown request type'
    end
    #r.processed = true
    r.save!
  rescue Mechanize::ResponseCodeError => e
    puts e
    r.addFailedAttempt
    r.save!
      # todo: if more than 10 attempts fail, delete this request
  rescue Exception => e
    puts e
    puts e.backtrace.inspect
    r.addFailedAttempt
    r.save!
  end
end


puts_divider
puts "Processing search infos"
puts_divider
puts "Getting SearchInfo with last check before #{dt}"
sis = SearchInfo.where('"lastCheckAt" <= ? or "lastCheckAt" is null', dt)
sis.each do |si|
  begin
    puts "Search info url: #{si.urlNormalized}"
    sreality = Sreality.new @http_tool
    is_changed = update_search_info si, sreality
    si.save!
    if is_changed
      puts "Search info with ID=#{si.id} has changed"
      si.requests.each do |r|
        puts "\tAcknowlidging owner of request #{r.id} - #{r.email}"
      end
    else
      puts "Searchinfo with ID=#{si.id} was not changed"
    end
  rescue Exception => e
    puts e
  end
  sleep 1 / requests_per_second
end

puts_divider
puts "Processing changes"
puts_divider
puts "Getting SearchInfo records, that has changed"
requestNotifications = {}
changes = Change.all.order('created_at DESC')
changes.each do |change|
  begin
    puts "Processing  change #{change.id}"
    si = change.search_info
    si.requests.each do |r|
      puts "New notification for request #{r.id}"
      puts "Change #{change.changeType}@#{change.changeSubtype}"
      notifications = requestNotifications[r] || []
      notifications << change
      requestNotifications[r] = notifications
    end
    change.delete
  rescue
    puts $!, $@
  end
end
puts_divider
puts "Sending notification emails: #{requestNotifications.length}"
requestNotifications.each do |k, v|
  begin
    puts "Sending email for request #{k.id}"
    RequestNotifier.SearchInfoChangeSummary(k, v).deliver
  rescue
    puts $!, $@
  end
end

#puts_divider
#puts "Processing ads"
#puts_divider
#puts "Getting Ads with last check before #{dt}"
#ads = Ad.where('lastCheckAt <= ? or lastCheckAt is null', dt)
#ads.each do |ad|
#  begin
#    puts "Ad url: #{ad.url}"
#    is_changed = update_ad ad
#    ad.save!
#    if is_changed
#      puts "Ad with ID=#{ad.id} has changed (#{ad.updatedAt}"
#      ad.requests.each do |r|
#        puts "\tAcknowlidging owner of request #{r.id} - #{r.email}"
#      end
#    else
#      puts "Ad with ID=#{ad.id} was not changed"
#    end
#  rescue Exception => e
#    puts e
#  end
#  sleep 1 / requests_per_second
#end

puts_divider
dt_end = Time.now
timeDiff = dt_end - dt_start
puts "#{DateTime.now} Time of run: #{timeDiff}"
puts_divider
