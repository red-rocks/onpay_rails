if OnpayRails.config.use_routes
  Rails.application.routes.draw do

    get '/onpay'      => 'onpay_rails/base#index'
    get '/onpay/api'  => 'onpay_rails/base#api'

    # get '/onpay/check'  => 'onpay_rails/base#check'
    # get '/onpay/pay'   => 'onpay_rails/base#pay'

  end
end
