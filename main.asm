[bits 64]

section .text
global _start
 _start:               ; ELF entry point
;mov rax, data2
; ;push rax
; mov rax, data3
; push rax
; push rax
; push rax
; lea rax, data4
; push rax
; push rax
; call multiplication_1024_modulaire
; pop rax
; pop rax
; pop rax
; pop rax
; pop rax
lea rax, data7
lea rbx, data6
lea rcx, addition_modulaire_1024_tmp
call div_r_2048
lea rax, addition_modulaire_1024_tmp
call print_hex_value_1024
;mov RAX, RCX
;call print_hex_value_33Q
mov rax, 60            ; sys_exit
mov rdi, 0             ; 0
syscall

; params : rbp+2*8 pointer to base number (16q)
;params : rbp + 3*8 pointer to power (16q)
;params : rbp+4*8 : pointer to N (modulus)
;params : rbp+5*8 : pointer to V
;params : rpb+6*8 : pointer to R (may be an optionnal argument)
;params : rpb+7*8 : pointer to return address
square_and_multiply_1024:
    push rbp
    mov rbp, rsp
    push RAX
    push RBX
    push RCX
    push RDX
    push R9
    push R10
    push R11
    push R12
    push R13

    ;can be optimized further by cancelling the last squares, will be investigated
    

    pop R13
    pop R12
    pop R11
    pop R10
    pop R9
    pop RDX
    pop RCX
    pop RBX
    pop RAX
    leave
    ret
;params : rbp+2*8 & +3*8 : pointer to arguments to multiply
;params : rbp+4*8 : pointer to N
;params : rbp+5*8 : pointer to V
;params : rpb+6*8 : pointer to R (may be an optionnal argument)
;params : rpb+7*8 : pointer to return address
multiplication_1024_modulaire:
    push rbp
    mov rbp, rsp
    push RAX
    push RBX
    push RCX
    push RDX
    push R9
    push R10
    push R11
    push R12
    push R13
    mov rax,[rbp+2*8];I
    mov rbx, [rbp + 3 * 8];J
    lea rcx, multiplication_1024_modulaire_tmp_S
    call multiplication_1024


    lea rax, multiplication_1024_modulaire_tmp_S +  17 * 8
    lea rbx, multiplication_1024_modulaire_tmp_S_mod
    mov r9, 16
    multiplication_1024_copy_s_loop:
        mov r10, [rax]
        mov qword [rbx],8
        add rax,8
        add rbx,8
        dec r9
        cmp r9,0
    jne multiplication_1024_copy_s_loop

    lea rax, multiplication_1024_modulaire_tmp_S_mod 
    mov rbx, [rbp +6*8];R
    call modulo_R_1024
    
    lea rax, multiplication_1024_modulaire_tmp_S_mod
    mov rbx, [rbp+5*8];V
    lea rcx, multiplication_1024_modulaire_tmp_T
    call multiplication_1024

    lea rax, multiplication_1024_modulaire_tmp_T + 17 * 8
    mov rbx, [rbp +6*8];R
    call modulo_R_1024
    
    lea rax,multiplication_1024_modulaire_tmp_T + 17 * 8
    mov rbx,[rbp+4*8]; N
    lea rcx,multiplication_1024_modulaire_tmp_TxN
    call multiplication_1024
    
    lea rax, multiplication_1024_modulaire_tmp_TxN + 8
    lea rbx, multiplication_1024_modulaire_tmp_S
    lea rcx, multiplication_1024_modulaire_tmp_M
    call addition_2048
    
    lea rax, multiplication_1024_modulaire_tmp_M
    mov rbx, [rbp +6*8];R
    lea rcx, multiplication_1024_modulaire_tmp_U

    lea rax, multiplication_1024_modulaire_tmp_U
    mov r8,[rax]
    cmp r8,0
    jne multiplication_1024_modulaire_to_sub
    
    add rax,8
    mov rbx, [rbp+4*8]
    mov rdx,16
    multiplication_1024_modulaire_cmp_loop:
        mov r8,[rax]
        mov r9, [rbx]
        cmp r8,r9
        jg  multiplication_1024_modulaire_to_sub
        jl  multiplication_1024_modulaire_not_to_sub
        dec rdx
        cmp rdx,0
    jne multiplication_1024_modulaire_cmp_loop
    multiplication_1024_modulaire_to_sub:
        lea rax, multiplication_1024_modulaire_tmp_U+8
        mov rbx, [rbp+4*8];N
        mov rcx, [rbp+7*8]; return address
        call substraction_1024
        jmp multiplication_1024_modulaire_end
    multiplication_1024_modulaire_not_to_sub:
        lea rax, multiplication_1024_modulaire_tmp_U+8
        mov rbx,[rbp+7*8]
        mov r8, 16
        multiplication_1024_modulaire_not_to_sub_copy_loop:
            mov r9, [rax]
            mov [rbx], r9
            add rax,8
            add rbx,8
            dec r8
            cmp r8,0
        jne multiplication_1024_modulaire_not_to_sub_copy_loop
    multiplication_1024_modulaire_end:
    pop R13
    pop R12
    pop R11
    pop R10
    pop R9
    pop RDX
    pop RCX
    pop RBX
    pop RAX
    leave
    ret

