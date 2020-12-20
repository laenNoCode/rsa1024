[bits 64]

section .text
global _start
 _start:               ; ELF entry point
lea RCX, data3
lea RAX, data4
lea RBX, data5
lea RDX, addition_out
call addition_modulaire_1024
lea rax, addition_out
call print_hex_value_1024
;mov RAX, RCX
;call print_hex_value_33Q
mov rax, 60            ; sys_exit
mov rdi, 0             ; 0
syscall
;0x00000000004010e6
;params : RAX,RBX :  toSum, RCX : mod 16q, RDX: out 16q
addition_modulaire_1024:
    push RSP
    mov RBP, RSP
    push RAX
    push RBX
    push RCX
    push RDX
    push R9
    push R10
    push R11
    push R12
    push R13
    mov R12, RDX
    
    ;addition non modulaire
    push RCX ;pile <= modulo
    lea RCX, addition_modulaire_1024_tmp
    call addition_1024
    
    mov RAX, RCX;on stocke le résultat dans un registre temporaire pour pouvoir  les comparer
    pop RBX ;pile => modulo
    mov R13, RBX
    mov R9, [RAX]
    cmp R9,0
    jne addition_modulaire_1024_sub
    mov R11,16
    add RAX,8
    addition_modulaire_1024_compare_loop:
        mov R9, [RAX]
        mov R10, [RBX]
        cmp R9, r10
        jl addition_modulaire_1024_sub
        add RAX,8
        add RBX,8
        dec R11
        cmp R11,0
    jne addition_modulaire_1024_compare_loop
    jmp addition_modulaire_1024_no_sub
    addition_modulaire_1024_sub:
        lea RAX,addition_modulaire_1024_tmp
        add RAX,8
        mov RBX, R13
        mov RCX, R12
        call substraction_1024
        jmp addition_modulaire_1024_end
    addition_modulaire_1024_no_sub:
        lea RAX, addition_modulaire_1024_tmp
        add RAX,8
        mov RBX, R13
        mov R9,16
        addition_modulaire_1024_no_sub_loop:
            mov R10, [RAX]
            mov [RBX], R10
            add RAX,8
            add RBX,8
            dec R9
            cmp R9,0
        jne addition_modulaire_1024_no_sub_loop

    addition_modulaire_1024_end:
    pop R13
    pop R12
    pop R11
    pop R10
    pop R9
    pop RDX
    pop RCX
    pop RBX
    pop RAX
    pop RSP
    ret


;params RAX, RBX : args (16q), RCX : out, 32q
multiplication_1024:
    push RSP
    mov RBP, RSP
    push RAX
    push RBX
    push RCX
    push RDX
    push R8;in 1
    push R9;in 2
    push R10;output result
    push r11; outer loop
    push r12;inner loop
    push r13; tmp low
    push r14; tmp high
    push r15; addition loop
    multiplication_1024_main:
        mov R8, RAX
        mov R9, RBX
        mov R10, RCX
        multiplication_1024_cleanup_result:
            mov R11, 33
            multiplication_1024_cleanup_result_loop:
                mov qword [R10],0
                add R10, 8
                dec R11
                cmp r11,0
            jne multiplication_1024_cleanup_result_loop 
            sub r10,8

        add R8, 120 ; on va multiplier chaque membre de [r8] par l'intégralité des membres de [R9]
        mov r11, 16; for r11 in range(16)
        multiplication_1024_outer_loop:
            add R9, 120
            mov R12, 16
            multiplication_1024_inner_loop:
                mov RAX, [R8]
                mov RBX, [R9]
                mul RBX
                mov R13, RAX
                mov R14, RDX

                
                add [r10], r13
                pushf 
                sub r10,8
                popf
                mov r15,0
                adc [r10], r14
                jnc multiplication_1024_add_stop
                multiplication_1024_add_start:
                SUB r10,8
                add r15,8
                clc
                add qword [r10],1
                jc multiplication_1024_add_start
                multiplication_1024_add_stop:
                add r10, r15
                sub R9,8
                dec R12
                cmp r12,0
                ;todo implement this
            jne multiplication_1024_inner_loop
            ;todo implement this
            add r10,120
            sub R8,8
            dec R11
            cmp r11,0
        jne multiplication_1024_outer_loop
    pop r15
    pop r14
    pop r13
    pop r12
    pop r11
    pop R10
    pop R9
    pop R8
    pop RDX
    pop RCX
    pop RBX
    pop RAX
    pop RSP
    ret

