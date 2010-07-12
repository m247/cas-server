Given /^I have a single sign on session$/ do
end

Given /^a user with credentials "([^\"]*)" and password "([^\"]*)"$/ do |user, pass|
  CASServer.authenticators.first.add(user, pass)
end

When /^I visit "([^"]*)"$/ do |url|
  visit(url)
end

Then /^I should be redirected to "([^"]*)"$/ do |url|
  Then "I should see \"GET\""
  Then "I should see \"#{url}\""
end
