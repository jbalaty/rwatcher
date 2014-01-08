# encoding:UTF-8

class Sreality
  def initialize(http_tool)
    @http_tool = http_tool

    @categoryTypes = {
        'prodej' => 1,
        'pronajem' => 2,
        'drazby' => 3
    }
    @categoryMains = {
        'byty' => 1,
        'domy' => 2,
        'pozemky' => 3,
        'komercni' => 3,
        'ostatni' => 3
    }
    @categorySubTypes = {
        'garsonka' => 1,
        '1+kk' => 2,
        '1+1' => 3,
        '2+kk' => 4,
        '2+1' => 5,
        '3+kk' => 6,
        '3+1' => 7,
        '4+kk' => 8,
        '4+1' => 9,
        '5+kk' => 10,
        '5+1' => 11,
        '6+kk' => 12,
        '6+1' => 13,
        'chaty' => 33,
        'garaze' => 34,
        'chalupy' => 43,
        'historicke objekty' => 35,
        'historicke-objekty' => 35,
        'pamatky' => 35,
        'zemedelske usedlosti' => 44,
        'zemedelske-usedlosti' => 44,
        'usedlosti' => 44,
        'kancelare' => 25,
        'sklady' => 26,
        'vyroba' => 27,
        'obchodni prostory' => 28,
        'obchodni-prostory' => 28,
        'ubytovani' => 29,
        'restaurace' => 30,
        'zemedelske objekty' => 31,
        'zemedelske-objekty' => 31,
        'jiny' => 32,
    }
  end

  def extract_detail_page_data(url, page)
    result = {}
    nodes = page.search('#realityInfo h2')
    result['Název'] = nodes.first.content
    nodes = page.search('#realityInfo p.row')
    result.merge! extract_rows nodes
    result['Popis'] = page.search('.row.last .description').first.content
    result['ExternId'] = extract_detail_page_externid(url)
    result
  end

  def extract_detail_page_externid(url)
    return Pathname.new(URI(url).path).basename.to_s
  end

  def normalize_detail_page_url(url)
    uri = URI(url)
    URI::HTTP.build(host: uri.host, path: uri.path)
  end

  def is_url_valid?(url)
    url_type = get_url_type url
    if url_type == :detail
      true
    elsif url_type == :search
      true
    else
      false
    end
  end

  def get_url_type(url)
    begin
      type = url.match(/sreality.cz\/(?<type>\w+)/)['type']
      if type == 'detail'
        :detail
      elsif type == 'hledani' or type == 'search'
        :search
      else
        nil
      end
    rescue
      return nil
    end
  end

  def convert_nice_url(url)
    #match = url.match(/sreality.cz\\\/hledani\\\/(?<categorytype>\w+)\\\/(?<category>\w+)\\\/(?<subtype>\w+)/)
    #category_type = match['categorytype']
    #category_type = match['category']
    #category_type = match['subtype']
    parsed = URI(url)
    path_segments = parsed.path.to_s.split('/')
    category_type = path_segments[2]
    category = path_segments[3]
    category_subtype = path_segments[4] if path_segments.length >= 5
    query_params = URI.decode_www_form(parsed.query || '')
    query_params << ['category_type_cb', @categoryTypes[category_type]]
    query_params << ['category_main_cb', @categoryMains[category]]
    query_params << ['sub[]', @categorySubTypes[category_subtype]] if category_subtype
    parsed.query = URI.encode_www_form(query_params)
    parsed.path = '/search'
    parsed.to_s
  end

  def normalize_search_page_url(url)
    # check if this is nice url eg: http://www.sreality.cz/hledani/prodej/byty/2+kk
    # and convert it to normal search url
    if /sreality.cz\/hledani/i =~ url
      url = convert_nice_url(url)
    end
    URI(url.sub(/sort=\d/, 'sort=0'))
  end

  def extract_search_page_info(url)
    result = {}
    page = @http_tool.get set_search_url_query_params(url, 'perPage' => 100)
    nodes = page.search('#results #showOnMap p span')
    result['foundCount'] = nodes.first.content.match(/(?<count>[\d ]+)/)['count'].to_i
    ads = []
    # repeat until we have page with some results
    while page
      nodes = page.search('#changingResults .result.vcard')
      nodes.each do |vcard|
        unless vcard['class'] =~ /tip/
          ads << extract_search_page_item(vcard)
        else
          puts "Skipping this node, it is probably SReality payed ad"
        end
      end
      # try to find next page link
      nodes = page.search('#paging a.next')
      if nodes.any?
        page = @http_tool.get nodes.first['href']
      else
        page = nil
      end
    end
    result['ads'] = ads
    result
  end

  def extract_search_page_summary(url)
    result = {}
    page = @http_tool.get url
    nodes = page.search('#results #showOnMap p span')
    result['total'] = nodes.first.content.match(/(?<count>[\d ]+)/)['count'].to_i
    result
  end

  def extract_search_page_item(vcard_node)
    nodes = nil
    begin
      result = {}
      result['shortInfoHtml'] = vcard_node.to_s
      nodes = vcard_node.search('.fn a')
      result['title'] = nodes.first.content
      result['urlNormalized'] = normalize_detail_page_url(nodes.first['href']).to_s
      result['externId'] = extract_detail_page_externid(result['urlNormalized'])
      result['externSource'] = 'sreality'
      nodes = vcard_node.search('.price')
      nodes = vcard_node.search('.price-discount') if nodes.empty?
      if nodes.first.content == 'Info o ceně u RK' then
        result['price'] = 0;
        result['priceNotice'] = nodes.first.content if nodes.any?
      else
        result['price'] = nodes.first.content.gsub(/ /, '').to_i
        nodes = vcard_node.search('.price-discount-desc')
        result['priceNotice'] = nodes.first.content if nodes.any?
      end
      nodes = vcard_node.search('.silver')
      result['priceType'] = nodes.first.content if nodes.any?
      nodes = vcard_node.search('.address.adr').children().slice(2..10)
      result['shortAddress'] = nodes.to_a.map { |n| n.content }.join
      nodes = vcard_node.search('.picture.url img')
      result['imageUrl'] = nodes.first['data-src']
      result
    rescue
      puts $!
      puts $!.backtrace.inspect
      puts 'Error parsing item vcard info: ' + vcard_node.inspect
      #puts "Additional node info: #{nodes.first.content}" if nodes.any?
      raise $!
    end
  end

  def get_page_summary(url)
    result = nil
    url_type = get_url_type url
    if url_type == :detail
      nil
    elsif url_type == :search
      url = normalize_search_page_url(url)
      result = extract_search_page_summary(url)
    else
      nil
    end
    result
  end

  protected
  def extract_rows(nodes)
    result = {}
    value = nil
    nodes.each do |row|
      desc = row.children()[1].content.strip.chop
      if ['Zlevněno', 'Původní cena', 'Celková cena'].include? desc
        value = row.children()[3].content.match(/(?<price>[\d ]+)/)['price'].gsub(/ /, '').to_i
      elsif desc == 'Datum aktualizace'
        value = Date.parse(row.children()[3].content)
      else
        value = row.children()[3].content
      end
      result[desc]=value
    end
    result
  end

  def set_search_url_query_params(url, hash)
    uri = URI(url)
    params = Rack::Utils.parse_query uri.query
    hash.each do |key, value|
      if params.has_key? key
        params[key] = value
      end
    end
    uri.query = URI.encode_www_form params
    uri.to_s
  end


end