require 'spec_helper'

describe Rivendell::API::Cart do

  describe "has_title?" do

    it "should return false if title is nil" do
      subject.title = nil
      subject.should_not have_title
    end

    it "should return false if title is empty" do
      subject.title = ""
      subject.should_not have_title
    end

    it "should return false if title is '[new cart]'" do
      subject.title = "[new cart]"
      subject.should_not have_title
    end

    it "should return true if title is something else" do
      subject.title = "dummy"
      subject.should have_title
    end

  end

end
