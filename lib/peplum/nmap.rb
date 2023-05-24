# frozen_string_literal: true

require 'peplum'

module Peplum
class Nmap

  require_relative "nmap/version"
  require_relative "nmap/payload"

  class Error < Peplum::Error; end

  class Application < Peplum::Application

    require_relative "nmap/services/info"
    instance_service_for :info, Services::Info

    require_relative "nmap/services/rest_proxy"
    rest_service_for :info, Services::RESTProxy

    def payload
      Payload
    end
  end

end
end
