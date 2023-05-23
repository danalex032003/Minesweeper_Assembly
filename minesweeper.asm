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

public start

.data
eax_format db "eax = %d ", 0
test_format db "test = %d ", 0
format db "%d ", 0
new_line_format db " ", 0Ah, 0
x_format db "x = %d ", 0
y_format db "y = %d", 0

WINDOW_TITLE DB "Minesweeper", 0
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

BLACK EQU 0

int_to_string db '0', 0


MATRIX_X EQU 100
MATRIX_Y EQU 100
CELL_WIDTH EQU 30
CELL_HEIGHT EQU 20
number_of_horizontal_cells EQU 20
number_of_vertical_cells EQU 20
matrix DD 0


include digit.inc
include digits.inc
include letters.inc
include mine.inc

.code
; procedura make_text afiseaza o litera sau o cifra la coordonatele date
; arg1 - simbolul de afisat (litera sau cifra)
; arg2 - pointer la vectorul de pixeli
; arg3 - pos_x
; arg4 - pos_y


make_matrix_proc macro numberOfMines
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
	
		
	
	; mov dword ptr [matrix + 19*4], -1
	
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
	xor eax, eax
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
	cmp eax, '9'
	jle bug
	sub eax, '0'
	lea esi, digit
	bug:
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

get_cell_number_macro macro x, y
	
	mov eax, x
	sub eax, 100
	xor edx, edx
	mov ebx, CELL_WIDTH
	div ebx
	
	push eax
	
	mov eax, y
	sub eax, 100
	xor edx, edx
	mov ebx, CELL_HEIGHT
	div ebx
	
	push eax
endm

get_symbol_from_click_macro macro x_cell, y_cell
	push eax
	push ebx
	
	mov eax, x_cell
	imul eax, 4
	mov ebx, y_cell
	imul ebx, 4 * number_of_vertical_cells
	add eax, ebx
	
	push eax
endm

; sau la fiecare interval de 200ms in care nu s-a dat click
; arg1 - evt (0 - initializare, 1 - click, 2 - s-a scurs intervalul fara click, 3 - s-a apasat o tasta)
; arg2 - x (in cazul apasarii unei taste, x contine codul ascii al tastei care a fost apasata)
; arg3 - y

game_over_macro macro
	
	make_text_macro 'G', area, 350, 300
	make_text_macro 'A', area, 360, 300
	make_text_macro 'M', area, 370, 300
	make_text_macro 'E', area, 380, 300
	make_text_macro ' ', area, 390, 300
	make_text_macro 'O', area, 400, 300
	make_text_macro 'V', area, 410, 300
	make_text_macro 'E', area, 420, 300
	make_text_macro 'R', area, 430, 300
	call exit
endm

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
	
		mov eax, [ebp + arg2]
		cmp eax, 100
		jle afisare_litere
		cmp eax, 700
		jge afisare_litere

		mov eax, [ebp + arg3] ; y
		cmp eax, 100
		jle afisare_litere
		cmp eax, 500
		jge afisare_litere
		mov ebx, AREA_WIDTH
		mul ebx
		add eax, [ebp + arg2] ; x
		shl eax, 2
		add eax, area
		
		get_cell_number_macro [ebp + arg2], [ebp + arg3]
		pop ebx ; y
		pop eax ; x
		
		
		
		get_symbol_from_click_macro eax, ebx
		
		pop edx
		pop ebx
		pop eax
		imul eax, CELL_WIDTH
		imul ebx, CELL_HEIGHT
		add eax, 110
		add ebx, 100
		
		; pusha	
		; mov ecx, eax
		; mov edx, eax
		; add edx, 30
		
		; pusha
		; push ecx
		; push offset eax_format
		; call printf
		; add esp, 8
		; popa
		; pusha
		; push edx
		; push offset eax_format
		; call printf
		; add esp, 8
		; popa
		; draw_horizontal_line_macro 30, ebx, CELL_HEIGHT, 1434A4h
		; draw_horizontal_line_macro 31, ebx, CELL_HEIGHT, 1434A4h
		; draw_horizontal_line_macro 32, ebx, CELL_HEIGHT, 1434A4h
		; add ecx, 5
		; add edx, 5
		; draw_horizontal_line_macro 100, 105, CELL_WIDTH, 3F00FFh
		; loop_for_white:
			; pusha
			; draw_horizontal_line_macro ecx, ebx, CELL_HEIGHT, 3F00FFh
			; popa
			; inc ecx
			; cmp ecx, edx
			; jl loop_for_white
		; popa	
		
		
		
		
		
		push eax
		mov eax, dword ptr [matrix + edx]
		add eax, '0'
		mov dword ptr [int_to_string], eax
		mov dword ptr [int_to_string + 1], 0 
		pop eax
		

		pusha
		push dword ptr [int_to_string]
		push offset test_format
		call printf
		add esp, 8
		popa
		
		
		make_text_macro dword ptr [int_to_string], area, eax, ebx
		cmp dword ptr [matrix + edx], -1
		jne afisare_litere
		game_over_macro
		; call exit
		
		jmp afisare_litere
		
	bucla_linii:
		mov eax, [ebp+arg2]
		and eax, 0FFh
		; provide a new (random) color
		mul eax
		mul eax
		add eax, ecx
		push ecx
		mov ecx, area_width
	bucla_coloane:
		mov [edi], eax
		add edi, 4
		add eax, ebx
		loop bucla_coloane
		pop ecx
		loop bucla_linii
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
		
		
		make_text_macro 'M', area, 350, 20
		make_text_macro 'I', area, 360, 20
		make_text_macro 'N', area, 370, 20
		make_text_macro 'E', area, 380, 20
		make_text_macro 'S', area, 390, 20
		make_text_macro 'W', area, 400, 20
		make_text_macro 'E', area, 410, 20
		make_text_macro 'E', area, 420, 20
		make_text_macro 'P', area, 430, 20
		make_text_macro 'E', area, 440, 20
		make_text_macro 'R', area, 450, 20
		
	cmp counter, 1
	jg afisare_linii_orizontale
	mov ecx, 100
	loop_for_color:
		pusha
		draw_vertical_line_macro ecx, MATRIX_Y, number_of_horizontal_cells * CELL_HEIGHT, 0c9e6f2h
		popa
		inc ecx
		cmp ecx, 700
		jl loop_for_color
	
	
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
	
	
	; pusha
	; push eax
	; push offset test_format
	; call printf
	; add esp, 8
	; popa

	
	
	;xor edx, edx
	mov eax, number_of_horizontal_cells
	mov ebx, number_of_vertical_cells
	mul ebx
	call malloc
	add esp, 4
	mov matrix, eax
	
	
	
	pusha
	make_matrix_proc 60
	popa
	
	
	push offset draw_proc
	push area
	push AREA_HEIGHT
	push AREA_WIDTH
	push offset WINDOW_TITLE
	call BeginDrawing
	add esp, 20
	
	

	push 0
	call exit
end start
