TITLE Jogo da Velha
LER_CARAC MACRO
    MOV AH, 1
    INT 21H
ENDM

INI_DS MACRO
    MOV AX, @DATA
    MOV DS, AX
ENDM

FIM_PROG MACRO
    MOV AH, 4CH
    INT 21H
ENDM

IMP_STRING MACRO MSG     
    MOV AH, 9
    LEA DX, MSG
    INT 21H
ENDM

IMP_TABULEIRO MACRO

ENDM

LIMPA_TELA MACRO
    MOV AH, 06h       ; Função 06h: scroll up (rolar para cima)
    MOV AL, 00h       ; 0 = limpa todas as linhas
    MOV BH, 07h       ; Atributo da cor (texto cinza, fundo preto)
    MOV CX, 0000h     ; Canto superior esquerdo (linha 0, coluna 0)
    MOV DX, 184Fh     ; Canto inferior direito (linha 24, coluna 79)
    INT 10h           ; Chama a interrupção de vídeo

    ; Reposiciona o cursor no canto superior esquerdo
    MOV AH, 02h       ; Função 02h: posicionar cursor
    MOV BH, 00h       ; Página 0
    MOV DH, 00h       ; Linha 0
    MOV DL, 00h       ; Coluna 0
    INT 10h
ENDM

PUSH_ALL MACRO
    PUSH AX ; SALVAR OS REGISTRADORES NA PILHA
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
ENDM

POP_ALL MACRO
    POP SI ; RESTAURO OS REGISTRADORES
    POP DX
    POP CX
    POP BX
    POP AX
ENDM

.model SMALL
.STACK 100H
.DATA
    N EQU 3
    TABULEIRO DB N DUP (N DUP ('_') )
    MSG_ENFEITE DB '=----------------------------------------------------------------=$'
    MSG_JOGO db "                          Jogo da Velha", 10,13,'$'
    MODO_JOGO db "Deseja Jogar contra Quem?",10,13,'$'
    ERRO DB 'Opcao Invalida!',10,13,'(Pressione Qualquer Tecla para Retornar)$'
    JogXJog db "1 - Jogador vs Jogador",10,13,'$'
    JogXComp db "2 - Jogador vs Computador",10,13,'$'
    TURNO_CIRCULO DB 'Turno do Circulo: $'
    TURNO_XIS DB  'Turno do Xis: $'
    quebralinha db 10,13,'$'
    VITORIA DB 'Vitoria!!$'
    

.CODE
MAIN PROC  

    INI_DS

TELA_INICIAL:

    IMP_STRING MSG_ENFEITE
    IMP_STRING MSG_JOGO
    IMP_STRING MSG_ENFEITE
    IMP_STRING quebralinha

    IMP_STRING MODO_JOGO
    IMP_STRING JogXJog
    IMP_STRING JogXComp

    LER_CARAC
    CMP AL, '1'
    JE JXJ
    CMP AL, '2'
    JE JXC
    LIMPA_TELA
    IMP_STRING ERRO
    LER_CARAC
    LIMPA_TELA
    JMP TELA_INICIAL

JXJ:
    CALL JOGADOR_X_JOGADOR


JXC:
    CALL JOGADOR_X_COMPUTADOR

    FIM_PROG
    
MAIN ENDP

JOGADOR_X_JOGADOR PROC ;(Jogador x Jogador)

INICIO:
    CALL IMPRIME_TAB_INI

RODADA_XIS:   
    LIMPA_TELA
    CALL IMPRIME_TAB
    IMP_STRING TURNO_XIS
    CALL LER_JOGADA_X

RODADA_CIRCULO:
    LIMPA_TELA
    CALL IMPRIME_TAB
    IMP_STRING TURNO_CIRCULO
    CALL LER_JOGADA_O
    CALL WIN_CHECK ; VERIFICA SE HOUVE VENCEDOR
    JNZ FIM
    JMP RODADA_XIS
FIM:
    IMP_STRING VITORIA
    RET

JOGADOR_X_JOGADOR ENDP


JOGADOR_X_COMPUTADOR PROC ;(Jogador x Computador)
    RET
JOGADOR_X_COMPUTADOR ENDP

IMPRIME_TAB_INI PROC
    ; IMPRIME A MATRIZ DO TABULEIRO
    ; ENTRADA - BX O OFFSET DA MATRIZ, CH NUMERO DE LINHAS E DH NUMERO DE COLUNAS
    ; SAIDA - MATRIZ IMPRESSA

    PUSH_ALL

    MOV AH,2 ; COMANDO IMPRESSÃO
    LEA BX, TABULEIRO
    XOR DH, DH ;  PARAMETROS DO TABULEIRO
    MOV CH, 3 ; # LINHA
    XOR BX,BX ; INDICE COLUNA

    COLUNA: ; IMPRIME UMA COLUNA
    MOV CL, 2 ; # COLUNA
    XOR SI,SI ; INDICE LINHA

    LINHA: ; IMPIRME UMA LINHA
    MOV DL, DH  ; LEIO ELEMENTO DA MATRIZ
    INT 21H ; IMPRIMO
    MOV DL, ' ' ; ESPAÇO PROXIMO CARACTER
    INT 21H ; IMPRIMO
    INC SI ; PROXIMA COLUNA
    DEC CL
    INC DH
    JNZ LINHA

    MOV DL, 10
    INT 21H
    ADD BX,3 ; PROXIMA LINHA
    DEC CH
    JNZ COLUNA

    POP_ALL

    RET
