.386
.model flat, stdcall
option casemap:none
include windows.inc
include kernel32.inc
include msvcrt.inc
includelib msvcrt.lib
includelib ucrtd.lib

.data
inputStatement db "Enter NUMBER or FUNCTION:", 10, "(any positive number: the number to be pushed onto the top of stack;", 10, " 0: pop the number from the top of the stack;" , 10 ,"-1: print out the number on the top of the stack without popping it;", 10, "-2: print out the size of numbers that have been pushed into the stack;",10, "-3: print out the contents of the stack.)", 10,  0
numberFormat db "%d", 0 ; format for scan
stackFormat1 db "===stack status===", 10, 0 ;format for print stack status
stackFormat2 db "      |%4d|      ", 10, 0 ;format for print stack status
stackFormat3 db "      ------      ", 10, 0 ;format for print stack status
stackFormat4 db "==================", 10, 0 ;format for print stack status
outputFormatForPop db "Pop %d", 10, 0 ; format for pop
outputFormatForTop db "Stack top is %d", 10, 0 ; format for gettopnumber
outputFormatForPrintIsEmpty db "Stack is empty", 10, 0; format for top when stack is empty
outputFormatForPrintSize db "Current stack size is %d", 10, 0; format for getsize
pushErrorStatement db "ERROR THE STACK IS FULL", 10, 0 ; error statement
popErrorStatement db "ERROR THE STACK IS EMPTY", 10, 0 ; error statement

stack dword 10 dup(1) ; Memory allocation for stack
stacklength dword 10 ; stack length
inputnumber dword "%d" ; hold the input number

.code
start:
	mov EBP, 4 ; make top pointer be equal to largest address of the stack, then store the largest address into EBP
	imul EBP, stacklength
	add EBP, offset stack

	mov ESI, EBP
		
	jmp input ; jmp to input

input:
	invoke crt_printf, addr inputStatement 
	invoke crt_scanf, addr numberFormat, addr inputnumber ; input number
	mov ECX, inputnumber ; load the inputnumber in ECX

	cmp ECX, 0; compare content of ECX with 0 (missing line)
	je popnum; if content of ECX is equal to 0, then jump to popnum (missing line)
	
	cmp ECX, -1
	je gettop

	cmp ECX, -2
	je getsize

	cmp ECX, -3; compare content of ECX with -3
	je showstack ; jump to print out the contents of the stack.
	jmp pushnum ; jump to pushnum

pushnum:
	cmp EBP, offset stack; compare EBP with the smallest address of the stack
	je pusherror; jump to pusherror when the stack is full
	
	sub EBP, 4 ; decrease the top pointer by 4 (missing line) 
	mov [EBP], ECX ; push the inputnumber into stack in memory (missing line) 
	jmp input

popnum:
	cmp ESI, EBP
	je poperror

	mov ECX, [EBP] ; get the top data of in the stack in memory, and load it to ECX (missing line)
	invoke crt_printf, addr outputFormatForPop, ECX ; print out the top data
	add EBP, 4 ; increase the top pointer by 4 (missing line)
	jmp input

gettop:
	cmp ESI, EBP
	je isempty

	mov ECX, [EBP]
	invoke crt_printf, addr outputFormatForTop, ECX
	jmp input

getsize:
	mov EAX, ESI
	sub EAX, EBP
	mov EBX, 4
	mov EDX, 0
	idiv EBX
	invoke crt_printf, addr outputFormatForPrintSize, EAX
	jmp input
	
	
showstack:
	invoke crt_printf, addr stackFormat1
	mov EBX, EBP
	jmp showstackdata

showstackdata:
	mov EAX, 4
	imul EAX, stacklength
	add EAX, offset stack ; compute the largest memory address of stack
	cmp EBX, EAX; see if the iterater is end
	je showstackend
	mov ECX, [EBX] ; mov the data to ECX
	invoke crt_printf, addr stackFormat2, ECX ; print out the data
	invoke crt_printf, addr stackFormat3 
	add EBX, 4 ; increase the pointer
	jmp showstackdata

showstackend:
	invoke crt_printf, addr stackFormat4
	jmp input

pusherror:
	invoke crt_printf, addr pushErrorStatement ; print push error message
	jmp exitprogram

poperror:
	invoke crt_printf, addr popErrorStatement ; print pop error message
	jmp exitprogram

isempty:
	invoke crt_printf, addr outputFormatForPrintIsEmpty ; print info that the stack is empty
	jmp input

exitprogram:
	invoke ExitProcess, NULL

end start