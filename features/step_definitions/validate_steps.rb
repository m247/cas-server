Given /^I have a valid service ticket for "([^"]*)"$/ do |url|
  @service_ticket = create_service_ticket(url)
end

Given /^the service ticket was granted by credentials$/ do
  @service_ticket.granted_by_credentials = true
  @service_ticket.save
end

Given /^the service ticket was granted by a cookie$/ do
  @service_ticket.granted_by_credentials = false
  @service_ticket.save
end

Given /^an invalid service ticket$/ do
  @service_ticket = "ST-BLAHBLAH"
end

When /^I validate the service ticket for "([^"]*)"$/ do |url|
  visit('/validate?ticket=%s&service=%s' % [@service_ticket, url])
end

When /^I validate the service ticket for "([^"]*)" with the renew option$/ do |url|
  visit('/validate?ticket=%s&service=%s&renew=true' % [@service_ticket, url])
end
