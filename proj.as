;ZONA I:	Constantes
SP_INICIAL	EQU	FDFFh
IO_CONTROL	EQU	FFFCh
IO_WRITE	EQU	FFFEh
INT_MASK	EQU	1000100000000011b
INT_MASK_ADDR	EQU	FFFAh
FIM_TEXTO	EQU	'@'
NEXTL		EQU	0100h
PosPista	EQU	001Eh	
LIM_DIR		EQU	1535h
LIM_ESQ		EQU	1520h
POS_TXT_1	EQU	0B17h
POS_TXT_2	EQU	0D16h
POS_TXT_3	EQU	0B22h
POS_TXT_4	EQU	0D16h
ULT_LINHA	EQU	1800h
RESET_CURS	EQU	FF00h
DEL_CAR		EQU	' '
RANDOM_MASK	EQU	1000000000010110b
TIMER_CONTROL	EQU	FFF7h
TIMER_VALUE	EQU	FFF6h
TIMER_ENABLE	EQU	0001h
NIVEL_1_LED	EQU	F000h
NIVEL_2_LED	EQU	FF00h
NIVEL_3_LED	EQU	FFF0h
TURBO_LED	EQU	FFFFh
LED_CONTROL	EQU	FFF8h
TIMER1		EQU	0005h
TIMER2		EQU	0004h
TIMER3		EQU	0003h
DISPLAY_0	EQU	FFF0h
DISPLAY_1	EQU	FFF1h
DISPLAY_2	EQU	FFF2h
DISPLAY_3	EQU	FFF3h
RES_BIKE	EQU	152Ah
RES_O_VARS	EQU	0000h
RES_NIVEL	EQU	0001h
LCD_CONTROL	EQU	FFF4h
LCD_WRITE	EQU	FFF5h
VER_OBIT	EQU	0001h
BIKE_ZONE	EQU	1500h
VER_COL		EQU	00FFh
MAX_OBS		EQU	0004h
LAST_LINE	EQU	1800h
VER_TEN		EQU	000Ah


;ZONA II:	Variaveis
		ORIG	8000h
Pista		STR	'+|                      |+',FIM_TEXTO
Texto1		STR	'Bem-vindo a Corrida de Bicicletas!',FIM_TEXTO
Texto2		STR	'Prima o Interruptor I1 para comecar',FIM_TEXTO
Texto3		STR	'Fim do Jogo!',FIM_TEXTO
Texto4		STR	'Prima o Interruptor I1 para recomecar',FIM_TEXTO
ApagadorTXT	STR	'                                                                                ',FIM_TEXTO
Distancia	STR	'Distancia:',FIM_TEXTO
Maximo		STR	'Maximo:',FIM_TEXTO
CAR_BIKE1	WORD	'O'
CAR_BIKE2	WORD	'|'
Obstaculo	STR	'***',FIM_TEXTO
DelObstaculo	STR	'   ',FIM_TEXTO
BikePos		WORD	152Ah
FlagI0		WORD	0000h
FlagI1		WORD	0000h
FlagIB		WORD	0000h
FlagTemp	WORD 	0000h
Ult_Random 	WORD	0000h
PosObs		TAB	4
CountObs	WORD	0000h
CountMoves	WORD	0000h
Velocidade	WORD	5
FlagFimJogo	WORD	0
Nivel_Jogo	WORD	0001h
Obs_ULT		WORD	0000h
Unidades	WORD	0000h
Dezenas		WORD	0000h
Centenas	WORD	0000h
Milhares	WORD	0000h
LCD_Mask1	WORD	8000h
LCD_Mask2	WORD	8010h
LCD_Mask3	WORD	800Ah
LCD_Mask4	WORD	8018h
LCD_Mask_Exit	WORD	800Eh
Unidades_LCD	WORD	'0'
Dezenas_LCD	WORD	'0'
Centenas_LCD	WORD	'0'
Milhares_LCD	WORD	'0'
DMilhar_LCD	WORD	'0'
M_Unidades_LCD	WORD	'0'
M_Dezenas_LCD	WORD	'0'
M_Centenas_LCD	WORD	'0'
M_Milhares_LCD	WORD	'0'
M_DMilhar_LCD	WORD	'0'
Reset_STR	WORD	'0'
Metros		WORD	'm'
Ver_Ten_LCD	WORD	':'



;ZONA III:	Tabela Interrupcoes
		ORIG	FE00h
Int0		WORD	Interrupcao0
Int1		WORD	Interrupcao1
		ORIG	FE0Bh
IntB		WORD	InterrupcaoB
		ORIG	FE0Fh
IntTemp		WORD	Temporizador	

