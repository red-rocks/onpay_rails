#encoding: utf-8
class OnpayRails::BaseController < ApplicationController
  skip_before_action :verify_authenticity_token, :only => [:api]
  before_action :load_order,                     :only => [:api]
  # ssl_required :index

  def order_class
    OnpayRails.config.order_class
  end

  def index
    @order = order_class.find(params["order_id"])
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
    begin
      case params["type"].to_sym
      when :check
        @order.send(OnpayRails.config.check_method, check_params)
        render json: @order.onpay_check_response_json

      when :pay
        if @order.send(OnpayRails.config.paid_method, pay_params)
          render json: @order.onpay_pay_response_json
        else
          render json: @order.onpay_pay_response_json
        end
        
      else
        render json: {}
      end

    rescue
      render json: {}
    end
  end

  def load_order
    @order = order_class.find(params["pay_for"])
  end

end