IMPRIME_TAB_INI ENDP

IMPRIME_TAB PROC
    ; IMPRIME A MATRIZ DO TABULEIRO
    ; ENTRADA - BX O OFFSET DA MATRIZ, CH NUMERO DE LINHAS E DH NUMERO DE COLUNAS
    ; SAIDA - MATRIZ IMPRESSA

    PUSH_ALL

    MOV AH,2 ; COMANDO IMPRESSÃO

    LEA BX, TABULEIRO
    MOV DH, 3 ;  PARAMETROS DO TABULEIRO
    MOV CH, 3 ; # LINHA
    XOR BX,BX ; INDICE COLUNA

COLUNAA: ; IMPRIME UMA COLUNA
    MOV CL,DH ; # COLUNA
    XOR SI,SI ; INDICE LINHA

LINHAA: ; IMPIRME UMA LINHA
    MOV DL,[BX][SI] ; LEIO ELEMENTO DA MATRIZ
    INT 21H ; IMPRIMO
    MOV DL, ' ' ; ESPAÇO PROXIMO CARACTER
    INT 21H ; IMPRIMO
    INC SI ; PROXIMA COLUNA
    DEC CL
    JNZ LINHA

    MOV DL, 10
    INT 21H
    ADD BX,3 ; PROXIMA LINHA
    DEC CH
    JNZ COLUNA

    POP_ALL

    RET
IMPRIME_TAB ENDP

LER_JOGADA_X PROC
; LE A JOGADA DO USUARIO E ATUALIZA A MATRIZ
    PUSH_ALL
INICIO_X:
    MOV AH,1 ; COMANDO LEITURA
    INT 21H
LE_JOGADA:
    CMP AL, '1'
    JE POS_1
    CMP AL, '2'
    JE POS_2
    CMP AL, '3'
    JE POS_3
    CMP AL, '4'
    JE POS_4
    CMP AL, '5'
    JE POS_5
    CMP AL, '6'
    JE POS_6
    CMP AL, '7'
    JE POS_7
    CMP AL, '8'
    JE POS_8
    CMP AL, '9'
    JE POS_9
    JMP INICIO ; CASO SEJA INVALIDO, LER NOVAMENTE

POS_1:
    MOV BX, 0
    MOV SI, 0
    MOV DL, 'X'
    XCHG [BX][SI], DL 
    JMP FIM_DA_RODADA
POS_2:
    MOV BX, 0
    MOV SI, 1
    MOV DL, 'X'
    XCHG [BX][SI], DL
    JMP FIM_DA_RODADA 
POS_3:
    MOV BX, 0
    MOV SI, 2
    MOV DL, 'X'
    XCHG [BX][SI], DL
    JMP FIM_DA_RODADA
POS_4:
    MOV BX, 3
    MOV SI, 0
    MOV DL, 'X'
    XCHG [BX][SI], DL
    JMP FIM_DA_RODADA
POS_5:
    MOV BX, 3
    MOV SI, 1
    MOV DL, 'X'
    XCHG [BX][SI], DL
    JMP FIM_DA_RODADA
POS_6:
    MOV BX, 3
    MOV SI, 2
    MOV DL, 'X'
    XCHG [BX][SI], DL
    JMP FIM_DA_RODADA
POS_7:
    MOV BX, 6
    MOV SI, 0
    MOV DL, 'X'
    XCHG [BX][SI], DL
    JMP FIM_DA_RODADA
POS_8:
    MOV BX, 6
    MOV SI, 1
    MOV DL, 'X'
    XCHG [BX][SI], DL
    JMP FIM_DA_RODADA
POS_9:
    MOV BX, 6
    MOV SI, 2
    MOV DL, 'X'
    XCHG [BX][SI], DL
    JMP FIM_DA_RODADA

FIM_DA_RODADA:
    POP_ALL
    RET
LER_JOGADA_X ENDP

LER_JOGADA_O PROC
; LE A JOGADA DO USUARIO E ATUALIZA A MATRIZ
    PUSH_ALL
INI:
    MOV AH,1 ; COMANDO LEITURA
    INT 21H
