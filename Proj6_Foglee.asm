TITLE Designing low-level I/O Procedures     (Proj6_Foglee.asm)

; Author: Erik Fogle
; Last Modified: 09/11/2021
; OSU email address: Foglee@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 6             Due Date: N/A
; Description: Program takes directed user entry numeric values as string. Using string pimititives, the 
;				numerical string is converted to SDWORD values and stored in an array. The sum and average 
;				of the values is calculated. The average rounds to the nearest whole number based on the 
;				Round Half Up approach. Lastly, it converts all numerical values back to string, then 
;				displays the string representation of all values entered and calculated. The read and write
;				code is written into macros that are invoked within the program procedures.

;				Program handles positive and negative numbers.
;				Program detects different types of entry errors and prompts the user respectively.

INCLUDE Irvine32.inc

; macros (May use ReadString and WriteString for Macros)

mGetString MACRO promptString, outputString, outputLength, enteredLength

	MOV		EDX, promptString
	CALL	WriteString

	MOV		EDX, outputString
	MOV		ECX, outputLength
	CALL	ReadString
	MOV		enteredLength, EAX

ENDM


mDisplayString MACRO displayString
	
	MOV		EDX, displayString
	CALL	WriteString

ENDM

; constants for array declarations
STRINGINPUTLENGTH = 11
CONVERTEDELEMENTS = 10


.data

; string variables
greetAndIntro	BYTE	"Welcome to PROGRAMMING ASSIGNMENT 6: Designing Low-level I/O procedures.",13,10
				BYTE	"Programmed by: Erik Fogle",13,10,10
				BYTE	"Please enter 10 signed decimal numbers. Each number must be small enough to fit" 
				BYTE	"inside a 32 bit",13,10,"register. Afterwards, the program will display the numbers you" 
				BYTE	"entered. Then calculate and display",13,10,"their sum and average.",13,10,10,0
inputPrompt		BYTE	"Please enter a signed number: ",0
invalidPrompt	BYTE	"ERROR: entry not a signed number or was too large!",13,10,"Please try again: ",0
emptyPrompt		BYTE	"ERROR: empty input is not a valid entry.",13,10,"Please try again: ",0
outputPrompt	BYTE	"You entered the following numbers:",13,10,0
sumPrompt		BYTE	"The sum of your numbers is: ",0
avgPrompt		BYTE	"The rounded average of your numbers is: ",0
commaSpace		BYTE	", ",0
goodbye			BYTE	"Thanks for using my Low-Level I/O program!",13,10,0

; output and tracking variables
entryLength		DWORD	?
signedFactor	SDWORD	?
valuesSum		SDWORD	?
valuesAvg		SDWORD	?

; array declarations
stringValues	BYTE	STRINGINPUTLENGTH DUP(?)	
outputString	BYTE	STRINGINPUTLENGTH DUP(?)	
convertedValues	SDWORD	CONVERTEDELEMENTS DUP(?)

.code
main PROC
; Greeting and introduction
	mDisplayString OFFSET greetAndIntro

; Counted loop to get 10 string entries
	MOV		ECX, CONVERTEDELEMENTS
	MOV		EAX, OFFSET convertedValues			; always on top of stack to inc. index

_readLoop:
	PUSH	OFFSET stringValues
	PUSH	OFFSET inputPrompt
	PUSH	OFFSET invalidPrompt
	PUSH	OFFSET emptyPrompt
	PUSH	OFFSET entryLength
	PUSH	OFFSET signedFactor
	
	CALL	ReadVal
	PUSH	EAX									; preserve current index

; update sum for valid entry
	MOV		EAX, [EAX]
	ADD		EAX, valuesSum
	MOV		valuesSum, EAX

	POP		EAX
	ADD		EAX, TYPE convertedValues			; inc. to next index position in dest. array
	LOOP	_readLoop
	CALL	CrLf

; Calculate and store average
	PUSH	valuesSum
	PUSH	OFFSET valuesAvg
	CALL	AverageVal

; Display the entries
	mDisplayString OFFSET outputPrompt
	MOV		ECX, TYPE convertedValues
	MOV		EDX, SIZEOF convertedValues
	PUSH	TYPE convertedValues
	PUSH	OFFSET commaSpace
	PUSH	OFFSET convertedValues
	PUSH	OFFSET outputString
	CALL	WriteVal

