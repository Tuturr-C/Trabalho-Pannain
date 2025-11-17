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

RODADA_XIS:
    LIMPA_TELA
    CALL IMPRIME_TAB
    IMP_STRING TURNO_XIS
    CALL LER_JOGADA

RODADA_CIRCULO:
    LIMPA_TELA
    CALL IMPRIME_TAB
    IMP_STRING TURNO_CIRCULO



    RET

JOGADOR_X_JOGADOR ENDP


JOGADOR_X_COMPUTADOR PROC ;(Jogador x Computador)
    RET
JOGADOR_X_COMPUTADOR ENDP

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

    COLUNA: ; IMPRIME UMA COLUNA
    MOV CL,DH ; # COLUNA
    XOR SI,SI ; INDICE LINHA

    LINHA: ; IMPIRME UMA LINHA
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

LER_JOGADA PROC
    ; LE UMA MATRIZ M X N E ARMAZENA NA MEMORIA
    ; ENTRADA - BX O OFFSET DA MATRIZ, CH NUMERO DE LINHAS E DH NUMERO DE COLUNAS
    ; SAIDA - MATRIZ ARMAZENADA NA MEMORIA
    PUSH_ALL

    ; MOV CH,3 ; # LINHAS
    ; XOR BX,BX ; INDICE COLUNA
    XOR BX,BX
    MOV AH,1
LER_LINHA:
    INT 21H
    ;CALL TRANS_POSICAO

LER_COLUNA:
    INT 21H
    AND AL, 30H
    MOV SI, AX
    MOV [BX][SI], 'X' ; ARMAZENA O X NA POSIÇÃO

    POP_ALL

    RET
LER_JOGADA ENDP

TRANS_POSICAO PROC

    CMP AL, '1'
    JE POS_0_0
    CMP AL, '2'
    JE POS_0_1
    CMP AL, '3'
    JE POS_0_2
    CMP AL, '4'
    JE POS_1_0
    CMP AL, '5'
    JE POS_1_1
    CMP AL, '6'
    JE POS_1_2
    CMP AL, '7'
    JE POS_2_0
    CMP AL, '8'
    JE POS_2_1
    CMP AL, '9'
    JE POS_2_2
    JMP LER_COLUNA ; SE INVALIDO, LER NOVAMENTE
TRANS_POSICAO ENDP



END MAIN