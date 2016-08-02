require 'spec_helper'
require 'synchromesh/test_components'

describe "Synchromesh", js: true do

  before(:all) do
    require 'pusher'
    require 'pusher-fake'
    Pusher.app_id = "MY_TEST_ID"
    Pusher.key =    "MY_TEST_KEY"
    Pusher.secret = "MY_TEST_SECRET"
    require 'pusher-fake/support/rspec'

    Synchromesh.configuration do |config|
      config.transport = :pusher
      config.channel_prefix = "synchromesh"
      config.opts = {app_id: Pusher.app_id, key: Pusher.key, secret: Pusher.secret}.merge(PusherFake.configuration.web_options)
    end
  end

  it "will synchronize on an attribute update" do
    mount "TestComponent"
    FactoryGirl.create(:test_model, test_attribute: "hello")
    page.should have_content("hello")
    TestModel.first.update_attribute(:test_attribute, 'goodby')
    page.should have_content("goodby")
  end

  describe "the .all method" do
    before(:each) do
      mount "TestComponent"
      5.times { |i| FactoryGirl.create(:test_model, test_attribute: "I am item #{i}") }
      page.should have_content("5 items")
    end

    it "will synchronize on create" do
      TestModel.new(test_attribute: "I'm new here!").save
      page.should have_content("6 items")
    end

    it "will synchronize on destroy" do
      TestModel.first.destroy
      page.should have_content("4 items")
    end
  end

  describe "scopes" do
    before(:each) do
      mount "TestComponent", scope: :active
      5.times { |i| FactoryGirl.create(:test_model, test_attribute: "I am item #{i}", completed: false) }
      page.should have_content("5 items")
    end

    it "will synchronize on create" do
      TestModel.new(test_attribute: "I'm new here!", completed: false).save
      page.should have_content("6 items")
    end

    it "will synchronize on destroy" do
      TestModel.first.destroy
      page.should have_content("4 items")
    end

    it "will syncronize on an update" do
      TestModel.first.update_attribute(:completed, true)
      page.should have_content("4 items")
    end
  end
end
