module OnpayRails

  def self.configuration
    @configuration ||= Configuration.new
  end
  def self.config
    @configuration ||= Configuration.new
  end

  def self.configure
    yield configuration
  end

  class Configuration
    attr_accessor :user_login
    attr_accessor :secret_key
    attr_accessor :api_in_key

    attr_accessor :order_class
    attr_accessor :use_routes

    attr_accessor :check_method
    attr_accessor :paid_method
    attr_accessor :log_fail_method

    def initialize
      @user_login = ENV['ONPAY_API_IN_KEY']
      @secret_key = ENV['ONPAY_SECRET_KEY']
      @api_in_key = ENV['ONPAY_API_IN_KEY']

      @order_class = ::Order if defined?(::Order)
      @use_routes = true

      @check_method = :check
      @paid_method = :set_paid!
      @log_fail_method = :log_fail

    end

  end
end