;ZONA IV:	Codigo
		ORIG	0000h
		MOV	R7, SP_INICIAL
		MOV	SP, R7			;Inicia Pilha
		MOV	R7, FFFFh
		MOV	M[IO_CONTROL], R7	;Ativa Modo grafico
		MOV	R7, INT_MASK
		MOV	M[INT_MASK_ADDR], R7	;Ativa interrupcoes		
		ENI
		JMP	Inicio

Interrupcao0:	INC	M[FlagI0]		
		RTI

Interrupcao1:	INC	M[FlagI1]
		RTI

InterrupcaoB:	INC	M[FlagIB]
		RTI

Temporizador:	PUSH	R7
		INC	M[FlagTemp]
		MOV	R7, M[Velocidade]
		MOV	M[TIMER_VALUE], R7
		MOV	R7, TIMER_ENABLE
		MOV	M[TIMER_CONTROL], R7
		POP	R7
		RTI

;ZONA IV.II:	Rotina Gerais

;Random:	Gera um numero pseudo-aleatorio atraves de um algoritmo
;		Entradas:	---
;		Saidas:		---
;		Efeitos:	---
Random:		PUSH	R1
		MOV	R1, M[Ult_Random]
		AND	R1, VER_OBIT
		CMP	R1, R0
		BR.NZ	Random_ALT
		ROR	M[Ult_Random],1
		POP	R1
		RET
Random_ALT:	MOV	R1, RANDOM_MASK
		XOR	M[Ult_Random], R1
		ROR	M[Ult_Random],1
		POP	R1
		RET

;EscCar_LCD:	Imprime no ecra o caracter
;		Entradas:	R3: Caracter, R4: Posicao
;		Saidas:		---
;		Efeitos:	Escreve no LCD
EscCar_LCD:	MOV	M[LCD_CONTROL], R4
		MOV	M[LCD_WRITE], R3
		RET
	

;EscString_LCD:	Imprime no ecra uma cadeia de caracteres
;		Entradas:	R1: String, R2: Posicao
;		Saidas:		---
;		Efeitos:	Escreve no LCD
EscString_LCD:	PUSH	R1
		PUSH	R2
		PUSH	R3
		PUSH	R4
		PUSH	R5
		MOV	R5, FIM_TEXTO
CicString_LCD:	CMP	M[R1], R5
		BR.Z	FimString_LCD
		MOV	R3, M[R1]
		MOV	R4, R2
		CALL	EscCar_LCD
		INC	R1
		INC	R2
		BR	CicString_LCD
FimString_LCD:	POP	R5
		POP	R4
		POP	R3
		POP	R2
		POP	R1
		RET


		

	
		
;EscCar:	Imprime no ecra o caracter
;		Entradas:	R3: Caracter, R4: Posicao
;		Saidas:		---
;		Efeitos:	Escreve na janela de texto
EscCar:		MOV	M[IO_CONTROL], R4
		MOV	M[IO_WRITE], R3
		RET
;Refresh_ALL:	Rotia auxiliar para actualizar todos os parametros relacionados com o nivel de jogo
;		Entradas:	---
;		Saidas:		---
;		Efeitos:	---
Refresh_All:	CALL	Refresh_LED
		CALL	Refresh_Timer
		CALL	Display_Ref
		CALL	Ref_LCD
		RET	

;EscString:	Imprime no ecra uma cadeia de caracteres
;		Entradas:	R1: String, R2: Posicao
;		Saidas:		---
;		Efeitos:	Escreve na janela de texto
EscString:	PUSH	R1
		PUSH	R2
		PUSH	R3
		PUSH	R4
		PUSH	R5
		MOV	R5, FIM_TEXTO
CicloEscString:	CMP	M[R1], R5
		BR.Z	FimEscString
		MOV	R3, M[R1]
		MOV	R4, R2
		CALL	EscCar
		INC	R1
		INC	R2
		BR	CicloEscString
FimEscString:	POP	R5
		POP	R4
		POP	R3
		POP	R2
		POP	R1
		RET

;LimpaEcra:	Limpa a janela de texto
;		Entradas:	---
;		Saidas:		---
;		Efeitos:	Escreve na janela de texto
LimpaEcra:	PUSH	R1
		PUSH	R2
		MOV	R2, R0
CicloLimpaEcra:	AND	R2, RESET_CURS
		MOV	R1, ApagadorTXT
		CALL	EscString
		ADD	R2, NEXTL
		CMP	R2, ULT_LINHA
		BR.N	CicloLimpaEcra
		POP	R2
		POP	R1
		RET

;DesenhaBike:	Imprime no ecra a bicicleta
;		Entradas:	---
;		Saidas:		---
;		Efeitos:	Escreve na janela de texto
DesenhaBike:	MOV	R3, M[CAR_BIKE1]
		MOV	R4, M[BikePos]
		CALL	EscCar
		ADD 	R4, NEXTL
		MOV	R3, M[CAR_BIKE2]
		CALL	EscCar
		ADD	R4, NEXTL
		MOV	R3, M[CAR_BIKE1]
		CALL	EscCar
		RET

