When /^I serviceValidate the service ticket for "([^"]*)"$/ do |url|
  visit('/serviceValidate?ticket=%s&service=%s' % [@service_ticket.name, url])
end

When /^I serviceValidate the service ticket for "([^"]*)" with proxy URL "([^"]*)"$/ do |url, callback|
  stub_request(:get, Regexp.new(callback)).to_return(:body => 'Ok')
  visit('/serviceValidate?ticket=%s&service=%s&pgtUrl=%s' % [@service_ticket.name, url, callback])
end

Then /^I should have xpath "([^"]*)"(?: with text "([^"]*)")?$/ do |element_name, text|
  xml = Nokogiri::XML.parse(page.driver.body)
  els = xml.xpath(text ? element_name + "/text()" : element_name, xml.root.namespaces)
  textp = Regexp.new(text) if text

  if els.respond_to? :should
    els.should_not be_empty
    els.should be_any { |node| textp.match(node.to_s) } if text
  else
    assert !els.empty?
    assert els.any? { |node| textp.match(node.to_s) } if text
  end
end

Then /^I should not have xpath "([^"]*)"(?: with text "([^"]*)")?$/ do |element_name, text|
  xml = Nokogiri::XML.parse(page.driver.body)
  els = xml.xpath(text ? element_name + "/text()" : element_name, xml.root.namespaces)
  textp = Regexp.new(text) if text

  if els.respond_to? :should
    els.should be_empty
    els.should_not be_any { |node| textp.match(node.to_s) } if text
  else
    assert els.empty?
    assert !els.any? { |node| textp.match(node.to_s) } if text
  end
end
