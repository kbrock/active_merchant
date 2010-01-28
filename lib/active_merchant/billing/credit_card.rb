require 'time'
require 'date'
require 'active_merchant/billing/expiry_date'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    # == Description
    # This credit card object can be used as a stand alone object. It acts just like an ActiveRecord object
    # but doesn't support the .save method as its not backed by a database.
    # 
    # For testing purposes, use the 'bogus' credit card type. This card skips the vast majority of 
    # validations. This allows you to focus on your core concerns until you're ready to be more concerned 
    # with the details of particular creditcards or your gateway.
    # 
    # == Testing With CreditCard
    # Often when testing we don't care about the particulars of a given card type. When using the 'test' 
    # mode in your Gateway, there are six different valid card numbers: 1, 2, 3, 'success', 'fail', 
    # and 'error'.
    # 
    #--
    # For details, see CreditCardMethods#valid_number?
    #++
    # 
    # == Example Usage
    #   cc = CreditCard.new(
    #     :first_name => 'Steve', 
    #     :last_name  => 'Smith', 
    #     :month      => '9', 
    #     :year       => '2010', 
    #     :type       => 'visa', 
    #     :number     => '4242424242424242'
    #   )
    #   
    #   cc.valid? # => true
    #   cc.display_number # => XXXX-XXXX-XXXX-4242
    #
    class CreditCard
      include CreditCardMethods
      include CreditCardValidations
      include Validateable
      
      ## Attributes
      
      # Essential attributes for a valid, non-bogus creditcards
      attr_accessor :number, :month, :year, :type, :first_name, :last_name
      
      # Required for Switch / Solo cards
      attr_accessor :start_month, :start_year, :issue_number

      # Optional verification_value (CVV, CVV2 etc). Gateways will try their best to 
      # run validation on the passed in value if it is supplied
      attr_accessor :verification_value

      #object#type already exists, so use card_type instead
      def card_type
        @type
      end

      def card_type=(value)
        @type=value
      end

      # Provides proxy access to an expiry date object
      def expiry_date
        ExpiryDate.new(@month, @year)
      end

      def expired?
        expiry_date.expired?
      end
      
      def name
        "#{@first_name} #{@last_name}"
      end
            
      # Show the card number, with all but last 4 numbers replace with "X". (XXXX-XXXX-XXXX-4338)
      def display_number
        self.class.mask(number)
      end
      
      def last_digits
        self.class.last_digits(number)
      end
      
      def validate
        validate_credit_card_data
      end
      
      private
      
      def before_validate #:nodoc: 
        sanitize_credit_card_data
      end
    end
  end
end
