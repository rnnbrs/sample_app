require 'spec_helper'

describe "Static pages" do
  
  subject{ page }
  
  shared_examples_for "all static pages" do
    it { should have_selector('h1', text: heading) }
    it { should have_selector('title', text: full_title(page_title)) }
  end
  
  describe "Home page" do
    before{ visit root_path }
    let(:heading)    { 'Sample App' }
    let(:page_title) { '' }
    
    it_should_behave_like "all static pages"
    it { should_not have_selector 'title', text: '| Home' }
    
    describe "for signed_in users" do
      let(:user) { FactoryGirl.create(:user) }
      before do
        FactoryGirl.create(:micropost, user: user, content: "Lorem ipsum")
        FactoryGirl.create(:micropost, user: user, content: "Dolor sit amet")
        valid_signin(user)
        visit root_path
      end
      
      it "should render the user's feed" do
        user.feed.each do |item|
          page.should have_selector("li##{item.id}", text: item.content)
          page.should have_link('delete', href: micropost_path(item))
        end
      end
      
      describe "should not have delete links on other user's feed" do
        let(:other_user) { FactoryGirl.create(:user) }
        before do
          FactoryGirl.create(:micropost, user: other_user, content: "Lorem ipsum")
          FactoryGirl.create(:micropost, user: other_user, content: "Dolor sit amet")
         visit user_path(other_user)
        end
        
        it { should_not have_link('delete') }
      end
      
      describe "pagination" do
        before(:all) { 30.times { FactoryGirl.create(:micropost, user: user) } }
        after(:all) { User.destroy_all }
        
        it { should have_selector('div.pagination') }
        it "should list each micropost" do
          user.feed.paginate(page: 1).each do |micropost|
            page.should have_selector("li##{micropost.id}", text: micropost.content)
          end
        end
      end
      
      describe "micropost count" do
        before do
          Micropost.destroy_all
          visit root_path
        end

        it { should have_selector('span', text: "0 microposts") }
        
        describe "should be 1" do
          before do
            FactoryGirl.create(:micropost, user: user)
            visit root_path
          end
        
          it { should have_selector('span', text: "1 micropost") }
          it { should_not have_selector('span', text: "1 microposts") }
          
          describe "should be 2" do
            before do
              FactoryGirl.create(:micropost, user: user)
              visit root_path
            end
        
            it { should have_selector('span', text: "2 microposts") }
          end
        end
      end
    end
  end
  
  
  describe "Help page" do
    before{ visit help_path }
    let(:heading)    { 'Help' }
    let(:page_title) { 'Help' }
    
    it_should_behave_like "all static pages"
  end
  
  describe "About page" do
    before{ visit about_path }
    let(:heading)    { 'About Us' }
    let(:page_title) { 'About Us' }
    
    it_should_behave_like "all static pages"
  end
  
  describe "Contact Page" do
    before{ visit contact_path }
    let(:heading)    { 'Contact' }
    let(:page_title) { 'Contact' }
    
    it_should_behave_like "all static pages"
  end
  
  
  ##
  ##  Tests for links on the layout
  ##
   
  it "should have the correct links on the layout" do
    visit root_path
    click_link "About"
    page.should have_selector 'title', text: full_title('About Us')
    click_link "Help"
    page.should have_selector 'title', text: full_title('Help')
    click_link "Contact"
    page.should have_selector 'title', text: full_title('Contact')
    click_link "Home"
    click_link "Sign up now!"
    page.should have_selector 'title', text: full_title('Sign up')
    click_link "sample app"
    page.should have_selector 'title', text: full_title('')
  end
end
