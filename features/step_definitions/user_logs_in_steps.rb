
Given /^a user exists with username '(.*)' and password '(.*)'$/ do |username, password|
  user = User.first(:username => username) || User.new(:username => username)
  user.password = password
  user.save
end

Given /^I visit the (.*) page$/ do |page_name|
  visit PAGES[page_name.to_sym]
end

Given /^I fill in '(.*)' for '(.*)'$/ do |value, field|
  fill_in(field, :with => value)
end

When /^I press '(.*)'$/ do |name|
  click_button(name)
end

Then /^I should see '(.*)'$/ do |text|
  response_body.should contain(/#{text}/m)
end

Then /^I should be on the (.*) page$/ do |page_name|
  current_url.should == PAGES[page_name.to_sym]
end

Given /^I'm an authenticated user$/ do
  user = User.first(:username => "test") || User.new(:username => "test")
  user.password = "test"
  user.save
  visit PAGES[:login]
  fill_in('username', :with => 'test')
  fill_in('password', :with => 'test')
  click_button('Login')
end

Given /^I'm not an authenticated user$/ do
end

Then /^I should be redirected to the (.*) page$/ do |page_name|
  redirected_to PAGES[page_name.to_sym]
end

Then /^I should see an? (.*) saying '(.*)'$/ do |type, message|
  hs = have_selector(".flash-#{type}") do |div|
    div.inner_text.should == message
  end
  hs.matches?(response_body).should == true
end

