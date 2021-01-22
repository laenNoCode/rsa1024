[bits 64]

section .text
global _start
 _start:               ; ELF entry point


mov r9,100
mov r10,toCypher
cypher_all_loop:
    mov rax, r10
    mov rbx, crypt_c
    mov rcx, decrypt_d
    mov rdx, cypher_out
    mov r8, decypher_out_normal_space
    call cypher_and_decypher_message
    add r10,8*16
    dec r9
    cmp r9,0
jne cypher_all_loop





;mov RAX, RCX
;call print_hex_value_33Q
mov rax, 60            ; sys_exit
mov rdi, 0             ; 0
syscall

;cyphers and decyphers a message, giving as output both the cyphered message and the deciphered message
;params : Rax = message
;params : Rbx = cypher key
;params : Rcx = decypher key
;params : Rdx = cypher out (montgomery space)
;params : R8 = decyphered message
cypher_and_decypher_message:
    push rbp
    mov rbp, rsp
    push RAX
    push r9

    mov r9, rax
    lea rax, cypher_montgomery_in
    push rax
    lea rax, var_r
    push rax
    lea rax, var_v
    push rax
    lea rax, var_n
    push rax
    mov rax, r9
    push rax
    lea rax, var_rrn_montgomery
    push rax
    call multiplication_1024_modulaire
    pop rax
    pop rax
    pop rax
    pop rax
    pop rax
    pop rax



    mov rax, Rdx
    push rax
    lea rax, var_r
    push rax
    lea rax, var_v
    push rax
    lea rax, var_n
    push rax
    mov rax, Rbx
    push rax
    mov rax, cypher_montgomery_in
    push rax
    call square_and_multiply_1024
    pop rax
    pop rax
    pop rax
    pop rax
    pop rax
    pop rax


    lea rax, decypher_out
    push rax
    lea rax, var_r
    push rax
    lea rax, var_v
    push rax
    lea rax, var_n
    push rax
    mov rax, Rcx
    push rax
    mov rax, Rdx
    push rax
    call square_and_multiply_1024
    pop rax
    pop rax
    pop rax
    pop rax
    pop rax
    pop rax


    mov rax, R8
    push rax
    lea rax, var_r
    push rax
    lea rax, var_v
    push rax
    lea rax, var_n
    push rax
    lea rax, square_and_multiply_1024_one
    push rax
    lea rax, decypher_out
    push rax
    call multiplication_1024_modulaire
    pop rax
    pop rax
    pop rax
    pop rax
    pop rax
    pop rax

    ; end of function
    pop r9
    pop rax
    leave
    ret

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
    mov rax, [rbp + 2 * 8]
    lea rbx, square_and_multiply_1024_square
    call copy_1024

    lea rax, square_and_multiply_1024_multiply
    push rax
    mov rax, [rbp + 6 * 8]
    push rax
    mov rax, [rbp + 5 * 8]
    push rax
    mov rax, [rbp+4*8]
    push rax
    lea rax, square_and_multiply_1024_one;j
    push rax
    lea rax, var_rrn_montgomery;i
    push rax
    call multiplication_1024_modulaire
    pop rax
    pop rax
    pop rax
    pop rax
    pop rax
    pop rax

    mov r8, [rbp+3*8]
    mov r9, 16
    mov r10, [r8]
    cmp r10,0
    jne start_square_and_multiply_process
    determine_number_blocks:
        dec r9
        add r8,8
        mov r10, [r8]
        cmp r10,0
        je determine_number_blocks
    start_square_and_multiply_process:
    mov r8,[rbp + 3 * 8]
    add r8, 15*8
    
    mov r15, 0
    square_and_multiply_1024_multiply_blocks_loop:
        mov r10, 64
        mov r11,[r8]
        
        square_and_multiply_1024_multiply_current_block_loop:
            add r15, 1
            mov r12, 0x01
            and r12, r11
            cmp r12, 0
            je  square_and_multiply_1024_square_op
            lea rax, square_and_multiply_1024_tmp_multiply
            push rax
            mov rax, [rbp + 6 * 8]
            push rax
            mov rax, [rbp + 5 * 8]
            push rax
            mov rax, [rbp+4*8]
            push rax
            lea rax, square_and_multiply_1024_square;j
            push rax
            lea rax, square_and_multiply_1024_multiply;i
            push rax
            call multiplication_1024_modulaire
            pop rax
            pop rax
            pop rax
            pop rax
            pop rax
            pop rax

            lea rax, square_and_multiply_1024_tmp_multiply
            lea rbx, square_and_multiply_1024_multiply
            call copy_1024
            square_and_multiply_1024_square_op:
            lea rax, square_and_multiply_1024_tmp_square
            push rax
            mov rax, [rbp + 6 * 8]
            push rax
            mov rax, [rbp + 5 * 8]
            push rax
            mov rax, [rbp+4*8]
            push rax
            lea rax, square_and_multiply_1024_square;j
            push rax
            lea rax, square_and_multiply_1024_square;i
            push rax
            call multiplication_1024_modulaire
            pop rax
            pop rax
            pop rax
            pop rax
            pop rax
            pop rax

            lea rax, square_and_multiply_1024_tmp_square
            lea rbx, square_and_multiply_1024_square
            call copy_1024

            shr r11,1
            dec r10
            cmp r10,0
        jne square_and_multiply_1024_multiply_current_block_loop
        sub r8,8
        dec r9
        cmp r9,0
    jne square_and_multiply_1024_multiply_blocks_loop
    lea rax, square_and_multiply_1024_multiply
    mov rbx, [rbp + 7 * 8]
    call copy_1024
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
;Montgomery multiplication
multiplication_1024_modulaire:
    push rbp
    mov rbp, rsp
    push RAX
    push RBX
    push RCX
    push RDX
    push r8
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
    call copy_1024
    
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
    lea rbx, multiplication_1024_modulaire_tmp_S + 8
    lea rcx, multiplication_1024_modulaire_tmp_M
    call addition_2048


    lea rax, multiplication_1024_modulaire_tmp_M
    mov rbx, [rbp +6*8];R
    lea rcx, multiplication_1024_modulaire_tmp_U
    call div_r_2048


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
    pop r8
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
    push rbp ; base de la pile précédente
    mov rbp, rsp ;on met la base de la nouvelle pile au dessus de la pile précédente
    push RAX
    push RBX
    push RCX
    push RDX
    push r8
    push r9
    push r10
    push r11
    add RAX, 120; on se place sur le dernier bloc (120 = 8*15)
    add RBX, 120; on se place sur le dernier bloc (120 = 8*15)
    add RCX, 128; on se place sur le dernier bloc (128 = 8*16)
    mov r11,rcx; on stocke l'adresse de retour dans r11
    mov r8, 16;variable de boucle 
    ;doit etre remplace par 16 occurences du code de for_addition_1024
    clc;on set la carry a 0
    pushf; on stocke la carry(0) sur la pile
    for_addition_1024:
        mov R9, [RAX]; on récupère la valeur du bloc actuel de A
        mov R10, [RBX]; on récupère la valeur du bloc actuel de B
        popf; on restore la carry
        ADC R9,R10; R9 <= R9 + R10 + carry
        pushf;on sauvegarde la carry
        mov [R11], R9; on stocke le résultat dans le bloc de retour
        SUB RAX, 8;on se décale pour l'addition suivante
        SUB RBX, 8
        SUB R11, 8
        dec r8; R8 = R8 - 1
        cmp r8,0 ; R8 == 0?
    jne for_addition_1024;si non, on recommence la boucle
    
    mov R9,0; on propage la dernière carry 
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
    leave ;restore la pile précédente
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
data2: dq 0x0fffffffffffffff, 0xffff0fffffffffff, 0xffffffffffffffff, 0xffffffffffffffff, 0xffffffffffffffff, 0xffffffffffffffff, 0xffffffffffffffff, 0xffffffffffffffff, 0xffffffffffffffff, 0xffffffffffffffff, 0xffffffffffffffff, 0xffffffffffffffff, 0xffffffffffffffff, 0xffffffffffffffff, 0xffffffffffffffff, 0xffffffffffffffff
data2b: dq 0x0FFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF
data3: dq 0x0000000000000000, 0x0010000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000
data4: dq 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA
data5: dq 0x0000000000000000, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF
data6: dq 0x8000000000000000, 0x0 ,0x0, 0x0, 0x0,0x0 ,0x0, 0x0, 0x0,0x0 ,0x0, 0x0, 0x0,0x0 ,0x0, 0x0
data7: dq 0x0000000000000000, 0xAAAAAAAAAAAAAAAF, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA, 0xAAAAAAAAAAAAAAAA
toCypher: dq 0xCF945FAAFF15678A, 0x185A72578CD7E669, 0xF83EA98760764035, 0x9E723A6D05727F22, 0x26C43E1BF371A1C2, 0x8F998AFBFD8A624F, 0x83E5D139D714B110, 0x3D003AAD0FA22B1F, 0x5A96764C31DBAEBE, 0x370285A0211F1E7F, 0xE59A1E47A0CB3076, 0x4AE22A9A84C3E54F, 0xAFAC75C9E795BEFC, 0x053047A1DCBB137F, 0x8FF3651FC548B03B, 0xBB345CAC1922F4BC, 0xA0D51883F2D2DF13, 0x054483D00EFBD674, 0x896B2D5F8253C920, 0x2DE75169FCDC75B8, 0xFCB8129D423C879D, 0x20EC7932879B745D, 0x5EE7C1BD5F026747, 0x51A05AA1E256AA54, 0xC5AFDF6554C215F3, 0x370600AFDA8289FB, 0x2CE5C0FDA9B7E0AC, 0x8DBC85082A9F30F3, 0x795CED76EB0122B5, 0xA97F6646F4E8D730, 0xFCD972D9296635DD, 0xBF7E21BFE655CC42, 0xA5DD92741F0F61CA, 0x52AA74E5CF68C3D1, 0x192B9C7DBD5C86A5, 0xF0B27BDBB1B423EB, 0x66DAC2040CBDE1D5, 0x59E49EAF52BD7AB4, 0x6C6C9917EF5F6DAC, 0xAE1C6EB6BD90E4CB, 0x256B5F0DCF285A59, 0xD35291E7C09C882E, 0xC3E070B645E027C4, 0x42A10667ABA24FED, 0xF2AB949A5590A7A8, 0x31AE8FD86F204847, 0xAD21EDA21B373DAB, 0xD7341A759F9C583E, 0xA8FA2C4A307035B8, 0x58AA2180E6F8C051, 0xB0BB3B82C9DCFBEA, 0x3C241CBEE2E9FF74, 0x3F135C4916B5C03B, 0xAA6531301A31E03E, 0xDE5BD4962F97EA7C, 0x8C83FD261A04234E, 0xB26BC4189972073E, 0x196E1E59512D2E84, 0x7C7B0ADA76A909EB, 0x79C434F3FC59EAAC, 0xCB37A1E82161ABCC, 0x5B58C76881059F3F, 0x7D335EE9600E0F2B, 0x6515D08401843872, 0x70F43D6DCB806930, 0x8E284B303118249F, 0xAD8FCEAE3A3509A8, 0x42CE5BD8547DE312, 0xEC25476162D94B6B, 0x82CED51ED500B3D5, 0xF41D642398ED1FDC, 0x0AC5797EBDDA5271, 0x7A7442BB71F6BB5D, 0x857CDEEBC9F51460, 0x99F284AFB01C9FEF, 0x07F32BEC214138D0, 0x9F1A662278CECA2F, 0x66E527E5754A1306, 0x6C5030F631C1B965, 0x75F28DE44F2B351F, 0xD049C53E482F3615, 0x195A4CFC205875DD, 0x7F81CB2CA974BFFD, 0x0575B796BD2DEF26, 0x98A245A07222F901, 0xD7873C69EBF14C13, 0xBBC1C8272B56B8FC, 0xCA6C6A283E7BEBE3, 0xB05C46CC61F79B3B, 0x4ACA36EC36E915D1, 0x87597ECC19513C30, 0x21CA5E3EE19E3641, 0x35A3BEB6928C1CC7, 0x5EA110E073BC6E4C, 0xD0D29CC7F5291E20, 0xCD31E88214CDFA3C, 0xC715A5AD79007C1D, 0xBCEA4784B872C75D, 0x026E2D628A3BA52E, 0x22E25B347852CAA3, 0xFE46227C52424064, 0x8A7F686071C3C9F6, 0xA5FB0039931BD64A, 0xAFBF96143CEA11BE, 0x66C95D6390784945, 0x5C86F7DEB9994F82, 0x6F98BEE19D801F5F, 0xA74225BEC938CC47, 0xDCD392C93DBFCAC4, 0x734BF69D1FC65023, 0x8E0DE4178C23B278, 0x00A1DE4A2D7FC966, 0xB4D8ED2B5BF3F321, 0x3FC17472DED93DBF, 0x6E01919B8F1CB4EF, 0x23120EFF04F4D923, 0x42A3FBE14AB62947, 0xCB57F973A35646A6, 0x0AFF15A3E811EDF4, 0x57F99E6FC8689DC9, 0xAF4F2091B9BAEEFD, 0xBD290855B06D9212, 0x3770D358A2BE6531, 0xEA234CC9B7262385, 0x534198CC6452432C, 0xE02C316E1AC08C88, 0x5F33136CFBB537DC, 0x353E16D4629AE763, 0xACFF90A1051AB5B4, 0x1FE2EC3F4EC32102, 0x770ADF6F2B000121, 0x43B0AEF2082F77A5, 0xCCDC6A68C5A34B22, 0xED4E5559EF344630, 0xD239B9B51B2A5CE4, 0xDFD51A6FE4436726, 0xD268C6E7D1F3B1DA, 0x490313C96ADFDCDD, 0xD9847AAD1EDC62D3, 0x7CCEA5908303E9EC, 0xB86111EACED635F3, 0x7B305B26CB3F0BEC, 0x1F5F81AD4799B485, 0xEC037229A91548E2, 0xE98BF98DF82D2D43, 0xAC5A68A5538FA7AA, 0xF325FA62FEB038E4, 0x2BAE5DF3A7A23ED5, 0xFC886C2E5CB7B1C9, 0xC8FAAD420C657706, 0x736F0EC23810421C, 0x97C43E3998B88FD8, 0xA4D2476D505FB208, 0x5A08F067BC8E6A3E, 0xC23AC71A7FDFF41C, 0x53B5466BE4C7CFBB, 0xFC3646E936D1E2A9, 0xA9F88DABE8BB85AF, 0x1C59A18004BFC5A3, 0x2212AAC9EDCF1857, 0xE7CA487EE487E314, 0x1D74D49685787962, 0x045F468D35DD744E, 0x8F5753E659335E53, 0xF3FCF8DD5C7553E8, 0x8E8ECE9B54BD3902, 0x2880209847FAEFB7, 0x566264E4A0E66E79, 0xAAE52BC61E5112B9, 0x5C248C1A5A31E096, 0x7100B7B9A4FCB236, 0x5A4DA3FE30103AEF, 0xAB1BA7A9BE927E8F, 0x42EB6DDABB3488C6, 0x796C806CA785164E, 0xF3DD00FFB1BA37A5, 0x36743EB118E581D3, 0x067309EF6CA5BC5E, 0xDF7AF7A130748F7F, 0x959F4647FF07DDAC, 0x8D0AAF5AA2E294A9, 0xF0CEBE145A8CABF3, 0xD54E4228104491A5, 0x42C296C8B0A5CCEB, 0xA7E9E4A032E52C26, 0x488DA27B9BCF6DBE, 0x1274548514503AD5, 0x9F25F7F5349E8281, 0x090F82208DE69FAF, 0x972FE22E5F07CC05, 0x158F3273225DA9E8, 0x19730C8F94FD8155, 0xB42624E6053CD878, 0xDBF1940014ED20A3, 0x3D5A184060C95335, 0xF66A6066CE675AC9, 0x7F66CA01DBAAA71A, 0xD03DA5696C886925, 0x22AE64B6CB6FA41A, 0x656CA5B315BCDDF3, 0x771C0BBF4620A731, 0x9528E4E2B45D037C, 0x984F5FBFFFFCE1AE, 0x7B88B195B257BDFF, 0xF66C2C67BC478514, 0xFC45C6253EC55907, 0xBF056A3059C6B64C, 0xC9A17BD0BE0C5C78, 0x6AE2F786B223888F, 0x1BB3F376286344B2, 0xE75C5B943190660F, 0x0D7571D1B9CB3A2A, 0x8778E546361C82B4, 0xBCE80B33434F4566, 0x83814B0616A3A20D, 0x96BA6D0AB6B04D5A, 0x410B72105B294906, 0x0BB5307CF3665BEB, 0x38AF46B9227C0F55, 0x502C8669C603A077, 0x3D5E34349501F0EC, 0xED45D1DA306AB4DB, 0x4A7D6F3763AE4C4F, 0x22E8D00EFE1897F4, 0x66BEA3423B80FA6A, 0x3CEB20217D8A40F8, 0x29C911096FB8F9C4, 0x99688EEDB9D83E49, 0x5B598D03B266B4FA, 0xA5A530DC0B279AFF, 0xF9DDA7244A4475AB, 0xA0874139FEE77FDA, 0x9C6FBB078BF0353F, 0xA27C3C228FFFC516, 0xDDF3FCD391CD9B5D, 0xB29B941AF1EE11B0, 0xCE3F1D24C87DD20F, 0xE205F75E229074B5, 0xBC213B0A49B47A07, 0xF10A8D41AAE45053, 0x8EC365D54FDF0B82, 0x9094146783635768, 0x0801154A3310369F, 0xDFC33232BD690FA2, 0x8383808C93D2CEF2, 0x91292809E1F068D5, 0x9CE4DC5DE033EFBA, 0xE69D469DF7DB2B32, 0x7AB6717AB7169C70, 0xEDB12429D08BABE3, 0xF8BD6EDD41DE991B, 0x6F54E3F7492EC2B5, 0x27FFAD7E45E7D0B2, 0xCAF2B4B130322EDE, 0xBC3BAF226DD3C9EE, 0x4C108B5342658A8D, 0x34548279DFD0FA89, 0xE9E08FF46B2ADAAB, 0x052937DF970F3B29, 0x5AAEA795F8C6F58C, 0xB2B288C9B9FD9FD5, 0x975590F18302C61F, 0x9D945B9557520707, 0x2F87CDC3FC11F264, 0x2C393FFDE0D3C6B0, 0xA827F1F04C50F487, 0x05095E3463C26A26, 0x1E8EB402BC2CA7D2, 0x41048C6F97339AC3, 0x9870D6A62AE1BA3B, 0x5B4E7ED083CDAD49, 0x365D80552B0EDBEE, 0x6D5D6A5AF4CFB6EA, 0x9F3113CC27513934, 0x9D844D6B82BFBD49, 0x61F212558939ED1A, 0xA11FD6C46AAFD7C8, 0x6CE174079C6FE7C1, 0x6BAA3D4A9DE74049, 0x70C420A7923A7F7D, 0x1EDF5BD1307AE4A6, 0xACFCC765AAC2B62A, 0x93CB39F76BE37E73, 0xE659FD94A4702D6B, 0xF13418622C6DBEB0, 0x93FE70B96D75DEC1, 0x034213E45EEE6EB9, 0x9744ACA732AA5AC5, 0x539FD7369B15FD83, 0x1ECBD98809EF0E60, 0x56D749C06B623CCC, 0x7C05C2E4EC583850, 0x71FD3B381C0E6D62, 0x17C4EA7274395A5C, 0x006B58C3563859BC, 0xFD5298C590A764C8, 0x73A19BF9F1E9BBD4, 0x260DC8830EC58B49, 0xBA5B03BC4DBE4851, 0xF5C9CA0760FC63F6, 0x79A624D5245B0059, 0x3F86CB50408BC221, 0x0C04EE2576B435BB, 0x964DD153A05D4BEC, 0xFD88E41254446D63, 0xCF87B82F543B1972, 0xB09E76EE1FB70FDB, 0x9CD5160C88065AE6, 0xE85E12F2BEE40322, 0xC8140385D7EDA360, 0xC7714FFA6FB3C99B, 0x9F60F6ED517AC4DC, 0x33E7C2470BB46FC2, 0x2F6DD20DDE6CC9A9, 0x595E6FCC641A7FA9, 0x5419C55152DF24AF, 0x55B5A07B066D116B, 0xDA0EA29217D66CBA, 0xD3AEF866D55B8907, 0x2DB12CE6D6596934, 0xA7CBB24B3125CA8D, 0x4B9ED2EEB5FA5466, 0x424948443ED5BE0E, 0xDA7715939BBDD1E4, 0x24C54BCD1DCF7879, 0x3917692FB71E6BB7, 0xCC10D3F15EF1E8A4, 0x0508073ACE7B7FAD, 0x884D2C3082E63DE8, 0x310E1C22F539C801, 0x452ED4AA4B40F55A, 0xCD6DF5D3639B141A, 0x3C6AEA6EEF21B37B, 0x8F691DC59E629F09, 0x7EF7F8EAB773B068, 0x731B588D0B6CF55D, 0x0CE7303178D8DF33, 0x981DDB818DD9B03F, 0x1B5224A1C4D97235, 0x288C051A04BBC6B9, 0x8C45DDCFF17C37BB, 0x6F42DD35EBFB3945, 0xC239266606EA1EEA, 0x1BA5D9B8D4E88552, 0xD0D22E2D1FFB7E11, 0xA192BDFEFBA1141C, 0x196FA734843D9C61, 0x3A08D6584A45DE60, 0xB2D36384B8011DEF, 0x0BB4B0EC24CFA3A4, 0x2454334D052E32EB, 0x23FB4A2EA22C68AD, 0x8C7898AD61C2194E, 0x7C3700F063802F43, 0xDDFD30716685EB0C, 0xEE6D52400BDA9E4E, 0xF08F80758E23E7AB, 0xDA01C876E2D89189, 0x079BB75A06DC7F47, 0x57CB2A9A2077324E, 0x3DB302BB24D99D61, 0x5513BBEA9B3B187B, 0xC5C4D1A8D60EBCCC, 0x8DE019BFA64D730C, 0x0DA821FC24DFB6CD, 0x2CC45DED739B88FF, 0x7FD1BE83016207EB, 0xB163B7877FF8F7AC, 0xB3654E7B6A72BB69, 0x18531D48D390C249, 0xD0D5AE9C7C5CF8CD, 0x73CB2F67246C0661, 0xC3BF79A0B9EFA0B7, 0x1402829F18D2621C, 0x7A1D49A152EEDCFD, 0xF0697D907494B64B, 0x36B458D639375A75, 0x9DED5E1F53A884C8, 0x83C62B7DEA356FA0, 0x7FAED0628475DAD5, 0x71AFEE8A652AC584, 0x7F3C8D914EBD49C8, 0x7D37F4CFB97CFCCF, 0x551A5173B32B57E1, 0xA60FA8534055AF9A, 0xC9BBD7E332F1F925, 0x8EB3E8A48EBB31DA, 0x67DED40A4995499F, 0x5F614BD72ACA9526, 0x78D17BCE6AFD88DF, 0xCAA49525E74292B7, 0x1F57963D473FEA47, 0x05DDE3C1DEC99945, 0x8FFB09C7644843D0, 0x5015DD9C1339C7C3, 0x7E2B6760D06126F9, 0x9787256FA6963288, 0x04B3932E718CB0C8, 0x1C48D27C7B112122, 0xF0E94F2A4D4F837C, 0xDD76098DE992A290, 0x4A1D22819170004D, 0xFC6F9A75AD3357FC, 0x2C059E29546F1EAC, 0x3DFCF2B21DEED64D, 0x3FF7B70FF88D1648, 0xFB4E52D717298E6D, 0x68F56D12B7F73FEE, 0x200CCC360D0126CA, 0xC2467CB173296EC8, 0x4E4E452E4AFF8B6A, 0x4B729375B8DE2423, 0x119F2E53C0D3FB78, 0x30A29BFB0D243919, 0x3D78D37E1B1C70BD, 0x3045968EA6FFFC90, 0x307D5CDD23BF4E4E, 0x53339AA016700E90, 0x1F47A538A9949FA7, 0x99D7A3BC650F35D5, 0xE26FC593958278A9, 0x8C3E7FA99D70F0D5, 0xB450001DB2929B92, 0x08F29F78D1141C10, 0x8A3A14B3E7961D37, 0xF4635B8A83DCC76F, 0x0D88E9E593725ED7, 0x7D9C7744E13C8683, 0x82604BBADF3B39E6, 0x65B771F9E027F7CD, 0x837A825254555F01, 0xBD52E76EDB6951BD, 0x01A530F9F0A16BBA, 0xA9421835A8B2A27A, 0xF88EDD22DA419367, 0x783C285150D6ABC6, 0x51D4C2EAAD952706, 0x44D4B78DBA40455C, 0x48AA60D1344CB923, 0x1D38B0AA812D6431, 0x5F26A7FD491C2DFA, 0xD12B2D8BB2DCC006, 0x0A8520ABFA4A1545, 0xC431881EAEC8569F, 0x1246F6D1AC1A3CB6, 0xB3756AB4DEFE9C17, 0x34B6AD9B9703E4E3, 0x295F52222A8C27F4, 0x0C0483DD9B55D980, 0xE6C06081D15C80FA, 0xA7A6FC784AB52A22, 0x05D6D46A1D9E26D4, 0x8B1A4815A2E2455C, 0x356F6E7547160260, 0xF2CEB6136591EEEC, 0xEC4E85308FC2B56D, 0x5531CF8695396AB8, 0xBB80A6EA6F9A7A68, 0x5781B3FA356E1BF3, 0xB4860A40227F8CA9, 0x014D2B80C14ACC74, 0x25A1CECED08E0E2A, 0xDB23BAA065AE5196, 0xBBEF425148185930, 0x588674F1F7A47787, 0xDADD5B25D2049BD1, 0x3E38CDA2033B4C0A, 0x30E5F95915F8709A, 0x2452DD352BCF1A1F, 0x06126BA35D0F9E99, 0x313089262D27C324, 0xC83F65984C6D3416, 0x3DA05ADF325E05BA, 0x290D725F69F172FE, 0x51661E03BCAF5FF8, 0xB58A3818ABC4801B, 0x32265238BE69E88E, 0xBA99761AFAC9B1E0, 0x95BBAF35CB0A59AB, 0xB1C4105EB48B2367, 0x8E3D17AB86CEFCDA, 0xFB768E5C67C6B153, 0x7075B90B53A6CA34, 0xAEF8C19A4DD2653E, 0x9A0B852629FADA2A, 0x7B3CEC65D434378F, 0x0AFE39ADBA8B949C, 0x897E5BA301E9B5B5, 0x6833F1CE3EAB4469, 0xFBB226F1F4793D6C, 0xF126032A782833FA, 0x84753AE9462D1788, 0xABFB58B1ECBD3974, 0x46B2CC2F9BAFF1EE, 0x7CF8C3A5801EB56B, 0x7E6D328B631A34A2, 0x1EFFE74F02CB1A01, 0xE6B4B3D189C195D9, 0x6E1E9D08C6980606, 0x4B2D916CE9C6B46C, 0x267905CF36150390, 0xF4BFF3455DBF1A3F, 0x1032CFDCA03B86C9, 0x5953410E74C0D90A, 0x1726268F2D7FF335, 0xEC895F77879EBB7A, 0x268156F3475C2A71, 0xD6D955E9D75D599E, 0x5C75640C5FA5AD16, 0x7FD54DD723E54BAD, 0xA0193FA66844E124, 0xF5CC4E8FB8ABCF71, 0xBB36C5D0D2DFAA50, 0x482C35B28EC4E110, 0x4F851262D98D7959, 0x9BDF965F5E1E9A20, 0x6496C73047752D03, 0x7EECCCD99F2514FC, 0xE8C0B5BB22E548DF, 0x284AFDFF3B5AB782, 0x102CDF53275138EC, 0x23B4E46C643474FE, 0xE1351E8F55E93D13, 0xC8EA4B408F4A8A4C, 0x126E1CC86ECF6A34, 0x178E3A59EC42817F, 0xBA5AAEEE2D47685A, 0x1594BEEB4EF57456, 0x722018C59FC2A908, 0x483D4F36DA6F6090, 0x8F2AA455606BC5BD, 0x93ABF6E0D3F6E11B, 0x356F7CA8603B1A13, 0x34D00D7B6022B8F2, 0xF9FABA29935709AD, 0xD8EA07741D6CE75C, 0x4C98A411E2F2AC5D, 0x9E1B82573E3A7E26, 0x71DBEAA6B5D03A9A, 0xE7B9741511463C0F, 0x8F9724DF428A2B55, 0x49AE6AFB7DF348ED, 0x4770605300CFE3E4, 0x85AC15D0F194CB71, 0x62DE58E80724E671, 0x7BA0E059F87E5C31, 0x3A7B637E0599F01C, 0x74F2E6A31C064BDD, 0x8E32B91575593008, 0x70D4F404C45F909C, 0x07ECAE48C6BD2316, 0x3BC420EE0D5B501C, 0x099341513D60C477, 0x6B6FB64215578668, 0xCC1543E2A88554FA, 0x0FE9905034146F42, 0x83042D7DD35B8EF3, 0x9FC59AA33DF26C74, 0x8CC8209FEBD42B75, 0x4C00F77601C10034, 0xBF0B1969B4849F79, 0x3A201B8A1AB98935, 0xF0D416977C7D6B86, 0xBFB94D085122D8A6, 0xEB6C9A6C53BAD0C0, 0x999A46468B1D9905, 0xEA871BEB5F24B0C3, 0xEEAFC91486AF9287, 0x7EBDF77856DDC393, 0xEC119FF281262676, 0xBCB70E3026AC862C, 0xA4DD692BEBAE91AD, 0x7FF89D3977EC42D6, 0x4841CB3606AF7DAD, 0xF42E0DE02DE3863E, 0x885620A64F305560, 0x03B9F6165D610FB4, 0xFAAF607BE83FABA3, 0xF2BACEC1953EA632, 0x24CE0CAFBDED3309, 0x0A0BBCAA8D048CED, 0x68AA73C9ED3DDF8D, 0x94C24C5214215C02, 0x8A42E8A496931E7D, 0x8E82976A7BE668E5, 0x8597EB7E0F913297, 0xF4323A6502959130, 0x57EA74075D4F247E, 0xC6E63189B9FAD573, 0x9BC4ABAC7C6B364B, 0xA941DD1D38D3463D, 0xE654322B771A02F4, 0x5C73C83259E39153, 0x64BB3141C6BCEB63, 0x6200184472833218, 0x07F57688D0E610C6, 0x70DE445D2507FDEF, 0x66965CD85ABDFC7F, 0xCFFE8E404088A0EA, 0xCC68FF686DE1F6C6, 0x49959C424331C1F6, 0x7225613FD873F99E, 0xFC67EEA7747996E9, 0x608759C1DCAB17AF, 0xA5E2E691007753E3, 0xA97E14A9B3E8AD9E, 0xBB2D5F0383EB5136, 0x8B278D958F7C132A, 0x9779E76BBE05F950, 0x2E77CC0212601677, 0x22552A01997DC079, 0xE8AE463C4A900938, 0x729A816DE6C9BAE8, 0x11DE6067A4578140, 0x21792B19AADFBD90, 0xF2393B30B12586DE, 0xFF3558CAD29D9F55, 0x9F20209A2D7BC6EE, 0x8F640D97436AD99B, 0xE3972FD78D4FB9EA, 0x3299F9C477C1788A, 0x0F9305EF3B91E1B3, 0x946B7BCBFC351D6A, 0xC8B04309242D34A1, 0x42131C3A7835A00B, 0xE790A188131F66E3, 0x1D55FB10DD1721DD, 0x9B46027972361236, 0xA1B46AF2333FB05D, 0x86206E7EC2927EB9, 0x2A99C4E6036A01FC, 0x0712829C378C3876, 0x189A4C09241DFDB2, 0x3486C111D4BBECD3, 0xD9516AB6F1B4C1C4, 0x23B5A2073E681957, 0xDC959CCC3BD236FD, 0x2B5533DB27B85709, 0xBF80CE060B293299, 0x4F87F5BA8A03751A, 0x57F7B12E8E1719C5, 0x1DB65DD8019F0041, 0x35BC4198B9BC32F5, 0x90EFD15DB1D8B8C5, 0x4EF414900C6AE951, 0xFEDA3559CFF61234, 0x46823ABA4DD246D6, 0x9AA5E94188F24FEC, 0x00A30C5A9E7ADA49, 0xD14C21AC842B8D9C, 0xEDFC0DCB21108C7D, 0x0812314579DE8FE7, 0x2AA0B27654BC8273, 0x17A14875B074795C, 0xEA82589ECD7B8B60, 0x7D09CEA07EE5422E, 0xD775E904E711B786, 0xDB72421FB9AE4E52, 0x43335CB9D0C8F659, 0x9AA99FFDCC9DDAC7, 0x368F8BC11009E83E, 0xB19C41D7D133772D, 0x5A1037D47DAC9CA1, 0x92F30E97F36891FB, 0xF6275FA73D7E26CB, 0xD694D46395C92BD2, 0xEC6FD8E6AE3A8042, 0xB172C5F4DA020022, 0x7A2C7B068F799958, 0x13320397AAB296EE, 0x7A3C9D9663BDBFCA, 0x68AB663F4D83D81D, 0x59559FBB8A113123, 0x540683CF3969F7E1, 0xB87E04A98BC3AE67, 0x529C539EAA068805, 0xC038E9AE665FEA31, 0x41FFAF5C3F714E22, 0xAD47CD9D4F127DF0, 0xCB82728BD53C4928, 0x846757326D78B13A, 0x79D1A8842E065F94, 0x2F6628A885925204, 0x8DA58DC7E2DB5C1F, 0x98E55166E0CB6968, 0xCCE122F16ADAE468, 0x704B563BA665BEEA, 0xDCF4E0B2F078ABCB, 0x249B382597F527B9, 0xF0433438F73B1CEE, 0x613CF321143B17C6, 0xD9EF075CB7561ABB, 0xA82ADC94B8809D60, 0x3AE48839A10D9F91, 0x5774273325ACB63D, 0x3E09A7DCC651DFA2, 0x1FFFEB33C13FA7CC, 0x070DA60A3F7AD279, 0x7063F60B061429CB, 0x085E4B8FAEA89340, 0xEF204C26C2AD3BEB, 0x9AE5FA1C6F99CDE6, 0xCCD351E222C7AB52, 0x9E2C842E3D4D000E, 0xF3A2E14B9686E6D1, 0x2089B548F45488BB, 0x914E189C3688311A, 0xBE7B28D0B1C1358E, 0x2B92C17D7214BA47, 0xDBA7353D4CDC1346, 0x24B5F1CC1B495B7B, 0x245D2F814A59AE03, 0xEB09E4756D86F213, 0x7A6B075CD050A2E2, 0x771D3AA9B95FE808, 0x92A63A3D282CA2B3, 0x376FA2E2745027CD, 0x539371367D9CCC1C, 0xC54283A6A940CF7D, 0x59C5E6509A142278, 0xA277EA6784CD8D07, 0x6E0DB6E6649EF46B, 0x1467E0867BF042A1, 0x9BE25F71FC2199B4, 0x4BB8E3755DAC25CB, 0x52312E1EC8E330A1, 0xE1926C57E4D1B585, 0x77B74E1746F627A4, 0xCFE35598E6891527, 0xCF5634AB85566B23, 0xA8EABD47E552CF80, 0x28685DF5A531CE72, 0x452F311E99DA810F, 0x06B57414F0F17F8B, 0x0AB1C29529FD545B, 0x0C33E82A7DAA9CB5, 0x2705B25FB5FDF8F6, 0x50A4A50233250557, 0x3D070F87388B7256, 0xE3422A81427D4FDA, 0x706348941609AFD4, 0x51C6F4ED12F1DEC6, 0x456E8CBB33CDC53B, 0xD235C1CA5BD50707, 0xA35CD77D3154F562, 0xA5796DE38CAE5C0E, 0x7B05C08F826D3675, 0x2D8A1FCC0BB7D7DF, 0x2D044A5765F2280A, 0x13D311C266F0CD55, 0xAE84347CBDF90562, 0xBFCADA04BFEC3614, 0x33CDE60697A6A761, 0x36E608D47BE15617, 0xA649B0C4C6745915, 0xEC6CDEB894EDF494, 0x67649832610C62FA, 0x9CC44A68B5AAFAAC, 0x1508F3D2BF090080, 0x3A736FACD1B0B3BA, 0x03DBD78A9C27724F, 0xB7EA3BF70B472B93, 0xF7FFFBDAD29D7932, 0xF68D87F7557832FE, 0x3C2EC246AD11EDDA, 0x6EE78FFD146BFA9B, 0x388EABE7C27C111F, 0xE04684918B556D5F, 0x28EC8D18491DD37D, 0x6C269B77436688C8, 0x1E84DD4AF6C35BF6, 0x1E6FB3B9C67197C2, 0x18065F5CA05E6B7C, 0xF7A04178104D9940, 0xB036413D67691745, 0x37C557995D687F1D, 0xC4E8409086179BCE, 0xBC3A9B4DAF50DF3E, 0xE12F179851C8B69C, 0x5BFCD3E180C81012, 0xEE82B78A599756EA, 0x40CFD91606568F5D, 0x2D85C6B95CFA0457, 0x9601405A98289238, 0xFC606A5EFAF18235, 0xCFEEC8A500FF10F8, 0xF0DFBC7F6A2B07B6, 0xC28100DCA4EF1015, 0xA2206EA44A714D19, 0x8DB8847CEC854AE6, 0x233F5AF3F28354E4, 0x268D9BC2629B4343, 0xDF1C2705477403C7, 0x8C3AC4A46CD4C7CC, 0x9047ED91CA4F0AAF, 0x6B2263EA102FABCC, 0xDFF23CE90116450E, 0x292AD5B6D3E86F22, 0xEF26CBC1043A6F78, 0xE5962D71D4E3DB31, 0x58C90A3115244D95, 0x39C545A0EDD62840, 0x631E5237CB9ABC05, 0x0CB22A5184E3B1BE, 0xA26D612BB2BF13D2, 0x352A704E6236E37B, 0x610838DE86A01607, 0x8D2B54A374F56158, 0x6B1D40D0015EACE6, 0xE62443175AB689C1, 0xC2EE1C6572C0393A, 0x69D7D45CD56D4734, 0x9FF5941C289BD3F6, 0x2187ACB21939731B, 0x85B474DE3AB324C8, 0xE1CCE95B1E4C801B, 0x95DF4134A733A409, 0x1B0FFD2EBE231D37, 0xE845818A4D497169, 0x4607C0132762B697, 0xC1FD9A5B882C102A, 0x34CC10FAA9122BC6, 0xBE845943BAC88F3D, 0x8B5CE6C59D2E1E37, 0xF4CC2288CBECA85D, 0x67DD6511E6897326, 0x43F8F56D911B2E62, 0xB5C0331103CA444C, 0xB844ACA367EC882A, 0xD7492C9893298E1A, 0xEB459EFD69C5DAFF, 0x4C46FE1E8A2A4C2C, 0xE48199782A6CBFBF, 0x43AEBA9FE52E0EFF, 0x393E83BF80CF95F5, 0x9101E57FE22331B9, 0x395B72BE43AC1528, 0xB489BDDA1300AA07, 0xF1559615A99E3CA9, 0x9DA0502AAF6D1014, 0x6563044B13ED1AA2, 0x9305C0B3B81EF5E8, 0x918220E9DC48FF34, 0xD7293FC413D82C88, 0xCBF410EC1CC3D79B, 0x28985037255D1E3E, 0x4F39A24C409D05D4, 0x478226800DC76906, 0x5D7815F72507A354, 0x7A0D047512C8ECBD, 0x0B6E736DFC09F8E7, 0x8710208034EA8109, 0xD327F5C1614BF32F, 0xD00E7166295FEBAC, 0x1E6D8320C817DA5C, 0x69412A8B5BD8EDF5, 0xDE9B1C1D9D310B7B, 0xEE8537D673151B8A, 0x98BAE166227593C3, 0xA4064E83985E4452, 0x2EC32B6BFB9374F3, 0x5439702B070ED383, 0x13F21D3F0B0E8EE3, 0xBB4F96503CFBD56D, 0x37C25521DF3ADDF7, 0xA4E7494D657BAA9F, 0x326EB6487FEB23CC, 0x93D703EE78A0C27D, 0xE8DFA205576CEEC6, 0x8B51E1A52FC1C638, 0x47D172721C63AAED, 0x9CCB25088DFD5461, 0x45B713852DE22CE4, 0xEF539920EF3632D7, 0x1CEB4F29DBC4FB78, 0x5179BA146A1FCB61, 0x41A4CB5E97CC4A4F, 0xCB23AD0A4FD0ECFB, 0x0B88B06DC07EFEFC, 0x70B1010DC203E7DE, 0xBFC014948A0C9221, 0x1564DFE4F23D5755, 0x089C50EC98FDFEFB, 0x1FC7011D0BD9A7A6, 0xD885C460797BC853, 0xF2D5CA816DCB2B20, 0x18B6FBD85E7EA0EA, 0x8D065A1455C772F5, 0x4641FBD5BC81F3E7, 0x5906D038BFACE83A, 0x411F0B57E452C40D, 0xF49338DCAF20C9CA, 0x755113340C868EB8, 0x5B29769A0FDE8FF9, 0x4EC7632E0FE8AFAC, 0xA742D68090A8CA81, 0x20F0411BDBAF1F43, 0xB8BAAA56EB9EB925, 0x787D233B8C205319, 0x581CC0E698085A32, 0x64DAFD1B71E71705, 0xD23BA928E1BB7B71, 0xDA8B2A6FCF71500F, 0x9089C38A00327658, 0x80A8A8F54ADB4808, 0x48D4B335CBACE75D, 0x2ABBF4405C5844EB, 0xBCB88499F7A84617, 0x6BE5077388012BED, 0xC20559302C922BED, 0xC19F15643A61E0D3, 0x63642FD2AED25495, 0x400CEC4A6B6AD0AB, 0x58613F986DCE96D0, 0xFD43C34C366534F6, 0xB61E80C5EFAE0A01, 0x28F2F8193F7226D9, 0x06BFE0584BBFA4FE, 0x627268A755433ABA, 0x5DFB67B8647DE0ED, 0x55F7526CA7AB00F7, 0xCF1D83DD271DA7C4, 0x7C2DE3B6FE180FA5, 0x8CD67CE8F4D316C7, 0xC090DD57479905B3, 0xA580F43AE47D9E9C, 0x7666D182C64B5F5D, 0xD7F54B0D0AC33A66, 0x05B60A05A6605C35, 0x9AD5859F1AC5546E, 0x7714B49B4A75534E, 0xBD1E3C35BC7BB30E, 0x7E48600325764132, 0x90D43D4ADF9E016B, 0xEF538878E4009ECF, 0x6C6330FBB5CF9656, 0x5912D4EBEE54A833, 0x08280C8347AC4DDD, 0x24E258AB7E3C13C0, 0xDA08814D44BF132A, 0x5F40E9909353D519, 0xE3F7C5A6A56BA8A4, 0x13A5A3FA68B2B077, 0x0ED8990585D34246, 0xDE4F78BAFC6943AE, 0xB25BF037CBE3A945, 0x7290EEDC1A390CB5, 0x5090006F898C673B, 0x0AB5AF4AE5B083C6, 0x9B99BF518F7DE4C2, 0x85B252CA4C745117, 0x5D98C38FFB5A94B7, 0x8B6DE627548B57F8, 0xD5ECECA8A35394CC, 0xE6E5AED7A8506B35, 0x461146ED20BA0FCC, 0x2FFD4594EC4C454E, 0x34964A120917BF59, 0x9C2B16E9F658B10A, 0x44C7194CD473A121, 0xDF70FD6E5D6158E5, 0xD398FD59E1578419, 0x83E5CCC84D6E6365, 0x834611F006959731, 0x86B21401886B1A7F, 0xF69EF3397C6762D6, 0x526AB11BE1E1E153, 0x4DA58733224E2796, 0xC4E59495A80D4501, 0xD4E7AFF811A4CB2F, 0xFC3FAB8843381D1D, 0x5C611572FAD0ADAA, 0x94FA16F46E2AA930, 0x2BD5B5413267F75E, 0x5531EC16012FD901, 0xED0BA2E0A72D5563, 0x87E6E5303131814A, 0x11C2D240A7F1CF72, 0x60360843DF1CCB69, 0xBAA89698EE45CFAB, 0x7AD51A49E7F4A5FF, 0x0E579D685C6CFA6B, 0xDD17A7ED6FE82FD7, 0x5F8985F151C5A23A, 0xC6C61BA2D8E228A7, 0xC9C5A7DD40DE1B36, 0x4DB53B12731B0C0D, 0xE7106672C519FB4D, 0x07205F63BE564305, 0x73154EF950568A25, 0xD3DAB33123482986, 0x4341410D4270953E, 0x4D4F039A76AEE7DB, 0xB4CE4B0BD9590305, 0x0D19893CAEDF0413, 0x2E3B50FAFA7C78E2, 0xDCF7084197652DB5, 0x9977E348E86605D5, 0x28518568A15FA76A, 0x2ADA4FF9D63536B0, 0x5293B66D53AA3D7E, 0x3C1D38AE252FFBAF, 0xF7AB8E07127B9C4F, 0x119A8C424D135A6C, 0x9543254571F56BE8, 0x2248E0566BCB6B4C, 0x3A2B73A64838A525, 0xD986A5AA0B1546EE, 0x7FE5E701B8ADB77D, 0xF3878821520A5F98, 0xBCC3BD5B8171056B, 0x66F1560BD2AD3257, 0x8FE295D526AFCBF5, 0x17BC66EE7D04897C, 0x9C92096640EA43F5, 0xFACE84692CE41CFC, 0xE71773883B7F8881, 0xBC7D4780BA6D1C11, 0xD4A35834230CB352, 0xE2B8A9FC446E9B15, 0xC9D2755706A3A959, 0x282D237DBA0C709B, 0x1F6C56655AC3CBF9, 0xE0DE2BACC37A25A2, 0x28EC02327275D3DA, 0x4218F823CD4CFFF5, 0x0E567E71CED1CA9B, 0x53EE47175E63CFCA, 0x6CEAFA49087B9992, 0x4991BD1F0B1B21ED, 0x7E17A2BD9D5B5E20, 0xFE2CCDD5CE5F8981, 0xD61F582B6206665F, 0xA60F8AD35A93E494, 0x291E918D1D7DE6D5, 0x1594BE0A55265042, 0xD025967A345CDC41, 0xA6816A6A49776949, 0x75EBFF9099B09C13, 0x007C2DE97BD25074, 0xCFF2128E7075F4F9, 0xFBB2974787D61FE2, 0x1038C564BCC6A032, 0x75486314600676A7, 0x73A651306E19112B, 0x6DAFD4856FEF36A2, 0xC769D163B28B180B, 0xA1DDC067FBA2F2AA, 0xEC6AA002E7E78240, 0x2B4E884E800B7330, 0xB37406FE2ABECC31, 0xE33EE2DFDB8E551F, 0x09294BCF3AEBE458, 0x84EE54D124B27802, 0xCB8E274F467CBD6A, 0x9B4D8A83CE9DC513, 0x53F603AD1ED43937, 0x83B2DE468A642087, 0xE9D9F1EE2DED203D, 0xDF2383838F46C9DB, 0x896AA692CCB15478, 0x0F894EF4EBAAD287, 0xE7058337642B2A96, 0x15567DB7F3B23D72, 0xE904A165FA24A162, 0x40D66C8FC9D28EB0, 0x154B1EC9A9E57A3B, 0xBAD3D61288F094A4, 0xCFD91B644E08AFE1, 0x3FF55244DB561EC0, 0x7528C65830FAB97A, 0xB77624758C9FAE75, 0xD5F89BC8A76300F1, 0x7230BA3F2A24792C, 0x0534A53B6E118105, 0x22F4A06ACE11CB02, 0xFDAA582FFB41CE02, 0x370C3364EE5E361F, 0x44D8552C4759C83F, 0x090AC2C7CFCF33D4, 0xBB362298748092AE, 0x60F3D5F8D356A174, 0x39BFE42F4AEDD3F0, 0x48869AF47A1F99FF, 0xBE21D0F9495BA5A2, 0xC1D6FEAE8E26CB76, 0x2A189F58930AB9DB, 0x9C5FBE89769A5719, 0x609A20BAD70347D5, 0x34C882C208B9FF38, 0x30E67E566EBFD240, 0xC1882F0BA7C1B1ED, 0xBB2B030E0B2E3B0A, 0x309EA717C73B07CE, 0x417E9EB210B25171, 0xA7995519EF697691, 0x73B97EE71BF98760, 0x8EC673DFF0BCD8FA, 0x879E0DBFF4323D98, 0xBB13FFA85D59B3D4, 0x984FB5F0F63EC582, 0xE8DE9B540C2DADB9, 0x71A7305E4DA0C9F3, 0xC5C4215A24C68A5C, 0x646A9DA97ED46AF2, 0x053D488161E61DA8, 0x4F11FBEBB52CCAD9, 0x243FE6E75F96F8C5, 0x6A59ECB414BBD755, 0xA452B2BD2882F75A, 0x3357494B624AFC34, 0x97BDC2FA16667CD9, 0x2CDCCB5A90B99A84, 0xE1BF54E2D8D56D2A, 0x051E35710B9650A6, 0xFB23F1E63A4D3904, 0x1A7C91D6785E8BFD, 0xEF66C7F7D35F6E9D, 0x924E178A09293688, 0xB900ABE0695F02B7, 0x37D2E4784489F1B4, 0x374734403D102CDB, 0x308A9C326ED606F0, 0x96D45F5DD4B693E3, 0x72F2B4B1339957D7, 0x37116F1E24135385, 0xA1D61B85D30B6F97, 0x55413189D3D5780C, 0xCF8CD12F9A1D0B5A, 0x185BBAC7EEDD3B9F, 0x9FE0F22D92304267, 0xB799297009A6A2CA, 0xE86920A60F803633, 0x32A2BDBB77A03FE6, 0xA93A36264EED941A, 0xB9325394BBF0E283, 0xAAE4EBA85631B6D4, 0x3CAA328670D6D283, 0x68F7C7E471C921E5, 0xC00EBB7314B9C161, 0x68A7CAFCB7344471, 0xEAA384A67E6D36C5, 0x03D213754F145630, 0x3FBA48FC5015C3CF, 0x89AB8C3AC1496256, 0xA6D1779FF77A9256, 0xB95040F44E42FD71, 0x656681D7C9D9580B, 0x34578CCBE4719725, 0xE24B378BB376F5AD, 0x8FD3F8283F0D7384, 0x2C55E22C94A4C925, 0xC435052C933890F0, 0x6A0A0E7AF32D67D4, 0x8EE0C2B5F8C3FA5E, 0x7C08F85742A9A893, 0x5F572565277B1589, 0x2DEF32CE49EFCA7D, 0x23B0CFBD69310C5D, 0xF9791D78A9C047B8, 0x5A7E5DA2A3F34510, 0x6073FADE063A2FCF, 0xA83098E58E520C15, 0x52FBFA1B59D496C7, 0x0F48F5EC959E98BA, 0x4D36AD100405B38C, 0x5CDBCE6EB44324F1, 0x97F2F462BB56E305, 0xE07C759EEE4858D8, 0xC399FA27E19C9A52, 0x8D8FBEF1BB796760, 0xD0C6E1A66A5BD14B, 0x61696542FA633970, 0x967602EDD5CF0267, 0x8D93803D21D752B8, 0x5AC79E8D40A12A06, 0x3E1B7AABFE51215B, 0xE338528D42778A4F, 0x33998A279097CF68, 0xD7BABDA8B4D82981, 0x72C75122CB6F11B0, 0x3A5DC261B1352611, 0x0DC0B1F5883708E2, 0xF1C9804EB1AE9433, 0x8E28B69916423E16, 0xB38178B4B7F4B615, 0x34C0D99CDBFA417C, 0x27FEE0C9B444EEA4, 0x1216659634F69DB4, 0x3033320028581631, 0xF4FB169828495659, 0x3AEA3A347C29FD47, 0x2D3A997B14FA192C, 0x2125C02ABFB800C9, 0x08AD95BD2401452E, 0x110EB3A485B32E0F, 0x26A064BD11EA128A, 0xB3C3E0B23DAE745B, 0x930C602705A3315E, 0x3B20A85DE77FAE6B, 0x1952A30170655906, 0xC002CB51F4C5C12B, 0xB552624425F0F87E, 0x22A66D6568E2BB7E, 0x0701FA0C0CFF0BAC, 0x76D83E3B2BF7AC0D, 0xDAB81C69994616D7, 0xD864F53D5EF42301, 0xC139765625F24544, 0xBC05DB425168073E, 0xA6034E49EE2CCEAF, 0xA1C4E7E2C9C373C8, 0x69DB01BCBC58CC5C, 0xF58D64FCB3D4C657, 0x7D17F6F04D5941A4, 0x0FF7359916AF50AF, 0x48D2932F0B7D5CBE, 0x0A760424FE61B21C, 0xA65661A98CF4C3C4, 0x959D1FACBDC3BA4F, 0xA5BCC596A0C4EF1B, 0x69178A4BC46A0939, 0xCA06E72545D3D3DB, 0xBBD0FD13C72A2BF4, 0xB5CC87EF025FA831, 0xF30416A9AB3B196E, 0x1BD26DF3A6C94778, 0xA61E961CE874AE40, 0xC6430D2E49FAC586, 0x3FDD1E03CDD97F06, 0xAF919A894F161AB4, 0x7D4FE03DA12FF33E, 0x3F1D548D8724352B, 0x5F4355E76B84BD9C, 0x6EE901A4634A7476, 0x26DC2A586F184476, 0x36416A4CC74C6F9E, 0x424A7817D553C430, 0xA5B7723184D3B48E, 0xB11051805885C6E2, 0x05FA7C8FCFC75A18, 0xCA7EAB3EAA5ABF87, 0xE957A8BDCFDADBF4, 0x078C243C49DA9A74, 0xB7C5D203BA30853A, 0x95C0871D878897D3, 0xD8D0626F23EB1C6B, 0xF08CDAE13D40FEC3, 0x8499213852071910, 0x653BA517E005645B, 0x1A8559D1B2FEE34C, 0x0C13E53249DB7748, 0x876C62611263B88C, 0x397E942A3157E4F5, 0x8B370293C9229229, 0xCD4DCB20259C6F9C, 0x2F1C241DAA7A7927, 0x947875E806BCBF4F, 0xEBC7ADD8DF6EA024, 0xEC0A2B500AC618BF, 0x63A33F1B04571C59, 0xD7158547EB8A81A0, 0xB9202E3611FBDD43, 0xBEFCE919713E1E89, 0x72A1920D468EC66A, 0x1FB573AD507C023A, 0x2FFAAB59AA34EECF, 0x990B892929673B9D, 0x7147AF2E6ACA616B, 0xB9C1BB9385C930F1, 0x051D3C348BD5453A, 0xE4C41B5DAA4103D5, 0x4E5421487C937C24, 0x4D44FC0863710450, 0xAEBA0ACA1DACEB68, 0x68E82CF46C4B3D78, 0x45C7FF144CA72C16, 0x407C4C5D75EFEFDA, 0xEA6B499A5D000889, 0xD80A88B40010104B, 0xA9B65D5BA1BD1745, 0x9C8BA950A7BD40E9, 0x5391FF3E28AE03FA, 0xCF9869B37ABECC89, 0xFC1E4F5BE3DCFC36, 0x63E88961FBADE148, 0x733EC9182DB27AAB, 0x81CBF178DA0F1BC6, 0xE236B12F7D4171E7, 0x6F53EE2FA22DEFD3, 0x1CA342CCD939FCD4, 0x6339CA27C7E12B9A, 0x5A9D8544766201A3, 0xB93022202A52C4D8, 0x5DC8B0E79AED3825, 0x7B0E3E6488F8077A, 0x09C813D47C50DD55, 0x29024F03C375B8C0, 0xEAA08E425D27AD97, 0xB58C697D84EC3193, 0x192C73D9BCB48B2F, 0x7EFE99B3B4FA0A08, 0x980F2B5767406016, 0x9FC730D90DDFF456, 0xE1A115AE306776D9, 0x6A7CF86D8C8FDD96, 0x9218EB732182CBF3, 0xFC77DF9B25C8FB7D, 0x324B03E0603FF341, 0x3127603D671F27F9, 0xC9AF2E13631932AE, 0x9A973C0C861B467A, 0x0C55854649DD60F8, 0xD64A0142FDB0D05D, 0x2F710F9684F5DA0E, 0x3CA023DCA0A2F7EE, 0x944709A098C6F28A, 0x32F379A2662BD4C8, 0x4D72BAF35A4D5262, 0xE8DF799771431F7F, 0xF97F799D8E3DEDB7, 0x5D877C67CC131944, 0x97C3E8697E207E48, 0xEED20843A5553DE4, 0xE99145FB5A7A97A6, 0xD55C64637DF91CA0, 0x43715D5BB2E7DAD0, 0xC47B658471B405F6, 0x8E0B1477D83EB808, 0xBA5B5B324C7AAC9F, 0x961F25B5AFDD2503, 0xBAEF90A00E01765F, 0xB0A216BC87C4267A, 0x2CFDEC18EC70A833, 0x842CBC78DA6EB97B, 0x7D508DCD1B786E14, 0xF793B07860290FF6, 0x8E38313A9A5BE089, 0x42F5CEAD419595AD, 0x2138DAAECCA61E4C, 0x925B068547A709BF, 0x35C51ACB18761865, 0xCB68A2DB4822662C, 0x7933266F1E2787DA, 0x780236F01763EB44, 0xFF35842910B570E0, 0xB76FE135C826F496, 0x24F7328C4C5AD511, 0x16935D68B664424A, 0xAB0072A0A9E8F3FA, 0x007B4DB072574551, 0x91E466AB6C313A5D, 0x78A0BBC7EEC38A4F, 0x24D116E3B0E2D6D1, 0x18D5E79BC85E51C8, 0x99D6E3290597AB15, 0xCC0B6A46901898FA, 0x6A8D62307B876511, 0x5AEE3F916E5DEF00, 0x3E98F2294A6EC687, 0x096BA5F6E8AAEF2D, 0x3FAE2B1BD288E944, 0xBA394AE41B7E9906, 0x83C3CD6E801A08A0, 0xB321B67B0E1A0BDE, 0xAF59D7EC6415FD0F, 0x7A3EE936C672C392, 0x075BDE274023AEE6, 0x0E0234E15454E8AD, 0xAFD709881CC09953, 0x10B2AB92E454EA73, 0xBAE9421758DBF056, 0x77ECCEBE17A6DC8F, 0x7F0ED3D71C625E24, 0x4DF9F52093413F55, 0x79C09AFC99077B5E, 0x09B3C3D8F030C5C7, 0x7B79C4E6AEC1888F, 0x5F904DC36128B76A, 0x5070EB2C7956237B, 0xAB57CB4B58245B59, 0xDF6CCB63AB437BB6, 0x65173D961754F3AC, 0x8A0EE85B9D86DA15, 0xD7C6912104C01831, 0xFAE972296CA38598, 0x28540720649A93CC, 0x8403DEEF1F21A20E, 0x1180312C92A51817, 0xC8AC42E18112B940, 0x8E55BB032B6A764B, 0xFEAC8ABDB256DD4B, 0x287BAD3E4AE2216F, 0xF38315CC02B6D3ED, 0xC69AE144331DA7D6, 0xC3739A98EF38CFD1, 0x8BE9AE319E12C316, 0xFFF000EE4617DA49, 0xF5C28178428F445D, 0x6DB81F57148ED1B2, 0x576CCE3A7FD586BC, 0xC2A08A558FED0642, 0xA953E9ED21970F59, 0x9F75B83FD66A5AED, 0xF77F1293A34C5052, 0x055734E9E410E804, 0x50C2331A2D886CBF, 0xFA4B6BF9A8C5B029, 0x8AAD0DDEE2BF9245, 0xE7CCB9AB6D394B3E, 0x8C4D3696887883CE, 0xCA6A7525A8A5F5DE, 0x2750E5A447B84EC5, 0x5660B6A235C79195, 0xC91B43F3AC535998, 0x783D50E7239FAD73, 0x0A332C8E32927495, 0x9D69084E9404FFAA, 0xEA0EAB16E143AAE9, 0xAF020F98C81251CA, 0x9CCE37FDF2429ECA, 0x353BA4F0E94184B8, 0xA8A2E71107FD2F96, 0x24AB15F1C91DA272, 0xB291F57287F92AC0, 0x712803592DDA8A2A, 0x74DCB88060C4C2DC, 0x40294EE9F7802CA6, 0x5625D36A1DE0657E, 0xA0FC9EA41A67CA80, 0xAB101D8E844072CA, 0xB7D1076524B4AF4A, 0x0C02243B7538116D, 0xFF6759A69234B486, 0xEEE2D2C555BDD399, 0xED297D1A05E53FFF, 0x9BCD955F5D9E26DF, 0x08C1C3A7197C8BCF, 0x743DE5D643D076EA, 0xDEF78B92BCCFB46C, 0x2CC0F3B9C0748233, 0x01B1D7FB3ED66BE5, 0x353A377D1E458600, 0x6C75BA16AF69AF4C, 0x75932DD9306DE0B2, 0x019FEA97C7FBFF31, 0xADD258203B565ABF, 0x5582675934FBE13B, 0xBBA666834AAEFF2D, 0xD2678A7730A38B0D, 0xA20ADEDEF2818265, 0xBF59B02CCA439E4D, 0x7DDA18443DD0C207, 0xA5765F21D47EA0F2, 0x04D8502E3A269965, 0xDB0C15E2B244CC92, 0x3ADEB07D85EA0EEE, 0x57972B46F8295973, 0x1A63DCA7CD45738E, 0xD4CE209245C08628, 0xAB4224259D36802C, 0x959D5C2CF8E8B9CC, 0x474EFD8DE832AC84, 0x2735C90640DD5DBE, 0x1B7812F4C1F24ED6, 0xC6E0309EBFE2C49B, 0x2644C6E111607070, 0x6F5133AEFE803E0C, 0xF85AA391ECC8AE24, 0xD5EECD5590D5C294, 0xCD2A2BBDDDE36BCD, 0x665C8D22DF8427A3, 0xD2CD652E8B483759, 0xCCD91E1C48DAA73B, 0xE2D9ECABAF7A4EAA, 0x5E6C1BF7EDC031DB, 0x7AF340BDDD2AD416, 0x8DE2C0C7C2FB092B, 0x5761762277FBF3CB, 0xAE4F503415DD7F16, 0x341D3F24866B4EEC, 0xCBC40F163EE4B88F, 0xA5F38396928C2A51, 0x590378652E5D4F8C, 0x443643396126F17A, 0x7C62F8F618D5DC1F, 0x483841F2E6B80FFD, 0xE53C24D8927AAF54, 0x5B533CFA13CAFF58, 0xC860F9DA0840ACC8, 0xE629247AA8F85A4E, 0xED834D2DF8DC4DE1, 0x6CB0EA272A714A42, 0x4108444B31116101, 0x85C5B7847481516C, 0x57871D8AF18B3C4E, 0x370589C90EF7A1D8, 0x8B3E3D8697217CE1, 0x0D7E66B8250813D8, 0xA939A8744E5FDF50, 0x6065B8A4832431B7, 0x4DAEDA4D5465FCD8, 0x1C337B46D0F1B452, 0x31FF281AF1D71FA7, 0x86E06C6FFBBE4BE0, 0x07248776D84E87AE, 0x3F05CAE2FFD47230, 0x424DDEA08FADCBDA, 0x63BECBA5A9678BE0, 0x088CDC53318891CF, 0xA8D0660EA3E717D7, 0x1322DA34D646CEFF, 0x302F07546FC75547, 0xEB4500578146869C, 0x91F4C171F547EC29, 0x2F06383F87793AF7, 0xF45D660016750197, 0x0CD10AB5649EED72, 0x2403D6A6AA9891F1, 0x6223781E73B2A0FF, 0xC66F2CACF181F93C, 0x7102A66DE9B2F9F4, 0x458F7ED5A5ADFE34, 0x077291FD0674BD4D, 0x57C4F5E647A81A1D, 0xD5436225F85A1CA7, 0x46110241ED9ADB63, 0x71C336C5C7AD9658, 0x1C43A3384A220EB2, 0xB0B88579032D4E02, 0x6D987C86F195A33F, 0x8906AF2D589A1BBC, 0x741566905CA74A50, 0x165B57DA950CF2C9, 0x20CF4DBD65DC5F07, 0x31DB27A776AE4EBE, 0x1317D6EA262C5B0F, 0x03B71CEFD5A9A3AE, 0x1E26C920A3E925B7, 0x0111C5BDCB2068D7, 0x5C0609612A9F27D0, 0x5263C7CDFBF90223, 0x534B08250BC86C13, 0xA7344F1AE4A6136D, 0xDD39F49AF0DFE79A, 0x45BFC4D86272B825, 0x75D86B2034222C0D, 0x08A46E35F7BEA26D, 0x6186BDC8DFAE476D, 0xCE537731AF5627D9, 0xC4D8450C8FD31BF2, 0xF9E084209DB1622D, 0xA04F36899AA826DF, 0x8EFCC4C11A26AE8B, 0x99705F9312DD9AFD, 0x41B301B3F4E2216A, 0x4EEA933AD95F7AF8, 0x2579620916FEF0FE, 0x16A2BC5C27549613, 0xB963F6C6426D620A, 0xBE54A1D6A2779335, 0xA3171C8C1D7D359E, 0xCB8C94F6373DA03C, 0x301E574EE65C8A03, 0x210E66E9169CA6B7, 0xE774E44B1E65956A, 0x214D1C35BC9AF876, 0x8554C56724A2D11C, 0x2ED41F80C99F548A, 0xC63655CF1ACF797F, 0x175D85D6D51E1CD5, 0xF4A7344ABF36E6D9, 0xD5B1D424C10E0E4D, 0xE1D646CE0C808DE9, 0x5CB6DFD379271B3A, 0x090E9FD679BFE15F, 0x53BA33CA33380195, 0xD6BDAF537B829B48, 0xDB00192E94A3CA7A, 0xC87D0B4AB448780F, 0xEC21BED1F33CE950, 0x03E660B484D49447, 0x1298CFC11489B268, 0x7130DAE8C43D46E5, 0x3AFED04D0B1E284D, 0xF8D3FDC98E3C6AE8, 0x4B60E892ECCD4262, 0xDB02CB46AC769B70, 0x43DADBD9E32AE9F9, 0x98FB2D5C3F33C31C, 0x0985A5BBE3714DA7, 0x5E6C34AA25A858D0, 0x8E8A0AC400DCB80B, 0x2470ABF15AB2CAA9, 0x3AB3AC7AD9472855, 0x2CD3227464E39EF8, 0xD6DCA39D590DA8F3, 0xEBBE4896F7192395, 0x184A09AA9B2B5095, 0xE3A3D73C84ACAEAD

