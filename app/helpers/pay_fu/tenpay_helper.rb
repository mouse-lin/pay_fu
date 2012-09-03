require 'digest/md5'

module PayFu
  module TenpayHelper

    def redirect_to_tenpay_gateway options={}
      encoded_query_string = tenpay_sign_params!(tenpay_query_params(options)).to_query
      redirect_to "https://gw.tenpay.com/gateway/pay.htm?" + encoded_query_string
    end

    private
    # tenpay's hash must contains three options
    # return_url: an url of page that will be redirect to after payment
    # notify_url: an url that Tencent will notify server
    # spbill_create_ip: 
    def tenpay_query_params(options)
      query_params = {
        :partner => ActiveMerchant::Billing::Integrations::Tenpay::SPID,
        :out_trade_no => options[:out_trade_no],
        :total_fee => options[:amount].to_s,
        :return_url => options[:return_url],
        :notify_url => options[:notify_url],
        :fee_type => "1",
        :body => options[:return_url],
        :subject => options[:subject],
        :bank_type => "DEFAULT",
        :service_version => "1.0",
        :input_charset => "UTF-8",
        :sign_key_index => "1",
        :sign_type => options[:sign_type] ||= "MD5",
        :spbill_create_ip => options[:purchaser_ip]
      }
      query_params = query_params.reject{ |k, v| v.blank? }
    end

    def tenpay_sign_params!(params)
      sign = Digest::MD5.hexdigest(CGI.unescape(params.to_query) + "&key=#{ActiveMerchant::Billing::Integrations::Tenpay::KEY}")
      params[:sign] = sign
      params
    end
 
  end
end
