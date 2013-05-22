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
        fill_in "Confirmation", with: "123456"
      end
      
      it "should create a user" do
        expect { click_button submit }.to change(User, :count).by(1)
      end
      
      describe "after saving the user" do
        let(:user) { User.find_by_email(user_email) }
        before { click_button submit }
        
        it { should have_selector('title', text: user.name) }
        it { should have_success_message('Welcome') }
        it { should have_link('Sign out') }
      end
    end
  end
  
  describe "edit" do
    let(:user) { FactoryGirl.create(:user) }
    let(:save_button) { "Save changes" }
    
    before do
      valid_signin user
      visit edit_user_path(user)
    end
    
    describe "page" do
      it { should have_selector('title', text: 'Edit user') }
      it { should have_selector('h1',    text: 'Update your profile') }
      it { should have_link('change', href: 'http://gravatar.com/emails') }
    end
    
    describe "with invalid information" do
      before { click_button save_button }
      
      it { should have_content('error') }
    end
    
    describe "with valid information" do
      let(:new_name)  { "New Name" }
      let(:new_email) { "new@email.com" }
      
      before do
        fill_in "Name",                  with: new_name
        fill_in "Email",                 with: new_email
        fill_in "Password",              with: user.password
        fill_in "Confirm Password", with: user.password
        click_button save_button
      end
      
      it { should have_selector('title', text: new_name) }
      it { should have_success_message }
      it { should have_link('Sign out', href: signout_path) }
      specify { user.reload.name.should  == new_name }
      specify { user.reload.email.should == new_email }
    end
  end
end
