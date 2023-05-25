module Peplum
class Nmap
module Services

class Info

  class <<self
    def progress_data
      @progress_data ||= {}
    end
  end

  def progress
    self.class.progress_data
  end

  def update( data )
    self.class.progress_data.merge! data
    nil
  end

end

end
end
end