; Display the sum
	mDisplayString OFFSET sumPrompt
	MOV		ECX, TYPE valuesSum
	MOV		EDX, SIZEOF valuesSum
	PUSH	TYPE valuesSum
	PUSH	OFFSET commaSpace
	PUSH	OFFSET valuesSum
	PUSH	OFFSET outputString
	CALL	WriteVal

; Display the average
	mDisplayString OFFSET avgPrompt
	MOV		ECX, TYPE valuesAvg
	MOV		EDX, SIZEOF valuesAvg
	PUSH	TYPE valuesAvg
	PUSH	OFFSET commaSpace
	PUSH	OFFSET valuesAvg
	PUSH	OFFSET outputString
	CALL	WriteVal

	CALL	CrLf
	mDisplayString OFFSET goodbye

	Invoke ExitProcess,0	; exit to operating system
main ENDP

; (insert additional procedures here)

; -------------------------------------------------------------------------------------
; ReadVal
; Procedure invokes a macro that gets a user-entered numeric string. Then it converts the string 
; using string primitives and validates the user's entry. If the entry is non-numeric, empty, or
; not a sign symbol the entry is invalid. If the entry is valid, it stores the converted value in
; an SDWORD array.
; Preconditions: greeting and intro displayed. Storage array declared.
; Postconditions: all registers altered for calculations, memory management, etc.
; Receives: misc. string variables for user prompt and error messages. Address offsets for 
; convertedValues, entryLength, and signedFactor.
; Returns: convertedValues
; -------------------------------------------------------------------------------------
ReadVal PROC

	PUSH	EAX							; preserve array index
	PUSH	ECX							; preserve counted loop counter
	PUSH	EBP
	MOV		EBP, ESP
	MOV		EDX, [EBP+32]				; set std. prompt to EDX

_readAgain:
	mGetString EDX, [EBP+36], STRINGINPUTLENGTH, [EBP+20]

	MOV		ECX, [EBP+20]				; user entry length
	MOV		EDI, [EBP+16]
	MOV		EDX, 1							
	MOV		[EDI], EDX					; default signedFactor to 1 for positive values
	MOV		EDX, 0						; set running total to 0 for initial pass
	MOV		ESI, [EBP+36]
	MOV		EDI, [EBP+8]

	CLD									; set flag direction to increment

	LODSB
_validationLoop:

	CMP		AL, 0
	JE		_emptyError

	CMP		AL, 45
	JE		_signedNegative
	CMP		AL, 43
	JE		_signedPositive
	CMP		AL, 48			
	JL		_invalidError
	CMP		AL, 57			
	JG		_invalidError

	SUB		AL, 48
	PUSH	EAX							; preserve current char. value
	MOV		EAX, EDX					; move running total into EAX
	MOV		EBX, 10
	MUL		EBX
	POP		EBX
	ADD		EAX, EBX

	JO		_invalidError				; after ea. addition, check if number is too large causing overflow

	CMP		ECX, 1
	JE		_endReadVal
	
	MOV		EDX, EAX					; move running total into EDX
	MOV		EAX, 0						; clear EAX for data integrity 
	LODSB
	LOOP	_validationLoop

_signedNegative:
	PUSH	ECX
	MOV		EDI, [EBP+16]
	MOV		ECX, -1
	MOV		[EDI], ECX					; signedFactor to -1
	MOV		EDI, [EBP+8]
	POP		ECX
_signedPositive:
	CMP		ECX, [EBP+20]				; if +/- is not first char. Check with index against entry length.
	JNE		_invalidError
	LODSB								; inc. past signed character
	LOOP	_validationLoop

_invalidError:
	MOV		EDX, [EBP+28]				; set invalid prompt to EDX to pass into macro invoke
	JMP		_readAgain

_emptyError:			
	MOV		EDX, [EBP+24]				; set empty prompt to EDX to pass into macro invoke
	JMP		_readAgain

_endReadVal:
	MOV		ESI, [EBP+16]
	MOV		EBX, [ESI]				
	MUL		EBX							; signed multiply total by signFactor
	MOV		[EDI], EAX

	POP		EBP
	POP		ECX
	POP		EAX
	RET 24