LE_JOGADA_O:
    CMP AL, '1'
    JE POSI_1
    CMP AL, '2'
    JE POSI_2
    CMP AL, '3'
    JE POSI_3
    CMP AL, '4'
    JE POSI_4
    CMP AL, '5'
    JE POSI_5
    CMP AL, '6'
    JE POSI_6
    CMP AL, '7'
    JE POSI_7
    CMP AL, '8'
    JE POSI_8
    CMP AL, '9'
    JE POSI_9
    JMP INI ; CASO SEJA INVALIDO, LER NOVAMENTE

POSI_1:
    MOV BX, 0
    MOV SI, 0
    MOV DL, 'O'
    XCHG [BX][SI], DL 
    JMP FIM_DA_RODADA_O
POSI_2:
    MOV BX, 0
    MOV SI, 1
    MOV DL, 'O'
    XCHG [BX][SI], DL
    JMP FIM_DA_RODADA_O
POSI_3:
    MOV BX, 0
    MOV SI, 2
    MOV DL, 'O'
    XCHG [BX][SI], DL
    JMP FIM_DA_RODADA_O
POSI_4:
    MOV BX, 3
    MOV SI, 0
    MOV DL, 'O'
    XCHG [BX][SI], DL
    JMP FIM_DA_RODADA_O
POSI_5:
    MOV BX, 3
    MOV SI, 1
    MOV DL, 'O'
    XCHG [BX][SI], DL
    JMP FIM_DA_RODADA_O
POSI_6:
    MOV BX, 3
    MOV SI, 2
    MOV DL, 'O'
    XCHG [BX][SI], DL
    JMP FIM_DA_RODADA_O
POSI_7:
    MOV BX, 6
    MOV SI, 0
    MOV DL, 'O'
    XCHG [BX][SI], DL
    JMP FIM_DA_RODADA_O
POSI_8:
    MOV BX, 6
    MOV SI, 1
    MOV DL, 'O'
    XCHG [BX][SI], DL
    JMP FIM_DA_RODADA_O
POSI_9:
    MOV BX, 6
    MOV SI, 2
    MOV DL, 'O'
    XCHG [BX][SI], DL
    JMP FIM_DA_RODADA_O

FIM_DA_RODADA_O:
    POP_ALL
    RET
LER_JOGADA_O ENDP

WIN_CHECK PROC
    PUSH_ALL
    XOR BX,BX
    XOR SI,SI

TEST_12:
    MOV AL, [BX][SI]       
    MOV DL, [BX][SI+1]     
    CMP AL, DL             

    JE TEST_23

TEST_14:
    MOV AL, [BX][SI]       
    MOV DL, [BX+3][SI]     
    CMP AL, DL 

    JE TEST_47

TEST_159:
    MOV AL, [BX][SI]       
    MOV DL, [BX+3][SI+1]     
    CMP AL, DL 
    JNE TEST_35
    MOV AL, [BX+3][SI+1]       
    MOV DL, [BX+6][SI+2]     
    CMP AL, DL 
    JE WIN

TEST_23:
    MOV AL, [BX][SI+1]       
    MOV DL, [BX][SI+2]     
    CMP AL, DL 
    JE WIN

TEST_47:
    MOV AL, [BX+3][SI]       
    MOV DL, [BX+6][SI]     
    CMP AL, DL 



TEST_35:
    MOV AL, [BX][SI]       
    MOV DL, [BX][SI+1]     
    CMP AL, DL 
    JE TEST_57

TEST_369:
    MOV AL, [BX][SI+2]       
    MOV DL, [BX+3][SI+2]     
    CMP AL, DL 
    JNE TEST_789
    MOV AL, [BX+3][SI+2]       
    MOV DL, [BX+6][SI+2]     
    CMP AL, DL 
    JE WIN

TEST_57: 
    MOV AL, [BX+3][SI+1]       
    MOV DL, [BX+6][SI]     
    CMP AL, DL 
    JE WIN

TEST_789:
    MOV AL, [BX+6][SI]       
    MOV DL, [BX+6][SI+1]     
    CMP AL, DL 
    JNE TEST_456
    MOV AL, [BX+6][SI+1]       
    MOV DL, [BX+6][SI+2]      
    CMP AL, DL 
    JE WIN

TEST_456:
    MOV AL, [BX+3][SI]       
    MOV DL, [BX+3][SI+1] 
    CMP AL, DL   
    JNE TEST_258
    MOV AL, [BX+3][SI+1]       
    MOV DL, [BX+3][SI+2] 
    CMP AL, DL
    JE WIN   

TEST_258:
    MOV AL, [BX][SI+1]       
    MOV DL, [BX+3][SI+1] 
    CMP AL, DL   
    JNE NO_WIN
    MOV AL, [BX+3][SI+1]       
    MOV DL, [BX+6][SI+1] 
    CMP AL, DL
    JE WIN   

NO_WIN:
; Não houve vitória
    POP_ALL
    XOR AX, AX
    CMP AX, AX      ; ZF=1
    RET

WIN:
; Houve vitória
    POP_ALL
    MOV AX, 1
    CMP AX, 0
    RET  

WIN_CHECK ENDP



END MAIN
