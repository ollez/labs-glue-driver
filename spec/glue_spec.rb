require 'spec_helper'

describe Glue do
  let(:glue) { Glue.new url: 'http://localhost:5000/' }

  describe 'publish a flow' do
    use_vcr_cassette 'glue_publish_flow'

    before do
      @reference = glue.flow(
        rule_reference: 'firstroute',
        smooks_config_url: 'http://10.46.10.141/flows/4fd0a6fcce230a9f80000007/smooks_config.xml').publish
    end

    it 'should get a reference' do
      @reference.should eql('firstroute6')
    end
  end

  describe 'flow with a reference' do
    let(:flow) { glue.flow(reference: 'firstroute6') }

    describe 'start' do
      use_vcr_cassette 'glue_start_flow'

      it 'should be running' do
        flow.start.should eql('running')
      end
    end

    describe 'waiting for start' do
      use_vcr_cassette 'glue_wait_start_flow'
      before(:each) do
        flow.stub(:sleep)
      end

      it 'should wait for the running state' do
        flow.start.should eql('running')
        a_request(:get, "http://localhost:5000/workflows/firstroute6").should  have_been_made.times(2)
      end
    end

    describe 'get flow state' do
      use_vcr_cassette 'glue_flow_state'

      it 'should be running' do
        flow.state.should eql('running')
      end
    end

    describe 'send data to a flow' do
      use_vcr_cassette 'glue_data_to_flow'

      it 'should be successfull' do
        flow.send_data('{"id": 5}').should be_true
      end
    end

    describe 'stop a flow' do
      use_vcr_cassette 'glue_stop_flow'

      it 'should be stopped' do
        flow.stop.should eql('stopped')
      end
    end

    describe 'get results from a flow' do
      use_vcr_cassette 'glue_get_results'

      it 'should get the 3 latest results' do
        flow.get_results(limit: 3).should have(3).results
      end
    end

    describe 'get results breakdown from a flow' do
      use_vcr_cassette 'glue_get_results_breakdown'

      it 'should include 3 steps' do
        flow.get_results_breakdown.should have(3).keys
      end
    end

    describe 'get incoming breakdown from a flow' do
      use_vcr_cassette 'glue_get_incoming_breakdown'

      it 'should include 3 steps' do
        flow.get_incoming_breakdown.should have(3).keys
      end
    end

  end
end

