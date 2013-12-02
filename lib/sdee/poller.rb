require 'json'
require 'uri'
require 'net/https'
require 'base64'
require 'nokogiri'

module SDEE
  class Poller
    def initialize(options = {})
      @host = options[:host]
      @path = '/cgi-bin/sdee-server'
      @proto = 'https://'

      @creds = Base64.encode64("#{options[:user]}:#{options[:pass]}")
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

    def poll_events(sleep_time=5)
      while true do
        get_events
        sleep sleep_time
      end
    end

    def get_events
      puts "Please login first" unless @subscription_id

      params = {
        action: 'get',
        confirm: 'yes',
        timeout: 1,
        maxNbrofEvents: 20,
        subscriptionId: @subscription_id,
        sessionId: @session_id
      }

      res = request params
      doc = Nokogiri::XML(res.body)

      xml_alerts = doc.xpath("//sd:evIdsAlert")
      hash_alerts = xml_alerts.collect {|x| Alert.new(x.to_s).to_hash }.uniq

      hash_alerts.each {|h| puts h.to_json }

      hash_alerts
    end

    def request(params)
      http = Net::HTTP.new(@host, 443)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      http.ssl_version = :SSLv3

      uri = URI(@proto + @host + @path)
      uri.query = URI.encode_www_form(params)

      req = Net::HTTP::Get.new(uri)
      req['Authorization'] = "BASIC #{@creds}"

      http.request(req)
    end
  end
end
