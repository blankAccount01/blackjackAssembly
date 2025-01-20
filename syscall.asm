%ifndef SYSCALL_ASM
%define SYSCALL_ASM

%define WRITE 1
%define IOCTL 16
%define EXIT  60

%macro DEF_STR 2+
    %1 db %2
    %1_len equ $-%1
%endmacro

struc termios
    resb 12
    .flags: resb 12
    resb 44
endstruc

section .text


global write

write:
    mov rax, WRITE
    syscall
    ret

global read

read:
    mov rax, 0
    syscall


global ioctl

; get struct
%define TCGETS 21505 
; set struct   
%define TCSETS 21506  

; rax: termios struct pointer
; rdx: 0 - get, 1 - set
ioctl:
    push rdi
    push rsi

    add rdx, TCGETS
    mov rsi, rdx
    mov rdx, rax
    mov rdi, 0
    mov rax, IOCTL
    syscall

    pop rsi
    pop rdi
    ret

global getrandom

getrandom:
    mov rax, 318
    syscall
    ret

global exit

exit:
    mov rax, EXIT
    syscall

%endif