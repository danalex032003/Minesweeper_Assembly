.386
.model flat, stdcall

includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc

includelib canvas.lib
extern BeginDrawing: proc

;include Irvine32.lib

public start

.data

_WINDOW_TITLE DB "Minesweeper", 0
AREA_WIDTH EQU 720
AREA_HEIGHT EQU 720

area DD 0
counter DD 0

arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20

symbol_width EQU 10
symbol_height EQU 20

_ROWS DW 10
_COLUMNS DW 10

ONE_SEC EQU 1000

RED EQU 0FF0000h
BLACK EQU 0


buton_x EQU 300
buton_y EQU 300
button_size EQU 100

MATRIX_X EQU 100
MATRIX_Y EQU 100
CELL_WIDTH_AND_HEIGHT EQU 25
NUMBER_OF_CELLS EQU 20


include digits.inc
include letters.inc

.code
; procedura make_text afiseaza o litera sau o cifra la coordonatele date
; arg1 - simbolul de afisat (litera sau cifra)
; arg2 - pointer la vectorul de pixeli
; arg3 - pos_x
; arg4 - pos_y

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
	mov ebx, AREA_WIDTH
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

draw_horizontal_line_macro macro x, y, lenght, color
local loop_for_line
	mov eax, y
	mov ebx, AREA_WIDTH
	mul ebx
	add eax, x
	shl eax, 2
	add eax, area
	
	mov ecx, lenght
	loop_for_line:
		mov dword ptr [eax], color
		add eax, 4
		loop loop_for_line
endm

draw_vertical_line_macro macro x, y, lenght, color
local loop_for_line
	mov eax, y
	mov ebx, AREA_WIDTH
	mul ebx
	add eax, x
	shl eax, 2
	add eax, area
	
	mov ecx, lenght
	loop_for_line:
		mov dword ptr [eax], color
		add eax, 4 * AREA_WIDTH
		loop loop_for_line
endm

; sau la fiecare interval de 200ms in care nu s-a dat click
; arg1 - evt (0 - initializare, 1 - click, 2 - s-a scurs intervalul fara click, 3 - s-a apasat o tasta)
; arg2 - x (in cazul apasarii unei taste, x contine codul ascii al tastei care a fost apasata)
; arg3 - y

draw_proc proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp + arg1]
	cmp eax, 1
	jz click_event
	cmp eax, 2
	jz timer_event
	
	mov eax, AREA_WIDTH
	mov ebx, AREA_HEIGHT
	mul ebx
	shl eax, 2
	push eax
	push 255
	push area
	call memset
	add esp, 12
	
	jmp afisare_litere
		
	click_event:
		; mov eax, [ebp + arg3]
		; mov ebx, _WIDTH
		; mul ebx		; eax = y * _WIDTH
		; add eax, [ebp + arg2] ;		eax = y * _WIDTH + x
		; shl eax, 2 ; 	eax = (y * _WIDTH + x) * 4
		; add eax, area
		; mov dword ptr [eax], ROSU
		; mov dword ptr [eax - 4], ROSU
		; mov dword ptr [eax + 4], ROSU
		; mov dword ptr [eax - 4 * _WIDTH], ROSU
		; mov dword ptr [eax + 4 * _WIDTH], ROSU
		
		;draw_horizontal_line_macro [ebp + arg2], [ebp + arg3], 30, ROSU
		;draw_vertical_line_macro [ebp + arg2], [ebp + arg3], 30, ROSU
		;draw_square_macro [ebp + arg2], [ebp + arg3], 30, ROSU
		
		; mov eax, [ebp + arg2]
		; cmp eax, buton_x
		; jl button_fail
		; cmp eax, buton_x + button_size
		; jg button_fail
		; mov eax , [ebp + arg3]
		; cmp eax, buton_y
		; jl button_fail
		; cmp eax, buton_y + button_size
		; jg button_fail
		
		; make_text_macro ' ', area, 330, 400
		; make_text_macro ' ', area, 340, 400
		; make_text_macro ' ', area, 350, 400
		; make_text_macro ' ', area, 360, 400
		; make_text_macro 'O', area, 340, 400
		; make_text_macro 'K', area, 350, 400
		
		
		; jmp afisare_litere
		
		; button_fail:
		; make_text_macro ' ', area, 340, 400
		; make_text_macro ' ', area, 350, 400
		; make_text_macro 'F', area, 330, 400
		; make_text_macro 'A', area, 340, 400
		; make_text_macro 'I', area, 350, 400
		; make_text_macro 'L', area, 360, 400
		
		jmp afisare_litere
		
	timer_event:
		inc counter
		; mov eax, counter
		; cmp eax, 30
		; jz button_fail
	
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
		
		
		make_text_macro 'M', area, 300, 20
		make_text_macro 'I', area, 310, 20
		make_text_macro 'N', area, 320, 20
		make_text_macro 'E', area, 330, 20
		make_text_macro 'S', area, 340, 20
		make_text_macro 'W', area, 350, 20
		make_text_macro 'E', area, 360, 20
		make_text_macro 'E', area, 370, 20
		make_text_macro 'P', area, 380, 20
		make_text_macro 'E', area, 390, 20
		make_text_macro 'R', area, 400, 20
		
	afisare_linii_orizontale:
	
		mov ecx, -1
		mov ebx, CELL_WIDTH_AND_HEIGHT
		loop_for_horizontal_lines:
			inc ecx
			mov eax, ecx
			mul ebx
			add eax, MATRIX_Y
			
			pusha
			draw_horizontal_line_macro MATRIX_X, eax, NUMBER_OF_CELLS * CELL_WIDTH_AND_HEIGHT, BLACK
			popa
			cmp ecx, NUMBER_OF_CELLS
			jl loop_for_horizontal_lines
			
			
	___________test____________:
		draw_vertical_line_macro 100, MATRIX_Y, NUMBER_OF_CELLS * CELL_WIDTH_AND_HEIGHT, BLACK
		draw_vertical_line_macro 125, MATRIX_Y, NUMBER_OF_CELLS * CELL_WIDTH_AND_HEIGHT, BLACK
			
	afisare_linii_verticale:
		mov ecx, -1
		mov ebx, CELL_WIDTH_AND_HEIGHT
		loop_for_vertical_lines:
			inc ecx
			mov eax, ecx
			mul ebx
			add eax, MATRIX_X
			
			pusha
			draw_vertical_line_macro eax, MATRIX_Y, NUMBER_OF_CELLS * CELL_WIDTH_AND_HEIGHT, BLACK
			popa
			cmp ecx, NUMBER_OF_CELLS
			jl loop_for_vertical_lines
		
		
; patrat:
	; draw_horizontal_line_macro buton_x, buton_y, button_size, 0
	; draw_horizontal_line_macro buton_x, buton_y + button_size, button_size, 0
	 draw_vertical_line_macro buton_x, buton_y, button_size, 0
	 draw_vertical_line_macro buton_x + button_size, buton_y, button_size, 0

		
	
final_draw:
	popa
	mov esp, ebp
	pop ebp
	ret

draw_proc endp
	

start:

	mov eax, AREA_WIDTH
	mov ebx, AREA_HEIGHT
	mul ebx
	shl eax, 2
	push eax
	call malloc
	add ESP, 4
	mov area, eax
	
	;mov ebx, [_ROWS]
	;mov ecx, [_COLUMNS]
	
	push offset draw_proc
	push area
	push AREA_HEIGHT
	push AREA_WIDTH
	push offset _WINDOW_TITLE
	call BeginDrawing
	add esp, 20

	push 0
	call exit
end start
