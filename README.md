# rsa1024
a NASM implementation of RSA1024

how to use:

`apt install nasm`

`apt install ld`

`make`

`./main`

variables are to set (HSB -> LSB) in the .BSS section

you can add a :

```
push RAX
mov RAX, variable_1024
call print_hex_value_1024 
pop rax
```
to see variables
