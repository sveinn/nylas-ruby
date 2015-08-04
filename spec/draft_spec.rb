::ENV['RACK_ENV'] = 'test'
$LOAD_PATH << './lib'
require File.join(File.dirname(__FILE__), 'spec_helper')
require 'draft'

describe Inbox::Draft do
  before (:each) do
    @app_id = 'ABC'
    @app_secret = '123'
    @access_token = 'UXXMOCJW-BKSLPCFI-UQAQFWLO'
    @namespace_id = 'nnnnnnn'
    @inbox = Inbox::API.new(@app_id, @app_secret, @access_token)
  end

  describe "#save!" do
    it "does save all the fields of the draft object and only sends the required JSON" do

      stub_request(:post, "https://#{@access_token}:@api.nylas.com/n/#{@namespace_id}/drafts/").with(
        :body => '{"id":null,"namespace_id":"nnnnnnn","cursor":null,"created_at":null,"subject":"Test draft","snippet":null,"from":null,"to":[{"name":"Helena Handbasket","email":"helena@nylas.com"}],"cc":null,"bcc":null,"date":null,"thread_id":null,"body":null,"unread":null,"starred":null,"folder":null,"labels":null,"version":null,"reply_to_message_id":null}',).to_return(:status => 200,
            :body => File.read('spec/fixtures/draft_save.txt'),
            :headers => {"Content-Type" => "application/json"})

      draft = Inbox::Draft.new(@inbox, @namespace_id)
      draft.subject = 'Test draft'
      draft.to = [{:name => 'Helena Handbasket', :email => 'helena@nylas.com'}]
      expect(draft.id).to be nil

      result = draft.save!
      expect(result.id).to_not be nil

      # Check that calling send! with a saved draft only sends the draft_id and version:
      stub_request(:post, "https://UXXMOCJW-BKSLPCFI-UQAQFWLO:@api.nylas.com/n/384uhp3aj8l7rpmv9s2y2rukn/send").
         with(:body => '{"draft_id":"2h111aefv8pzwzfykrn7hercj","version":0}').to_return(:status => 200,
                   :body => File.read('spec/fixtures/send_endpoint.txt'),
                   :headers => {"Content-Type" => "application/json"})

      result.send!
    end
  end

  describe "#send!" do
    it "sends all the JSON fields when sending directly" do
      stub_request(:post, "https://UXXMOCJW-BKSLPCFI-UQAQFWLO:@api.nylas.com/n/nnnnnnn/send").
         with(:body => '{"id":null,"namespace_id":"nnnnnnn","cursor":null,"created_at":null,"subject":"Test draft","snippet":null,"from":null,"to":[{"name":"Helena Handbasket","email":"helena@nylas.com"}],"cc":null,"bcc":null,"date":null,"thread_id":null,"body":null,"unread":null,"starred":null,"folder":null,"labels":null,"version":null,"reply_to_message_id":null}').to_return(:status => 200,
                 :body => File.read('spec/fixtures/send_endpoint.txt'),
                 :headers => {"Content-Type" => "application/json"})

      draft = Inbox::Draft.new(@inbox, @namespace_id)
      draft.subject = 'Test draft'
      draft.to = [{:name => 'Helena Handbasket', :email => 'helena@nylas.com'}]
      expect(draft.id).to be nil

      result = draft.send!
      expect(result.id).to_not be nil
      expect(result.snippet).to_not be ""
    end
  end

end
