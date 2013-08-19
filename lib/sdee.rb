require 'base64'
require 'net/https'
require 'uri'
require 'nokogiri'
require 'json'

class Alert
  attr_accessor :event_id, :severity, :originator, :alert_time, :risk_rating,
    :protocol, :sig_id, :subsig_id, :sig_version, :sig_detail, :attacker,
    :targets, :attacker_locality, :target_locality, :attacker_port,
    :target_port, :threat_rating

  def initialize(xml_doc)
    @doc = xml_doc

    build_alert
    build_sig
    build_participants 
  end

  def to_hash
    vars = {}

    instance_variables.reject {|var| var == :@doc }.each do |var|
      vars["ids.#{var.to_s[1..-1]}"] = instance_variable_get(var)
    end

    vars
  end

  def to_json
    to_hash.to_json
  end

  private

  def build_alert
    @event_id = @doc.xpath('//sd:evIdsAlert').first.attribute('eventId').value
    @severity = @doc.xpath('//sd:evIdsAlert').first.attribute('severity').value
    @originator = @doc.xpath('//sd:originator').first.
      xpath('sd:hostId').first.text
    @alert_time = @doc.xpath('//sd:time').first.text
    @risk_rating = @doc.xpath('//cid:riskRatingValue').first.text
    @threat_rating = @doc.xpath('//cid:threatRatingValue').first.text
    @protocol = @doc.xpath('//cid:protocol').first.text
  end

  def build_sig
    sig = @doc.xpath('//sd:signature').first

    @sig_id = sig.attribute('id').value
    @sig_version = sig.attribute('version').value
    @subsig_id = sig.xpath('//cid:subsigId').first.text

    begin
      @sig_detail = sig.xpath('//cid:sigDetails').first.text
    rescue
      @sig_detail = sig.attribute('description').value
    end
  end

  def build_participants
    @targets = []

    attacker = @doc.xpath('//sd:attacker').first
    attacker_addr = attacker.xpath('//sd:addr').first
    @attacker_locality = attacker_addr.attribute('locality').value
    @attacker = attacker_addr.text

    begin
      @attacker_port = attacker.xpath('//sd:port').first.text
    rescue
      @attacker_port = '0'
    end

    target_list = @doc.xpath('//sd:target')

    target_list.each do |target|
      data = {}

      target_addr = target.xpath('//sd:addr').first

      data['ids.target'] = target_addr.text
      data['ids.target_locality'] = target_addr.attribute('locality').value

      begin
        data['ids.target_port'] = target.xpath('//sd:port').first.text
      rescue
        data['ids.target_port'] = '0'
      end

      @targets << data
    end
  end
end

class SDEE
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
    hash_alerts = xml_alerts.collect {|x| Alert.new(x).to_hash }.uniq

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

    response = http.request(req)
  end
end
