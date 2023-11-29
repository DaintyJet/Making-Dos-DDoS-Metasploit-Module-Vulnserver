# Information on how to Install
## Installing the Auxiliary Modules
These modules are located in this folder under the [./Auxillary/](./Auxillary/) subfolder 

1. Download the two modules.
1. Save the modules into `/usr/share/metasploit-framework/modules/auxiliary/dos/vchat`
     * This is the path for a Linux/Kali-Linux host OS.
     * You will need to make the `/\*/dos/vchat` subdirectory.
3. Launch the Metasploit Framework.
4. In the Metasploit Framework console run the following command:
``` 
reload_all
```
## Installing the Exploit Module
Follow the instrictions listed at [this](https://github.com/xinwenfu/Malware-Analysis/tree/main/MetasploitNewModule) page.

You can download the knock.rb file and follow similar instructions to above.
1. Downlaod the knock.rb module from [this](https://github.com/xinwenfu/Malware-Analysis/tree/main/MetasploitNewModule) page.
1. Save the module at `/usr/share/metasploit-framework/modules/exploit/windows/vchat`
     * This is the path for a Linux/Kali-Linux host OS. 
     * You will need to make the `/\*/vchat` directory.
1. Launch the Metasploit Famework. 
1. Open the Metasploit Framework console and run the following command:
``` 
reload_all
```

> You can install all three modules first then use the reload_all command once.
## Optional
The Auxillary DoS modules will not show up in Arimtage's *find attacks* option. If you would like, you can install a Exploit version of the Auxilliary modules too, these would also be saved at `/usr/share/metasploit-framework/modules/exploit/windows/vchat`

These modules are located in this folder under the [./Exploit/](./Exploit/) subfolder 