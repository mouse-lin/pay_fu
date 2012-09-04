module PayFu
  class Engine < ::Rails::Engine
    isolate_namespace PayFu

    initializer "pay_fu_engine.load_configs" do |app|
      config_file = Rails.root.join("config/pay_fu.yml")
      if config_file.file?
        require 'active_merchant'
        require 'activemerchant_patch_for_china'

        PayFu::CONFIGS = YAML.load_file(config_file)[Rails.env]

        # config for paypal
        paypal_config = PayFu::CONFIGS["paypal"]
        unless paypal_config.hash_values?("")
          ActiveMerchant::Billing::Base.mode = paypal_config["mode"].to_sym
          ActiveMerchant::Billing::PaypalGateway.new(
            :login => paypal_config["login"],
            :password => paypal_config["password"],
            :signature => paypal_config["signature"]
          )
        end

        # config for alipay
        alipay_config = PayFu::CONFIGS["alipay"]
        unless alipay_config.has_values?("")
          ActiveMerchant::Billing::Integrations::Alipay::KEY = alipay_config["key"]
          ActiveMerchant::Billing::Integrations::Alipay::ACCOUNT = alipay_config["account"]
          ActiveMerchant::Billing::Integrations::Alipay::EMAIL = alipay_config["email"]
        end

        # config for tenpay
        tenpay_config = PayFu::CONFIGS["tenpay"]
        unless tenpay_config.hash_values("")
          ActiveMerchant::Billing::Integrations::Alipay::SPID = PayFu::CONFIGS["tenpay"]["spid"]
          ActiveMerchant::Billing::Integrations::Alipay::KEY = PayFu::CONFIGS["tenpay"]["key"]
        end

      end
    end
  end
end
