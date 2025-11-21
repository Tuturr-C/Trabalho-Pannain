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
    PUSH_ALL     
    MOV AH, 9
    LEA DX, MSG
    INT 21H
    POP_ALL
ENDM

IMP_TABULEIRO MACRO

ENDM

LIMPA_TELA MACRO
    PUSH_ALL
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
    POP_ALL
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

WIN_X_OU_O MACRO

ENDM

.model SMALL
.STACK 100H
.DATA
    TABULEIRO DB '1', '2', '3','4','5','6' ,'7', '8', '9'

    MSG_ENFEITE DB '=----------------------------------------------------------------=$'
    MSG_JOGO db "                          Jogo da Velha", 10,13,'$'
    MODO_JOGO db "Deseja Jogar contra Quem?",10,13,'$'
    ERRO DB 'Opcao Invalida!',10,13,'(Pressione Qualquer Tecla para Retornar)$'
    JogXJog db "1 - Jogador vs Jogador",10,13,'$'
    JogXComp db "2 - Jogador vs Computador",10,13,'$'
    TURNO_CIRCULO DB 'Turno do Circulo: $'
    TURNO_XIS DB  'Turno do Xis: $'
    quebralinha db 10,13,'$'
    VITORIA_XIS DB 'Vitoria do Xis!$'
    VITORIA_CIRCULO DB 'Vitoria do Circulo!$'
    INVALIDO DB 'Casa Invalida! (Escolha entre 1-9)',10,13,'(Pressione Qualquer Tecla para Retornar)$'
    REPETIDA DB 'Esta Casa ja foi selecionada',10,13,'(Pressione Qualquer Tecla para Retornar)$'
    

.CODE
MAIN PROC  

    INI_DS

TELA_INICIAL:
; INTERFACE DA TELA INICIAL
    LIMPA_TELA
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

; SE NAO OBEDECER NENHUMA DAS CONDICOES, RETORNA PARA A PAGINA INICIAL
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

; SEPARADO EM TURNOS DE CADA JOGADOR
RODADA_XIS:
    MOV DL, 'X'
    CALL LER_JOGADA
    LIMPA_TELA
    CALL IMPRIME_TAB
    CALL WIN_CHECK ; VERIFICA SE HOUVE VENCEDOR
    JNZ FIM_DE_JOGO

RODADA_CIRCULO:
    MOV DL, 'O'
    CALL LER_JOGADA
    LIMPA_TELA
    CALL IMPRIME_TAB
    CALL WIN_CHECK ; VERIFICA SE HOUVE VENCEDOR
    JNZ FIM_DE_JOGO
    JMP RODADA_XIS

; AQUI MOSTRARA A OPCAO DE JOGAR NOVAMENTE OU ESCOLHER OUTRO MODO (VOLTAR PAGINA INICIAL)
; (VOLTAR PAGINA INICIAL)
FIM_DE_JOGO:

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
; LE A JOGADA DO USUARIO E ATUALIZA A MATRIZ
    PUSH_ALL


TURNO:
    MOV AH, 1
    LIMPA_TELA
    CALL IMPRIME_TAB

    CMP DL, 'X'
    JE RODADA_X

RODADA_O:
    IMP_STRING TURNO_CIRCULO
    INT 21H
    JMP VALIDA_1a9

RODADA_X:
    IMP_STRING TURNO_XIS
    INT 21H

VALIDA_1a9:
    CMP AL, '1'
    JB  CASA_INVALIDA
    CMP AL, '9'
    JA  CASA_INVALIDA
    JMP EXECUCAO

CASA_INVALIDA:
    IMP_STRING quebralinha
    IMP_STRING quebralinha
    IMP_STRING INVALIDO
    INT 21H
    JMP TURNO

EXECUCAO:
    LEA BX, TABULEIRO
    SUB AL, '1' ; TRANSFORMA O INPUT EM INDICE DA CASA
    XOR AH, AH ; RESETA PARA DIVISAO

    MOV BL,3 ; DEFINE O DIVIDENDO
    DIV BL
    MOV SI, AX
    SHR SI, 8 ; INDICE DA COLUNA CONCLUIDO

    MUL BL ; MULTIPLICO PARA RESULTAR EM INDICE DA LINHA
    MOV BX, AX ; INDICE DA LINHA CONCLUIDO