;ApagaBike:	Apaga a bicicleta do local onde se encontra
;		Entradas	---
;		Saidas		---
;		Efeitos		Apaga a bicicleta da janela de texto
ApagaBike:	MOV	R3, DEL_CAR
		MOV	R4, M[BikePos]
		CALL	EscCar
		ADD 	R4, NEXTL
		CALL	EscCar
		ADD	R4, NEXTL
		CALL	EscCar
		RET

;MoveBikeEsq:	Desloca Bicicleta a esquerda
;		Entradas	---
;		Saidas		---
;		Efeitos		Apaga a bicicleta, decrementa a sua posição e torna a desenhá-la na janela de texto
MoveBikeEsq:	CMP	M[FlagI0], R0
		BR.Z	FimMoveBikeEsq
		MOV	M[FlagI0], R0
		MOV	R1, LIM_ESQ
		CMP	M[BikePos], R1
		BR.Z	FimMoveBikeEsq
		CALL	ApagaBike		
		DEC	M[BikePos]
		CALL	DesenhaBike
FimMoveBikeEsq:	RET

;MoveBikeDir:	Desloca Bicicleta a direita
;		Entradas	---
;		Saidas		---
;		Efeitos		Apaga a bicicleta, incrementa a sua posicao e volta a desenha-la na janela de texto	
MoveBikeDir:	CMP	M[FlagIB], R0
		BR.Z	FimMoveBikeDir
		MOV	M[FlagIB], R0
		MOV	R1, LIM_DIR
		CMP	M[BikePos], R1
		BR.Z	FimMoveBikeDir
		CALL	ApagaBike
		INC	M[BikePos]
		CALL	DesenhaBike
FimMoveBikeDir:	RET

;DesenhaEstrada:Imprime no ecra a bicicleta
;		Entradas:	---
;		Saidas:		---
;		Efeitos:	Escreve na janela de texto
DesenhaEstrada:	MOV	R2, PosPista
CicloEstrada:	AND	R2, RESET_CURS
		ADD	R2, PosPista
		MOV	R1, Pista
		CALL	EscString
		ADD	R2, NEXTL
		CMP	R2, ULT_LINHA
		BR.N	CicloEstrada
		RET	

;Desenha_Obs:	Desenha os obstaculos no 
;		Entradas:	---
;		Saidas:		---
;		Efeitos:	Escreve na janela de texto os obstaculos
Desenha_Obs:	PUSH	R1
		MOV	R1,PosObs
		CMP	M[R1],R0
		CALL.NZ	Desenha_Obs_Aux
		INC	R1
		CMP	M[R1],R0
		CALL.NZ	Desenha_Obs_Aux
		INC	R1
		CMP	M[R1],R0
		CALL.NZ	Desenha_Obs_Aux
		INC	R1
		CMP	M[R1],R0
		CALL.NZ	Desenha_Obs_Aux
		POP	R1
		RET

;Desenha_Obs_Aux:Desenha o obstaculo com posicao em R1 no ecra
;		Entradas:	R1: Posicao de memoria da posicao do meteoro
;		Saidas:		---
;		Efeitos:	Escreve na janela de texto um obstaculo
Desenha_Obs_Aux:PUSH	R1
		PUSH	R2
		MOV	R2,M[R1]
		MOV	R1, Obstaculo
		CALL	EscString
		POP	R2
		POP	R1		
		RET 
;Apaga_Obs:	Apaga os obstaculos na janela de texto 
;		Entradas:	---
;		Saidas:		---
;		Efeitos:	Elimina os obstaculos da janela de texto
Apaga_Obs:	PUSH	R1
		MOV	R1,PosObs
		CALL	Apaga_Obs_Aux
		INC	R1
		CALL	Apaga_Obs_Aux
		INC	R1
		CALL	Apaga_Obs_Aux
		INC	R1
		CALL	Apaga_Obs_Aux
		POP	R1
		RET

;Apaga_Obs_Aux:	Apaga o obstaculo com posicao em R1 no ecra
;		Entradas:	R1: Posicao de memoria da posicao do meteoro
;		Saidas:		---
;		Efeitos:	Apaga um obstaculo no ecra
Apaga_Obs_Aux:	PUSH	R1
		PUSH	R2
		MOV	R2,M[R1]
		MOV	R1, DelObstaculo
		CALL	EscString
		POP	R2
		POP	R1		
		RET 


;Gera_Obs:	Gera um obstaculo
;		Entradas:	---
;		Saidas:		---
;		Efeitos:	Altera a memoria, e escreve no ecra
Gera_Obs:	PUSH	R1
		PUSH	R2
		PUSH	R3
		PUSH	R4
		MOV	R1,6				; Numero de movimentos necessario ate gerar um novo obstaculo
		MOV	M[CountMoves],R1
		CALL	Random
		MOV	R3,M[Ult_Random]
		MOV	R4,20				; 20 e o numero de espacos onde a posicao relativa ao obstaculo pode ser associada
		DIV	R3,R4
		ADD	R4,32				; 32 e a primeira coluna dentro da pista
		MOV	R1,PosObs
