;********************************************************************************************
;       Exp#1_Source_Code.s
;       Example Assembly Code to start experiment #1
;
;       Project Team Members: Roger Younger
;
;
;       Version 1.0      Feb. 13, 2020
;
;********************************************************************************************

        INCLUDE STM32L4R5xx_constants.inc


        AREA program, CODE, READONLY
		EXPORT ASSEMBLY_INIT
		ALIGN
		
ASSEMBLY_INIT
	PUSH {R14}
	LDR R0, =RCC_BASE
	LDR R1, [R0, #RCC_AHB2ENR]
	ORR R1, R1, #(RCC_AHB2ENR_GPIOFEN)      ; Enables clock for GPIOF
	STR R1, [R0, #RCC_AHB2ENR]

	; MODE: 00: Input mode, 01: General purpose output mode
    ;       10: Alternate function mode, 11: Analog mode (reset state)
	LDR R0, =GPIOF_BASE                     ; Base address for GPIOF
	; CpE5151 Programers code continues here
	LDR R1, [R0, #GPIO_MODER]
	BIC R1, R1, #(0xFF<<(2*12))
	ORR R1, R1, #(0x55<<(2*12))
	STR R1,[R0, #GPIO_MODER] ; Store modified mode reg
	LDR R1,[R0, #GPIO_OTYPER]  ; Read output type
	BIC R1, R1, #(0x0F<<12)
	STR R1,[R0, #GPIO_OTYPER]
	LDR R1,[R0, #GPIO_ODR]         ; Read the output data reg
	ORR R1, R1, #(0x0F<<(12))
	STR R1,[R0, #GPIO_ODR]
	;BL User_PushButton_Init //CHECK THIS LATER FOR MANIPULATION OF CODE
;**********************************************************************
;LOOP	
	;BL LCD_DISPLAY
	;BL DELAY_1ms
	;ADD R4,R4,#0x1
	;CMP R4,#0xF
	;BLE LOOP
;**********************************************************************
	POP {R14}
	BX R14
	
	
		EXPORT LCD_DISPLAY
		ALIGN
LCD_DISPLAY
    PUSH{R14} 
	LDR R2, =GPIOF_BASE 
	LDR R1, [R2, #GPIO_ODR]
	BIC R1, R1, #0xF000
	ORR R1, R1, R0, LSL #12
	STR R1, [R2, #GPIO_ODR]
	POP{R14}
	BX R14
	
;********************************************************************************************
; Delay Function needs to be of 1ms and each time unit of the processor is 0.25us(assuming 
; that we have 4MHZ ) so to get 1ms delay we need 4000 cycles of 0.25us cycles so the reeat 
; loop repeats around (499*8)which gives us approximately 3989 and we add the other 11 
; instruction cycles to get overall of 4000 cycles
;********************************************************************************************


		EXPORT DELAY_50ms
		ALIGN
DELAY_50ms
	PUSH{R5,R7,R14}	;Assuming it takes 1 cycle
	MOV R7, #50	; 1 cycle
	NOP
	NOP
	NOP
	;BEQ EXIT_DELAY_LOOP	; 3 Cycles
	MOV R5, #499	; 1 cycle
	MUL R5,R5,R7	; 1 cycle
REPEAT	
	CMP R5, #0	; 1 Cycle
	BEQ EXIT_DELAY_LOOP	; 3 cycle
	SUB R5,R5,#1; 1 cycle
	B REPEAT	;3 cycle
EXIT_DELAY_LOOP			
	POP{R5,R7,R14}	; 1 cycle
	BX R14		;3 Cycles

;********************************************************************************************

		EXPORT UPB_B1_INIT
		ALIGN
UPB_B1_INIT
	PUSH {R0,R1,R4,R14}
	LDR R0, =RCC_BASE
	LDR R1, [R0, #RCC_AHB2ENR]
	ORR R1, R1, #(RCC_AHB2ENR_GPIOCEN)      ; Enables clock for GPIOF
	STR R1, [R0, #RCC_AHB2ENR]
	LDR R0,=GPIOC_BASE ; Set to GPIOC BASE address
	LDR R1,[R0, #GPIO_MODER] ; Read mode reg.
	BIC R1, R1, #(3<<(2*13)) ; Clear bits 10 and 11
	STR R1,[R0, #GPIO_MODER] ; Store modified mode reg.
	LDR R1,[R0, #GPIO_PUPDR] ; Read pull up/down reg.
	BIC R1, R1, #(3<<(2*13)) ; Clear any existing setting
	ORR R1, R1, #(2<<(2*13)) ; ‘10’ to enable pull down
	STR R1,[R0, #GPIO_PUPDR]
	POP {R0,R1,R4,R14}
	BX R14
	
;*****************************************************************	
		EXPORT CHECK_FOR_PINPRESS
		ALIGN
CHECK_FOR_PINPRESS	
	PUSH {R14}
	LDR R6,=GPIOC_BASE
CHECK_PIN_AGAIN	
	LDR R1,[R6, #GPIO_IDR] ; Read the value
	MOV R9,#0x50
	LSR R1, R1 ,#13
	TEQ R1, #1
	MOV R0, #0
	BNE SKIP
	BL DELAY_50ms
	TEQ R1, #1
	BNE SKIP
	MOV R0, #1
SKIP
	POP {R14}
	BX R14
;*****************************************************************


		EXPORT GREEN_LED0
		ALIGN
GREEN_LED0
	PUSH{R0,R1,R2,R4,R5,R14}
	LDR R2, =RCC_BASE
	LDR R1, [R2, #RCC_AHB2ENR]
	ORR R1, R1, #(RCC_AHB2ENR_GPIOEEN)      ; Enables clock for GPIOF
	STR R1, [R2, #RCC_AHB2ENR]
	LDR R4,=GPIOE_BASE           ; Set to GPIOE
	LDR R5,[R4, #GPIO_MODER] ; Read mode reg.
	BIC R5, R5, #(3<<(2*9))           ; Clear bits 18 and 19
	ORR R5, R5, #(1<<(2*9))         ; Set bit 18 for output  
	STR R5,[R4, #GPIO_MODER] ; Store modified mode reg.
	LDR R5,[R4, #GPIO_OTYPER]  ; Read output type
	BIC R5, R5, #(1<<9); Clear bit 9 for push-pull
	STR R5,[R4, #GPIO_OTYPER]
	LDR R5,[R4, #GPIO_ODR]         ; Read the output data reg
	CMP R0,#0
	BEQ GREEN_LED_OFF
	ORR R5, R5, #(1<<9)
	B GREEN_LED0_EXIT
GREEN_LED_OFF
	AND R5, R5, #(0<<9)
GREEN_LED0_EXIT
	STR R5,[R4, #GPIO_ODR]
	POP{R0,R1,R2,R4,R5,R14}
	BX R14
	
	
	
		EXPORT KEYPAD_INIT
		ALIGN
KEYPAD_INIT
	PUSH{R0,R1,R4,R5,R14}		
;*************************************************************************	
;**********************INPUT KEYPAD PIN INITIALISATIONS*******************	
;
	LDR R0, =RCC_BASE
	LDR R1, [R0, #RCC_AHB2ENR]
	ORR R1, R1, #(RCC_AHB2ENR_GPIOCEN)      ; Enables clock for GPIOF
	STR R1, [R0, #RCC_AHB2ENR]
	
	LDR R4,=GPIOC_BASE           ; Set to GPIOA
	LDR R5,[R4, #GPIO_MODER] ; Read mode reg.
	BIC R5, R5, #0x0F           ; Clear bits 0 and 1 OF PINS PC0 PC1 	
	BIC R5, R5, #(0x0F<<6)      ; Clear bits 0 and 1 OF PINS PC3 PC4
	STR R5,[R4, #GPIO_MODER] 	; Store modified mode reg.
	LDR R5,[R4, #GPIO_PUPDR]  	; Read pull up/down reg.
	BIC R5, R5, #(0x0F)		; Clear any existing setting
	BIC R5, R5, #(0x0F<<6)		; Clear any existing setting
	STR R5,[R4, #GPIO_PUPDR]
	
;*************************************************************************

;*************************************************************************
;*********************OUTPUT KEYPAD PIN INITILISATIONS********************
	LDR R0, =RCC_BASE
	LDR R1, [R0, #RCC_AHB2ENR]
	ORR R1, R1, #(RCC_AHB2ENR_GPIODEN)      ; Enables clock for GPIOD
	STR R1, [R0, #RCC_AHB2ENR]
	
	LDR R4,=GPIOD_BASE           ; Set to GPIOC
	LDR R5,[R4, #GPIO_MODER] ; Read mode reg.
	BIC R5, R5, #(0x0F<<(2*8))           ; Clear bits 16 and 17
	BIC R5, R5, #(0x0F<<(2*14))
	ORR R5, R5, #(0x05<<(2*8))         ; Set bit 16 for output 
	ORR R5, R5, #(0x05<<(2*14))
	STR R5,[R4, #GPIO_MODER] ; Store modified mode reg.
	LDR R5,[R4, #GPIO_OTYPER]  ; Read output type
	ORR R5, R5, #(0X00C3<<8); Clear bit 8 for push-pul=
	STR R5,[R4, #GPIO_OTYPER]
	LDR R5,[R4, #GPIO_ODR]         ; Read the output data reg
	BIC R5, R5, #(0X0000<<8);ORR or BIC to set or clear a bit
	STR R5,[R4, #GPIO_ODR]

;*************************************************************************
	
	
	POP{R0,R1,R4,R5,R14}
	BX R14
	
	
		EXPORT KEYPAD_SCAN
		ALIGN
			
KEYPAD_SCAN
	PUSH {R3,R4,R5,R6,R7,R8,R9,R14}
	LDR R3, =GPIOD_BASE
	LDR R4, [R3, #GPIO_ODR]
	BIC R4, R4, #(0XC3<<8)
	STR R4, [R3, #GPIO_ODR]
	LDR R6, =GPIOC_BASE
	LDR R7, [R6,#GPIO_IDR]
	TEQ R7, #0x1B 
	BL DELAY_50ms
	TEQ R7, #0x1B
	MOV R0, #0x10
	BEQ JUMP_TO_EXIT
	TEQ R7, #0x1A
	BEQ COL1_KeyPressed
	TEQ R7, #0x19
	BEQ COL2_KeyPressed
	TEQ R7, #0x13
	BEQ COL3_KeyPressed
	TEQ R7, #0x0B
	B JUMP_TO_COL_4
	
	
JUMP_TO_COL_4
	B COL4_KeyPressed
	
JUMP_TO_EXIT
	B EXIT_KEYPAD_SCAN

COL1_KeyPressed
	LDR R4,=GPIOD_BASE
	LDR R7, [R4,#GPIO_ODR]
	BIC R7, R7, #(0XC3<<8)
	ORR R7, R7, #(0x43<<8)
	STR R7, [R4,#GPIO_ODR]
	LDR R6, =GPIOC_BASE
	LDR R8, [R6,#GPIO_IDR]
	TEQ R8, #0x1A
	BEQ BRANCH_STAR
	
	LDR R7, [R4,#GPIO_ODR]
	BIC R7, R7, #(0XC3<<8)
	ORR R7, R7, #(0x83<<8)
	STR R7, [R4,#GPIO_ODR]
	LDR R6, =GPIOC_BASE
	LDR R8, [R6,#GPIO_IDR]
	TEQ R8, #0x1A
	BEQ BRANCH_SEVEN
	
	LDR R7, [R4,#GPIO_ODR]
	BIC R7, R7, #(0XC3<<8)
	ORR R7, R7, #(0xC1<<8)
	STR R7, [R4,#GPIO_ODR]
	LDR R6, =GPIOC_BASE
	LDR R8, [R6,#GPIO_IDR]
	TEQ R8, #0x1A
	BEQ BRANCH_FOUR
	
	LDR R7, [R4,#GPIO_ODR]
	BIC R7, R7, #(0XC3<<8)
	ORR R7, R7, #(0xC2<<8)
	STR R7, [R4,#GPIO_ODR]
	LDR R6, =GPIOC_BASE
	LDR R8, [R6,#GPIO_IDR]
	TEQ R8, #0x1A
	BEQ BRANCH_ONE


COL2_KeyPressed
	LDR R4,=GPIOD_BASE
	LDR R7, [R4,#GPIO_ODR]
	BIC R7, R7, #(0XC3<<8)
	ORR R7, R7, #(0x43<<8)
	STR R7, [R4,#GPIO_ODR]
	LDR R6, =GPIOC_BASE
	LDR R8, [R6,#GPIO_IDR]
	TEQ R8, #0x19
	BEQ BRANCH_ZERO
	
	LDR R7, [R4,#GPIO_ODR]
	BIC R7, R7, #(0XC3<<8)
	ORR R7, R7, #(0x83<<8)
	STR R7, [R4,#GPIO_ODR]
	LDR R6, =GPIOC_BASE
	LDR R8, [R6,#GPIO_IDR]
	TEQ R8, #0x19
	BEQ BRANCH_EIGHT
	
	LDR R7, [R4,#GPIO_ODR]
	BIC R7, R7, #(0XC3<<8)
	ORR R7, R7, #(0xC1<<8)
	STR R7, [R4,#GPIO_ODR]
	LDR R6, =GPIOC_BASE
	LDR R8, [R6,#GPIO_IDR]
	TEQ R8, #0x19
	BEQ BRANCH_FIVE
	
	LDR R7, [R4,#GPIO_ODR]
	BIC R7, R7, #(0XC3<<8)
	ORR R7, R7, #(0xC2<<8)
	STR R7, [R4,#GPIO_ODR]
	LDR R6, =GPIOC_BASE
	LDR R8, [R6,#GPIO_IDR]
	TEQ R8, #0x19
	BEQ BRANCH_TWO
	
BRANCH_ONE
	B SEND_ONE
BRANCH_FOUR
	B SEND_FOUR
BRANCH_SEVEN
	B SEND_SEVEN
BRANCH_STAR
	B SEND_STAR	
	
	
BRANCH_TWO
	B SEND_TWO
BRANCH_FIVE
	B SEND_FIVE
BRANCH_EIGHT 
	B SEND_EIGHT
BRANCH_ZERO
	B SEND_ZERO
	
COL3_KeyPressed
	LDR R4,=GPIOD_BASE
	LDR R7, [R4,#GPIO_ODR]
	BIC R7, R7, #(0XC3<<8)
	ORR R7, R7, #(0x43<<8)
	STR R7, [R4,#GPIO_ODR]
	LDR R6, =GPIOC_BASE
	LDR R8, [R6,#GPIO_IDR]
	TEQ R8, #0x13
	BEQ BRANCH_POUND
	
	LDR R7, [R4,#GPIO_ODR]
	BIC R7, R7, #(0XC3<<8)
	ORR R7, R7, #(0x83<<8)
	STR R7, [R4,#GPIO_ODR]
	LDR R6, =GPIOC_BASE
	LDR R8, [R6,#GPIO_IDR]
	TEQ R8, #0x13
	BEQ SEND_NINE
	
	LDR R7, [R4,#GPIO_ODR]
	BIC R7, R7, #(0XC3<<8)
	ORR R7, R7, #(0xC1<<8)
	STR R7, [R4,#GPIO_ODR]
	LDR R6, =GPIOC_BASE
	LDR R8, [R6,#GPIO_IDR]
	TEQ R8, #0x13
	BEQ SEND_SIX
	
	LDR R7, [R4,#GPIO_ODR]
	BIC R7, R7, #(0XC3<<8)
	ORR R7, R7, #(0xC2<<8)
	STR R7, [R4,#GPIO_ODR]
	LDR R6, =GPIOC_BASE
	LDR R8, [R6,#GPIO_IDR]
	TEQ R8, #0x13
	BEQ	SEND_THREE
	
	
BRANCH_POUND
	B SEND_POUND
	
	
COL4_KeyPressed
	LDR R4,=GPIOD_BASE
	LDR R7, [R4,#GPIO_ODR]
	BIC R7, R7, #(0XC3<<8)
	ORR R7, R7, #(0x43<<8)
	STR R7, [R4,#GPIO_ODR]
	LDR R6, =GPIOC_BASE
	LDR R8, [R6,#GPIO_IDR]
	TEQ R8, #0x0B
	BEQ SEND_D
	
	LDR R7, [R4,#GPIO_ODR]
	BIC R7, R7, #(0XC3<<8)
	ORR R7, R7, #(0x83<<8)
	STR R7, [R4,#GPIO_ODR]
	LDR R6, =GPIOC_BASE
	LDR R8, [R6,#GPIO_IDR]
	TEQ R8, #0x0B
	BEQ SEND_C
	
	LDR R7, [R4,#GPIO_ODR]
	BIC R7, R7, #(0XC3<<8)
	ORR R7, R7, #(0xC1<<8)
	STR R7, [R4,#GPIO_ODR]
	LDR R6, =GPIOC_BASE
	LDR R8, [R6,#GPIO_IDR]
	TEQ R8, #0x0B
	BEQ SEND_B
	
	STR R7, [R4,#GPIO_ODR]
	BIC R7, R7, #(0XC3<<8)
	ORR R7, R7, #(0xC2<<8)
	STR R7, [R4,#GPIO_ODR]
	LDR R6, =GPIOC_BASE
	LDR R8, [R6,#GPIO_IDR]
	TEQ R8, #0x0B
	BEQ SEND_A




SEND_ZERO
	MOV R0,#0
	B EXIT_KEYPAD_SCAN
SEND_ONE
	MOV R0,#1
	B EXIT_KEYPAD_SCAN
SEND_TWO
	MOV R0,#2
	B EXIT_KEYPAD_SCAN
SEND_THREE
	MOV R0,#3
	B EXIT_KEYPAD_SCAN
SEND_FOUR
	MOV R0,#4
	B EXIT_KEYPAD_SCAN
SEND_FIVE
	MOV R0,#5
	B EXIT_KEYPAD_SCAN
SEND_SIX
	MOV R0,#6
	B EXIT_KEYPAD_SCAN
SEND_SEVEN
	MOV R0,#7
	B EXIT_KEYPAD_SCAN
SEND_EIGHT
	MOV R0,#8
	B EXIT_KEYPAD_SCAN
SEND_NINE
	MOV R0,#9
	B EXIT_KEYPAD_SCAN
SEND_A
	MOV R0,#10
	B EXIT_KEYPAD_SCAN
SEND_B
	MOV R0,#11
	B EXIT_KEYPAD_SCAN
SEND_C
	MOV R0,#12
	B EXIT_KEYPAD_SCAN
SEND_D
	MOV R0,#13
	B EXIT_KEYPAD_SCAN
SEND_STAR
	MOV R0,#14
	B EXIT_KEYPAD_SCAN
SEND_POUND
	MOV R0,#15
EXIT_KEYPAD_SCAN		
	POP {R3,R4,R5,R6,R7,R8,R9,R14}
	BX R14	

	
	
	
	
	; Area defined for variables, if needed.
	AREA VARS, DATA, READWRITE
		ALIGN
			
ASM_V1	DCD 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15      ; Variables for use in assembly
ASM_V2	DCD 0
	
	
	
	END
		
		