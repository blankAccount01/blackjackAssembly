%ifndef UTILS_ASM
%define UTILS_ASM

%include "syscall.asm"
%include "terminal.asm"

section .text

global rand

rand:
    ret

global itoa

; rdi: value
; rsi: buffer pointer
; rax: return, number of bytes written
itoa:
    xor rcx, rcx
._itoa:
    xor edx, edx
    mov eax, edi
    div dword [dividend]
    add edx, "0"
    mov byte [rsi + rcx], dl
    inc rcx

    mov edi, eax
    cmp edi, 0
    jnz ._itoa
.reverse:
    mov byte [rsi + rcx], 0 ; null-terminate string
    mov rax, rcx            ; move string length into return register
    
    ; below this is equivalent to strrev() in C's stdlib
    ; (without checking strlen since that's already stored in `rcx`)
    cmp rcx, 1
    jg .revloop_init
.revloop_init:
    dec rcx                 ; set rcx to strlen - 1
    xor r10, r10            ; set r10 to 0
.revloop:
    ; swap the bytes on opposite ends of the string
    mov dil, byte [rsi + r10]
    mov r8b, byte [rsi + rcx] 
    mov byte [rsi + r10], r8b
    mov byte [rsi + rcx], dil

    inc r10
    dec rcx
    cmp r10, rcx
    jl .revloop
.return:
    ret

global randint

; generates a random number in the given range (inclusive)
; dil: lower bound
; sil: upper bound
; al: return value
randint:
    ; save the parameters in preserved registers
    push r12
    push r13
    mov r12b, dil
    mov r13b, sil

    ; generate a single random byte in rax
    push qword 0
    mov rdi, rsp
    mov rsi, 1
    xor rdx, rdx
    call getrandom
    pop rax

    ; upper bound - lower bound + 1
    sub r13b, r12b
    inc r13b

    ; (random % range) + lower bound
    div r13b
    mov al, ah
    add r12b, al

    ; store result in the rax register
    xor rax, rax
    mov al, r12b

    ; restore preserved registers
    pop r13
    pop r12

    ret

global memcpy

; rdi: destination address
; rsi: source address
; rdx: length
memcpy:
    cmp rdx, 0
    jz .return

    mov al, byte [rsi]
    mov byte [rdi], al

    inc rdi
    inc rsi
    dec rdx
    jmp memcpy
.return:
    ret


global clear_term

clear_term:
    mov rsi, ansi_clear
    mov rdx, ansi_clear_len
    call print

    mov rsi, ansi_home
    mov rdx, ansi_home_len
    call print

    ret


section .data
    dividend: dd 10
    DEF_STR ansi_clear, 27,"[2J"
    DEF_STR ansi_home, 27,"[H"

%endif