CicloGera_Obs:	CMP	M[R1],R0
		BR.Z	ColocaObs
		INC	R1
		BR	CicloGera_Obs
ColocaObs:	MOV	M[R1],R4
		CALL	Desenha_Obs
		POP	R4
		POP	R3
		POP	R2
		POP	R1
		RET


;Move_Obs:	Move obstaculos
;		Entradas:	---
;		Saidas:		---
;		Efeitos:	Altera as posicoes dos obstaculos no ecra
Move_Obs:	PUSH	R1
		PUSH	R2
		MOV	M[FlagTemp],R0
		DEC	M[CountMoves]
		CALL	FimJogo
		CALL	Apaga_Obs
		MOV	R2,NEXTL
		MOV	R1,PosObs
MoveObs1:	CMP	M[R1],R0
		BR.Z	MoveObs2
		ADD	M[R1],R2
MoveObs2:	INC	R1
		CMP	M[R1],R0
		BR.Z	MoveObs3
		ADD	M[R1],R2
MoveObs3:	INC	R1
		CMP	M[R1],R0
		BR.Z	MoveObs4
		ADD	M[R1],R2
MoveObs4:	INC	R1
		CMP	M[R1],R0
		BR.Z	EndMovObs
		ADD	M[R1],R2
EndMovObs:	CALL	Limpa_Obs
		CALL	Desenha_Obs
		CALL	FimJogo
		INC	M[Unidades_LCD]
		POP	R2
		POP	R1
		RET


;Limpa_Obs:	Limpa a posicao de um obstaculo uma vez que este ultrapasse o final da pista
;		Entradas:	---
;		Saidas:		---
;		Efeitos:	Altera a memoria
Limpa_Obs:	PUSH	R1
		PUSH	R2
		PUSH	R3
		PUSH	R4
		MOV	R1,PosObs
		MOV	R2, LAST_LINE
		MOV	R4, MAX_OBS	
CicloLimpa_Obs:	CMP	R4,R0
		BR.Z	FimLimpa_Obs2
		DEC	R4
		MOV	R3,M[R1]		
		CMP	R3,R2
		BR.NN	FimLimpa_Obs1
		INC	R1
		BR	CicloLimpa_Obs
FimLimpa_Obs1:	MOV	M[R1],R0
		INC	M[Obs_ULT]
		INC	M[Unidades]
FimLimpa_Obs2:	POP	R4
		POP	R3
		POP	R2
		POP	R1
		RET

;Refresh_LVL:	Actualiza o nivel de jogo
;		Entradas:	---
;		Saidas:		---
;		Efeitos:	Actualiza o conteudo da posicao de memoria com o endereco relativo a Nivel_Jogo
Refresh_LVL:	PUSH	R1
		PUSH	R2
		MOV	R1, M[Nivel_Jogo]
		CMP	R1, 3			;3 e o nivel maximo de jogo, nao tendo sido adicionado as constantes
		BR.Z	End_LVL
		MOV	R2, M[Obs_ULT]
		CMP	R2, 4			;4 e o numero de obstaculos necessario para passar de nivel
		BR.NZ	End_LVL
		INC	M[Nivel_Jogo]
		MOV	M[Obs_ULT], R0
End_LVL:	POP	R2
		POP	R1
		RET
;Refresh_LED:	Actualiza o numero de LED's ligados conforme o nivel de jogo
;		Entradas:	---
;		Saidas:		---
;		Efeitos:	Actualiza o conteudo da posicao de memoria com endereco LED_CONTROL
Refresh_LED:	PUSH	R1
		PUSH	R2
		MOV	R1, M[Nivel_Jogo]
		CMP	R1, 1
		BR.Z	LED_1
		CMP	R1, 2
		BR.Z	LED_2
		CMP	R1, 3
		BR.Z	LED_3
LED_1:		MOV	R2, NIVEL_1_LED
		MOV	M[LED_CONTROL], R2
		BR	End_LED
LED_2:		MOV	R2, NIVEL_2_LED
		MOV	M[LED_CONTROL],	R2
		BR	End_LED
LED_3:		MOV	R2, NIVEL_3_LED
		MOV	M[LED_CONTROL], R2
End_LED:	POP	R2
		POP	R1
		RET
