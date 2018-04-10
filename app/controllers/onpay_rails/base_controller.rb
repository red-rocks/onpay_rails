#encoding: utf-8
class OnpayRails::BaseController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:api]
  before_filter :load_order,                     :only => [:api]
  # ssl_required :index

  def order_class
    OnpayRails.config.order_class
  end

  def index
    @order = order_class.find_by_id(params["order_id"])
  end

  # params
  # type	string	Тип запроса (check)
  # pay_for	string	Номер заказа
  # amount	float	Сумма платежа в центах, если параметр mode = free, то будет передан 0
  # way	string	Валюта платежа
  # mode	string	Тип платежа, fix или free
  # user_email	string	Email плтельщика
  # signature	string	Контрольная подпись, SHA1 от строки - «check;pay_for;amount;way;mode;secret_key»
  # additional_params.onpay_ap_xxx	string	Дополнительные параметры, переданные в платежной ссылке(см документацию по платежным ссылкам). Данных параметров в запросе НЕ будет, если они не были переданы в платежной ссылке. Алгоритм их формирования смотрите ниже

  # def check
  #   @order =  order_class.find(params[:pay_for])
  #
  #   if @order.blank?
  #     flash[:error] = I18n.t("invalid_arguments")
  #     redirect_to :back
  #   else
	# 		@pay_type = @gateway.options[:pay_type]
	# 		@price = sprintf("%.2f",@order.total.to_f).to_f
	# 		@currency = @gateway.options[:currency]
	# 		@convert_currency = @gateway.options[:convert_currency] ? 'yes':'no'
	# 		@price_final = @gateway.options[:price_final] ? 'yes':'no'
	# 		@user_email = @order.email
	# 		@md5 = Digest::MD5.hexdigest([@gateway.options[:pay_type],
	# 																sprintf("%.1f",@order.total.to_f).to_f,
	# 																@currency,
	# 																@order.id,
	# 																@convert_currency,
	# 																@gateway.options[:priv_code]].join(';'))
  #
  #     render :action => :show
  #   end
  # end

  def check_params
    params.permit(:pay_for, :amount, :way, :mode, :user_email, :signature, additional_params: [])
  end

  # type	string	Тип запроса (pay)
  # signature	string	Контрольная подпись, SHA1 от строки - «pay;pay_for;payment.amount;payment.way;balance.amount;balance.way;secret_key», где pay - строковая константа «pay», «;» - символ «точка с запятой»
  # pay_for	string	Номер заказа
  # user.email	string	E-mail плательщика
  # user.phone	string	Телефон плательщика
  # user.note	string	Комментарий плательщика
  # payment.id	int	Номер платежа
  # payment.date_time	string	Дата создания платежа в формате «CCYY-MM-DDThh:mm:ssTZD» где TZD смещение часового пояса в формате [+-]hh:mm
  # payment.amount	float	Сумма платежа
  # payment.way	string	Валюта платежа
  # payment.rate	float	Курс обмена между валютами balance.way/payment.way
  # payment.release_at	string	Время зачисления платежа, для отложенных платежей строится аналогично payment.date_time, null если уже зачислен
  # balance.amount	float	Сумма, зачисляемая на баланс
  # balance.way	string	Валюта зачисления на баланс
  # order.from_amount	float	Сумма из ордера, которую должен был заплатить плательщик
  # order.from_way	string	Валюта из ордера, в которой должен был заплатить плательщик
  # order.to_amount	float	Сумма из ордера, которая должна была поступить на баланс магазина
  # order.to_way	string	Валюта из ордера, в которой должен был пополниться баланс магазина
  # additional_params.onpay_ap_xxx

  def pay_params
    params.permit(:pay_for, :signature,
      user: [:email, :phone, :note],
      payment: [:id, :date_time, :amount, :way, :rate, :release_at],
      balance: [:amount, :way],
      order: [:from_amount, :from_way, :to_amount, :to_way],
      additional_params: [])
  end

	def api

    case params["type"].to_sym do
    when :check
      @order.send(OnpayRails.config.check_method, check_params)
      render json: @order.onpay_check_response_json
    when :pay
      if @order.send(OnpayRails.config.paid_method, pay_params)
        render json: @order.onpay_pay_response_json
      else
        render json: @order.onpay_pay_response_json()
      end
    else
      render json: {}
    end



		if params["type"] == "check" then
      check
			if params["md5"] == Digest::MD5.hexdigest([params["type"],
																												params["pay_for"],
																												params["order_amount"],
																												params["order_currency"],
																												@gateway.options[:priv_code]].join(';')).upcase
				if @gateway.options[:test_mode] then
					tst_valid_check(params["pay_for"],params["order_amount"],params["order_currency"]) ? out_code_comment(0,"All,OK") :	out_code_comment(3,"Error on parameters check")
				else
					valid_check(params["pay_for"],params["order_amount"],params["order_currency"]) ? out_code_comment(0,"All,OK") :	out_code_comment(3,"Error on parameters check")
				end
				@out["md5"] = create_check_md5(params["type"],params["pay_for"],params["order_amount"],
																		 params["order_currency"],@out["code"],@gateway.options[:priv_code])
				render :action => "check"
			else
				out_code_comment(7,"MD5 signature wrong")
				@out["md5"] = create_check_md5(params["type"],params["pay_for"],params["order_amount"],
																		 params["order_currency"],@out["code"],@gateway.options[:priv_code])
				render :action => "check"
			end
		end


		if params["type"] == "pay" then
			if params["md5"] == Digest::MD5.hexdigest([params["type"],
																											params["pay_for"],
																											params["onpay_id"],
																											params["order_amount"],
																											params["order_currency"],
																											@gateway.options[:priv_code]].join(';')).upcase
				@out["onpay_id"] = params["onpay_id"]
				if @gateway.options[:test_mode] then
					if tst_valid_check(params["pay_for"],params["order_amount"],params["order_currency"]) then
						create_payment(params["order_amount"].to_f)
						out_code_comment(0,"OK")
					else
						out_code_comment(3,"Error on parameters check")
					end
				else
					if valid_check(params["pay_for"],params["order_amount"],params["order_currency"]) then
						create_payment(params["order_amount"].to_f)
						out_code_comment(0,"OK")
					else
						out_code_comment(3,"Error on parameters check")
					end
				end


				@out["md5"] = create_pay_md5(params["type"],params["pay_for"],params["onpay_id"],params["pay_for"],params["order_amount"],
																		params["order_currency"],@out["code"],@gateway.options[:priv_code])
				render :action => "pay"
			else
				out_code_comment(7,"MD5 signature wrong")
				@out["onpay_id"] = params["onpay_id"]
				@out["md5"] = create_pay_md5(params["type"],params["pay_for"],params["onpay_id"],params["pay_for"],params["order_amount"],
																	 params["order_currency"],@out["code"],@gateway.options[:priv_code])
				render :action => "pay"
			end
		end

	end



  private

	def create_payment(order_amount)
 	     		payment = @order.payments.build(:payment_method => @order.payment_method)
					payment.payment_method = PaymentMethod.find_by_type('Gateway::Onpay')
	      	payment.state = "completed"
	      	payment.amount = order_amount
	      	payment.save
 	     		@order.save!
 	     		@order.next! until @order.state == "complete"
 	     		@order.update!
	end

	def create_check_md5(type,pay_for,order_amount,order_currency,code,priv_code)
		md5 = Digest::MD5.hexdigest([type,pay_for,order_amount,order_currency,code,priv_code].join(';')).upcase
		return md5
	end

	def create_pay_md5(type,pay_for,onpay_id,order_id,order_amount,order_currency,code,priv_code)
		md5 = Digest::MD5.hexdigest([type,pay_for,onpay_id,order_id,order_amount,order_currency,code,priv_code].join(';')).upcase
		return md5
	end

	def valid_check(pay_for,order_amount,order_currency)
		return false if @order.state == "complete"
		return false until order_amount.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true
		return false until pay_for == @order.id.to_s
		return false until order_amount.to_f == sprintf("%.1f",@order.total).to_f
		return false if order_currency != @gateway.options[:currency]
		return true
	end

	def tst_valid_check(pay_for,order_amount,order_currency)
		return false if @order.state == "complete"
		return false until order_amount.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true
		return false until pay_for == @order.id.to_s
		return false until order_amount.to_f == sprintf("%.1f",@order.total).to_f
		return true
	end

	def out_code_comment(code,comment)
		@out["code"] = code
		@out["comment"] = comment
	end

  def load_order
    @order = order_class.find_by_id(params["pay_for"])
  end

end
