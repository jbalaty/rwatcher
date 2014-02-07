# encoding:UTF-8
require 'uri'
require 'pathname'
require 'csv'

require_relative 'config/environment.rb'
require_relative 'lib/workers/http_tool.rb'
require_relative 'lib/workers/sreality.rb'

dt_start = Time.now
puts "Start time: #{dt_start}"
requests_per_second = 50
dt = DateTime.now - 1.minutes
@http_tool = HttpTool.new

def write_csv_header(csv)
  csv << [
      'ExternId',
      'Název',
      'Celková cena',
      '',
      'Poznámka k ceně',
      'Adresa',
      'Datum aktualizace',
      'ID zakázky',
      'Budova',
      'Stav objektu',
      'Vlastnictví',
      'Podlaží umístění',
      'Plocha užitná',
      'Plocha podlahová',
      'Garáž',
      'Voda',
      'Elektřina',
      'Plyn',
      'Doprava',
      'Výtah',
      'Typ domu',
      'Podlaží počet',
      'Topení',
      'Umístění objektu',
      'Odpad',
      'Telekomunikace',
      'Datum nastěhování',
      'Rok rekonstrukce',
      'Zařízeno',
      'Sklep',
      'Bezbariérový přístup',
      'Terasa',
      'Parkovací stání',
      'Plocha pozemku',
      'Zástavba',
      'Komunikace',
      'Energetická náročnost budovy: Energetická náročnost budov',
      'Půdní vestavba',
      nil,
      'Popis'
  ]
end

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

puts_divider
puts "Processing given SReality URLs"
puts_divider
data_urls = []
# SReality - byty
#data_urls << 'http://www.sreality.cz/search?category_type_cb=1&category_main_cb=1&price_min=&price_max=&region=&distance=0&usable_area-min=&usable_area-max=&floor_number-min=&floor_number-max=&age=0&extension=0&sort=0&perPage=10&hideRegions=0&discount=-1'
#data_urls << 'http://www.sreality.cz/search?category_type_cb=1&category_main_cb=1&sub%5B%5D=2&price_min=&price_max=&region=&distance=0&usable_area-min=&usable_area-max=&floor_number-min=&floor_number-max=&age=0&extension=0&sort=0&perPage=30&hideRegions=0&discount=-1'
data_urls << 'http://www.sreality.cz/search?category_type_cb=1&category_main_cb=1&sub%5B%5D=2&price_min=&price_max=&region=&distance=0&rg%5B%5D=10&dt%5B%5D=5002&usable_area-min=&usable_area-max=&floor_number-min=&floor_number-max=&age=0&extension=0&sort=0&perPage=30&hideRegions=0&discount=-1'
sreality = Sreality.new @http_tool
data_urls.each do |url|
  begin
    puts "Getting data from listing: #{url}"
    spinfo = sreality.extract_search_page_info(url)
    puts "Number of ads stated:#{spinfo['foundCount']} / downloaded: #{spinfo['ads'].length}"
    ad_details = {}
    detail_field_stats = {}
    total = spinfo['ads'].length
    spinfo['ads'].each_index do |index|
      begin
        ad = spinfo['ads'][index]
        # get add details
        page = @http_tool.get(ad['urlNormalized'])
        detail = sreality.extract_detail_page_data ad['urlNormalized'], page
        ad_details[detail['ExternId']] = detail
        # update detail fields stats
        detail.keys.each do |k|
          detail_field_stats[k] = if detail_field_stats[k] then
                                    detail_field_stats[k]+1
                                  else
                                    1
                                  end
        end
        puts "Extracted detail page info (#{index+1}/#{total}): EID=#{detail['ExternId']} - #{detail['Název']}"
        sleep 1/requests_per_second
      rescue
        puts $!, $@
      end
    end
    puts "Detail keys stats"
    detail_field_stats.each { |k, v| puts "Key #{k} : #{v}" }
    puts "Writing data to CSV"
    CSV.open("data_all.csv", "wb") do |csv|
      write_csv_header csv
      ad_details.each do |k, v|
        record = [
            v['ExternId'],
            v['Název'],
            v['Celková cena'],
            v[''],
            v['Poznámka k ceně'],
            v['Adresa'],
            v['Datum aktualizace'],
            v['ID zakázky'],
            v['Budova'],
            v['Stav objektu'],
            v['Vlastnictví'],
            v['Podlaží umístění'],
            v['Plocha užitná'],
            v['Plocha podlahová'],
            v['Garáž'],
            v['Voda'],
            v['Elektřina'],
            v['Plyn'],
            v['Doprava'],
            v['Výtah'],
            v['Typ domu'],
            v['Podlaží počet'],
            v['Topení'],
            v['Umístění objektu'],
            v['Odpad'],
            v['Telekomunikace'],
            v['Datum nastěhování'],
            v['Rok rekonstrukce'],
            v['Zařízeno'],
            v['Sklep'],
            v['Bezbariérový přístup'],
            v['Terasa'],
            v['Parkovací stání'],
            v['Plocha pozemku'],
            v['Zástavba'],
            v['Komunikace'],
            v['Energetická náročnost budovy: Energetická náročnost budov'],
            v['Půdní vestavba'],
            nil,
            v['Popis'],
            nil
        ]
        if v['Images']
          v['Images'].each { |image| record << image['image'] }
        end
        csv << record
      end
    end
  rescue
    puts $!, $@
  end
end

puts_divider
dt_end = Time.now
timeDiff = dt_end - dt_start
puts "#{DateTime.now} Time of run: #{timeDiff}"
puts_divider
