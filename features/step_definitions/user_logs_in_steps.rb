
Given /^A user exists with username '(.*)' and password '(.*)'$/ do |username, password|
  user = User.first(:username => username) || User.new(:username => username)
  user.password = password
  user.save
end

Given /^I visit the (.*) page$/ do |page_name|
  visit PAGES[page_name]
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
  current_url.should == PAGES[page_name]
end
