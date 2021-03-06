
Given /^a user exists with username '(.*)' and password '(.*)'$/ do |username, password|
  user = User.first(:username => username) || User.new(:username => username)
  user.name = "Real Name"
  user.password = password
  user.save
end

Given /^I visit the login page$/ do 
  visit "/"
end


Given /^'(.*)' number does not belong to the pool$/ do |number|
  pending # express the regexp above with the code you wish you had
end

  

Given /^I fill in '(.*)' for '(.*)'$/ do |value, field|
  fill_in field, :with => value
end

Given /^I select '(.*)' for '(.*)'$/ do |value, field|
  select value, :from => field
end

When /^I press '(.*)'$/ do |name|
  click_button name
end


When /^I visit the home page$/ do
  visit "/users/1"
end

When /^I visit the help page$/ do
  visit "/help"
end

When /^I visit the logout page$/ do
  visit "/logout"
end

Then /^I should see '(.*)'$/ do |text|
  response_body.should contain(/#{text}/m)
end

Then /^I should be on the (.*) page$/ do |page_name|
  current_url.should == "#{page_name}"
end

Given /^I'm an authenticated (user|administrator)$/ do |role|
  username = "test#{role}"
  user = User.first(:username => username) || User.new(:username => username)
  user.name = role
  user.password = "test"
  user.save
  visit "/"
  fill_in('username', :with => username)
  fill_in('password', :with => 'test')
  click_button('Login')
end

Given /^I'm not an authenticated user$/ do
end

Then /^I should be redirected to the (.*) page$/ do |page_name|
  redirected_to "/#{page_name}"
end

Then /^I should see an? (.*) saying '(.*)'$/ do |type, message|
  hs = have_selector(".flash-#{type}") do |div|
    div.inner_text.should == message
  end
  hs.matches?(response_body).should == true
end

