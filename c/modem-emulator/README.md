# Modem Emulator

## Description
This is a modem emulator that communicates with the outside world through a pty. It responds to the received AT commands and,
when requested (AT command 'ATD*99#'), it switches to PPP mode and launches pppd daemon to provide connectivity through the 
serial link. When the ppp connection is closed it goes back to AT mode.

```sh
Usage:  ./modemEmulator options
-h --help      :  Shows this help
-v --verbosity :  Increase verbosity
-t --type      :  Modem type (TBD)
-d --device    :  Modem device (default: /dev/gsmtty2)
```
                
    Currently only Quectel BG95 is supported

## Requirements
You have to have ppp installed in your machine, well configured (config files provided) and the user has to be in the dip group
in order to be able to run pppd command.
You can add yourself to the dip group with the command:
```sh
sudo usermod -aG dip $USER
```

Copy the contents of ./etc/ppp directoris to /etc/ppp accordenly. Update WAN_IFACE in '00-iptables' files with your WAN interface (the one
that gives you internet connectivity)

## Usage
```sh
./modemEmulator -d <device> -vv
```
