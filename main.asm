%include "utils.asm"
%include "terminal.asm"
%include "syscall.asm" 
     
section .data           ;Text to output
    DEF_STR title, "Blackjack in QR code v1.0",10,10,"There was suppose to be a fancy ascii title here but it got",10,"removed to fit inside the QR code 😭, so feel free to just",10,"imagine it 🙂"  
    DEF_STR instruction1, 10,10,"Press H to start",10,10
    DEF_STR instruction2, "You pulled a "
    DEF_STR instruction3, "               Score: "
    DEF_STR instruction4,    "Your cards:     "
    DEF_STR instruction4Opp, "Computer cards: "
    DEF_STR instruction5, "Press H to Hit or Press F to Fold",10
    DEF_STR spacer, "       "
    DEF_STR question, "?"
    DEF_STR lose, 10, "Bust!, You went over 21"
    DEF_STR lose2, 10, "You lost, Computer has a higher score of "
    DEF_STR win, 10,"You Win!"
    DEF_STR byebye, 10, 10, "Press any key to exit:" 
section .bss                                  
    char_buffer resb 3      ;buffer for itoa
    old_action resb 128     ;for sig_handler
    score resb 8            ;User score
    scoreOpp resb 8         ;Computer score
section .text
    global _start 
_start:                      
    xor rax, rax            ;set rax to 0
    mov [score], rax        ;set score to 0
    mov rdi, 2           
    mov rsi, sig_handler 
    mov rdx, old_action  
    mov rax, 13          
    syscall               
    call unbuffer 
                 
introScreen:                ;Intro screen to greet user
    call clear_term     
    mov rsi, title 
    mov rdx, title_len    
    call println
    mov rsi, instruction1     
    mov rdx, instruction1_len             
    call println  
    call getchar            
    cmp al, 0x68            ;Check if it is H to continue    
    je generateCard  
    jmp introScreen         ;repeat if h not selected
generateCard:               ;generate hand for user
    call clear_term         ;pretty self explainatory 
    mov rsi, instruction4     ;print user cards
    mov rdx, instruction4_len
    call print 
    
    mov dil, 2                        
    mov sil, 10                       
    call randint            ;Generate card
    
    mov rbx, [score]        ;Add to user score          
    add rbx, rax                      
    mov [score], rbx                   
    lea rsi, [char_buffer]
    mov rdi, rax                      
    call itoa               ;Convert to string using itoa           
    lea rsi, [char_buffer]  
    call print 
    mov dil, 2                        
    call randint                       
    mov sil, 10             ;Generate second card     
    
    mov rbx, [score]        ;Add to user score   
    add rbx, rax                      
    mov [score], rbx        ;Add to user score      
    lea rsi, [char_buffer]
    mov rdi, rax                      
    call itoa               ;Convert to string using itoa            
    mov rsi, spacer     
    mov rdx, spacer_len
    call print 
    lea rsi, [char_buffer]
    call println 
    mov rsi, instruction4Opp     
    mov rdx, instruction4Opp_len
    call print                  ;Print robot cards
    mov dil, 2                        
    mov sil, 10                       
    call randint                       
    
    mov rbx, [scoreOpp]         ;Generate one card for computer    
    add rbx, rax                      
    mov [scoreOpp], rbx                   
    lea rsi, [char_buffer]
    mov rdi, rax                      
    call itoa   
    call print 
    mov rsi, spacer     
    mov rdx, spacer_len
    call print 
    mov rsi, question     
    mov rdx, question_len
    call println                ;Hide one card

    mov rsi, instruction5       ;instructions on controls
    mov rdx, instruction5_len
    call println 
    call getchar
    cmp al, 0x68                 ;User Hits
    je mainloop
    cmp al, 0x66                 ;User Folds
    je foldCondition 
    jmp introScreen              ;Go back to title if wrong input
     
mainloop: ;User hits
    
    mov dil, 2                        
    mov sil, 10                       
    call randint                        ;Generate Card
    
    mov rbx, [score]                  
    add rbx, rax                        ;Add to user score
    mov [score], rbx                   
    
    lea rsi, [char_buffer]
    mov rdi, rax                      
    call itoa                          
    mov rsi, instruction2
    mov rdx, instruction2_len           ;Tell user what card was pulled
    call print 
    
    lea rsi, [char_buffer]
    call print 
    
    lea rsi, [char_buffer]
    mov rdi, rbx                      
    call itoa                          
    mov rsi, instruction3
    mov rdx, instruction3_len           ;Tell user the total score
    call print 
    
    lea rsi, [char_buffer]
    call println 
    
    mov rbx, [score]                    ;Check if it is above 21
    cmp rbx, 21           
    jg loseCondition                    ;Lose if above 21
    call getchar            
    cmp al, 0x68                        ;Check if hit again
    je mainloop
    cmp al, 0x66                        ;Check if fold
    je foldCondition 
    jmp introScreen                     ;Wrong input goes to intro screen
foldCondition:
    mov al, [scoreOpp]                  ;if fold, check if lower than 17
    cmp al, 17
    jl pullOppCard                      ;if lower, computer hits until above
    cmp al, 21
    jg winCondition                     ;if com is above 21, user wins
    mov ah, [score]
    cmp al, ah
    jl winCondition                     ;if com is below user, user wins
    jmp loseCondition2                  ;else user loses
pullOppCard:                            ;Computer hits
    mov dil, 2                        
    mov sil, 10                       
    call randint                       
    
    mov rbx, [scoreOpp]                  
    add rbx, rax                      
    mov [scoreOpp], rbx                   
    jmp foldCondition 
winCondition:                           ;print you win
    mov rsi, win
    mov rdx, win_len
    call println 
    call exit_program 
loseCondition:
    mov rsi, lose                       ;user loses because above 21
    mov rdx, lose_len
    call print 
    jmp exit_program 
loseCondition2:                         ;user loses because com is higher
    mov rsi, lose2
    mov rdx, lose2_len
    call print 
    mov rax, [scoreOpp]
    lea rsi, [char_buffer]
    mov rdi, rax                    
    call itoa                       
    call println                        ;prints com score
    jmp exit_program
exit_program:
    mov rsi, byebye                     ;Gives prompt to leave
    mov rdx, byebye_len
    call print
    call getchar                        ;Any key exits the program
    call clear_term    
    call restore_buffer                 ;restore user input
    mov rdi, 1
    call exit                   
sig_handler:
    
    call restore_buffer                 ;if user stops program prematurely using ctrl+c, restore user input
    mov rdi, 1           
    call exit             
