require 'spec_helper'

describe ApplicationHelper do
  
  describe "full_title" do
    it "should include the page title" do
      full_title("foo").should =~ /foo/
    end
    
    it "should include the base title" do
      full_title("foo").should =~ /^Ruby on Rails Tutorial Sample App/
    end
    
    it "should not include a pipe for home page" do
      full_title("").should_not =~ /\|/
    end
    
    it "should include a pipe for non-home pages" do
      full_title("foo").should =~ /\|/
    end
  end
end