;Refresh_Timer:	Actualiza a velocidade do jogo conforme o nivel de jogo
;		Entradas:	---
;		Saidas:		---
;		Efeitos:	Altera o conteudo da posicao de memoria com o endereco respectivo a Velocidade
Refresh_Timer:	PUSH	R1
		PUSH	R2
		MOV	R1, M[Nivel_Jogo]
		CMP	R1, 1
		BR.Z	Timer_1
		CMP	R1, 2			;1 ,2 e 3 sao os niveis de jogo possiveis
		BR.Z	Timer_2
		CMP	R1,3
		BR.Z	Timer_3
Timer_1:	MOV	R2, TIMER1
		MOV	M[Velocidade],	R2
		BR	End_Timer
Timer_2:	MOV	R2, TIMER2
		MOV	M[Velocidade],	R2
		BR	End_Timer
Timer_3:	MOV	R2, TIMER3
		MOV	M[Velocidade], R2
End_Timer:	POP	R2
		POP	R1
		RET


;Display_Ref:	Actualiza o numero de obstaculos ultrapassados no display
;		Entradas:	---
;		Saidas:		---
;		Efeitos:	Actualiza as posicoes de memoria com os enderecos responsaveis pela escrita nos 4 portos do display
Display_Ref:	PUSH	R1
		PUSH	R2
		PUSH	R3
		PUSH	R4
		MOV	R1, M[Unidades]
		CMP	R1, VER_TEN
		CALL.Z	Null_U
		MOV	R2, M[Dezenas]
		CMP	R2, VER_TEN
		CALL.Z	Null_D
		MOV	R3, M[Centenas]
		CMP	R3, VER_TEN
		CALL.Z	Null_C
		MOV	R4, M[Milhares]
		CMP	R4, VER_TEN
		CALL.Z	Null_M
		MOV	M[DISPLAY_0], R1
		MOV	M[DISPLAY_1], R2
		MOV	M[DISPLAY_2], R3
		MOV	M[DISPLAY_3], R4
		POP	R4
		POP	R3
		POP	R2
		POP	R1
		RET

;Null_U:	Aumenta uma unidade nas dezenas e coloca as unidades a 0
;		Entradas:	---
;		Saidas:		---
;		Efeitos:	Altera as posicoes de memoria com enderecos respectivos a Unidades e Dezenas 
Null_U:		MOV	M[Unidades], R0
		INC	M[Dezenas]
		RET

;Null_D:	Aumenta uma unidade nas centenas e coloca as dezenas a 0
;		Entradas:	---
;		Saidas:		---
;		Efeitos:	Altera as posicoes de memoria com enderecos respectivos a Dezenas e Centenas 
Null_D:		MOV	M[Dezenas], R0
		INC	M[Centenas]
		RET

;Null_U:	Aumenta uma unidade nos milhares e coloca as centenas a 0
;		Entradas:	---
;		Saidas:		---
;		Efeitos:	Altera as posicoes de memoria com enderecos respectivos a Centenas e Milhares
Null_C:		MOV	M[Centenas], R0
		INC	M[Milhares]
		RET

;Null_M:	Coloca os milhares a 0
;		Entradas:	---
;		Saidas:		---
;		Efeitos:	Altera a posicao de memoria com endereco respectivo a Milhares 
Null_M:		MOV	M[Milhares], R0
		RET


;Escreve_LCD1:	Escreve  no LCD as strings 'Distancia:' e 'Maximo:'	
;		Entradas:	---
;		Saidas:		---
;		Efeitos:	Imprime strings no LCD
Escreve_LCD1:	PUSH	R1
		PUSH	R2
		MOV	R1, Distancia
		MOV	R2, M[LCD_Mask1]
		CALL	EscString_LCD
		MOV	R1, Maximo
		MOV	R2, M[LCD_Mask2]
		CALL	EscString_LCD
		POP	R2
		POP	R1
		RET	

;Escreve_LCD2:	Escreve no LCD os caracteres que formam a forma do numero 'XXXXXm' na primeira linha do LCD ou seja a distancia percorrida	
;		Entradas:	---
;		Saidas:		---
;		Efeitos:	Imprime Caracteres no LCD
Escreve_LCD2:	PUSH	R3
		PUSH	R4
		MOV	R3, M[DMilhar_LCD]
		MOV	R4, M[LCD_Mask3] 
		CALL	EscCar_LCD
		MOV	R3, M[Milhares_LCD]
		INC	R4
		CALL	EscCar_LCD
		MOV	R3, M[Centenas_LCD]
		INC	R4
		CALL	EscCar_LCD
		MOV	R3, M[Dezenas_LCD]
		INC	R4
		CALL	EscCar_LCD
		MOV	R3, M[Unidades_LCD]
		INC	R4
		CALL	EscCar_LCD
		MOV	R3, M[Metros]
		INC	R4
		CALL	EscCar_LCD
		POP	R4
		POP	R3
		RET