; VALIDA SE JA FOI JOGADA
    MOV AL, [BX][SI]
    CMP AL, '9'
    JA REPETIDO
    JMP FIM_DA_RODADA

; INDICA AOS JOGADDORES QUE JA FOI JOGADA A CASA SELECIONADA
REPETIDO:
    IMP_STRING quebralinha
    IMP_STRING quebralinha
    IMP_STRING REPETIDA
    MOV AH,1 
    INT 21H
    JMP TURNO ; RETORNA

FIM_DA_RODADA:
    XCHG DL, [BX][SI]  

    POP_ALL
    RET

LER_JOGADA ENDP







WIN_CHECK PROC
    PUSH_ALL
    LEA BX, TABULEIRO
    XOR SI,SI

TEST_123:
    MOV AL, [BX][SI]       
    MOV DL, [BX][SI+1]     
    CMP AL, DL             
    JNE TEST_456
    MOV AL, [BX][SI+1]       
    MOV DL, [BX][SI+2]     
    CMP AL, DL 
    JNE TEST_456
    JMP WINNER

TEST_456:
    MOV AL, [BX+3][SI]       
    MOV DL, [BX+3][SI+1] 
    CMP AL, DL   
    JNE TEST_789
    MOV AL, [BX+3][SI+1]       
    MOV DL, [BX+3][SI+2] 
    CMP AL, DL
    JNE TEST_789
    JMP WINNER   

TEST_789:
    MOV AL, [BX+6][SI]       
    MOV DL, [BX+6][SI+1]     
    CMP AL, DL 
    JNE TEST_147
    MOV AL, [BX+6][SI+1]       
    MOV DL, [BX+6][SI+2]      
    CMP AL, DL 
    JE WIN

TEST_147:
    MOV AL, [BX][SI]       
    MOV DL, [BX+3][SI]     
    CMP AL, DL
    JNE TEST_258
    MOV AL, [BX+3][SI]       
    MOV DL, [BX+6][SI]     
    CMP AL, DL
    JE WIN  

TEST_258:
    MOV AL, [BX][SI+1]       
    MOV DL, [BX+3][SI+1] 
    CMP AL, DL   
    JNE TEST_369
    MOV AL, [BX+3][SI+1]       
    MOV DL, [BX+6][SI+1] 
    CMP AL, DL
    JE WIN 

TEST_369:
    MOV AL, [BX+2][SI]       
    MOV DL, [BX+3][SI+2] 
    CMP AL, DL   
    JNE TEST_159
    MOV AL, [BX+3][SI+2]       
    MOV DL, [BX+6][SI+2] 
    CMP AL, DL
    JE WIN 


TEST_159:
    MOV AL, [BX][SI]       
    MOV DL, [BX+3][SI+1]     
    CMP AL, DL 
    JNE TEST_357
    MOV AL, [BX+3][SI+1]       
    MOV DL, [BX+6][SI+2]     
    CMP AL, DL 
    JE WIN

TEST_357:
    MOV AL, [BX][SI+2]       
    MOV DL, [BX+3][SI+1]     
    CMP AL, DL 
    JNE NO_WIN
    MOV AL, [BX+3][SI+1]       
    MOV DL, [BX+6][SI]     
    CMP AL, DL 
    JE WIN

NO_WIN:
; Não houve vitória
    POP_ALL
    XOR AX, AX
    CMP AX, AX      ; ZF=1
    RET

WINNER: 
WIN:
; Houve vitória
    CMP DL, 'X'
    JE VIT_X 
VIT_O:
    IMP_STRING VITORIA_CIRCULO
    MOV AX, 1
    CMP AX, 0
    POP_ALL
    RET   

VIT_X:
    IMP_STRING VITORIA_XIS
    MOV AX, 1
    CMP AX, 0
    POP_ALL
    RET  

WIN_CHECK ENDP

END MAIN
