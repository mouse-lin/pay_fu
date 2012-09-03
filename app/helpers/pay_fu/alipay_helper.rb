require 'digest/md5'

module PayFu
  module AlipayHelper
    def redirect_to_alipay_gateway(options={})
      encoded_query_string = sign_params!(query_params(options)).to_query
      redirect_to "https://www.alipay.com/cooperate/gateway.do?" + encoded_query_string
    end

    private
    def query_params(options)
      query_params = {
        :partner => ActiveMerchant::Billing::Integrations::Alipay::ACCOUNT,
        :out_trade_no => options[:out_trade_no],
        :total_fee => options[:amount],
        :seller_email => ActiveMerchant::Billing::Integrations::Alipay::EMAIL,
        :notify_url => options[:notify_url],
        :return_url => options[:return_url],
        :"_input_charset" => 'utf-8',
        :service => ActiveMerchant::Billing::Integrations::Alipay::Helper::CREATE_DIRECT_PAY_BY_USER,
        :payment_type => "1",
        :subject => options[:subject],
        :body => options[:body]
      }
      query_params = query_params.reject{ |k, v| v.blank? }
      Hash[query_params.sort]
    end

    # alipay's sign_type must after sign
    def sign_params!(params)
      sign = Digest::MD5.hexdigest(CGI.unescape(params.to_query) + ActiveMerchant::Billing::Integrations::Alipay::KEY)
      params[:sign] = sign
      params[:sign_type] = 'MD5'
      params
    end
  end
end
