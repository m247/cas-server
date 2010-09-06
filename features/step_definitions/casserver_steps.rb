Given /^I have a single sign on session(?: for service "([^\"]*)")?$/ do |service|
  @ticket_granting_cookie = create_session("testing", "testing", service)
end

Given /^a user with credentials "([^\"]*)" and password "([^\"]*)"$/ do |user, pass|
  add_test_user(user, pass)
end

When /^I visit "([^"]*)"$/ do |url|
  visit(url)
end

Then /^I should be redirected to "([^"]*)"$/ do |url|
  Then "I should see \"GET\""
  Then "I should see \"#{url}\""
end

Then /^I should be redirected to "([^"]*)" with a service ticket$/ do |url|
  Then "I should see \"GET\""
  Then "I should see \"#{url}\""
  Then "I should see \"ST-\""
end

Then /^I should be redirected to "([^"]*)" without a service ticket$/ do |url|
  Then "I should see \"GET\""
  Then "I should see \"#{url}\""
  Then "I should not see \"ST-\""
end

Then /^I should see fields:$/ do |table|
  table.raw.each do |field, _|
    Then %<I should have xpath "//input[@name='#{field}']">
  end
end

Then /^I should see fields with values:$/ do |table|
  table.raw.each do |field, value|
    if value == ''
      Then %<I should have xpath "//input[@name='#{field}']">
    else
      Then %<I should have xpath "//input[@name='#{field}'][@value='#{value}']">
    end
  end
end
