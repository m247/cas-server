module CASHelpers
  def add_test_user(username, password)
    CASServer.authenticators.first.add(username, password)
  end
  def create_session(username, password, service = nil)
    visit("/login#{service ? '?service=' + service : nil}")
    fill_in('username', :with => username)
    fill_in('password', :with => password)
    click_button("Sign In")

    if page.response_headers["Set-Cookie"]
      tgc = page.response_headers["Set-Cookie"].split(';')[0].split('=')[1]
      return CASServer::TicketGrantingCookie.get(tgc)
    end

    return nil
  end
  def create_service_ticket(service)
    add_test_user("testing", "testing")
    tgc = create_session("testing", "testing", service)

    uri = URI.parse(page.current_url)
    uri.query ||= ""
    params = Hash[*uri.query.split('&').map{|p| p.split('=')}.flatten]

    raise "Did not get ST back from session create" unless params.has_key?("ticket")
    CASServer::ServiceTicket.get(params["ticket"])
  end
  def create_proxy_granting_ticket(service, pgtUrl)
    st = create_service_ticket(service)

    stub_request(:any, Regexp.new(pgtUrl)).to_return(:status => [200, 'Ok'])
    visit("/serviceValidate?ticket=#{st}&service=#{service}&pgtUrl=#{pgtUrl}")

    xml = Nokogiri::XML.parse(page.driver.body)
    iou = xml.xpath("//cas:proxyGrantingTicket/text()", xml.root.namespaces)[0].to_s.strip

    pgtiou = CASServer::ProxyGrantingTicketIou.get(iou)
    pgt = pgtiou.proxy_granting_ticket
  end
  def create_proxy_ticket(service, proxy)
    pgt = create_proxy_granting_ticket(service, proxy)
    visit("/proxy?pgt=#{pgt}&targetService=#{service}")

    xml = Nokogiri::XML.parse(page.driver.body)
    pt = xml.xpath("//cas:proxyTicket/text()", xml.root.namespaces)[0].to_s.strip
    CASServer::ProxyTicket.get(pt)
  end
end

World(CASHelpers)