ReadVal ENDP


; -------------------------------------------------------------------------------------
; WriteVal
; Procedures takes an address offset for an array of numeric SDWORD values, converts the values to
; a string of ASCII digits, and invokes a macro to print the string representation of the numeric
; values.
; Preconditions: array of validated numeric values filled. Sum and Avg. calculated.
; Postconditions: all registers altered for calculations, memory management, etc.
; Receives: string prompt respective to data to be displayed. Address offset for numeric value(s) to
; be converted and displayed.
; Returns: none
; -------------------------------------------------------------------------------------
WriteVal PROC
	PUSH	EBP
	MOV		EBP, ESP

	MOV		ESI, [EBP+12]
	MOV		EDI, [EBP+8]

	PUSH    EDX
	PUSH	ECX

_nextElement:
	MOV		EAX, [ESI]					; move source value to EAX for repeat EAX use 

; check sign
	CMP		EAX, 0
	JL		_negativeVal
	JMP		_loopTrigger
	CLD

_negativeVal:
	PUSH	EAX
	MOV		AL, 45						; display negative sign
	STOSB
	mDisplayString [EBP+8]

	DEC		EDI
	POP		EAX
	NEG		EAX

_loopTrigger:
	PUSH	0							; trigger end of stack pop for converted string display 
_valConversion:

	MOV		EDX, 0						; clear EDX for division
	MOV		EBX, 10
	DIV		EBX

	ADD		EDX, 48						; ASCII char. offset to numerical string
	PUSH	EDX							; save current digit
	CMP		EAX, 0						; check if quotient (running total) is 0
	JNE		_valConversion

_popPrintLoop:							
	POP		EAX							; print each str. character in order since converted in reverse (FILO)
	CMP		EAX, 0
	JE		_arrayCheck

	STOSB
	mDisplayString [EBP+8]
	
	DEC		EDI
	JMP		_popPrintLoop

_arrayCheck:
	POP		ECX
	POP		EDX

	CMP		ECX, EDX
	JE		_endWrite					; check if array and if at last element

	ADD		ECX, [EBP+20]				; inc. position trigger
	PUSH	EDX
	PUSH	ECX

	mDisplayString [EBP+16]				; if array, add comma and space between elements
	ADD		ESI, [EBP+20]		
	JMP		_nextElement

_endWrite:
	CALL	CrLf
	POP		EBP
	RET 16
WriteVal ENDP


; -------------------------------------------------------------------------------------
; AverageVal
; Procedure takes the sum of all validated numbers and calculates the average. Then rounds up or down 
; as needed based on Round Half Up rounding.
; Preconditions: 10 validated, converted user-entered numbers and their sum calculated.
; Postconditions: all registers altered for calculations, memory management, etc.
; Receives: Address offsets for valuesSum and valuesAvg.
; Returns: valuesAvg.
; -------------------------------------------------------------------------------------
AverageVal PROC
	PUSH	EBP
	MOV		EBP, ESP
	
	MOV		ESI, [EBP+12]
	MOV		EDI, [EBP+8]
	MOV		EDX, 0
	MOV		ECX, CONVERTEDELEMENTS

	MOV		EAX, ESI
	CDQ
	IDIV	ECX
	PUSH	EAX


	CMP		EAX, 0
	JL		_negativeAvg
	CMP		EDX, 0					
	JE		_restoreAvg				; no remainder, store pos result
	MOV		EBX, 2
	MOV		EAX, EDX
	CMP		EAX, CONVERTEDELEMENTS
	JL		_restoreAvg				; effectively round down
	POP		EAX
	INC		EAX						; round up
	JMP		_storeAvg

_negativeAvg:
	CMP		EDX, 0					
	JE		_restoreAvg				; no remainder, store pos result
	MOV		EBX, 2
	MOV		EAX, EDX
	IMUL	EBX
	NEG		EAX
	CMP		EAX, CONVERTEDELEMENTS
	JL		_restoreAvg				; effectively round down
	POP		EAX
	DEC		EAX						; round up
	JMP		_storeAvg

_restoreAvg:
	POP		EAX
_storeAvg:
	MOV		[EDI], EAX
	POP		EBP
	RET 8
AverageVal ENDP

END main

