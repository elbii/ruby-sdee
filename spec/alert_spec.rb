require 'sdee'

describe SDEE::Alert do
  before :all do
    @doc = Nokogiri::XML(File.open('./spec/data/sample.xml'))
  end    

  context 'first alert' do
    before :all do
      alert_xml = @doc.xpath('//sd:evIdsAlert').first
      @alert = SDEE::Alert.new(alert_xml)
    end

    it 'should parse event_id' do
      @alert.event_id.should eq '6823242457034'
    end

    it 'should parse severity' do
      @alert.severity.should eq 'informational'
    end

    it 'should parse originator' do
      @alert.originator.should eq 'sample_host'
    end

    it 'should parse alert_time' do
      @alert.alert_time.should eq '1385965224300024000'
    end

    it 'should parse risk_rating' do
      @alert.risk_rating.should eq '15'
    end

    it 'should parse protocol' do
      @alert.protocol.should eq 'IP protocol 0'
    end

    it 'should parse sig_id' do
      @alert.sig_id.should eq '1208'
    end

    it 'should parse subsig_id' do
      @alert.subsig_id.should eq '0'
    end

    it 'should parse sig_version' do
      @alert.sig_version.should eq 'S212'
    end

    it 'should parse sig_detail' do
      @alert.sig_detail.should eq 'Fragmented IP Datagram with fragments missing'
    end

    it 'should parse attacker' do
      @alert.attacker.should eq '0.0.0.0'
    end

    it 'should parse targets' do
      @alert.targets.first['target'].should include '0.0.0.0'
    end

    it 'should parse attacker_locality' do
      @alert.attacker_locality.should eq 'OUT'
    end

    it 'should parse target_locality' do
      @alert.targets.first['target_locality'].should eq 'OUT'
    end

    it 'should parse attacker_port' do
      @alert.attacker_port.should eq '0'
    end

    it 'should parse target_port' do
      @alert.targets.first['target_port'].should eq '0'
    end

    it 'should parse threat_rating' do
      @alert.threat_rating.should eq '15'
    end
  end

  context 'second alert' do
    before :all do
      alert_xml = @doc.xpath('//sd:evIdsAlert').last
      @alert = SDEE::Alert.new(alert_xml)
    end

    it 'should parse event_id' do
      @alert.event_id.should eq '6823242457036'
    end

    it 'should parse severity' do
      @alert.severity.should eq 'high'
    end

    it 'should parse originator' do
      @alert.originator.should eq 'sample_host'
    end

    it 'should parse alert_time' do
      @alert.alert_time.should eq '1385965230914381000'
    end

    it 'should parse risk_rating' do
      @alert.risk_rating.should eq '100'
    end

    it 'should parse protocol' do
      @alert.protocol.should eq 'tcp'
    end

    it 'should parse sig_id' do
      @alert.sig_id.should eq '3250'
    end

    it 'should parse subsig_id' do
      @alert.subsig_id.should eq '0'
    end

    it 'should parse sig_version' do
      @alert.sig_version.should eq 'S739'
    end

    it 'should parse sig_detail' do
      @alert.sig_detail.should eq 'TCP Hijack'
    end

    it 'should parse attacker' do
      @alert.attacker.should eq '10.0.0.2'
    end

    it 'should parse targets' do
      @alert.targets.first['target'].should eq '10.1.0.8'
    end

    it 'should parse attacker_locality' do
      @alert.attacker_locality.should eq 'OUT'
    end

    it 'should parse target_locality' do
      @alert.targets.first['target_locality'].should eq 'OUT'
    end

    it 'should parse attacker_port' do
      @alert.attacker_port.should eq '59433'
    end

    it 'should parse target_port' do
      @alert.targets.first['target_port'].should eq '443'
    end

    it 'should parse threat_rating' do
      @alert.threat_rating.should eq '100'
    end
  end
end
