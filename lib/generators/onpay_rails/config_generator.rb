require 'rails/generators'

module OnpayRails
  class ConfigGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    desc 'OnpayRails Config generator'
    def install
      template 'onpay_rails.erb', "config/initializers/onpay_rails.rb"
    end

  end
end
