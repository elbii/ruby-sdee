require 'json'

module SDEE
  class Alert
    attr_accessor :event_id, :severity, :originator, :alert_time, :risk_rating,
      :protocol, :sig_id, :subsig_id, :sig_version, :sig_detail, :attacker,
      :targets, :attacker_locality, :target_locality, :attacker_port,
      :target_port, :threat_rating

    def initialize(xml_doc)
      @alert_xml = xml_doc

      build_alert
      build_sig
      build_participants 
    end

    def to_hash
      vars = {}

      instance_variables.reject {|var| var == :@alert_xml }.each do |var|
        vars[var.to_s[1..-1]] = instance_variable_get(var)
      end

      vars
    end

    def to_json
      to_hash.to_json
    end

    private

    def build_alert
      @event_id = @alert_xml.attribute('eventId').value
      @severity = @alert_xml.attribute('severity').value
      @originator = @alert_xml.xpath('.//sd:originator').first.
        xpath('sd:hostId').first.text
      @alert_time = @alert_xml.xpath('.//sd:time').first.text
      @risk_rating = @alert_xml.xpath('.//cid:riskRatingValue').first.text
      @threat_rating = @alert_xml.xpath('.//cid:threatRatingValue').first.text
      @protocol = @alert_xml.xpath('.//cid:protocol').first.text
    end

    def build_sig
      sig = @alert_xml.xpath('.//sd:signature').first

      @sig_id = sig.attribute('id').value
      @sig_version = sig.attribute('version').value
      @subsig_id = sig.xpath('.//cid:subsigId').first.text

      begin
        @sig_detail = sig.xpath('.//cid:sigDetails').first.text
      rescue
        @sig_detail = sig.attribute('description').value
      end
    end

    def build_participants
      @targets = []

      attacker = @alert_xml.xpath('.//sd:attacker').first
      attacker_addr = attacker.xpath('.//sd:addr').first
      @attacker_locality = attacker_addr.attribute('locality').value
      @attacker = attacker_addr.text

      begin
        @attacker_port = attacker.xpath('.//sd:port').first.text
      rescue
        @attacker_port = '0'
      end

      target_list = @alert_xml.xpath('.//sd:target')

      target_list.each do |target|
        data = {}

        target_addr = target.xpath('.//sd:addr').first

        data['target'] = target_addr.text
        data['target_locality'] = target_addr.attribute('locality').value

        begin
          data['target_port'] = target.xpath('.//sd:port').first.text
        rescue
          data['target_port'] = '0'
        end

        @targets << data
      end
    end
  end
end
