.include	"address_map_arm.s"
				.include	"defines.s"
				.include	"interrupt_ID.s"

/*********************************************************************************
 * Initialize the exception vector table
 ********************************************************************************/
				.section .vectors, "ax"

				B 			_start					// reset vector
				B 			SERVICE_UND				// undefined instruction vector
				B 			SERVICE_SVC				// software interrrupt vector
				B 			SERVICE_ABT_INST		// aborted prefetch vector
				B 			SERVICE_ABT_DATA		// aborted data vector
				.word 	0							// unused vector
				B 			SERVICE_IRQ				// IRQ interrupt vector
				B 			SERVICE_FIQ				// FIQ interrupt vector

/* ********************************************************************************
 * This program demonstrates use of interrupts with assembly code. It first starts
 * two timers: an HPS timer, and the Altera interval timer (in the FPGA). The 
 * program responds to interrupts from these timers in addition to the pushbutton 
 * KEYs in the FPGA.
 *
 * The interrupt service routine for the HPS timer causes the main program to flash
 * the green light connected to the HPS GPIO1 port.
 * 
 * The interrupt service routine for the Altera interval timer displays a pattern 
 * on the HEX3-0 displays, and rotates this pattern either left or right:
 *		KEY[0]: loads a new pattern from the SW switches
 *		KEY[1]: rotates the displayed pattern to the right
 *		KEY[2]: rotates the displayed pattern to the left
 *		KEY[3]: stops the rotation
 ********************************************************************************/
				.text
				.global	_start
