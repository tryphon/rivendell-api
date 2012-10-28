require 'spec_helper'

describe Rivendell::API::Xport do

  def xml_response(response_code = 200, error_string = "OK")
    "<RDWebResult><ResponseCode>#{response_code}</ResponseCode><ErrorString>#{error_string}</ErrorString></RDWebResult>"
  end

  def fixture_file(file)
    File.expand_path("../../../fixtures/#{file}", __FILE__)
  end

  def fixture_content(file)
    File.read fixture_file(file)
  end

  describe "initialization" do
    
    it "should use specified attributes" do
      Rivendell::API::Xport.new(:login_name => "dummy").login_name.should == "dummy"
    end

  end

  describe "#login_name" do

    before do
      FakeWeb.register_uri(:post, "http://localhost/rd-bin/rdxport.cgi", :body => fixture_content("rdxport_list_groups.xml"))

      def subject.make_request
        list_groups
      end
    end

    it "should be 'user' by default" do
      subject.login_name.should == 'user'
    end

    it "should be used in queries" do
      subject.login_name = "dummy"
      subject.make_request
      FakeWeb.last_request.form_data["LOGIN_NAME"].should == "dummy"
    end

  end

  describe "#password" do

    before do
      FakeWeb.register_uri(:post, "http://localhost/rd-bin/rdxport.cgi", :body => fixture_content("rdxport_list_groups.xml"))

      def subject.make_request
        list_groups
      end
    end
    
    it "should be '' by default" do
      subject.password.should == ''
    end

    it "should be used in queries" do
      subject.password = "dummy"
      subject.make_request
      FakeWeb.last_request.form_data["PASSWORD"].should == "dummy"
    end

  end

  describe "host" do

    let(:host) { "example.com" }

    subject { Rivendell::API::Xport.new :host => host }

    before do
      FakeWeb.register_uri(:post, "http://#{host}/rd-bin/rdxport.cgi", :body => fixture_content("rdxport_list_groups.xml"))
      def subject.make_request
        list_groups
      end
    end
    
    it "should used host specified in constructor" do
      subject.make_request
    end

  end

  describe ".rdxport_uri" do

    it "should use host" do
      subject.host = "dummy"
      subject.rdxport_uri.should == "http://dummy/rd-bin/rdxport.cgi"
    end
    
  end

  describe "#list_groups" do

    before(:each) do
      FakeWeb.register_uri(:post, "http://localhost/rd-bin/rdxport.cgi", :body => fixture_content("rdxport_list_groups.xml"))
    end

    it "should use COMMAND 4" do
      subject.list_groups
      FakeWeb.last_request["COMMAND"] == "4"
    end

  end

  describe "#import" do

    before(:each) do
      FakeWeb.register_uri(:post, "http://localhost/rd-bin/rdxport.cgi", :body => xml_response)
    end

    it "should use a timeout of 10 minutes" do
      subject.should_receive(:post).with(anything, anything, hash_including(:timeout => 600))
      subject.import 123, 001, fixture_file("empty.wav")
    end

    it "should use COMMAND 2" do
      subject.import 123, 001, fixture_file("empty.wav")
      FakeWeb.last_request["COMMAND"] == "2"
    end

    it "should use 2 as default channels" do
      subject.import 123, 001, fixture_file("empty.wav")
      FakeWeb.last_request["CHANNELS"] == "2"
    end

    it "should use -13 as default normalization level" do
      subject.import 123, 001, fixture_file("empty.wav")
      FakeWeb.last_request["NORMALIZATION_LEVEL"] == "-13"
    end

  end

  describe "#add_cart" do
    
    before(:each) do
      FakeWeb.register_uri(:post, "http://localhost/rd-bin/rdxport.cgi", :body => fixture_content("rdxport_add_cart.xml"))
    end

    it "should use COMMAND 12" do
      subject.add_cart 
      FakeWeb.last_request["COMMAND"] == "12"
    end

    it "should use audio as default type" do
      subject.add_cart
      FakeWeb.last_request["TYPE"] == "audio"
    end

    it "should use group as group_name" do
      subject.add_cart :group => "TEST"
      FakeWeb.last_request["GROUP_NAME"] == "TEST"
    end

    it "should return Cast number" do
      subject.add_cart(:group => "TEST").number.should == 1005
    end

  end

  describe "#add_cut" do
    
    before(:each) do
      FakeWeb.register_uri(:post, "http://localhost/rd-bin/rdxport.cgi", :body => fixture_content("rdxport_add_cut.xml"))
    end

    it "should use COMMAND 10" do
      subject.add_cut(123)
      FakeWeb.last_request["COMMAND"] == "10"
    end

    it "should return Cut info with number" do
      subject.add_cut(123).number.should == 1
    end

  end

  describe "#list_carts" do
    
    before(:each) do
      FakeWeb.register_uri(:post, "http://localhost/rd-bin/rdxport.cgi", :body => fixture_content("rdxport_list_carts.xml"))
    end

    it "should use COMMAND 6" do
      subject.list_carts
      FakeWeb.last_request["COMMAND"] == "6"
    end

    it "should return Casts" do
      subject.list_carts.map(&:title).should include("Rivendell 1", "Rivendell 2", "Rivendell 3")
    end

    it "should use group as group_name" do
      subject.list_carts :group => "TEST"
      FakeWeb.last_request["GROUP_NAME"] == "TEST"
    end

  end

  describe "#list_cuts" do
    
    before(:each) do
      FakeWeb.register_uri(:post, "http://localhost/rd-bin/rdxport.cgi", :body => fixture_content("rdxport_list_cuts.xml"))
    end

    it "should use COMMAND 9" do
      subject.list_cuts(123)
      FakeWeb.last_request["COMMAND"] == "9"
    end

    it "should return Cuts" do
      subject.list_cuts(123).map(&:description).should include("Rivendell 1", "Rivendell 2", "Rivendell 3")
    end

  end

  describe "#clear_cuts" do

    let(:number) { 123 }

    def cut(cut_number)
      Rivendell::API::Cut.new :number => cut_number
    end

    let(:cuts) { [ cut(1), cut(2) ]}
    
    it "should load specified Cart" do
      subject.should_receive(:list_cuts).with(number).and_return(cuts)
      subject.clear_cuts number
    end

    it "should remove Cart's Cuts" do
      subject.stub :list_cuts => cuts
      subject.should_receive(:remove_cut).with(number, 1)
      subject.should_receive(:remove_cut).with(number, 2)
      subject.clear_cuts number
    end

  end

  describe "#remove_cut" do
    
    before(:each) do
      FakeWeb.register_uri(:post, "http://localhost/rd-bin/rdxport.cgi", :body => xml_response)
    end

    let(:cart_number) { 123 }
    let(:cut_number) { 1 }

    it "should use COMMAND 11" do
      subject.remove_cut cart_number, cut_number
      FakeWeb.last_request["COMMAND"] == "11"
    end

    it "should specify cart_number" do
      subject.remove_cut 123, cut_number
      FakeWeb.last_request["CART_NUMBER"] == "123"
    end

    it "should specify cut_number" do
      subject.remove_cut cart_number, 1
      FakeWeb.last_request["CUT_NUMBER"] == 1
    end

  end

  describe "#post" do

    it "should use options in post request" do
      subject.class.should_receive(:post).with(anything, hash_including(:option => "value")).and_return(mock(:success? => true))
      subject.post "dummy", {}, :option => "value"
    end
    
    it "should raise an error when http response is an error" do
      FakeWeb.register_uri(:post, "http://localhost/rd-bin/rdxport.cgi", :status => ["403", "Error"])
      lambda { subject.post("dummy") }.should raise_error(Net::HTTPServerException)
    end


  end

end
