require 'logger'
require 'middleman-aldo/helpers'

module Middleman
  module Aldo
    class Middleman::AldoExtension < ::Middleman::Extension
      # option :config, 'config for the extension'
      # option :banner, 'Brand folder name'
      # option :season, 'Season folder name'
      # option :campaign, 'Spreadsheet name'
      # option :l3_datafile, 'Path to the L3 Folder'

      # self.defined_helpers = [::Middleman::Aldo::Helpers]

      helpers Middleman::Aldo::Helpers
      include Middleman::Aldo::Helpers

      expose_to_application :get_data, :sanitize_clean
      expose_to_config :get_data, :sanitize_clean

      def initialize(app, options_hash={}, &block)

        super

        # Grab a reference to self so we can access it deep inside blocks
        _self = self

        require 'livingstyleguide'
        # require 'middleman-autoprefixer'
        # require 'susy'
        require 'fastimage'
        # require 'middleman-imageoptim'
        require 'rack'
        require 'rack_staging'

        unless File.directory?('data/cache')
          FileUtils.mkdir 'data/cache'
        end

        app.config[:base_url] = '/'
        app.config[:media_host] = '/'
        app.config[:cache] = true

        # @banner = options[:config][:banner]
        # @season = options[:config][:season]
        # @campaign = options[:config][:campaign]
        # @generate_l3 = options[:config][:l3][:enable]
        # @l3_datafile = options[:config][:l3][:path]

        # Default environment variables
        app.config[:version] =  ENV['VER'] || 'hybris'
        app.config[:revision] = ENV['REV'] || 'dev'

        # Store environmental arrays so we can easily update lists
        app.set :version_list,  ['icongo', 'hybris']
        app.set :revision_list, ['dev', 'staging', 'prod']

        # Config for Middleman
        app.config[:layouts_dir]       = 'layouts/'
        app.config[:build_dir]         = "build/#{app.environment.to_s}/hybris"
        app.config[:partials_dir]      = 'layouts/partials/'
        app.config[:css_dir]           = 'assets/css/'
        app.config[:js_dir]            = 'assets/js/'
        app.config[:images_dir]        = app.config[:media_host] + 'assets/img/'

        # Settings for Heroku
        if  ENV['STAGING'] == 'heroku'
          app.use Rack::Staging
          # app.set :offline, false
          # app.set :cache_duration, 45
        end

        unless ENV['STAGING'] == 'heroku'
          app.set :cache_duration, 180
        end


        # syntax = Proc.new {
        #   activate :autoprefixer do |config|
        #     config.browsers = [
        #       'last 2 versions',
        #       'Opera >= 8',
        #       'Firefox >= 12',
        #       'Explorer >= 8',
        #       'ie 8',
        #       'ie 9',
        #       'opera 12'
        #     ]
        #     config.cascade  = false
        #     config.inline   = true
        #   end
        #   # Activate some extra gems
        #   activate :directory_indexes
        # }

        # app.configure(:development, &syntax)
        # app.configure(:build, &syntax)

        # Slim config
        I18n.config.enforce_available_locales = false
        Slim::Engine.disable_option_validator!
        Slim::Engine.set_options lang: I18n.locale, locals: {}
        app.config[:slim] = {layout_engine: :slim}

        ###########################
        # Dynamic Pages generator #
        ###########################

        # Generate Dynamic Level3 Pages


        app.configure :development do
          activate :relative_assets
        end

        app.configure :build do
          ignore "css/core/*"
          ignore "css/vendor/*"
          ignore "js/dev/*"
        end
      end

      # require 'net/http'

      # def get_url(url, multi_options={})
      #   uri = URI(url)
      #   response = Net::HTTP.get uri
      #   response
      # end

      # # Returns the response on success, nil on TimeoutErrors after all retry_count attempts.
      # def get_with_retries(url, retry_count)
      #   retry_count.times do
      #     result = get_url(url)
      #     return JSON.parse(result) if result
      #   end
      #   nil
      # end

      # def get_data(locale, *args)
      #   options = args.extract_options!
      #   tab = options[:tab] || nil
      #   banner = options[:banner] || app.config[:banner]
      #   season = options[:season] || app.config[:season]
      #   campaign = options[:campaign] || app.config[:campaign]
      #   cache_period = app.config[:cache_duration] || 30
      #   base_url = "http://gdrive-api.herokuapp.com/api/v1/"
      #   path = options[:path] || "#{banner}/#{season}/#{campaign}/#{locale}/#{tab}"
      #   url = base_url + path
      #   data = load_from_cache(locale, tab, "#{cache_period}s")

      #   unless data
      #     data = get_with_retries(url, 3)
      #     store_in_cache(locale, tab, data)
      #   end
      #   return data
      # end

      # def store_in_cache(locale, tab, data)
      #   ::File.open("data/cache/#{locale}_#{tab}.yml", "w") do |file|
      #     file << YAML.dump({
      #       "ts" => Time.now.to_i,
      #       "data" => data
      #     })
      #   end
      # end

      # def load_from_cache(locale, tab, cache_period)
      #   cache_seconds = period_to_seconds(cache_period)
      #   return nil unless cache_seconds
      #   return nil unless cache_seconds > 0

      #   cache = YAML.load(::File.read("data/cache/#{locale}_#{tab}.yml")) rescue nil
      #   return nil unless cache
      #   return nil if Time.at(cache['ts'].to_i) + period_to_seconds(cache_period) < Time.now

      #   cache['data']
      # end

      # def period_to_seconds(period)
      #   return nil unless period

      #   _, value, unit = *period.match(/(\d+)\s*(s|second|seconds|m|minute|minutes|h|hour|hours)/)

      #   return puts "Bad time period for GDrive cache '#{period}'" unless value && unit

      #   multiplier = case unit
      #   when "s", "second", "seconds"
      #     1
      #   when "m", "minute", "minutes"
      #     60
      #   when "h", "hour", "hours"
      #     60 * 60
      #   end

      #   multiplier * value.to_i
      # end

    end
  end
end