;Escreve_LCD3:	Escreve  no LCD os caracteres que formam a forma do numero 'XXXXXm', na segunda linha linha do Maximo.	
;		Entradas:	---
;		Saidas:		---
;		Efeitos:	Imprime Caracteres no LCD
Escreve_LCD3:	PUSH	R3
		PUSH	R4
		MOV	R3, M[M_DMilhar_LCD]
		MOV	R4, M[LCD_Mask4] 
		CALL	EscCar_LCD
		MOV	R3, M[M_Milhares_LCD]
		INC	R4
		CALL	EscCar_LCD
		MOV	R3, M[M_Centenas_LCD]
		INC	R4
		CALL	EscCar_LCD
		MOV	R3, M[M_Dezenas_LCD]
		INC	R4
		CALL	EscCar_LCD
		MOV	R3, M[M_Unidades_LCD]
		INC	R4
		CALL	EscCar_LCD
		MOV	R3, M[Metros]
		INC	R4
		CALL	EscCar_LCD
		POP	R4
		POP	R3
		RET
;Ref_M_Vars:	Actualiza os digitos do Maximo percorrido.
;		Entradas:	---
;		Saidas:		---
;		Efeitos:	Altera o conteudo das posicoes de memoria com enderecos relativos aos diferentes digitos do Maximo	
Ref_M_Vars:	PUSH	R1
		MOV 	R1, M[DMilhar_LCD]
		CMP	R1, M[M_DMilhar_LCD]
		BR.N	No_Update_DM
		CMP	R1, M[M_DMilhar_LCD]
		BR.Z	No_Update_DM
		CALL	Update_DM
		POP	R1
		RET
No_Update_DM:	MOV 	R1, M[Milhares_LCD]
		CMP	R1, M[M_Milhares_LCD]
		BR.N	No_Update_M
		CMP	R1, M[M_Milhares_LCD]
		BR.Z	No_Update_M
		CALL	Update_M
		POP	R1
		RET
No_Update_M:	MOV 	R1, M[Centenas_LCD]
		CMP	R1, M[M_Centenas_LCD]
		BR.N	No_Update_C
		CMP	R1, M[M_Milhares_LCD]
		BR.Z	No_Update_C
		CALL	Update_C
		POP	R1
		RET
No_Update_C:	MOV 	R1, M[Dezenas_LCD]
		CMP	R1, M[M_Dezenas_LCD]
		BR.N	No_Update_D
		CMP	R1, M[M_Milhares_LCD]
		BR.Z	No_Update_D
		CALL	Update_D
		POP	R1
		RET
No_Update_D:	MOV 	R1, M[Unidades_LCD]
		CMP	R1, M[M_Unidades_LCD]
		BR.N	No_Update
		CMP	R1, M[M_Milhares_LCD]
		BR.Z	No_Update
		CALL	Update_U
		POP	R1
		RET
No_Update:	POP	R1
		RET

;Update_DM:	Actualiza o valor do maximo, incluindo todos os digitos
;		Entradas:	---
;		Saidas:		---
;		Efeitos: Altera o conteudo das posicoes de memoria com enderecos relativos a todos os digitos do maximo
Update_DM:	PUSH	R1
		MOV	M[M_DMilhar_LCD], R1
		MOV 	R1, M[Milhares_LCD]
		MOV	M[M_Milhares_LCD], R1
		MOV 	R1, M[Centenas_LCD]
		MOV	M[M_Centenas_LCD], R1
		MOV 	R1, M[Dezenas_LCD]
		MOV	M[M_Dezenas_LCD], R1
		MOV 	R1, M[Unidades_LCD]
		MOV	M[M_Unidades_LCD], R1
		POP	R1
		RET

;Update_M:	Actualiza o valor do maximo, incluindo todos os digitos menos as dezenas de milhar
;		Entradas:	---
;		Saidas:		---
;		Efeitos: Altera o conteudo das posicoes de memoria com enderecos relativos a todos os digitos do maximo excepto as dezenas de milhar
Update_M:	PUSH	R1
		MOV	M[M_Milhares_LCD], R1
		MOV 	R1, M[Centenas_LCD]
		MOV	M[M_Centenas_LCD], R1
		MOV 	R1, M[Dezenas_LCD]
		MOV	M[M_Dezenas_LCD], R1
		MOV 	R1, M[Unidades_LCD]
		MOV	M[M_Unidades_LCD], R1
		POP	R1
		RET

;Update_C:	Actualiza o valor do maximo, incluindo os digitos das unidades dezenas e centenas
;		Entradas:	---
;		Saidas:		---
;		Efeitos: Altera o conteudo das posicoes de memoria com enderecos relativos as unidades, as dezenas, e as centenas
Update_C:	PUSH	R1
		MOV	M[M_Centenas_LCD], R1
		MOV 	R1, M[Dezenas_LCD]
		MOV	M[M_Dezenas_LCD], R1
		MOV 	R1, M[Unidades_LCD]
		MOV	M[M_Unidades_LCD], R1
		POP	R1
		RET

