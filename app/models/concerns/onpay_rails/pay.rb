module OnpayRails::Pay
  extend ActiveSupport::Concern

  included do

    # pay;pay_for;payment.amount;payment.way;balance.amount;balance.way;secret_key
    def onpay_pay_request_signature
      Digest::SHA1.hexdigest ["pay", onpay_pay_for, onpay_amount, onpay_way, onpay_balance_amount, onpay_balance_way, onpay_secret_key].join(";")
    end
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

    def onpay_set_paid!(_params = {})
      return false
    end

    def set_paid!(_params = {})
      return onpay_set_paid!
    end


  end

end
