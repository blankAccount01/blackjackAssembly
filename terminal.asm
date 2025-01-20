%ifndef TERMINAL_ASM
%define TERMINAL_ASM

%include "syscall.asm"

%define ICANON (1<<1)
%define ECHO   (1<<3)

section .data
    DEF_STR newline, 10

section .bss
    stty resb termios_size
    tty  resb termios_size

section .text

global print

print:
    mov rdi, 1     ; STDOUT_FILENO
    call write
    ret

global println

println:
    call print            ; print original string
    mov rsi, newline
    mov rdx, newline_len
    call print            ; print newline
    ret

global getchar

; gets the character at the top of stdin
; rax: return character
getchar:
    mov rdi, 0        ; read from STDIN (fd 0)
    push 0            ; make room at the top of the stack to read into
    mov rsi, rsp      ; read into the top of the stack  
    mov rdx, 1        ; count (1 byte)
    call read
    
    pop rax
    ret

global unbuffer

unbuffer:
    mov rax, stty
    mov rdx, 0
    call ioctl

    ; store 
    mov rax, tty
    mov rdx, 0
    call ioctl
    
    ; remove icanon and echo flags
    and dword [tty+termios.flags], (~ICANON)
    and dword [tty+termios.flags], (~ECHO)

    ; store new termios
    mov rax, tty
    mov rdx, 1
    call ioctl

    ret

global restore_buffer

restore_buffer:
    mov rax, stty
    mov rdx, 1
    call ioctl

    ret

%endif