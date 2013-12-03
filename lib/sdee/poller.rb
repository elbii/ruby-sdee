require 'json'
require 'uri'
require 'net/https'
require 'base64'
require 'nokogiri'

module SDEE
  class Poller

    attr_accessor :authenticated, :host, :path, :scheme, :user, :password,
      :base64_credentials, :verify_ssl, :ssl_version

    def initialize(options = {})
      @host = options[:host] || 'localhost'
      @path = options[:path] || '/cgi-bin/sdee-server'
      @scheme = options[:scheme] || 'https://'
      @user = options[:user]
      @password = options[:password]
      @verify_ssl = options[:verify_ssl]
      @ssl_version = options[:ssl_version] || :SSLv3

      @base64_credentials = Base64.encode64("#{@user}:#{@pass}")
    end

    def login
      params = {
        action: 'open',
        events: 'evIdsAlert',
        force: 'yes'
      }

      response = request params
      doc = Nokogiri::XML(response.body)

      @session_id = doc.xpath('//env:Header').first.
        xpath('//sd:oobInfo').first.
        xpath('//sd:sessionId').first.text

      @subscription_id = doc.xpath('//env:Body').first.
        xpath('//sd:subscriptionId').first.text

      response
    end

    def poll(sleep_time=5)
      while true do
        puts get_events
        sleep sleep_time
      end
    end

    def get_events
      login unless @subscription_id

      params = {
        action: 'get',
        confirm: 'yes',
        timeout: 1,
        maxNbrofEvents: 20,
        subscriptionId: @subscription_id,
        sessionId: @session_id
      }

      doc = Nokogiri::XML(request(params).body)
      doc.xpath("//sd:evIdsAlert").collect {|x| Alert.new(x).to_hash }.uniq
    end

    def request(params)
      http = Net::HTTP.new(@host, 443)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE unless @verify_ssl
      http.ssl_version = @ssl_version

      uri = URI(@scheme + @host + @path)
      uri.query = URI.encode_www_form(params)

      req = Net::HTTP::Get.new(uri)
      req['Authorization'] = "BASIC #{@base64_credentials}"

      http.request(req)
    end
  end
end
