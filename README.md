# Making-Dos-Metasploit-Module-Vulnserver
This is a walkthrough of making the DOS Metasploit module for Vulnserver a vulnerable chat server. 
## Table of Contents 
* [Introduction](#introduction)
    * [Different types of Modules](#different-types-of-modules)
## Introduction 
Let us first look at the different kinds of modules there are and the uses of each one.
### Different types of Modules 
There are three different types of modules.
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
4. **Payload Modules**
    * shell code that runs after an exploit successfully compromises a system.
    * enables you to define how you want to connect to the shell and what you want to do to the target system after you take control of it.
    * A payload can open a Meterpreter or command shell.
        * This command shell is an advanced payload that allows you to write DLL files to dynamically create new features as you need them.
5. **NOP-generator Module**
    * A NOP generator produces a series of random bytes that you can use to bypass standard IDS and IPS NOP sled signatures. Use NOP generators to pad buffers
6. The only aplicable ones to the class are Auxiliary and Exploit Modules, maybe keeping the payload or post exploit but this should at least for no only go into the exploit and auxillary.
4. [Reference](https://docs.rapid7.com/metasploit/msf-overview/#:~:text=executes%20a%20sequence%20of%20commands%20to%20target%20a%20specific%20vulnerability%20found%20in%20a%20system%20or%20application.%20An%20exploit%20module%20takes%20advantage%20of%20a%20vulnerability%20to%20provide%20access%20to%20the%20target%20system)


