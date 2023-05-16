.386
.586
.model flat, stdcall

includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc
extern printf: proc

includelib canvas.lib
extern BeginDrawing: proc

;include Irvine32.lib

public start

.data
eax_format db "eax = %d ", 0
format db "%d ", 0
new_line_format db " ", 0Ah, 0

_WINDOW_TITLE DB "Minesweeper", 0
AREA_WIDTH EQU 800
AREA_HEIGHT EQU 600

area DD 0
counter DD 0

arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20

symbol_width EQU 10
symbol_height EQU 20

RED EQU 0FF0000h
BLACK EQU 0


buton_x EQU 300
buton_y EQU 300
button_size EQU 100

MATRIX_X EQU 100
MATRIX_Y EQU 100
CELL_WIDTH EQU 30
CELL_HEIGHT EQU 20
number_of_horizontal_cells EQU 20
number_of_vertical_cells EQU 20
matrix DD 0

dir dd -4, -84, -80, -76, 4, 84, 80, 76

include digits.inc
include letters.inc
include mine.inc

.code
; procedura make_text afiseaza o litera sau o cifra la coordonatele date
; arg1 - simbolul de afisat (litera sau cifra)
; arg2 - pointer la vectorul de pixeli
; arg3 - pos_x
; arg4 - pos_y


make_matrix_proc macro numberOfMines, _height, _width
	local i_loop, j_loop, check, assign_mines_loop, i_assign_values_loop, j_assign_values_loop, loop_test, west, north_west, north, north_east, east, south_east, south, south_west, skip
	xor ecx, ecx
	i_loop:
		xor edx, edx
		j_loop:
			mov eax, number_of_vertical_cells
			imul eax, edx
			add eax, ecx
			mov dword ptr [matrix + eax * 4], 0
			inc edx
			cmp edx, number_of_vertical_cells
			jl j_loop
		inc ecx
		cmp ecx, number_of_horizontal_cells
		jl i_loop
	
	
	xor ecx, ecx
	assign_mines_loop:
		rdtsc
		mov ebx, number_of_horizontal_cells * number_of_vertical_cells - 1
		xor edx, edx
		div ebx
		
		cmp dword ptr [matrix + edx * 4], -1
		je next
		mov dword ptr [matrix + edx * 4], -1
		inc ecx
		next:
		cmp ecx, numberOfMines
		jl assign_mines_loop
		
		
	; mov dword ptr [dir], -4
	; mov dword ptr [dir + 4], -84
	; mov dword ptr [dir + 8], -60
	; mov dword ptr [dir + 12], -76
	; mov dword ptr [dir + 16], 4
	; mov dword ptr [dir + 20], 84
	; mov dword ptr [dir + 24], 80
	; mov dword ptr [dir + 28], 76
	
	mov dword ptr [matrix + 19*4], -1
	
	xor ecx, ecx
	i_assign_values_loop:
		xor edx, edx
		j_assign_values_loop:
			mov eax, ecx
			imul eax, number_of_vertical_cells
			add eax, edx
			imul eax, 4
			
			cmp dword ptr [matrix + eax], -1; daca este bomba dam skip
			je skip
			
			west:
			cmp edx, 0; daca nu suntem in matrice dam skip
			je north_west
			cmp dword ptr [matrix + eax - 4], -1; daca nu este bomba in vest dam skip
			jne north_west
			;toate conditiile au fost indeplinite
			inc dword ptr [matrix + eax]
			
			north_west:
			cmp edx, 0
			je north
			cmp ecx, 0
			je north
			cmp dword ptr [matrix + eax - 84], -1; daca nu este bomba in vest dam skip
			jne north
			;toate conditiile au fost indeplinite
			inc dword ptr [matrix + eax]
			
			north:
			cmp ecx, 0
			je north_east
			cmp dword ptr [matrix + eax - 80], -1; daca nu este bomba in vest dam skip
			jne north_east
			;toate conditiile au fost indeplinite
			inc dword ptr [matrix + eax]
			
			north_east:
			cmp edx, number_of_vertical_cells - 1 
			je east
			cmp ecx, 0
			je east
			cmp dword ptr [matrix + eax - 76], -1; daca nu este bomba in vest dam skip
			jne east
			;toate conditiile au fost indeplinite
			inc dword ptr [matrix + eax]
			
			east:
			cmp edx, number_of_vertical_cells - 1
			je south_east
			cmp dword ptr [matrix + eax + 4], -1; daca nu este bomba in vest dam skip
			jne south_east
			;toate conditiile au fost indeplinite
			inc dword ptr [matrix + eax]
			
			south_east:
			cmp edx, number_of_vertical_cells
			je south
			cmp ecx, number_of_horizontal_cells
			je south
			cmp dword ptr [matrix + eax + 84], -1; daca nu este bomba in vest dam skip
			jne south
			;toate conditiile au fost indeplinite
			inc dword ptr [matrix + eax]
			
			south:
			cmp ecx, number_of_horizontal_cells - 1
			je south_west
			cmp dword ptr [matrix + eax + 80], -1; daca nu este bomba in vest dam skip
			jne south_west
			;toate conditiile au fost indeplinite
			inc dword ptr [matrix + eax]
			
			south_west:
			cmp edx, 0
			je skip
			cmp ecx, number_of_horizontal_cells - 1
			je skip
			cmp dword ptr [matrix + eax + 76], -1; daca nu este bomba in vest dam skip
			jne skip
			;toate conditiile au fost indeplinite
			inc dword ptr [matrix + eax]
			
			
			skip:
			inc edx
			
			cmp edx, number_of_vertical_cells
			jl j_assign_values_loop
		
		
		inc ecx
		cmp ecx, number_of_horizontal_cells
		jl i_assign_values_loop
		
	xor ecx, ecx
	i_loop_test:
		xor edx, edx
		
		j_loop_test:
		
			pusha
			mov eax, number_of_vertical_cells
			imul eax, ecx
			add eax, edx
			push dword ptr [matrix + eax * 4]
			push offset format
			call printf
			add esp, 8
			popa
			inc edx
			cmp edx, number_of_vertical_cells
			jl j_loop_test
			
			
			pusha
			push offset new_line_format
			call printf
			add esp, 4
			popa
			
		inc ecx
		cmp ecx, number_of_horizontal_cells
		jl i_loop_test

