Given /^I have a valid service ticket for "([^"]*)"$/ do |url|
  @service_ticket = CASServer::ServiceTicket.create(:username => 'testing', :service => url)
end

Given /^the service ticket was granted by a cookie$/ do
  @granting_cookie = CASServer::TicketGrantingCookie.create(:username => 'testing')
  @service_ticket.granted_by_cookie = @granting_cookie
  @service_ticket.save
end

When /^I validate the service ticket for "([^"]*)"$/ do |url|
  visit('/validate?ticket=%s&service=%s' % [@service_ticket.name, url])
end

When /^I validate the service ticket for "([^"]*)" with the renew option$/ do |url|
  visit('/validate?ticket=%s&service=%s&renew=true' % [@service_ticket.name, url])
end
