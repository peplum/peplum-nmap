# Peplum::Nmap

Peplum::Nmap is a distributed network mapper/security scanner backed by:

* [Peplum](https://github.com/peplum/peplum) for the distributed architecture.
* [nmap](https://nmap.org/) for the scanning engine.
* [ruby-nmap](https://github.com/postmodern/ruby-nmap) for the Ruby middleware.

Its basic function is to distribute the scanning of IP ranges across multiple machines and thus parallelize an otherwise
quite time consuming task.

## Installation

    $ git clone git@github.com:peplum/peplum-nmap.git
    $ cd peplum-nmap
    $ bundle install

## Usage

See the `examples/` directory.

### Grid

Peplum::Nmap can initiate scans from the same machine, but the idea behind it is to use a _Grid_ which transparently load-balances
and line-aggregates, in order to combine resources and perform a faster scan than one single machine could.

That _Grid_ technology is graciously provided by [Peplum](https://github.com/peplum/peplum) and can be setup like so:

```
$ bundle exec irb
irb(main):001:0> require 'peplum/nmap'
=> true
irb(main):002:0> Peplum::Nmap::Application.spawn( :agent, address: Socket.gethostname )
I, [2023-05-21T19:11:20.772790 #359147]  INFO -- System: Logfile at: /home/zapotek/.cuboid/logs/Agent-359147-8499.log
I, [2023-05-21T19:11:20.772886 #359147]  INFO -- System: [PID 359147] RPC Server started.
I, [2023-05-21T19:11:20.772892 #359147]  INFO -- System: Listening on xps:8499
```

And at the terminal of another machine:

```
$ bundle exec irb
irb(main):001:0> require 'peplum/nmap'
=> true
irb(main):002:0> Peplum::Nmap::Application.spawn( :agent, address: Socket.gethostname, peer: 'xps:8499' )
I, [2023-05-21T19:12:38.897746 #359221]  INFO -- System: Logfile at: /home/zapotek/.cuboid/logs/Agent-359221-5786.log
I, [2023-05-21T19:12:38.998472 #359221]  INFO -- System: [PID 359221] RPC Server started.
I, [2023-05-21T19:12:38.998494 #359221]  INFO -- System: Listening on xps:5786
```

That's a _Grid_ of 2 Peplum::Nmap _Agents_, both of them available to provide scanner _Instances_ that can be used to parallelize
network mapping/security scans.

If those 2 machines use a different pipe to the network you wish to scan, the result will be that the network resources
are going to be in a way combined; or if the scan is too CPU intensive for just one machine, this will split the workload
amongst the 2.

The cool thing is that it doesn't matter to which you refer for _Instance_ _spawning_, the appropriate one is going to
be the one providing it.

You can then configure the _REST_ service to use any of those 2 _Agents_ and perform your scan --
see [examples/rest.rb](https://github.com/peplum/peplum-nmap/blob/master/examples/rest.rb).

The _REST_ service is good for integration, so it's your safe bet; you can however also take advantage of the internal
_RPC_ protocol and opt for something more like [examples/rpc.rb](https://github.com/peplum/peplum-nmap/blob/master/examples/rpc.rb).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/peplum/peplum-nmap.

## Funding

Peplum::Nmap is a [Peplum](https://github.com/peplum/) project and as such funded by [Ecsypno Single Member P.C.](https://ecsypno.com).