endm

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
	cmp eax, ' '
	jnz make_mine
	mov eax, 26 ; de la 0 pana la 25 sunt litere, 26 e space
	lea esi, letters
make_mine:
	mov eax, 0
	lea esi, mine
	mov edx, -1
	
draw_text:
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax
	mov ecx, symbol_height
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matrix de pixeli
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

draw_on_center macro start_x, start_y, end_x, end_y
	local
	

endm

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
		mov ebx, CELL_HEIGHT
		
		loop_for_horizontal_lines:
			inc ecx
			xor edx, edx
			mov eax, ecx
			mul ebx
			add eax, MATRIX_Y
			
			pusha
			draw_horizontal_line_macro MATRIX_X, eax, number_of_vertical_cells * CELL_WIDTH, BLACK
			popa
			
			cmp ecx, number_of_vertical_cells
			jl loop_for_horizontal_lines
			
			
	___________test____________:
		draw_horizontal_line_macro MATRIX_X, 99, number_of_horizontal_cells * CELL_WIDTH + 2, BLACK
		draw_horizontal_line_macro MATRIX_X - 1, 501, number_of_horizontal_cells * CELL_WIDTH + 2, BLACK
		draw_vertical_line_macro 99, MATRIX_Y, number_of_horizontal_cells * CELL_HEIGHT + 2, BLACK
		draw_vertical_line_macro 100, MATRIX_Y, number_of_horizontal_cells * CELL_HEIGHT, BLACK
		draw_vertical_line_macro 130, MATRIX_Y, number_of_horizontal_cells * CELL_HEIGHT, BLACK
		draw_vertical_line_macro 160, MATRIX_Y, number_of_horizontal_cells * CELL_HEIGHT, BLACK
		draw_vertical_line_macro 190, MATRIX_Y, number_of_horizontal_cells * CELL_HEIGHT, BLACK
		draw_vertical_line_macro 220, MATRIX_Y, number_of_horizontal_cells * CELL_HEIGHT, BLACK
		draw_vertical_line_macro 250, MATRIX_Y, number_of_horizontal_cells * CELL_HEIGHT, BLACK
		draw_vertical_line_macro 280, MATRIX_Y, number_of_horizontal_cells * CELL_HEIGHT, BLACK
		draw_vertical_line_macro 310, MATRIX_Y, number_of_horizontal_cells * CELL_HEIGHT, BLACK
		draw_vertical_line_macro 340, MATRIX_Y, number_of_horizontal_cells * CELL_HEIGHT, BLACK
		draw_vertical_line_macro 370, MATRIX_Y, number_of_horizontal_cells * CELL_HEIGHT, BLACK
		draw_vertical_line_macro 400, MATRIX_Y, number_of_horizontal_cells * CELL_HEIGHT, BLACK
		draw_vertical_line_macro 430, MATRIX_Y, number_of_horizontal_cells * CELL_HEIGHT, BLACK
		draw_vertical_line_macro 460, MATRIX_Y, number_of_horizontal_cells * CELL_HEIGHT, BLACK
		draw_vertical_line_macro 490, MATRIX_Y, number_of_horizontal_cells * CELL_HEIGHT, BLACK
		draw_vertical_line_macro 520, MATRIX_Y, number_of_horizontal_cells * CELL_HEIGHT, BLACK
		draw_vertical_line_macro 550, MATRIX_Y, number_of_horizontal_cells * CELL_HEIGHT, BLACK
		draw_vertical_line_macro 580, MATRIX_Y, number_of_horizontal_cells * CELL_HEIGHT, BLACK
		draw_vertical_line_macro 610, MATRIX_Y, number_of_horizontal_cells * CELL_HEIGHT, BLACK
		draw_vertical_line_macro 640, MATRIX_Y, number_of_horizontal_cells * CELL_HEIGHT, BLACK
		draw_vertical_line_macro 670, MATRIX_Y, number_of_horizontal_cells * CELL_HEIGHT, BLACK
		draw_vertical_line_macro 700, MATRIX_Y, number_of_horizontal_cells * CELL_HEIGHT, BLACK
		draw_vertical_line_macro 701, MATRIX_Y, number_of_horizontal_cells * CELL_HEIGHT + 2, BLACK
			
	; afisare_linii_verticale:
		; mov ecx, -1
		; mov ebx, CELL_WIDTH
		; loop_for_vertical_lines:
			; inc ecx
			; xor edx, edx
			; mov eax, ecx
			; mul ebx
			; add eax, MATRIX_X
			
			; pusha
			; draw_vertical_line_macro eax, MATRIX_Y, number_of_horizontal_cells * CELL_HEIGHT, BLACK
			; popa
			; cmp ecx, number_of_horizontal_cells
			; jl loop_for_vertical_lines
		
		
