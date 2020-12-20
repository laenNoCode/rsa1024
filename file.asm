section .text
global _start

_start:
    lea RBX,file_name
    call create_file
    mov rax, 60            ; sys_exit
    mov rdi, 0             ; 0
    syscall
;rbx = file_name
create_file:
    push rsp
    mov rbp, rsp
    push rax
    push rdi
    push rsi
    mov RAX,85
    mov rdi, file_name
    mov esi, 0777Q
    syscall
    pop rsi
    pop rdi
    pop rax
    pop rsp
    ret



section .data
file_name db "folder/test.txt"