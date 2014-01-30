# encoding:UTF-8
require 'uri'
require 'pathname'

require_relative 'config/environment.rb'
require_relative 'lib/workers/http_tool.rb'
require_relative 'lib/workers/sreality.rb'

dt_start = Time.now
puts "Start time: #{dt_start}"
requests_per_second = 100
dt = DateTime.now - 1.minutes
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
  url = sreality.set_search_page_url_age_to(si.urlNormalized, :new)
  extractedsi = sreality.extract_search_page_info(url)
  ads = extractedsi['ads']
  if ads.length == 0
    changed = false
  else
    ads.each do |ad_hash|
      tmp = ad_hash
      tmp['lastCheckAt'] = DateTime.now
      puts "Searching AdInfo with externId = #{tmp['externId']}"
      ai = AdInfo.where('search_info_id = ? AND "externId"=?', si.id, tmp['externId']).order('created_at DESC').first()
      #puts "ai='#{ai}', ai.shortInfoHtmlHash='#{if ai then ai.shortInfoHtml.hash else '' end}', newInfoHtmlhash='#{ad_hash['shortInfoHtml'].hash}'"
      #puts "ai='#{ai}', ai.shortInfoHtmlHash='#{if ai then ai.shortInfoHtml else '' end}', newInfoHtmlhash='#{ad_hash['shortInfoHtml']}'"
      if ai == nil
        changed = true
        is_new = ai == nil
        puts "Creating new AdInfo ExternID=#{tmp['externId']}"
        ai = AdInfo.new tmp
        ai.search_info_id=si.id
        ai.save!
        # create new change
        change_sub_type= if is_new then
                           'new_ad'
                         else
                           'updated_ad'
                         end
        puts "Creating new change (siid=#{si.id} and aiid=#{ai.id}) - #{change_sub_type}"
        change = Change.new(changeType: 'search_info', changeSubtype: change_sub_type)
        change.search_info_id = si.id
        change.ad_info_id = ai.id
        change.save!
      end
    end
  end
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
      si = SearchInfo.find_by_urlNormalized urln
      unless si
        puts 'Creating new SearchInfo'
        si = SearchInfo.new
        si.urlNormalized = urln
        si.save!
        #update_search_info si, sreality
      end
      # check if we have watched resource associated with this request
      unless r.search_infos.include?(si)
        puts 'Associating new Search info to request'
        r.search_infos << si
      end
    elsif type == :detail
      puts 'Type Ad is not implemented yet'
      raise NotImplementedError
    else
      raise 'Unknown request type'
    end
    r.processed = true
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
    puts "Search info SIID=#{si.id} URL: #{si.urlNormalized}"
    sreality = Sreality.new @http_tool
    is_changed = update_search_info si, sreality
    si.save!
    if is_changed
      puts "Search info with SIID=#{si.id} was changed"
    else
      puts "Searchinfo with SIID=#{si.id} was not changed"
    end
  rescue
    puts $!, $@
  end
  sleep 1 / requests_per_second
end

puts_divider
puts "Processing changes"
puts_divider
#puts "Getting SearchInfo records, that has changed"
requestNotifications = {}
changes = Change.all.order('created_at DESC')
changes.each do |change|
  begin
    puts "Processing  change #{change.id} (siid: #{change.search_info_id}, aid: #{change.ad_info_id})"
    si = change.search_info
    si.requests.each do |r|
      if r.numnotificationrounds > 0
        puts "New notification for request #{r.id} -  #{change.changeType}@#{change.changeSubtype}"
        notifications = requestNotifications[r] || []
        notifications << change
        requestNotifications[r] = notifications
      end
    end
    change.delete
  rescue
    puts $!, $@
  end
end

puts_divider
puts "Increasing num notification rounds"
requests.each do |r|
  puts "Increasing num notification rounds for request ID=#{r.id}"
  r.numnotificationrounds += 1
  r.save!
end


puts_divider
puts "Sending notification emails: #{requestNotifications.length}"
requestNotifications.each do |k, v|
  begin
    puts "Sending email for request #{k.id} - number of notifications: #{v.length}"
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