;Update_D:	Actualiza o valor do maximo, incluindo os digitos das unidades e dezenas
;		Entradas:	---
;		Saidas:		---
;		Efeitos: Altera o conteudo das posicoes de memoria com enderecos relativos as unidades e as dezenas
Update_D:	PUSH	R1
		MOV	M[M_Dezenas_LCD], R1
		MOV 	R1, M[Unidades_LCD]
		MOV	M[M_Unidades_LCD], R1
		POP	R1
		RET

;Update_U:	Actualiza o valor do maximo, incluindo os digitos das unidades
;		Entradas:	---
;		Saidas:		---
;		Efeitos: Altera o conteudo das posicoes de memoria com endereco relativos as unidades 
Update_U:	MOV	M[M_Unidades_LCD], R1
		POP	R1
		RET

		
		


		
;Ref_LCD:	Rotina auxiliar para actualizar todos os parametros do LCD
;		Entradas:	---
;		Saidas:		---
;		Efeitos:	---
Ref_LCD:	CALL	Ref_LCD_Val
		CALL	Escreve_LCD1
		CALL	Escreve_LCD2
		CALL	Escreve_LCD3
		RET

;Ref_LCD_Val:	Actualiza os digitos da distncia percorrida
;		Entradas:	---
;		Saidas:		---
;		Efeitos:	Altera o conteudo das posicoes de memoria com enderecos relativos aos digitos da distancia	
Ref_LCD_Val:	PUSH	R1
		PUSH	R2
		PUSH	R3
		PUSH	R4
		PUSH	R5
		MOV	R1, M[Unidades_LCD]
		CMP	R1, M[Ver_Ten_LCD]
		CALL.Z	Null_U_LCD
		MOV	R2, M[Dezenas_LCD]
		CMP	R2, M[Ver_Ten_LCD]
		CALL.Z	Null_D_LCD
		MOV	R3, M[Centenas_LCD]
		CMP	R3, M[Ver_Ten_LCD]
		CALL.Z	Null_C_LCD
		MOV	R4, M[Milhares_LCD]
		CMP	R4, M[Ver_Ten_LCD]
		CALL.Z	Null_M_LCD
		MOV	R5, M[DMilhar_LCD]
		CMP	R5, M[Ver_Ten_LCD]
		CALL.Z	Null_DM_LCD
		POP	R5
		POP	R4
		POP	R3
		POP	R2
		POP	R1
		RET

;Null_U_LCD:	Coloca as unidades do numero distancia do LCD a 0 e aumenta as dezenas do mesmo numero
;		Entradas:	---
;		Saidas:		---
;		Efeitos:	Altera as posicoes de memoria com enderecos respectivos a Unidades_LCD e Dezenas_LCD
Null_U_LCD:	PUSH	R1
		MOV	R1, M[Reset_STR]
		MOV	M[Unidades_LCD], R1
		INC	M[Dezenas_LCD]
		POP	R1
		RET

;Null_D_LCD:	Coloca as dezenas do numero distancia do LCD a 0 e aumenta as centenas do mesmo numero
;		Entradas:	---
;		Saidas:		---
;		Efeitos:	Altera as posicoes de memoria com enderecos respectivos a Dezenas_LCD e Centenas_LCD
Null_D_LCD:	PUSH	R1
		MOV	R1, M[Reset_STR]
		MOV	M[Dezenas_LCD], R1
		INC	M[Centenas_LCD]
		POP	R1
		RET

;Null_C_LCD:	Coloca as centenas do numero distancia do LCD a 0 e aumenta os milhares do mesmo numero
;		Entradas:	---
;		Saidas:		---
;		Efeitos:	Altera as posicoes de memoria com enderecos respectivos a Centenas_LCD e Milhares_LCD
Null_C_LCD:	PUSH	R1
		MOV	R1, M[Reset_STR]
		MOV	M[Centenas_LCD], R1
		INC	M[Milhares_LCD]
		POP	R1
		RET

;Null_M:	Coloca os milhares do numero distancia do LCD a 0 e aumenta as dezenas de milhar do mesmo numero
;		Entradas:	---
;		Saidas:		---
;		Efeitos:	Altera as posicoes de memoria com enderecos respectivos a Milhares_LCD e DMilhar_LCD
Null_M_LCD:	PUSH	R1
		MOV	R1, M[Reset_STR]
		MOV	M[Milhares_LCD], R1
		INC	M[DMilhar_LCD]
		POP	R1
		RET

;Null_M:	Coloca as dezenas de milhar do numero distancia do LCD a 0
;		Entradas:	---
;		Saidas		---
;		Efeitos: Altera a posicao de memoria com o endereco respectivo  DMilhar_LCD
Null_DM_LCD:	PUSH	R1
		MOV	R1, M[Reset_STR]
		MOV	M[DMilhar_LCD], R1
		POP	R1
		RET



