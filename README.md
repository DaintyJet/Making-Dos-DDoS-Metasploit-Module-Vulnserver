# Making-Dos-Metasploit-Module-Vulnserver
This is a walkthrough of making the DOS Metasploit module for Vulnserver a vulnerable chat server. 
## Table of Contents 
* [Introduction](#introduction)
    * [Different types of Modules](#different-types-of-modules)

* [References](#references)
## Introduction 
Metasploit modules are software written in Ruby that the Metasploit Framework uses to preform a specific task 
\([reference](https://docs.rapid7.com/metasploit/modules#:~:text=A%20module%20is%20a%20piece%20of%20software%20that%20the%20Metasploit%20Framework%20uses%20to%20perform%20a%20task%2C%20such%20as%20exploiting%20or%20scanning%20a%20target.)\).

The first thing that you should know is what the different kinds of modules are, as each one gives them different sets of functionality. What type of module you define it as also give us an idea of what it should be used for.



### Different types of Modules 
There are different types of modules. They and their characteristics are listed below. The two main modules we are concerned with are the Auxiliary and Exploit modules. This is because in our case we want to make both a DOS/DDOS and Exploit module for the vChat server. 

In the cases of our Exploit we are going to want to include a payload to gain further access to the system, so it should be an Msf::Exploit class of module. Then in the case of our DOS/DDOS module we would want it to be a Msf:Auxillary class of module as no payload is going to be used or needed.

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

This results in a Module that looks a little different 
```ruby
class MetasploitModule < Msf::Exploit
  Rank = NormalRanking	# Potential impact to the target
  ...
```
#### Mixins
Mixins are an important concept in Ruby and the Metasploit Framework. They are modules that are included inside of a class. They expand the functionality of the class with that of the module. The main thing we are concerned with in the Metasploit framework are the **Datastore** objects and functions they provide.

When creating the DOS, DDOS and Exploit modules all will use the **Msf::Exploit::Remote::Tcp** Mixin. If the module is a DOS or DDOS module it will also include the **Msf::Auxillary::Dos** module. 

The [**Msf::Exploit::Remote::Tcp**](https://www.rubydoc.info/github/rapid7/metasploit-framework/Msf/Exploit/Remote/Tcp) Mixin will provide us with necessary TCP/IP functions to interact with  remote servers, and **Datastore** objects to control that. 

*Note that it is possible to implement this using standard Ruby TCP/IP libraries and functions.* ***REmove Space between this and above later***

The [**Msf::Auxillary::Dos**](https://www.rubydoc.info/github/rapid7/metasploit-framework/Msf/Auxiliary/Dos) provides DOS functionalities to the module, along with identifying the Auxiliary module specifically as a DOS module.

So we will have the following Module
```ruby
class MetasploitModule < Msf::Exploit
  Rank = NormalRanking	# Potential impact to the target

  include Msf::Exploit::Remote::Tcp	# In DOS, DDOS and Exploit
  include Msf::Auxiliary::Dos       # Only in DOS and DDOS
```
//Need to mentione super and all that stuff first.......

#### Datastore
This is a structure used by the Metasploit framework to configure options in the Metasploit Module. As previously mentioned, some of these Datastore objects are from Mixins but we can defined new ones as part of the new module. 
## References
1. [Make citation - Metasploit different modules](https://docs.rapid7.com/metasploit/msf-overview/)
1. [Make citation - Metasploit What is a module](https://docs.rapid7.com/metasploit/modules/#:~:text=A%20module%20is%20a%20piece,%2C%20or%20post%2Dexploitation%20module.)
1. More