;101010111001010110 > 10000000 
; rax 33Q, rbx 16q, sortie rcx 17q
div_r_2048:
    push rbp
    mov rbp, rsp
    push RAX
    push RBX
    push RCX
    push RDX
    push R9
    push R10
    push R11
    push R12
    push R13
    mov r11, rax
    mov r12, rbx
    mov r13, rcx
    add r11, 32*8
    add r12, 15*8
    add r13, 16*8

    mov rax, [r12]
    cmp rax,0
    jne div_r_2048_find_nonzero_loop_end
    div_r_2048_find_nonzero_loop:
        sub r12,8
        sub r11, 8
        mov rax, [r12]
        cmp rax,0
        je div_r_2048_find_nonzero_loop
    div_r_2048_find_nonzero_loop_end:
    mov r8b,0
    mov r9b,64
    cmp rax, 1
    je div_r_2048_find_one_loop_end
    div_r_2048_find_one_loop:
        inc R8b
        dec r9b
        shr rax, 1
        cmp rax, 1
        jne div_r_2048_find_one_loop
    div_r_2048_find_one_loop_end:

    mov r10, 17
    mov rax, [r11]
    debug_flag:
    mov cl, r8b
    shr rax, cl
    sub r11, 8
    div_r_2048_find_fill_loop:
        mov rbx, [r11]
        mov cl, r9b
        shl rbx, cl
        add rax,rbx
        mov [r13], rax
        mov rax, [r11]
        mov cl, r8b
        shr rax, cl
        sub r13, 8
        sub r11, 8
        dec r10
        cmp r10,0
    jne div_r_2048_find_fill_loop
    pop R13
    pop R12
    pop R11
    pop R10
    pop R9
    pop RDX
    pop RCX
    pop RBX
    pop RAX
    leave
    ret

;params : rax => to mod (16q in place), rbx mod (16q)
modulo_R_1024:
    push rbp
    mov rbp, rsp
    push RAX
    push RBX
    push RCX
    push RDX
    push R9
    push R10
    push R11
    push R12
    push R13
    mov r8,rax
    mov r9, rbx
    mov rbx, [r9]
    cmp rbx,0
    jne modulo_R_1024_loop_end
    modulo_R_1024_loop:
    mov qword [r8], 0
    add r8, 8
    add r9, 8
    mov rbx, [r9]
    cmp rbx, 0
    je modulo_R_1024_loop
    modulo_R_1024_loop_end:
    
    mov rax,[r8]
    div rbx
    mov [r8],rdx
    pop R13
    pop R12
    pop R11
    pop R10
    pop R9
    pop RDX
    pop RCX
    pop RBX
    pop RAX
    leave
    ret
;use of allocated memory : 
;params : RAX,RBX :  toSum, RCX : mod 16q, RDX: out 16q
addition_modulaire_1024:
    push rbp
    mov rbp, rsp
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
    leave
    ret


;params RAX, RBX : args (16q), RCX : out, 32q
multiplication_1024:
    push rbp
    mov rbp, rsp
    push RAX
    push RBX
    push RCX
    push RDX
    push R8;in 1
    push R9;in 2
    push R10;output result
    push r11; outer loop
    push r12;inner loop
    push r13; tmp val
    push r14; tmp high
    push r15; 
    multiplication_1024_main:
        mov r8, rax
        mov r9, rbx
        ;cleans the output
        mov r10, rcx
        mov r11, 33
        multiplication_1024_clean_output_loop:
            mov qword [r10],0
            add r10,8
            dec r11
            cmp r11,0
        jne multiplication_1024_clean_output_loop
        
        sub r11, 8
        sub r10, 8
        add r8, 120
        add r9, 120
        mov r11, 16
        multiplication_1024_outer_loop:
            lea r13,addition_modulaire_1024_tmp
            add r13, 128
            mov rbx, [r8]
            mov rax, [r9]
            mul rbx
            mov [r13], rax
            sub r9, 8
            sub r13,8
            mov r12, 15
            multiplication_1024_inner_loop:
                mov r14, rdx;r14 is local to this loop
                mov rax, [r9]
                mul rbx
                add r14,rax
                adc rdx,0
                mov [r13], r14
                sub r13,8
                sub r9,8
                dec r12
                cmp r12,0
            jne multiplication_1024_inner_loop
            mov [r13], rdx
            add r13,128
            ;adds the result to the current data,
            mov r12,17
            clc
            pushf
            multiplication_1024_addition_loop:
                mov rax,[r10]
                mov rbx,[r13]
                popf
                adc rax,rbx
                pushf
                mov [r10],rax
                sub r10,8
                sub r13,8
                dec r12
                cmp r12,0
            jne multiplication_1024_addition_loop
            mov rax,0
            popf
            add r10,128
            add r9,128
            sub r8, 8
        
        dec r11
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
    leave
    ret

