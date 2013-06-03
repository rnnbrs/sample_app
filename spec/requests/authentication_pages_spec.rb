require 'spec_helper'

describe "Authentication" do
  
  subject { page }
  
  describe "signin page" do
    before { visit signin_path }
    
    describe "with invalid information" do
      before { invalid_signin }
    
      it { should have_selector('title', text: 'Sign in') }
      it { should have_error_message('Invalid') }
      it { should_not have_link('Profile') }
      it { should_not have_link('Settings') }
      it { should_not have_link('Users') }
      it { should_not have_link('Sign out') }
      
      describe "after visiting another page" do
        before { click_link "Home" }
        
        it { should_not have_error_message() }
      end
    end
    
    describe "with valid information" do
      let(:user) { FactoryGirl.create(:user) }
      before { valid_signin user }
      
      it { should have_selector('title', text: user.name) }
      it { should have_link('Profile', href: user_path(user)) }
      it { should have_link('Settings', href: edit_user_path(user)) }
      it { should have_link('Users', href: users_path) }
      it { should have_link('Sign out', href: signout_path) }
      it { should_not have_link('Sign in', href: signin_path) }
      
      describe "followed by signout" do
        before { click_link "Sign out" }
        
        it { should have_link('Sign in') }
      end
    end
  end
  
  describe "authorization" do
    
    describe "for non-signed-in users" do
      let(:user) { FactoryGirl.create(:user) }
      
      describe "when attempting to visit a protected page" do
        before do 
          visit edit_user_path(user)
          valid_signin user
        end
        
        describe "after signing in" do
          it "should render the desired protected page" do
            page.should have_selector('title', text: 'Edit user')
          end
          
          describe "when signing in again" do
            before do
              #Destroy session
              delete signout_path
              visit signin_path
              valid_signin user
            end
            
            it "should render profile page" do
              page.should have_selector('title', text: user.name)
            end
          end
        end
      end
      
      describe "in the users controller" do
        
        describe "visiting the user index" do
          before { visit users_path }
          it { should have_selector('title', text: "Sign in") }
        end
        
        describe "visiting the edit page" do
          before { visit edit_user_path(user) }
          it { should have_selector('title', text: "Sign in") }
        end
        
        describe "submitting to the update action" do
          before { put user_path(user) }
          specify { response.should redirect_to(signin_path) }
        end
      end
      
      describe "in the mocroposts controller" do
        
        describe "submitting to the create action" do
          before { post microposts_path }
          specify { expect(response).to redirect_to(signin_path) }
        end
        
        describe "submitting to the destroy action" do
          before { delete micropost_path(FactoryGirl.create(:micropost)) }
          specify { expect(response).to redirect_to(signin_path) }
        end
      end
    end
    
    describe "as wrong user" do
      let(:user) { FactoryGirl.create(:user) }
      let(:wrong_user) { FactoryGirl.create(:user, email: "wrong@user.com") }
      
      before { valid_signin user }
      
      describe "visiting Users#edit page" do
        before { visit edit_user_path(wrong_user) }
        
        it { should_not have_selector('title', text: full_title('Edit user')) }
      end
      
      describe "submitting a PUT request to the Users#update action" do
        before { put user_path(wrong_user) }
        
        specify { response.should redirect_to(root_path) }
      end
    end
    
    describe "as non-admin user" do
      let(:user) { FactoryGirl.create(:user) }
      let(:non_admin) { FactoryGirl.create(:user) }
      before { valid_signin non_admin }

      describe "submitting a DELETE request to the Users#destroy action" do
        before { delete user_path(user) }
        specify { response.should redirect_to(root_path) }
      end
    end
    
    describe "as admin user" do
      let(:admin) { FactoryGirl.create(:admin) }
      before { valid_signin admin }
      
      describe "submitting a DELETE request to the Users#destroy action on itself" do
        before { delete user_path(admin) }

        specify { response.should redirect_to(root_path) }

        it "should not delete the user" do
          expect { delete user_path(admin) }.to change(User, :count).by(0)
        end
      end
    end
    
    describe "as signed-in user" do
      let(:user) { FactoryGirl.create(:user) }
      before { valid_signin user }
      
      describe "submitting to the Users#new action" do
        before { get new_user_path }
        specify { response.should redirect_to(root_path) }
      end
      
      describe "submitting to the Users#create action" do
        before { post users_path }
        specify { response.should redirect_to(root_path) }
      end
      
      describe "visiting profile page" do
        let!(:micropost) { FactoryGirl.create(:micropost, user: user) } 
        before do
          visit user_path(user)
        end
        
        it "should show delete link on microposts" do
          page.should have_link('delete', href: micropost_path(micropost))
        end
      end
    end
  end
end
