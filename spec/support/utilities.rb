include ApplicationHelper

RSpec::Matchers.define :have_error_message do |message|
  match do |page|
    page.should have_selector('div.alert.alert-error', text: message)
  end
end

RSpec::Matchers.define :have_success_message do |message|
  match do |page|
    page.should have_selector('div.alert.alert-success', text: message)
  end
end



def signin_button
  "Sign in"
end

def valid_signin(user)
  visit signin_path
  fill_in "Email",    with: user.email.upcase
  fill_in "Password", with: user.password
  click_button signin_button
  # Sign in when not using Capybara as well.
  cookies[:remember_token] = user.remember_token  
end

def invalid_signin
  visit signin_path
  click_button signin_button
end