;params : RAX,RBX : args (32q) , RCX : out, 33q
addition_2048:
    push rbp
    mov rbp, rsp
    push RAX
    push RBX
    push RCX
    push RDX
    push r8
    push r9
    push r10
    push r11
    add RAX, 248
    add RBX, 248
    add RCX, 256
    mov r11,rcx
    mov r8, 32
    clc
    pushf
    for_addition_2048:

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
    jne for_addition_2048
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
    leave
    ret

;params : RAX,RBX : args (16q) , RCX : out, 17q
addition_1024:
    push rbp
    mov rbp, rsp
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
    leave
    ret

;params RAX 16q RBX 16q RCX 16q : RCX <= RAX-RBX
;params : rax 16q in
;params : rbx 16q dest
copy_1024:
    push rbp
    mov rbp, rsp
    push RAX
    push RBX
    push RCX
    push RDX
    push R9
    push R10
    push R11
    push R12
    push R13

    ;can be optimized further by cancelling the last squares, will be investigated
    mov rcx, 16
    copy_1024_loop:
        mov rdx, [rax]
        mov [rbx], rdx
        add rax, 8
        add rbx, 8
    loop copy_1024_loop
    pop R13
    pop R12
    pop R11
    pop R10
    pop R9
    pop RDX
    pop RCX
    pop RBX
    pop RAX
    leave
    ret

substraction_1024:
    push rbp
    mov rbp, rsp
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
    leave
    ret 

print_hex_value_64:
    push rbp
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
    leave
    ret


print_hex_value_1024:
    push rbp
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
    leave
    ret

print_spacer:
    push rbp
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
    leave
    ret


print_hex_value_33Q:
    push rbp
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
    leave
    ret


prepare_hex_print_message_33Q:
    push rbp
    mov rbp, rsp

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
    leave
    ret


;RAX = addresse de l'entier sur 1024 bits a afficher
prepare_hex_print_message_1024:
    push rbp
    mov rbp, rsp

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
    leave
    ret

prepare_hex_print_message_64:
    push rbp
    mov rbp, rsp

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
    leave
    ret





section .data
debug_reg: dq 0
addition_tmp: dq 0
data0: dq 0x0000000000000000, 0x1111111111111111, 0x2222222222222222, 0x3333333333333333, 0x4444444444444444, 0x5555555555555555, 0x6666666666666666, 0x7777777777777777, 0x8888888888888888, 0x9999999999999999, 0xaaaaaaaaaaaaaaaa, 0xbbbbbbbbbbbbbbbb, 0xcccccccccccccccc, 0xdddddddddddddddd, 0xeeeeeeeeeeeeeeee, 0xffffffffffffffff
data1: dq 0x0000000000000000, 0x1111111111111111, 0x2222222222222222, 0x3333333333333333, 0x4444444444444444, 0x5555555555555555, 0x6666666666666666, 0x7777777777777777, 0x8888888888888888, 0x9999999999999999, 0xaaaaaaaaaaaaaaaa, 0xbbbbbbbbbbbbbbbb, 0xcccccccccccccccc, 0xdddddddddddddddd, 0xeeeeeeeeeeeeeeee, 0xffffffffffffffff
data2: dq 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF
data2b: dq 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF
data3: dq 0x0000000000000000, 0x0010000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000
data4: dq 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA
data5: dq 0x0000000000000000, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF
data6: dq 0x8000000000000000, 0x0 ,0x0, 0x0, 0x0,0x0 ,0x0, 0x0, 0x0,0x0 ,0x0, 0x0, 0x0,0x0 ,0x0, 0x0
data7: dq 0x0000000000000000, 0xAAAAAAAAAAAAAAAF, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA
spacer: db 10
section .bss
square_and_multiply_1024_tmp_multiply: resq 16
square_and_multiply_1024_multiply: resq 16
square_and_multiply_1024_tmp_square: resq 16
square_and_multiply_1024_square: resq 16


multiplication_1024_modulaire_tmp_S: resq(33)
multiplication_1024_modulaire_tmp_S_mod: resq(16)
multiplication_1024_modulaire_tmp_T: resq(33)
multiplication_1024_modulaire_tmp_TxN: resq(33)
multiplication_1024_modulaire_tmp_M: resq(33)
multiplication_1024_modulaire_tmp_U: resq(17)
tmp_print_64: resq(1)
addition_out: resq(17)
multiplication_out: resq 33
multiplication_tmp_result: resq 17
addition_modulaire_1024_tmp: resq 17
hex_print_message_1024: resb(259)
hex_print_message_33Q: resb(531)
hex_print_message_64: resb(19)


var1: resq 16
.end:


