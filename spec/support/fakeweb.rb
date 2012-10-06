require 'fakeweb'
FakeWeb.allow_net_connect = false

class Net::HTTPGenericRequest

  def form_data
    @form_data ||= Hash[CGI.unescape(body).scan(/([^=]+)=([^&]*)&?/)]
  end

end

