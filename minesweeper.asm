.386
.model flat, stdcall

includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc

includelib canvas.lib
extern BeginDrawing: proc

public start

.data

_WINDOW_TITLE DB "Minesweeper", 0
_WIDTH EQU 720
_HEIGHT EQU 720

area DD 0
counter DD 0

arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20

symbol_width EQU 10
symbol_height EQU 20

include digits.inc
include letters.inc

.code

;set_title_macro macro

make_text proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	cmp eax, 'A'
	jl make_digit
	cmp eax, 'Z'
	jg make_digit
	sub eax, 'A'
	lea esi, letters
	jmp draw_text
make_digit:
	cmp eax, '0'
	jl make_space
	cmp eax, '9'
	jg make_space
	sub eax, '0'
	lea esi, digits
	jmp draw_text
make_space:	
	mov eax, 26 ; de la 0 pana la 25 sunt litere, 26 e space
	lea esi, letters
	
draw_text:
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax
	mov ecx, symbol_height
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, symbol_height
	sub eax, ecx
	mov ebx, _WIDTH
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, symbol_width
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb
	mov dword ptr [edi], 0
	jmp simbol_pixel_next
simbol_pixel_alb:
	mov dword ptr [edi], 0FFFFFFh
simbol_pixel_next:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_text endp

; un macro ca sa apelam mai usor desenarea simbolului
make_text_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text
	add esp, 16
endm

draw_proc proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, _WIDTH
	mov ebx, _HEIGHT
	mul ebx
	shl eax, 2
	push eax
	push 255
	push area
	call memset
	add esp, 12
	
	timer:
		pusha
		; start delay
		mov EAX, 11
		delay:
		mov ECX, 72000000
		dec eax
		loop_for_timer_delay:
		nop
		loop loop_for_timer_delay
		cmp eax, 0
		jne delay
		; end delay
		popa
		inc counter
	
	afisare_litere:
		;afisam valoarea counter-ului curent (sute, zeci si unitati)
		mov ebx, 10
		mov eax, counter
		;cifra unitatilor
		mov edx, 0
		div ebx
		add edx, '0'
		make_text_macro edx, area, 30, 10
		;cifra zecilor
		mov edx, 0
		div ebx
		add edx, '0'
		make_text_macro edx, area, 20, 10
		;cifra sutelor
		mov edx, 0
		div ebx
		add edx, '0'
		make_text_macro edx, area, 10, 10
		
		
		make_text_macro 'M', area, 110, 100
		make_text_macro 'I', area, 120, 100
		make_text_macro 'N', area, 130, 100
		make_text_macro 'E', area, 140, 100
		make_text_macro 'S', area, 150, 100
		make_text_macro 'W', area, 160, 100
		make_text_macro 'E', area, 170, 100
		make_text_macro 'E', area, 180, 100
		make_text_macro 'P', area, 190, 100
		make_text_macro 'E', area, 200, 100
		make_text_macro 'R', area, 210, 100
		
	
final_draw:
	popa
	mov esp, ebp
	pop ebp
	ret

draw_proc endp
	

start:

	mov eax, _WIDTH
	mov ebx, _HEIGHT
	mul ebx
	shl eax, 2
	push eax
	call malloc
	add ESP, 4
	mov area, eax
	
	push offset draw_proc
	push area
	push _HEIGHT
	push _WIDTH
	push offset _WINDOW_TITLE
	call BeginDrawing
	add esp, 20

	push 0
	call exit
end start
