
# Udev rules

`/etc/udev/rules.d/99-blackmagic.rules`

```
# Black Magic Probe
# there are two connections, one for GDB and one for uart debugging
SUBSYSTEM=="tty", ATTRS{interface}=="Black Magic GDB Server", SYMLINK+="ttyBMP"
SUBSYSTEM=="tty", ATTRS{interface}=="Black Magic UART Port", SYMLINK+="ttyBMPUART"
```
