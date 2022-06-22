section .data
strc_c_lib: db "c library says: hello world!", 0xa
strc_c_lib_len equ $-strc_c_lib

strc_syscall: db "syscall says:hello world!"", 0xa
strc_syscall_len equ $-strc_syscall

section .text
global _start

_start:
	push strc_c_lib_len
	push strc_c_lib
	push 1

	call simu_write
	add esp, 12

	mov eax,4
	mov ebx,1
	mov ecx, strc_syscall
	mov edx, strc_syscall_len
	int 0x80

	mov eax, 1; exit
	int 0x80

simu_write:
	push ebp
	mov ebp, esp
	mov eax, 4
	mov ebx, [ebp+8]
	mov ecx, [ebp+12]
	mov edx, [ebp+16]
	int 0x80
	pop ebp
	ret
