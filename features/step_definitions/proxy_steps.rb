Given /^an invalid proxy granting ticket$/ do
  @proxy_granting_ticket = "PGT-BLAHBLAH"
end

When /^I request a proxy ticket for "([^"]*)"$/ do |url|
  visit("/proxy?pgt=%s&targetService=%s" % [@proxy_granting_ticket, url])
end
