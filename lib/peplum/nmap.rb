# frozen_string_literal: true

require 'peplum'

module Peplum
class Nmap

  require_relative "nmap/version"
  require_relative "nmap/payload"

  class Error < Peplum::Error; end

  class Application < Peplum::Application
    def payload
      Payload
    end
  end

end
end
