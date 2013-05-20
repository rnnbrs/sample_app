require 'spec_helper'

describe "User pages" do
  subject{ page }
  
  describe "profile page" do
    let(:user) { FactoryGirl.create(:user) }
    before { visit user_path(user) }
    
    it { should have_selector('h1',    text: user.name) }
    it { should have_selector('title', text: user.name) }
  end
  
  describe "signup page" do
    before { visit signup_path }
    
    it { should have_selector('h1', text: 'Sign up') }
    it { should have_selector('title', text: full_title('Sign up')) }
  end
  
  describe "signup" do
    let(:submit) { "Create my account" }
    before { visit signup_path }
    
    describe "with invalid information" do
      it "should not create a user" do
        expect { click_button submit }.not_to change(User, :count)
      end
      
      describe "after submission" do
        before { click_button submit }
        
        it { should have_selector('title', text: "Sign up")}
        it { should have_content('error') }
      end
    end
    
    describe "with valid information" do
      let(:user_email) { "user@example.com" }
      
      before do
        fill_in "Name", with: "Example user"
        fill_in "Email", with: user_email
        fill_in "Password", with: "123456"
        fill_in "Password confirmation", with: "123456"
      end
      
      it "should create a user" do
        expect { click_button submit }.to change(User, :count).by(1)
      end
      
      describe "after saving the user" do
        let(:user) { User.find_by_email(user_email) }
        before { click_button submit }
        
        it { should have_selector('title', text: user.name) }
        it { should have_selector('div.alert.alert-success', text: 'Welcome') }
        it { should have_link('Sign out') }
      end
    end
  end
end
