# Legacy Modem Emulator

## Description
This TCL script emulates a Quectel BG95 modem.

## Requirements
Install expect with:
```Shell
sudo apt-get install expect
```

## Usage
The emulator uses stdin and stdout as the modem serial interface.
Debugging messages are printed out to stderr.

Use socat to connect the modem emulator to a local software

```Shell
# Execute the script and redirect input and output to a virtual port
socat -v -x EXEC:"./modemEmulator.exp",pty,rawer,icanon=0 PTY,rawer,link=ttyModem,mode=0666,icanon=0
# Make your application use the created virtual port
./yourApp ttyModem
```
