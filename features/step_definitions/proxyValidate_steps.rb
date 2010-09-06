Before do
  @service_ticket = @proxy_ticket = @proxy_granting_ticket = nil
end
After do
  @service_ticket = @proxy_ticket = @proxy_granting_ticket = nil
end

Given /^an invalid proxy ticket$/ do
  @proxy_ticket = "PT-BLAHBLAH"
end

Given /^I have a proxy granting ticket for proxy "([^"]*)"$/ do |proxy|
  @proxy_granting_ticket = create_proxy_granting_ticket('http://test.com', 'https://test-proxy.com')
end

Given /^I have a valid proxy ticket for "([^"]*)" with proxy "([^"]*)"$/ do |url, proxy|
  @proxy_ticket = create_proxy_ticket(url, proxy)
end

When /^I proxyValidate the proxy ticket for "([^"]*)"$/ do |url|
  visit("/proxyValidate?ticket=%s&service=%s" % [@proxy_ticket || '', url])
end
