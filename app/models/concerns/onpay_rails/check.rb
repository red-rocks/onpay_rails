module OnpayRails::Check
  extend ActiveSupport::Concern

  included do

    # check;pay_for;amount;way;mode;secret_key
    def onpay_check_request_signature
      Digest::SHA1.hexdigest ["check", onpay_pay_for, onpay_amount, onpay_way, onpay_mode, onpay_secret_key].join(";")
    end
    # check;status;pay_for;secret_key
    def onpay_check_response_signature
      Digest::SHA1.hexdigest ["check", onpay_status, onpay_pay_for, onpay_secret_key].join(";")
    end
    def onpay_check_response_json
      {
        status: onpay_status,
        pay_for: onpay_pay_for,
        signature: onpay_check_response_signature
      }
    end

    def update_onpay_check_attributes(_params = {})
      keys = [:user_email, :amount, :amount, :way]
      keys.each do |k|
        self.send("onpay_#{k}=", _params[k]) if self.send("onpay_#{k}").nil?
      end
      self
    end

    def onpay_check(_params = {})
      ret = true
      # self.update_onpay_check_attributes(_params)
      ret &&= _params[:user_email] == onpay_user_email
      ret &&= _params[:pay_for] == onpay_pay_for
      ret &&= _params[:amount] == onpay_amount
      ret &&= _params[:way] == onpay_way
      return ret
    end

    def check(_params = {})
      return onpay_check(_params)
    end

  end

end