;Reset_Vars:	Reinicia as variaveis que sofrem alteracoes durante o jogo, sem alterar os digitos do maximo
;		Entradas:	---
;		Saidas:		---
;		Efeitos:	Reinicia o conteudo das posicoes de memoria com o endereco das variaveis que foram alteradas durante o jogo
Reset_Vars:	PUSH	R1
		PUSH	R2
		MOV	R1, RES_BIKE
		MOV	M[BikePos], R1
		MOV	R1, RES_O_VARS
		MOV	M[CountObs], R1
		MOV	M[CountMoves], R1
		MOV	M[Obs_ULT], R1
		MOV	M[Unidades], R1
		MOV	M[Dezenas], R1
		MOV	M[Centenas], R1
		MOV	M[Milhares], R1
		MOV	R2, PosObs
		MOV 	M[R2], R1
		INC	R2
		MOV 	M[R2], R1
		INC	R2
		MOV 	M[R2], R1
		INC	R2
		MOV	M[R2], R1
		MOV	R1, M[Reset_STR]
		MOV	M[Unidades_LCD], R1
		MOV	M[Dezenas_LCD], R1
		MOV	M[Centenas_LCD], R1
		MOV	M[Milhares_LCD], R1
		MOV	M[DMilhar_LCD], R1
		MOV	R1, RES_NIVEL
		MOV	M[Nivel_Jogo], R1
		POP	R2
		POP	R1
		RET





;FimJogo:	Verifica se a bicicleta bateu num obstaculo
;		Entradas:	---
;		Saidas:		---
;		Efeitos:	---
FimJogo:	PUSH	R1
		PUSH	R2
		PUSH	R3
		PUSH	R4
		MOV	R1,PosObs
		MOV	R2, BIKE_ZONE
		CMP	M[R1],R2
		BR.NN	Loss_Ver
		INC	R1
		CMP	M[R1],R2
		BR.NN	Loss_Ver
		INC	R1
		CMP	M[R1],R2
		BR.NN	Loss_Ver
		INC	R1
		CMP	M[R1],R2
		BR.NN	Loss_Ver
		BR	Fim_FimJogo
Loss_Ver:	MOV	R3,M[BikePos]
		AND	R3, VER_COL
First:		MOV	R4,M[R1]
		AND	R4, VER_COL
		CMP	R3,R4
		BR.NZ	Second
		INC	M[FlagFimJogo]
Second:		INC	R4
		CMP	R3,R4
		BR.NZ	Third
		INC	M[FlagFimJogo]
Third:		INC	R4
		CMP	R3,R4
		BR.NZ	Fim_FimJogo
		INC	M[FlagFimJogo]		
Fim_FimJogo:	POP	R4
		POP	R3
		POP	R2
		POP	R1
		RET





;ZONA IV:	Codigo principal
;Inicio		Comeca por escrever as mensagens iniciais
;		Entradas:	---
;		Saidas:		---
Inicio:		MOV	R1, Texto1
		MOV	R2, POS_TXT_1
		CALL	EscString
		MOV	R1, Texto2
		MOV	R2, POS_TXT_2
		CALL	EscString
cicloinicio:	INC	M[Ult_Random]	; Existe sempre uma comparacao para ver se o jogador clicou no butao da int1, para iniciar o jogo,
		CMP	M[FlagI1], R0	; dependendo do tempo demorado um numero pseudo-aleatorio diferente e gerado
		BR.Z	cicloinicio
		CALL	LimpaEcra
		CALL	DesenhaEstrada
		CALL	DesenhaBike
		MOV	R7, M[Velocidade]
		MOV	M[TIMER_VALUE], R7
		MOV	R7, TIMER_ENABLE
		MOV	M[TIMER_CONTROL], R7
ciclojogo:	CALL	MoveBikeEsq	; Ciclo principal que realiza todas as funcoes basicas do jogo
		CALL	MoveBikeDir
		CMP	M[CountMoves], R0
		CALL.Z	Gera_Obs
		CMP	M[FlagTemp],R0
		CALL.NZ	Move_Obs
		CALL	Refresh_LVL
		CALL	Refresh_All
		CMP	M[FlagFimJogo],R0
		BR.Z	ciclojogo
GameOver:	MOV	M[FlagI1], R0
		CALL	LimpaEcra
		MOV	R1, Texto3
		MOV	R2, POS_TXT_3
		CALL	EscString
		MOV	R1, Texto4
		MOV	R2, POS_TXT_4
		CALL	EscString
		CALL	Ref_M_Vars
		CALL	Escreve_LCD3
		CALL	Reset_Vars
		MOV	M[FlagFimJogo], R0
Reinicia:	CMP	M[FlagI1], R0
		BR.Z	Reinicia
fim:		JMP	cicloinicio
