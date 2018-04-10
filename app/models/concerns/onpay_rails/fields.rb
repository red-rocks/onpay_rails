module OnpayRails::Fields
  extend ActiveSupport::Concern

  included do

    if defined?(Mongoid)
      field :onpay_user_email
      field :onpay_amount, type: Float
      field :onpay_way, default: "RUR"
      field :onpay_mode, default: "fix"

      field :onpay_balance_amount, type: Float
      field :onpay_balance_way

      if defined?(RailsAdmin) and respond_to?(:rails_admin)
        rails_admin do

          group :onpay do
            field :onpay_user_email, :string do
              read_only true
            end
            field :onpay_amount do
              read_only true
            end
            field :onpay_way, :string do
              read_only true
            end
            field :onpay_mode, :string do
              read_only true
            end
            field :onpay_balance_amount do
              read_only true
            end
            field :onpay_balance_way, :string do
              read_only true
            end
          end # group :onpay do

        end # rails_admin do
      end # if defined?(RailsAdmin) and respond_to?(:rails_admin)
    end # if defined?(Mongoid)

  end # included do

end # module OnpayRails::Fields
