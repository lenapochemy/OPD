		ORG 	0x0
V0:	WORD	$DEFAULT, 0x180 	;вектор прерывания #0
V1:	WORD	$DEFAULT, 0x180	;вектор прерывания #1 
V2:	WORD	$INT2, 0x180			;вектор прерывания #2 (для ВУ-2)
V3:	WORD	$INT3, 0x180			;вектор прерывания #3 (для ВУ-3)
V4:	WORD	$DEFAULT, 0x180	;вектор прерывания #4
V5:	WORD	$DEFAULT, 0x180	;вектор прерывания #5
V6:	WORD	$DEFAULT, 0x180	;вектор прерывания #6
V7:	WORD	$DEFAULT, 0x180	;вектор прерывания #7
DEFAULT: 	IRET 		;обработка прерываний по умолчанию

		ORG 	0x021
X:		WORD 	0x0000	;переменная x
MIN:	WORD	0xFFBD	;минимальное значение x
MAX:	WORD	0x003C	;максимальное значение x
HELP: WORD	0x0000	;вспомогательная ячейка, для операции маскирования


START:	DI
		CLA			;запрет прерываний на неиспользуемых ВУ
		OUT		0x1		
		OUT 		0x3
		OUT 		0xB
		OUT		0xD
		OUT 		0x11
		OUT 		0x15
		OUT 		0x19
		OUT		0x1D

		LD 		#0xA 			; разрешить прерывания и вектор №2
		OUT 		5 			; (1000|0010=1010) в MR КВУ-2
		LD 		#0xB 			; разрешить прерывания и вектор №3 
		OUT 		7 			; (1000|0011=1011) в MR КВУ-3
		EI

MAIN:	
		DI			;запрет прерываний, для атомарности программы
		LD			X
		SUB 		#0x03		;уменьшение х на три
		CALL		CHECK	;проверка на одз
		ST			X
		NOP 		;(первый NOP для проверки цикла на одз)
		EI
		JUMP		MAIN

;F(X) = 2X+7

INT3:	
			LD			X
			ASL 				;X -> 2X
			ADD		#0x07	;2X -> 2X+7
			OUT		6
			NOP 		;(второй NOP для проверки прерывания на ВУ-3)
			IRET
						
INT2:	
			CLA
			IN 		4		;получаем 4 младших разряда из РД ВУ-2
		
			NOP 		;(третий NOP для проверки прерывания на ВУ-2)
				
			ASL
			ASL
			ASL
			ASL
			SXTB
			ST		$HELP

			LD		X		;получаем 4 младших разряда из Х
			SWAB
			
			ASL
			ASL
			ASL
			ASL

			CLC
			
			ROL
			ROL
			ROL
			ROL
			ROL
			
			ADD		$HELP		;маскирование сделано
			SXTB
			CALL		CHECK		;проверка на одз
			ST			X				;сохранение в х
			NOP 		;(четвертый NOP для проверки прерывания на ВУ-2)
			IRET
		
CHECK:				;проверка на одз

CMIN:	CMP		MIN 	;проверка на минимальное
			BGE		CMAX
			JUMP		LDMAX

CMAX:	CMP		MAX		;проверка на максимальное
			BEQ		RETURN
			BLT		RETURN

LDMAX:	LD			MAX
			

RETURN:	RET

		
		
