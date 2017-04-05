# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## 0.4, the wilderness years
There is no 0.4.x release. Active support moved to the community during this time. Much kudos and love to kkirsche for keeping this project alive. As a sign of respect (and to avoid confusion) the only 0.4 releases will be the ones developed my kkirsche.

Next stop: 0.5.0!

## 0.3.1, 2013-07-26
### Added
- extension support to Netconf::SSH. For example, see net/netconf/jnpr/ssh.rb.
- Juniper Netconf::SSH extension to access NETCONF subsystem via CLI command if NETCONF port (830) is not enabled. This enhancement was added for users that have Junos systems depoloyed, but didn't enable NETCONF. Note that this enhacement assumes that the user login starts at the standard Junos CLI (i.e. not root user)

## 0.3.0, 2013-07-21
A number of pull requests were manually merged as a result of my learning curve around git. My sincere apologies, on the delay bringing these updates into the mainline. If I missed you on this list, please let me know and I'll update accordingly. Thx, Jeremy

NOTE: If you intend to use `Netconf::Serial` you will need to ensure that the `serialport` gem is installed. This gem is not explicitly included in the gemspec

### Added
- Netconf::RPC::MSG_END on each RPC. kudos: wpaulson
- Juniper specific request_pfe_execute. kudos: dgjnpr
- `:ssh_args` hash on Netconf::SSH to support any of the Net::SSH start args. kudos: imbracio
- "deep" look for rpc-error tags rather than just the first two levels. kudos: jof
- Netconf helper method `open?` and `closed?` for checking NETCONF session state. kudos: jof
- net-scp to netconf.gemspec dependency. This gem is really only required if you intent to use the SCP functionality; but since this is turning out to be a common use-case, the gem has been added to the dependency list

### Changed
- check for rpc-error severity='error' to handle the case where the rpc-error element is actually not an error, but rather severity='warning'. If the severity is in fact __not__ error, then the Netconf::RpcError __will not__ be generated. In Netconf::VERSION <= 0.2.5, the warnings would actually cause an exception. If you would like to maintain the older behavior, then you will need to set `Netconf::raise_on_warning = true`. kudos: jeremyschulman
- netconf.gemspec to include only the `version.rb` file; also separated out the Netconf::VERSION into a separate file. kudos: request by multiple folks
- Converted files from MS-DOS format to Unix; stripped out all of MS-DOS format kruft. kudos: jof

## 0.2.5, 2012-01-29
### Added
- IOProc support

### Changed
- Refactored code to enhance multi-vendor

### Fixed
- Junos specific RPCs

## 0.2.4, 2012-01-16
### Added
- `command` support for Junos RPC

## 0.2.2, 2012-01-14
Tested against Tail-F "confD" server

### Added
- RFC required `rpc` namespace and `message-id` attributes

## 0.2.1, 2012-01-09
### Added
- support for Net::SCP accessor in SSH transport. See example code [scp.rb](examples/jnpr/scp.rb); you will need to explicity require 'net/scp' in your top-level code

## 0.2.0, 2012-01-06
Tested against JUNOS devices

### Added
- Support for SSH, Telnet, and Console
