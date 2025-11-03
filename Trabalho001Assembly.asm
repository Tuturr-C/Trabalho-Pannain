Title Jogo da Velha
.Model Small
.Stack 100h
.data
    Msg1 db "------------------------------------------------------------------------",10,13,
        db "                          Jogo da Velha", 10,13,
        db "Deseja Jogar contra Quem?",10,13,
        db "1 - Jogador vs Jogador",10,13,
        db "2 - Jogador vs Computador",10,13,
    quebralinha db 10,13,'$'

.code
Main Proc
    mov ax, @data
    mov ds, ax

    mov ah, 9
    lea dx, Msg1 
    int 21h 

    mov ah, 9
    lea dx, quebralinha
    int 21h


  
 

    

Main endp
End Main