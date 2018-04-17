module OnpayRails::Check
  extend ActiveSupport::Concern

  included do

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

    def onpay_check_paid(_params = {})
      return @onpay_status unless @onpay_status.nil?
      ret = true
      # self.update_onpay_check_attributes(_params)
      # ret &&= ((_params[:user] and _params[:user][:email]) == onpay_user_email) # temp
      ret &&= _params[:pay_for] == onpay_pay_for
      ret &&= (_params[:amount] || (_params[:payment] && _params[:payment][:amount])) == onpay_amount
      ret &&= (_params[:way] || (_params[:payment] && _params[:payment][:way])) == onpay_way
      ret &&= ['check', 'pay'].include?(_params[:type])
      ret &&= _params[:signature] == self.class.send("onpay_#{_params[:type]}_request_signature", _params)
      return @onpay_status = ret
    end

    def check_paid(_params = {})
      return self.onpay_check_paid(_params)
    end

  end

  class_methods do
    # check;pay_for;amount;way;mode;secret_key
    def onpay_check_request_signature(_params = {})
      Digest::SHA1.hexdigest(
        [
          "check",
          _params[:pay_for],
          _params[:amount],
          _params[:way],
          _params[:mode],
          onpay_secret_key
        ].join(";")
      )
    end
  end

end
