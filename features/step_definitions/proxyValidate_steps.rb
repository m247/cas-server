Before do
  @service_ticket = @proxy_ticket = @proxy_granting_ticket = nil
end
After do
  @service_ticket = @proxy_ticket = @proxy_granting_ticket = nil
end

Given /^an invalid proxy ticket$/ do
  @proxy_ticket = "PT-BLAHBLAH"
end

Given /^I have a proxy granting ticket for the service ticket for proxy "([^"]*)"$/ do |proxy|
  @proxy_granting_ticket = CASServer::ProxyGrantingTicket.new(:proxy => proxy)
  @proxy_granting_ticket.save
  @service_ticket.proxy_granting_ticket = @proxy_granting_ticket
end

Given /^I have a valid proxy ticket for "([^"]*)" with proxy "([^"]*)"$/ do |url, proxy|
  Given "I have a valid service ticket for \"#{url}\""
  Given "I have a proxy granting ticket for the service ticket for proxy \"#{proxy}\""

  @proxy_ticket = CASServer::ProxyTicket.new(:service => url,
    :username => @proxy_granting_ticket.service_ticket.username)
  @proxy_ticket.granted_by_ticket = @proxy_granting_ticket
  @proxy_ticket.save
end

When /^I proxyValidate the proxy ticket for "([^"]*)"$/ do |url|
  visit("/proxyValidate?ticket=%s&service=%s" % [@proxy_ticket || '', url])
end
