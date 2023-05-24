module Peplum
class Nmap
module Services
module RESTProxy
def self.registered( app )

  app.get '/progress' do
    instance_for( params[:instance] ) do |instance|
      json instance.info.progress
    end
  end

end
end
end
end
end
