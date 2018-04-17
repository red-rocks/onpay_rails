module OnpayRails::Pay
  extend ActiveSupport::Concern

  included do
    # pay;status;pay_for;secret_key
    def onpay_pay_response_signature
      Digest::SHA1.hexdigest ["pay", onpay_status, onpay_pay_for, onpay_secret_key].join(";")
    end
    def onpay_pay_response_json
      {
        status: onpay_status,
        pay_for: onpay_pay_for,
        signature: onpay_pay_response_signature
      }
    end


    def onpay_set_paid(_params = {})
      if self.check_paid(_params)
        begin # WTF
          self.onpay_pay_params = _params.to_h
        rescue Exception => ex
          logger.info ex.message
          logger.info ex.backtrace
        end
        return true
      end
      return false
    end

    def onpay_set_paid!(_params = {})
      if self.onpay_set_paid(_params)
        if self.save
          return true
        end
      end
      return false
    end

    def set_paid!(_params = {})
      return self.onpay_set_paid!(pay_params)
    end


  end

  class_methods do
    # pay;pay_for;payment.amount;payment.way;balance.amount;balance.way;secret_key
    def onpay_pay_request_signature(_params = {})
      Digest::SHA1.hexdigest(
        [
          "pay",
          _params[:pay_for],
          (_params[:payment] && _params[:balance][:amount]),
          (_params[:payment] && _params[:balance][:way]),
          (_params[:balance] && _params[:balance][:amount]),
          (_params[:balance] && _params[:balance][:way]),
          onpay_secret_key
        ].join(";")
      )
    end
  end

end
