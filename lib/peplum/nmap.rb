# frozen_string_literal: true

require 'peplum'

module Peplum
class Nmap

  require_relative "nmap/version"
  require_relative "nmap/native"

  class Error < Peplum::Error; end

  class Application < Peplum::Application
    def native_app
      Native
    end
  end

end
end
