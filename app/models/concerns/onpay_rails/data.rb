module OnpayRails::Data
  extend ActiveSupport::Concern

  included do
    include OnpayRails::Fields


    def onpay_pay_for
      id.to_s
    end
    def onpay_status
      @onpay_status ||= onpay_check #!new_record?
    end

    def self.onpay_secret_key
      OnpayRails.config.secret_key
    end
    def onpay_secret_key
      self.class.onpay_secret_key
    end

    include OnpayRails::Check
    include OnpayRails::Pay

    def make_payment_link
      url = "https://secure.onpay.ru/pay/make_payment_link"
      keys = [:pay_amount, :pay_for, :one_way, :ticker, :user_login, :user_email, :price_final, :pay_type, :notify_by_api, :md5]
      pay_amount = self.total
      pay_for = self.onpay_pay_for
      one_way = nil # self.onpay_way
      ticker = self.onpay_way
      user_login = OnpayRails.config.user_login
      price_final = "0"
      pay_type = 2
      notify_by_api = "1"
      api_in_key = OnpayRails.config.api_in_key
      md5 = Digest::MD5.hexdigest [pay_amount, pay_for, ticker, user_login, price_final, pay_type, notify_by_api, api_in_key].join(":").upcase
      _params = {
        pay_amount: pay_amount,
        pay_for: pay_for,
        one_way: one_way,
        ticker: ticker,
        user_login: user_login,
        price_final: price_final,
        pay_type: pay_type,
        notify_by_api: notify_by_api,
        api_in_key: api_in_key,
        md5: md5
      }.select { |k,v|
        !v.blank?
      }
      return "#{url}?#{_params.to_query}"
    end

    def success_url
    end
    def fail_url
    end

    def payment_url
      url = "https://secure.onpay.ru/pay/#{OnpayRails.config.user_login}"
      pay_mode = "fix"
      price = "%.2f" % self.total
      ticker = self.onpay_way
      pay_for = self.onpay_pay_for
      convert = 'yes'
      url_success = self.success_url
      # url_success_enc
      url_fail = self.fail_url
      # url_fail_enc
      user_email = self.email[0...40] rescue nil
      user_phone = self.phone[0...40] rescue nil
      note = ""
      ln = "ru"
      f = "7"
      one_way = nil # self.onpay_way
      price_final = "true"
      md5 = Digest::MD5.hexdigest [pay_mode, price, ticker, pay_for, convert, onpay_secret_key].join(";")

      _params = {
        pay_mode: pay_mode,
        price: price,
        ticker: ticker,
        pay_for: pay_for,
        convert: convert,
        url_success: url_success,
        url_fail: url_fail,
        user_email: user_email,
        user_phone: user_phone,
        note: note,
        ln: ln,
        f: f,
        one_way: one_way,
        price_final: price_final,
        md5: md5
      }.select { |k,v|
        !v.blank?
      }
      return "#{url}?#{_params.to_query}"

    end

    def onpay_log_fail(_params = {})
      Rails.logger.error "OnPay Fail #{Time.new}"
      Rails.logger.error _params.inspect
      Rails.logger.error self.inspect
      return false
    end

    def log_fail(_params = {})
      return onpay_log_fail
    end

  end

end
