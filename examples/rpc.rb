require 'pp'
require 'peplum/nmap'

# Spawn an nmap Agent as a daemon.
nmap_agent = Peplum::Nmap::Application.spawn( :agent, daemonize: true )
at_exit { nmap_agent.shutdown rescue nil }

# Spawn and connect to an nmap Instance.
nmap = Peplum::Nmap::Application.connect( nmap_agent.spawn )
# Don't forget this!
at_exit { nmap.shutdown }

# Run a distributed scan.
nmap.run(
  peplum: {
    objects:     ['192.168.1.*'],
    max_workers: 5
  },
  payload: {
    connect_scan:   true,
    service_scan:   true,
    default_script: true
  }
)

# Waiting to complete.
while nmap.running?
  ap nmap.info.progress
  sleep 1
end

# Hooray!
puts JSON.pretty_generate( nmap.generate_report.data )
