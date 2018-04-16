module OnpayRails::All

  extend ActiveSupport::Concern

  included do

    include OnpayRails::Data

    include OnpayRails::Check
    include OnpayRails::Pay
  end

end