;params : RAX,RBX : args (16q) , RCX : out, 17q
addition_1024:
    push RSP
    mov RBP, RSP
    push RAX
    push RBX
    push RCX
    push RDX
    push r8
    push r9
    push r10
    push r11
    add RAX, 120
    add RBX, 120
    add RCX, 128
    mov r11,rcx
    mov r8, 16
    clc
    pushf
    for_addition_1024:

        mov R9, [RAX]
        mov R10, [RBX]
        popf
        ADC R9,R10
        pushf
        mov [R11], R9
        SUB RAX, 8
        SUB RBX, 8
        SUB R11, 8
        dec r8
        cmp r8,0
    jne for_addition_1024
    mov R9,0
    popf
    ADC R9,0
    mov [R11],r9
    pop r11
    pop r10
    pop r9
    pop r8
    pop RDX
    pop RCX
    pop RBX
    pop RAX
    pop RSP
    ret

;params RAX 16q RBX 16q RCX 16q : RCX <= RAX-RBX
substraction_1024:
    push RSP
    mov RBP, RSP
    push RAX
    push RBX
    push RCX
    push RDX
    push r8
    push r9
    push r10
    push r11
    add RAX, 120
    add RBX, 120
    add RCX, 120
    mov r11,rcx
    mov r8, 16
    clc
    pushf
    for_substraction_1024:
        mov R9, [RAX]
        mov R10, [RBX]
        popf
        jnc substraction_1024_no_sub
        SUB R9,1 
        substraction_1024_no_sub:
        SUB R9, R10
        pushf
        mov [R11], R9
        SUB RAX, 8
        SUB RBX, 8
        SUB R11, 8
        dec r8
        cmp r8,0
    jne for_substraction_1024
    popf
    pop r11
    pop r10
    pop r9
    pop r8
    pop RDX
    pop RCX
    pop RBX
    pop RAX
    pop RSP
    ret 

print_hex_value_64:
    push RSP
    mov rbp, rsp
    push rdi
    push rsi
    push rdx
    push rcx
    push rbx
    push rax
    push r8
    push r9
    push r10
    push r11
    push r12
    push r13
    push r14
    push r15
    call prepare_hex_print_message_64
    mov rax, 1             ; sys_write
    mov rdi, 1             ; STDOUT
    mov rsi, hex_print_message_64       ; buffer
    mov rdx, 19  ; length of buffer
    syscall
    pop r15
    pop r14
    pop r13
    pop r12
    pop r11
    pop r10
    pop r9
    pop r8
    pop rax
    pop rbx
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    pop RSP
    ret


print_hex_value_1024:
    push RSP
    mov rbp, rsp
    push rdi
    push rsi
    push rdx
    push rcx
    push rbx
    push rax
    push r8
    push r9
    push r10
    push r11
    push r12
    push r13
    push r14
    push r15
    call prepare_hex_print_message_1024
    mov rax, 1             ; sys_write
    mov rdi, 1             ; STDOUT
    mov rsi, hex_print_message_1024       ; buffer
    mov rdx, 259  ; length of buffer
    syscall
    pop r15
    pop r14
    pop r13
    pop r12
    pop r11
    pop r10
    pop r9
    pop r8
    pop rax
    pop rbx
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    pop RSP
    ret

print_spacer:
    push RSP
    mov rbp, rsp
    push rdi
    push rsi
    push rdx
    push rcx
    push rbx
    push rax
    push r8
    push r9
    push r10
    push r11
    push r12
    push r13
    push r14
    push r15
    mov rax, 1             ; sys_write
    mov rdi, 1             ; STDOUT
    mov rsi, spacer       ; buffer
    mov rdx, 1  ; length of buffer
    syscall
    pop r15
    pop r14
    pop r13
    pop r12
    pop r11
    pop r10
    pop r9
    pop r8
    pop rax
    pop rbx
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    pop RSP
    ret


print_hex_value_33Q:
    push RSP
    mov rbp, rsp
    push rdi
    push rsi
    push rdx
    push rcx
    push rbx
    push rax
    push r8
    push r9
    push r10
    push r11
    push r12
    push r13
    push r14
    push r15
    call prepare_hex_print_message_33Q
    mov rax, 1             ; sys_write
    mov rdi, 1             ; STDOUT
    mov rsi, hex_print_message_33Q       ; buffer
    mov rdx, 531  ; length of buffer
    syscall
    pop r15
    pop r14
    pop r13
    pop r12
    pop r11
    pop r10
    pop r9
    pop r8
    pop rax
    pop rbx
    pop rcx
    pop rdx
    pop rsi
    pop rdi
    pop RSP
    ret