spacer: db 10


decrypt_d:                    dq 0x04c5f5a7d1ac599e, 0x68105c7ab544c5c1, 0x5f2e800c42455a82, 0xaf40d41b44464bc8, 0x7a6c808084cba8fb, 0xbf7d1e09c33ba7cc, 0x45c79dfce8ab6381, 0x87665c5302e22141, 0x461a206b34ddc7a7, 0xf2a3d68a84c0af2f, 0x74f21c3036ea731f, 0xc27c70218c7f4399, 0x77eda3d6237ba626, 0xf9749cfa475d06cb, 0x60066b458f24b7cd, 0xbac956374d1a526f
crypt_c:                      dq 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x00001c527b7ccc7f
var_n:                        dq 0x4000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x00000000000001cc, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000015ec7
var_r:                        dq 0x8000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000
var_v:                        dq 0x5b173d778b0e3ccf, 0xa4ccf18241ecdbe0, 0xf108dc374dde4c90, 0x9983f1e5d9100e3c, 0xbd0664103ee262b3, 0xe0869f553670ea50, 0xc57b7bfd00cf7492, 0x0599d582c259819a, 0xc17c0c1f246b4b0a, 0xba442c9ef3283765, 0x9f74554316906d84, 0x4ab9b80d1d1d869e, 0x3f9fd90be8681c93, 0x979a7154c64a80cb, 0x405e53e066cfc8c3, 0x3f11890c0b6ffd09
var_rrn_montgomery:           dq 0x3fffffffffffffff, 0xffffffffffffffff, 0xffffffffffffffff, 0xffffffffffffffff, 0xffffffffffffffff, 0xffffffffffffffff, 0xffffffffffffffff, 0xffffffffb6dec26b, 0xffffffffffffffff, 0xffffffffffffffff, 0xffffffffffffffff, 0xffffffffffffffff, 0xffffffffffffffff, 0xffffffffffffffff, 0xffffffffffffffff, 0xffffffc0b95dfa8b
square_and_multiply_1024_one: dq 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000001
section .bss


cypher_montgomery_in: resq 16
cypher_out: resq 16
decypher_out: resq 16
decypher_out_normal_space: resq 16

square_and_multiply_1024_tmp_multiply: resq 16
square_and_multiply_1024_multiply: resq 16
square_and_multiply_1024_tmp_square: resq 16
square_and_multiply_1024_square: resq 16
square_and_multiply_1024_tmp_multiplication_left: resq 16

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


