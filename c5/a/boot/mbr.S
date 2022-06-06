%include "boot.inc"
SECTION MBR vstart=0x7c00
mov ax,cs
mov ds,ax
mov es,ax
mov ss,ax
mov fs,ax
mov sp,0x7c00
mov ax,0xb800 					; GPU register address
mov gs,ax

; clear screen	
mov ax,0600h
mov bx,0700h
mov cx,0
mov dx,184fh
int 10h

; print 'MBR' on screen
mov byte [gs:0x0],'1'
mov byte [gs:0x1],0xa4

mov byte [gs:0x2],' '
mov byte [gs:0x3],0xa4

mov byte [gs:0x4],'M'
mov byte [gs:0x5],0xa4

mov byte [gs:0x6],'B'
mov byte [gs:0x7],0xa4

mov byte [gs:0x8],'R'
mov byte [gs:0x9],0xa4

mov eax,LOADER_START_SECTOR 	; loader's LBA 
mov bx,LOADER_BASE_ADDR 	; write loader to 0x900
mov cx,4 			; number of sector to read
call rd_disk_m_16

jmp LOADER_BASE_ADDR+ 0x300

rd_disk_m_16:	
	mov esi,eax
	mov di,cx

	; step 1: config number of secto to read
	mov dx,0x1f2
	mov al,cl
	out dx,al

	mov eax,esi

	; step 2: write LBA to 0x1f3 ~ 0x1f6
	
	; 2.1 write bits 0~7 to 0x1f3
	mov dx,0x1f3
	out dx,al

	;2.1 write bits 8~15 to 0x1f4
	mov cl,8
	shr eax,cl
	mov dx,0x1f4
	out dx,al

	;2.2 write bits 16~23 to 0x1f5
	shr eax,cl
	mov dx,0x1f5
	out dx,al

	;2.3 write bits 24~31 to 0x1f6
	shr eax,cl
	and al,0x0f					; LBA bits 24~27
	or al,0xe0					; set bits 7~4 to 1110, using LBA mode
	mov dx,0x1f6
	out dx,al

	; step 3: write command(0x20) to 0x1f7
	mov dx,0x1f7
	mov al,0x20
	out dx,al

	; step 4: monitor disk's status, if disk is not ready then wait
.not_ready:
	nop
	in al,dx
	and al,0x88
	cmp al,0x08
	jnz .not_ready

	; step 5: read disk from 0x1f0 port
	mov ax,di					; di:number of sector to read
	mov dx,256					; 256 = 512(sector's size)/2(ready 2 bytes each time)
	mul dx
	mov cx,ax 					; total bytes to read: di*512/2=di*256

	mov dx,0x1f0
.go_on_read:
	in ax,dx
	mov [bx],ax
	add bx,2
	loop .go_on_read
	ret

times 510-($-$$) db 0
db 0x55, 0xaa