prepare_hex_print_message_33Q:
    push RSP
    mov RBP, RSP

    push R8
    push R9
    push R10
    push R11
    push RDX
    push RBX

    mov R10, RAX
    lea R11, hex_print_message_33Q
    mov byte [R11], 48
    add R11, 1
    mov byte [R11], 120
    add R11,1
    mov R8, 33
    for1_start_33Q:; for each qword to print

        mov qword RAX, [R10]
        add R10, 0x8
        mov R9, 16

        for2_start_33Q:;decomposition in hex, put it on the stack
            mov RDX, 0
	        mov RBX, 16
	        div RBX
	        cmp RDX, 10
	        jl  final_hex_33Q
	        add RDX, 0x7
	        final_hex_33Q:
            add RDX, 0x30

            push RDX
            dec R9
            cmp R9,0
        jne for2_start_33Q

        mov R9, 16
        for3_start_33Q:
            pop RDX
            mov byte [R11], DL
            add R11, 1 
            dec R9
            cmp R9,0
        jne for3_start_33Q

        dec R8
        cmp R8, 0
    jne for1_start_33Q
    mov byte [R11], 10

    pop RBX
    pop RDX
    pop R11
    pop R10
    pop R9
    pop R8
    pop RSP
    ret


;RAX = addresse de l'entier sur 1024 bits a afficher
prepare_hex_print_message_1024:
    push RSP
    mov RBP, RSP

    push R8
    push R9
    push R10
    push R11
    push RDX
    push RBX

    mov R10, RAX
    lea R11, hex_print_message_1024
    mov byte [R11], 48
    add R11, 1
    mov byte [R11], 120
    add R11,1
    mov R8, 16
    for1_start_1024:; for each qword to print

        mov qword RAX, [R10]
        add R10, 0x8
        mov R9, 16

        for2_start_1024:;decomposition in hex, put it on the stack
            mov RDX, 0
	        mov RBX, 16
	        div RBX
	        cmp RDX, 10
	        jl  final_hex_1024
	        add RDX, 0x7
	        final_hex_1024:
            add RDX, 0x30

            push RDX
            dec R9
            cmp R9,0
        jne for2_start_1024

        mov R9, 16
        for3_start_1024:
            pop RDX
            mov byte [R11], DL
            add R11, 1 
            dec R9
            cmp R9,0
        jne for3_start_1024

        dec R8
        cmp R8, 0
    jne for1_start_1024
    mov byte [R11], 10

    pop RBX
    pop RDX
    pop R11
    pop R10
    pop R9
    pop R8
    pop RSP
    ret

prepare_hex_print_message_64:
    push RSP
    mov RBP, RSP

    push R9
    push R10
    push R11
    push RDX
    push RBX

    mov R10, RAX
    lea R11, hex_print_message_64
    mov byte [R11], 48
    add R11, 1
    mov byte [R11], 120
    add R11,1

    mov qword RAX, [R10]
    mov R9, 16

    for2_start:;decomposition in hex, put it on the stack
        mov RDX, 0
	    mov RBX, 16
	    div RBX
	    cmp RDX, 10
	    jl  final_hex
	    add RDX, 0x7
	    final_hex:
        add RDX, 0x30
        push RDX
        dec R9
        cmp R9,0
        jne for2_start

    mov R9, 16
    for3_start:
        pop RDX
        mov byte [R11], DL
        add R11, 1 
        dec R9
        cmp R9,0
    jne for3_start


    mov byte [R11], 10

    pop RBX
    pop RDX
    pop R11
    pop R10
    pop R9
    pop RSP
    ret





section .data
debug_reg: dq 0
addition_tmp: dq 0
data0: dq 0x0000000000000000, 0x1111111111111111, 0x2222222222222222, 0x3333333333333333, 0x4444444444444444, 0x5555555555555555, 0x6666666666666666, 0x7777777777777777, 0x8888888888888888, 0x9999999999999999, 0xaaaaaaaaaaaaaaaa, 0xbbbbbbbbbbbbbbbb, 0xcccccccccccccccc, 0xdddddddddddddddd, 0xeeeeeeeeeeeeeeee, 0xffffffffffffffff
data1: dq 0x0000000000000000, 0x1111111111111111, 0x2222222222222222, 0x3333333333333333, 0x4444444444444444, 0x5555555555555555, 0x6666666666666666, 0x7777777777777777, 0x8888888888888888, 0x9999999999999999, 0xaaaaaaaaaaaaaaaa, 0xbbbbbbbbbbbbbbbb, 0xcccccccccccccccc, 0xdddddddddddddddd, 0xeeeeeeeeeeeeeeee, 0xffffffffffffffff
data2: dq 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF
data2b: dq 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF
data3: dq 0x0000000000000001, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000
data4: dq 0x0000000000000000, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF
data5: dq 0x0000000000000000, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF
spacer: db 10
section .bss
addition_out: resq 17
multiplication_out: resq 33
addition_modulaire_1024_tmp: resq 17
hex_print_message_1024: resb(259)
hex_print_message_33Q: resb(531)
hex_print_message_64: resb(19)
var1: resq 16
.end: