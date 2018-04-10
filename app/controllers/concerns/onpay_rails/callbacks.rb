#encoding: utf-8
module OnpayRails::Callbacks
  extend ActiveSupport::Concern

  included do

    def get_order
      @order
    end

    def success
      get_order.send(OnpayRails.config.paid_method) if OnpayRails.config.paid_method
    end

    def fail
      get_order.send(OnpayRails.config.log_fail_method) if OnpayRails.config.log_fail_method
    end

  end

end
