require 'fileutils'

module Middleman
  module Aldo
    module Helpers
      def format_price(price)
        (t(:lang).include? 'ca_fr') ? price + "&thinsp;$" : "$" + price
      end

      def is_ca(lang = "both")
        case lang
        when "en"
          (t(:lang) == 'ca_en')
        when "fr"
          (t(:lang) == 'ca_fr')
        else
          (t(:lang) == 'ca_en' || t(:lang) == 'ca_fr')
        end
      end

      def is_fr
        is_ca('fr')
      end

      def is_us
        (t(:lang) == 'us_en_US')
      end

      def slim_partial(name, options = {}, &block)
        Slim::Template.new("#{name}.slim.erb", options).render(self, &block)
      end

      def element_style(block_name, element_name)
        block_name + '__' + element_name
      end

      def modifier_style(block_name, element_name=nil, modifier_name)
        if element_name.nil?
          block_name + '--' + modifier_name
        else
          block_name + '__' + element_name + '--' + modifier_name
        end
      end

      def bemit(type, name, element=nil, modifier=nil)
        types = {
          'object' => 'o',
          'component' => 'c'
        }

        if element.nil? && modifier.nil?
          namespace = "#{types[type]}-#{name}"
        elsif !element.nil? && modifier.nil?
          namespace = "#{types[type]}-#{name}__#{element}"
        elsif !modifier.nil? && element.nil?
          namespace = "#{types[type]}-#{name}--#{modifier}"
        else
          namespace = "#{types[type]}-#{name}__#{element}--#{modifier}"
        end

      end

      def page_class
       current_resource.url.sub('.html', '').gsub('/', ' ')
      end

      def get_current_page
        page = page_class.split[1]
        subpage = page_class.split[2]
        if subpage.nil?

          (page.blank?) ? 'homepage' : page
        else
          page + '/' + subpage
        end
      end

      def image_size(image_n_path)
          begin
            FastImage.size(image_n_path)
          rescue NoMethodError
            puts "There is an error on: #{image_n_path}"
          end
      end

      def image_height(image_n_path)
        begin
          unless image_n_path.include? config[:source]
            image_n_path = config[:source] + '/assets/img/' + image_n_path
          end
          FastImage.size(image_n_path)[1]
        rescue
          puts "There is an error on: #{image_n_path}"
        end
      end

      def image_width(image_n_path)
        begin
          unless image_n_path.include? config[:source]
            image_n_path = config[:source] + '/assets/img/' + image_n_path
          end
          FastImage.size(image_n_path)[0]
        rescue
          puts "There is an error on: #{image_n_path}"
        end
      end

      def price_bubbles(price_data, image)
        price       = price_data['price']
        sale_price  = price_data['sale']
        coordinates = price_data['coordinates']
        position    = price_data['image']

        image_n_path = config[:source] + '/assets/img/' + image


        unless price.nil? || price.empty?
          "<div class=\"adl-bubble-container\" style=\"#{px2percentage(css_array(coordinates), image_size(image_n_path), 'left')}; #{px2percentage(css_array(coordinates), image_size(image_n_path), 'top')};\">
            <div class=\"adl-bubble #{position}\">
              #{sale_price.empty? ? reg_bubble(price) : sale_bubble(price, sale_price)}
            </div>
          </div>"
        end
      end

      def px2percentage(content, context, property)
        value = content["#{property}"]
        unless value.nil?
          if value.include?('px')
            if property == 'left'
              begin
                value = (content["#{property}"].gsub('px', '').to_f) / context[0].to_f * 100
              rescue
                  value = 0
              end

            else
              begin
                value = (content["#{property}"].gsub('px', '').to_f) / context[1].to_f * 100
              rescue
                value = 0
              end
            end
            "#{property}:#{value.round(3)}%"
          else
            "#{property}:#{value}%"
          end
        else
          value = 0
          "#{property}:#{value.round(3)}%"
        end


      end

      def sale_bubble(reg_price, down_price)
        "<p class=\"highlight\">#{format_price down_price}<br /><span class=\"adl-sale-price\"><strike>#{format_price reg_price}</strike></span></p>"
      end

      def reg_bubble(price)
        "<p>#{format_price price}</p>"
      end

      def sanitize_clean(name)
        I18n.transliterate(name).downcase.gsub(/[\`\~\!\@\#\$\%\^\&\*\(\)\-\=\_\+\[\]\\\;\'\,\.\/\{\}\|\:\"\<\>\?]/,' ').gsub(/\s+/, '-').gsub(/[^a-z0-9_-]/, '').squeeze('-') unless(name.nil?)
      end

      def newline2br(longname)
        longname.gsub(/\n/, '<br/>')
      end

      def newspan2br(longname)
        longname.gsub(/\n/, '</span><br/><span>')
      end

      def css_array(property)
        a = property.split(/\W+/)
        return Hash[*a]
      end

      def convert_class(width)
        "adl-col" + width.chomp(' columns')
      end

      def remove_host(link)
        if link.include?('perf.callitspring.com') || link.include?('www.callitspring.com')
          link = URI.escape(link)
          unless URI.parse(link).query.nil?
            URI.unescape(URI.parse(link).path + '?' + URI.parse(link).query)
          else
            URI.unescape(URI.parse(link).path)
          end
        else
          link
        end
      end

      def hybris_link(link)
        link + '_hybris'
      end

      def getlink(row, link)
        row[hybris_link(link)].rstrip
      end

      require 'net/http'

      def get_url(url, multi_options={})
        uri = URI(url)
        response = Net::HTTP.get uri
        response
      end

      # Returns the response on success, nil on TimeoutErrors after all retry_count attempts.
      def get_with_retries(url, retry_count=3)
        retry_count.times do
          result = get_url(url)
          return JSON.parse(result) if result
        end
        nil
      end

      def get_data(locale, *args)
        # require 'pry'
        # binding.pry
        options = args.extract_options!
        tab = options[:tab] || nil
        banner = options[:banner] || extensions[:aldo].options[:banner]
        season = options[:season] || extensions[:aldo].options[:season]
        campaign = options[:campaign] || extensions[:aldo].options[:campaign]
        cache_period = config[:cache_duration] || 15
        base_url = "http://gdrive-api.herokuapp.com/api/v1/"
        path = options[:path] || "#{banner}/#{season}/#{campaign}/#{locale}/#{tab}"
        url = base_url + path
        data = load_from_cache(locale, tab, "#{cache_period}s")

        unless data
          data = get_with_retries(url, 5)
          store_in_cache(locale, tab, data)
        end
        return data
      end

      def store_in_cache(locale, tab, data)
        ::File.open("data/cache/#{locale}_#{tab}.yml", "w") do |file|
          file << YAML.dump({
            "ts" => Time.now.to_i,
            "data" => data
          })
        end
      end

      def gdrive(locale, sheet_name)
        get_data(locale, tab: sheet_name)
      end

      def get_sheet(locale, ss_path)
        get_data(locale, path: "#{banner}/#{ss_path}")
      end

      def load_from_cache(locale, tab, cache_period)
        cache_seconds = period_to_seconds(cache_period)
        return nil unless cache_seconds
        return nil unless cache_seconds > 0

        cache = YAML.load(::File.read("data/cache/#{locale}_#{tab}.yml")) rescue nil
        return nil unless cache
        return nil if Time.at(cache['ts'].to_i) + period_to_seconds(cache_period) < Time.now

        cache['data']
      end

      def period_to_seconds(period)
        return nil unless period

        _, value, unit = *period.match(/(\d+)\s*(s|second|seconds|m|minute|minutes|h|hour|hours)/)

        return puts "Bad time period for GDrive cache '#{period}'" unless value && unit

        multiplier = case unit
        when "s", "second", "seconds"
          1
        when "m", "minute", "minutes"
          60
        when "h", "hour", "hours"
          60 * 60
        end

        multiplier * value.to_i
      end

      def getItemByPosition(grid_position, page_data_request)
        return nil unless page_data_request
        item_by_position = page_data_request.find { |k| k['grid_position'] == grid_position }
        item_by_position ? item_by_position : '<span>no item found!</span>'
      end

      def getItemByPositionAndType(grid_position, page_type, page_data_request)
        return nil unless page_data_request
        item_by_position = page_data_request.find {|k| k['grid_position'] == grid_position && k['type'] == page_type }
        item_by_position ? item_by_position : '<span>no item found!</span>'
      end

      def getItemByType(type, page_data_request)
        return nil unless page_data_request
        item_by_position = page_data_request.find { |k| k['type'] == type}
        item_by_position ? item_by_position : '<span>no item found!</span>'
      end

      def getItemByPage(page, page_data_request)
        return nil unless page_data_request
        item_by_position = page_data_request.find { |k| k['page'] == page}
        item_by_position ? item_by_position : '<span>no item found!</span>'
      end

      def getAllItemsByPosition(grid_position, page_data_request)
        return nil unless page_data_request
        item_by_position = page_data_request.find_all {|k| k['grid_position'] == grid_position }
        item_by_position ? item_by_position : '<span>no item found!</span>'
      end

      def getAllItemsByType(type, page_data_request)
        return nil unless page_data_request
        item_by_position = page_data_request.find_all {|k| k['type'] == type }
        item_by_position ? item_by_position : '<span>no item found!</span>'
      end

      def getAllItemsByPage(page, page_data_request)
        return nil unless page_data_request
        item_by_position = page_data_request.find_all { |k| k['page'] == page }
        item_by_position ? item_by_position : '<span>no item found!</span>'
      end

      def getCell(grid_position, column_name, page_data_request)
        return nil unless page_data_request
        getItemByPosition(grid_position, page_data_request)[column_name]
      end

      def getData(data_type, data_name, page_data)
        return nil unless page_data
        request = page_data.find_all {|k| k["#{data_type}"].match /#{data_name}/}
        if request.length == 1
          return request[0]
        else
          return request ? request : 'Error: No Data Found'
        end
      end

      def getAllData(data_type, data_name, page_data)
        return page_data.find_all { |k| k["#{data_type}"].match /#{data_name}(.*)/ }
      end
    end
  end
end
