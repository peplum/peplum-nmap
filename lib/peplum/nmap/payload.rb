require 'nmap/command'
require 'nmap/xml'
require 'tmpdir'

module Peplum
class Nmap

module Payload
  include Peplum::Application::Payload

  DEFAULT_OPTIONS = {
    'output_normal' => '/dev/null',
    'quiet'         => true
  }

  PING_REPORT = "#{Dir.tmpdir}/nmap-ping-#{Process.pid}.xml"
  SCAN_REPORT = "#{Dir.tmpdir}/nmap-scan-#{Process.pid}.xml"

  at_exit do
    FileUtils.rm_f PING_REPORT
    FileUtils.rm_f SCAN_REPORT
  end

  def run( targets, options )
    # Do it this way so we'll be able to have progress reports per scanned host.
    targets.map do |target|
      _run options.merge( targets: target, output_xml: SCAN_REPORT )

      report = report_from_xml( SCAN_REPORT )
      next if report.empty?

      Nmap::Application.master.info.update report
      report
    end.compact
  end

  def split( targets, chunks )
    @hosts ||= self.live_hosts( targets )
    @hosts.chunk( chunks ).reject(&:empty?)
  end

  private

  def live_hosts( targets )
    _run targets:    targets,
         ping:       true,
         output_xml: PING_REPORT

    hosts = hosts_from_xml( PING_REPORT )

    # Seed the progress data with the live hosts
    hosts.each { |h| Services::Info.progress_data[h] ||= {} }

    hosts
  end

  def set_default_options( nmap )
    set_options( nmap, DEFAULT_OPTIONS )
  end

  def set_options( nmap, options )
    options.each do |k, v|
      nmap.send "#{k}=", v
    end
  end

  def _run( options = {}, &block )
    ::Nmap::Command.run do |nmap|
      set_default_options nmap
      set_options nmap, options
      block.call nmap if block_given?
    end
  end

  def hosts_from_xml( xml )
    hosts = []
    ::Nmap::XML.open( xml ) do |xml|
      xml.each_host do |host|
        hosts << host.ip
      end
    end
    hosts
  end

  def report_from_xml( xml )
    report_data = {}
    ::Nmap::XML.open( xml ) do |xml|
      xml.each_host do |host|
        report_data[host.ip] = host_to_hash( host )

        report_data[host.ip]['ports'] = {}
        host.each_port do |port|
          report_data[host.ip]['ports'][port.number] = port_to_hash( port )
        end
      end
    end
    report_data
  end

  def host_to_hash( host )
    h = {}
    %w(start_time end_time status addresses mac vendor ipv4 ipv6 hostname hostnames os uptime).each do |k|
      v = host.send( k )
      next if !v

      if v.is_a? Array
        h[k] = v.map(&:to_s)
      else
        h[k] = v.to_s
      end
    end

    if host.host_script
      h['scripts'] = {}
      host.host_script.scripts.each do |name, script|
        h['scripts'][name] = {
          output: script.output,
          data:   script.data
        }
      end
    end

    h
  end

  def port_to_hash( port )
    h = {}

    %w(protocol state reason reason_ttl).each do |k|
      h[k] = port.send( k )
    end
    h['service'] = port.service.to_s

    h['scripts'] ||= {}
    port.scripts.each do |name, script|
      h['scripts'][name] = {
        output: script.output,
        data:   script.data
      }
    end

    h
  end

  extend self

end

end
end
