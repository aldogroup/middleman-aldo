require 'middleman-aldo/helpers'

module Middleman
  module Aldo
    class Middleman::AldoExtension < ::Middleman::Extension
      self.defined_helpers = [::Middleman::Aldo::Helpers]

      def initialize(app, options_hash = {}, &block)

        super

        # Grab a reference to self so we can access it deep inside blocks
        _self = self

        # require 'livingstyleguide'
        require 'middleman-autoprefixer'
        require 'susy'
        require 'fastimage'
        require 'middleman-imageoptim'
        require 'rack'
        require 'rack_staging'

        unless File.directory?('data/cache')
          FileUtils.mkdir 'data/cache'
        end

        app.set :base_url, '/'
        app.set :media_host, '/'
        app.set :cache, true

        # Default environment variables
        app.set :version,  ENV['VER'] || 'hybris'
        app.set :revision, ENV['REV'] || 'dev'

        # Store environmental arrays so we can easily update lists
        app.set :version_list,  ['icongo', 'hybris']
        app.set :revision_list, ['dev', 'staging', 'prod']

        # Config for Middleman
        app.config[:layouts_dir]       = 'layouts/'
        app.config[:build_dir]         = "build/#{app.revision}/#{app.version}"
        app.config[:partials_dir]      = 'layouts/partials/'
        app.config[:css_dir]           = 'assets/css/'
        app.config[:js_dir]            = 'assets/js/'
        app.config[:images_dir]        = app.media_host + 'assets/img/'

        # Settings for Heroku
        if  ENV['STAGING'] == 'heroku'
          app.use Rack::Staging
          app.set :offline, false
          app.set :cache_duration, 45
        end

        unless ENV['STAGING'] == 'heroku'
          app.set :cache_duration, 180
        end


        syntax = Proc.new {
          activate :autoprefixer do |config|
            config.browsers = [
              'last 2 versions',
              'Opera >= 8',
              'Firefox >= 12',
              'Explorer >= 8',
              'ie 8',
              'ie 9',
              'opera 12'
            ]
            config.cascade  = false
            config.inline   = true
          end
          # Activate some extra gems
          activate :directory_indexes
        }

        app.configure(:development, &syntax)
        app.configure(:build, &syntax)

        # Slim config
        I18n.config.enforce_available_locales = false
        Slim::Engine.disable_option_validator!
        Slim::Engine.set_options lang: I18n.locale, locals: {}
        app.set :slim, :layout_engine => :slim

        ###########################
        # Dynamic Pages generator #
        ###########################

        # Generate Dynamic Level3 Pages
        if app.generate_l3 == true
          app.ready do
            logger.warn "== Generating L3 Pages"
            Dir.foreach('locales') do |proxy_lang|
              next if proxy_lang == '.' or proxy_lang == '..'
              localeID = "#{proxy_lang}".split('.')[0]

              if localeID == 'us_en_US'
                newLocaleID = localeID.gsub('us_en_US', 'us-en')
              else
                newLocaleID = localeID.gsub('_', '-')
              end
              

              # l3_data = get_data(localeID, path: "#{banner}/#{config[:l3_datafile]}/#{localeID}/l3", tab: "l3")

              l3_data = get_data(localeID, path: "#{banner}/#{config[:l3_datafile]}/CIS_Categories/L3_#{modLocaleID}", tab: "L3_#{modLocaleID}")

              require 'pry'
              binding.pry

              l3_data.each do |i|
                # begin
                #   unless i['page'].empty? || i['hybris ID'].to_i.to_s.empty?
                #     image = i['image']
                #     copy = i['copy']
                #     title = i['page']
                #     raw_type = i['type']
                #     type = sanitize_clean(raw_type)
                #     raw_category = i['category']
                #     hybris_id = i['hybris ID']
                #     disclaimer = i['disclaimer']
                #     category = sanitize_clean(raw_category)
                #     filename = category + '-' + sanitize_clean(title)
                #     filepath = "#{localeID}/l3/#{hybris_id}-#{category}.html"
                #     proxy filepath, "/localizable/l3/template_l3.html", :locals => { :l3_title => title, :l3_category => category, :l3_type => type, :l3_image => image, :l3_copy => copy, :l3_disclaimer => disclaimer, :lang => localeID }
                #   end
                # rescue
                #   require 'pry'
                #   binding.pry
                # end
                begin
                  unless i['TITLE'].empty? || i['CATEGORY ID'].to_i.to_s.empty?
                    image = i['MEDIA']
                    copy = i['COPY']
                    title = i['TITLE']
                    raw_type = i['TYPE']
                    type = sanitize_clean(raw_type)
                    raw_category = i['DEPARTMENT']
                    hybris_id = i['CATEGORY ID']
                    disclaimer = i['DISCLAIMER']
                    category = sanitize_clean(raw_category)
                    filename = category + '-' + sanitize_clean(title)
                    filepath = "#{localeID}/l3/#{hybris_id}-#{category}.html"
                    proxy filepath, "/localizable/l3/template_l3.html", :locals => { :l3_title => title, :l3_category => category, :l3_type => type, :l3_image => image, :l3_copy => copy, :l3_disclaimer => disclaimer, :lang => localeID }
                  end
                rescue
                  require 'pry'
                  binding.pry
                end
              end
            end
          end
        end

        app.configure :development do
          activate :relative_assets
        end

        app.configure :build do
          ignore "css/core/*"
          ignore "css/vendor/*"
          ignore "js/dev/*"
          # Add custom build statements here
          activate :imageoptim do |options|
            # Use a build manifest to prevent re-compressing images between builds
            options.manifest = true

            # Silence problematic image_optim workers
            options.skip_missing_workers = true

            # Cause image_optim to be in shouty-mode
            options.verbose = false

            # Setting these to true or nil will let options determine them (recommended)
            options.nice = true
            options.threads = true

            # Image extensions to attempt to compress
            options.image_extensions = %w(.jpg .jpeg .gif)

            # Compressor worker options, individual optimisers can be disabled by passing
            # false instead of a hash
            options.gifsicle = { :interlace => false }
            options.jpegoptim = { :strip => ['all'], :max_quality => 90 }
            options.jpegtran = {:copy_chunks => false, :progressive => true, :jpegrescan => true}
            options.pngout   = false
            options.svgo     = false

          end
        end
      end
    end
  end
end