; patrat:
	; draw_horizontal_line_macro buton_x, buton_y, button_size, 0
	; draw_horizontal_line_macro buton_x, buton_y + button_size, button_size, 0
	;draw_vertical_line_macro buton_x, buton_y, button_size, 0
	;draw_vertical_line_macro buton_x + button_size, buton_y, button_size, 0

		
	
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
	
	xor edx, edx
	mov eax, number_of_horizontal_cells
	mov ebx, number_of_vertical_cells
	mul ebx
	call malloc
	add esp, 4
	mov matrix, eax
	
	; mov dir[0], -4 ; west
	; mov eax, number_of_vertical_cells
	; imul eax, 4
	; neg eax
	; sub eax, 4
	; mov dir[1], eax ; north-west
	; add eax, 4
	; mov dir[2], eax ; north
	; add eax, 4
	; mov dir[3], eax ; north-east
	; mov dir[4], 4 ; east
	; mov eax, number_of_vertical_cells
	; imul eax, 4
	; add eax, 4
	; mov dir[5], eax ; south-east
	; sub eax, 4
	; mov dir[6], eax	; south
	; sub eax, 4
	; mov dir[7], eax ; south-west
	
	
	; pusha
	; push dir[6]
	; push offset format
	; add esp, 8
	; popa
	
	pusha
	make_matrix_proc 60, 20, 20
	popa
	
	
	; pusha
	; push dword ptr [matrix + 181*4]
	; push offset format
	; call printf
	; add esp, 8
	; popa
	
	
	
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