_start:		
				/* Set up stack pointers for IRQ and SVC processor modes */
				MOV		R1, #INT_DISABLE | IRQ_MODE
				MSR		CPSR_c, R1					// change to IRQ mode
				LDR		SP, =A9_ONCHIP_END - 3	// set IRQ stack to top of A9 onchip memory
				/* Change to SVC (supervisor) mode with interrupts disabled */
				MOV		R1, #INT_DISABLE | SVC_MODE
				MSR		CPSR_c, R1					// change to supervisor mode
				LDR		SP, =DDR_END - 3			// set SVC stack to top of DDR3 memory

				BL			CONFIG_GIC					// configure the ARM generic interrupt controller
				BL			CONFIG_HPS_TIMER			// configure the HPS timer
				BL			CONFIG_INTERVAL_TIMER	// configure the Altera interval timer
				BL			CONFIG_KEYS					// configure the pushbutton KEYs

				/* initialize the GPIO1 port */
				LDR 		R0, =HPS_GPIO1_BASE		// GPIO1 base address
				MOV		R4, #0x01000000			// value to turn on the HPS green light LEDG
				STR		R4, [R0, #0x4]				// write to the data direction register to set
															// bit 24 (LEDG) to be an output	
				/* enable IRQ interrupts in the processor */
				MOV		R1, #INT_ENABLE | SVC_MODE		// IRQ unmasked, MODE = SVC
				MSR		CPSR_c, R1

				LDR		R1, =SW_BASE				// slider switch base address
				LDR		R2, =LEDR_BASE				// LEDR base address
				LDR		R3, =TICK
				LDR		R12,=0xFF200060			    // base address of global port
				MOV 	R10,#0xF                    //make r10's least significant bit to 1
				STR		R10,[R12,#4]                //store it to global port enable bit
LOOP:
				

				LDR		R11,=FLAG           //load flag value from memory to r11
				LDR		R11,[R11]           //take value from address in r11
				STRB	R11,[R12]	        //store it to r12


DO_DELAY:	
				LDR R9, =FREQ               //take frequency value's address to r9
				LDR	R9,[R9]                 // take fequency from address
SUB_LOOP: 		
				SUBS R9, R9, #1             //sub one until r9 is 0
				BNE SUB_LOOP

				B 		LOOP2

LOOP2:			

				LDR		R11,=ZERO                   // load r11 with 0
				LDR		R11,[R11]                   // take the zero from address in r11
				STRB	R11,[R12]					// make eneable bit of buzzer 0
				LDR 	R1,=KEY_PRESSED             // load which key is pressed address to r11
				LDR 	R1,[R1]                     //load which key is pressed to r11
				CMP		R1,#KEY0                    //check if pressed key0
				BNE 	CMP2                        //if not go to cmp2
				LDR 	R11,=0x0FF200020            //if it is key0 load 7-segment code address to r11
				MOV		R10,#0b00111111				/* several lines below are about numbers will be showen in 7-segment code
				STRB	R10,[R11]
				MOV		R10,#0b00111111
				STRB	R10,[R11,#1]
				MOV		R10,#0b00000110
				STRB	R10,[R11,#2]
				MOV		R10,#0b00111111
				STRB	R10,[R11,#3]                 */
				LDR		R9,=CHANGE                  // load address of where frequency holds to r9
				LDR		R6,=SLOW                    // load slow frequency address to r6
				LDR		R6,[R6]                     //take slow frequency value from r6
				STR		R6,[R9]	                     //store slow frequency value to current frequency value
				B DO_DELAY2			
	
CMP2:			
				CMP		R1,#KEY1                        //check if pressed key1
				BNE 	CMP3                            //if not go to cmp3
				LDR 	R11,=0x0FF200020                //if it is key0 load 7-segment code address to r11
				MOV		R10,#0b00111111					/* several lines below are about numbers will be showen in 7-segment code
				STRB	R10,[R11]
				MOV		R10,#0b00000110
				STRB	R10,[R11,#1]
				MOV		R10,#0b00111111
				STRB	R10,[R11,#2]
				MOV		R10,#0b00111111
				STRB	R10,[R11,#3]                   */
				LDR		R9,=CHANGE                  // load address of where frequency holds to r9
				LDR		R6,=MEDIUM                  // load medium frequency address to r6
				LDR		R6,[R6]						//take slow frequency value from r6
				STR		R6,[R9]				        //store slow frequency value to current frequency value
				B DO_DELAY2

CMP3:
				CMP		R1,#KEY2                    //check if pressed key2
				BNE 	CMP4                        //if not go to cmp4
				LDR 	R11,=0x0FF200020            //if it is key0 load 7-segment code address to r11
				MOV		R10,#0b01100110             /* several lines below are about numbers will be showen in 7-segment code
				STRB	R10,[R11]
				MOV		R10,#0b00111111
				STRB	R10,[R11,#1]
				MOV		R10,#0b00111111
				STRB	R10,[R11,#2]
				MOV		R10,#0b00111111
				STRB	R10,[R11,#3]                */
				LDR		R9,=CHANGE                   // load address of where frequency holds to r9
				LDR		R6,=FAST                    // load fast frequency address to r6
				LDR		R6,[R6]						//take fast frequency value from r6
				STR		R6,[R9]				        //store fast frequency value to current frequency value
				B DO_DELAY2
CMP4:
				CMP		R1,#KEY3                    ////check if pressed key3
				BNE 	DO_DELAY2                   //if not go to DO_DELAY2
				LDR 	R11,=0x0FF200020            //if it is key0 load 7-segment code address to r11
				MOV		R10,#0b00000110				/* several lines below are about numbers will be showen in 7-segment code
				STRB	R10,[R11]
				MOV		R10,#0b00111111
				STRB	R10,[R11,#1]
				MOV		R10,#0b00111111
				STRB	R10,[R11,#2]
				MOV		R10,#0b00111111
				STRB	R10,[R11,#3]               */
				LDR		R9,=CHANGE                  // load address of where frequency holds to r9
				LDR		R6,=FASTER                  // load faster frequency address to r6
				LDR		R6,[R6]						//take faster frequency value from r6
				STR		R6,[R9]				        //store faster frequency value to current frequency value
				B DO_DELAY2

DO_DELAY2: 		
				LDR R9, =CHANGE                     //load current frequency value's address to r9
				LDR	R9,[R9]                         // load r9 to value's stored in address value in r9
SUB_LOOP2: 		
				SUBS R9, R9, #1                     //sub r9 t0 1
				BNE SUB_LOOP2
		
				B 		LOOP


						

/* Configure the HPS timer to create interrupts at one-second intervals */
CONFIG_HPS_TIMER:
				/* initialize the HPS timer */
				LDR 		R0, =HPS_TIMER0_BASE		// base address
				MOV		R1, #0						// used to stop the timer
				STR		R1, [R0, #0x8]
							// write to timer control register
				
				LDR		R1, =FREQ				// period = 1/(100 MHz) x (100 x 10^6) = 1 sec
				LDR		R1, [R1]	
				//LDR		R1, =025000000				// period = 1/(100 MHz) x (100 x 10^6) = 1 sec
				STR		R1, [R0]						// write to timer load register
				MOV		R1, #0b011					// int mask = 0, mode = 1, enable = 1
				STR		R1, [R0, #0x8]				// write to timer control register
				BX			LR
				   
/* Configure the Altera interval timer to create interrupts at 50-msec intervals */
CONFIG_INTERVAL_TIMER:
				LDR 		R0, =TIMER_BASE
				/* set the interval timer period for scrolling the HEX displays */
				LDR		R1, =5000000				// 1/(100 MHz) x 5x10^6 = 50 msec
				STR		R1, [R0, #0x8]				// store the low half word of counter start value
				LSR 		R1, R1, #16
				STR		R1, [R0, #0xC]				// high half word of counter start value

				// start the interval timer, enable its interrupts
				MOV		R1, #0x7						// START = 1, CONT = 1, ITO = 1
				STR		R1, [R0, #0x4]
				BX			LR

/* Configure the pushbutton KEYS to generate interrupts */
CONFIG_KEYS:
				// write to the pushbutton port interrupt mask register
				LDR		R0, =KEY_BASE				// pushbutton key base address
				MOV		R1, #0xF						// set interrupt mask bits
				STR		R1, [R0, #0x8]				// interrupt mask register is (base + 8)
				BX			LR

/* Global variables */



				.global FAST
FAST:
				.word 2500000000

				.global SLOW
SLOW:
				.word 250000000


				.global MEDIUM
MEDIUM:
				.word 1000000000


				.global FASTER
FASTER:
				.word 25000000000
				

				.global STABLE
STABLE:
				.word 300000000

				.global CHANGE
CHANGE:
				.word 750000000

				.global FREQ
FREQ:
				.word 250000000

				.global	TICK
TICK:		
				.word		0x0						// used by HPS timer
				.global	PATTERN
PATTERN:		
				.word		0x0000000F				// initial pattern for HEX displays
				.global	KEY_PRESSED
KEY_PRESSED:
				.word		KEY1 	
				.global FLAG					// stores code representing pushbutton key pressed
				
FLAG:
				.word		0x1
				.global RESET
				
RESET:			
				.word 0x0
				.global ZERO
ZERO:	
				.word 0x0
				.global	SHIFT_DIR

SHIFT_DIR:	
				.word		RIGHT	 					// pattern shifting direction
				.end   
