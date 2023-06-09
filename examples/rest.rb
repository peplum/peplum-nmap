require 'peplum/nmap'
require 'pp'
require_relative 'rest/helpers'

# Boot up our REST nmap server for easy integration.
rest_pid = Peplum::Nmap::Application.spawn( :rest, daemonize: true )
at_exit { Cuboid::Processes::Manager.kill rest_pid }

# Wait for the REST server to boot up.
while sleep 1
  begin
    request :get
  rescue Errno::ECONNREFUSED
    next
  end

  break
end

# Assign an nmap Agent to the REST service for it to provide us with scanner Instances.
nmap_agent = Peplum::Nmap::Application.spawn( :agent, daemonize: true )
request :put, 'agent/url', nmap_agent.url
at_exit { nmap_agent.shutdown rescue nil }

# Create a new scanner Instance (process) and run a scan with the following options.
request :post, 'instances', {
  peplum: {
    objects:     ['192.168.1.*'],
    max_workers: 5
  },
  payload: {
    connect_scan:   true,
    service_scan:   true,
    default_script: true
  }
}

# The ID is used to represent that instance and allow us to manage it from here on out.
instance_id = response_data['id']

while sleep( 1 )
  request :get, "instances/#{instance_id}/info/progress"
  ap response_data

  # Continue looping while instance status is 'busy'.
  request :get, "instances/#{instance_id}"
  break if !response_data['busy']
end

puts '*' * 88

# Get the scan report.
request :get, "instances/#{instance_id}/report.json"

# Print out the report.
puts JSON.pretty_generate( JSON.load( response_data['data'] ) )

# Shutdown the Instance.
request :delete, "instances/#{instance_id}"
