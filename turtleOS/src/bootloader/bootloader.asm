ORG 0x7c00
BITS 16


CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

bios_parameter_block:
    jmp short initialize_code_segment
    nop

; some BIOSes might fill BIOS specific parameters.
; we can prevent the BIOS from corrupting our data by skipping 33 bytes.
times 33 db 0

initialize_code_segment:
    jmp 0:start ; initializing code segment to 0x7c0 as required by BIOS

start:
    mov si, realmode_welcome_message
    call realmode_print

    cli ; clear interrupts
    mov ax, 0x00 ; segment registers can't store immediate data.
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00
    sti ; enable interrupts
    
    ; loading to 32bit space from 16bit
    .load_protected:
        cli ; clear interrupts
        lgdt[gdt_descriptor] ; load global descriptor table
        mov eax, cr0
        or eax, 0x1,
        mov cr0, eax
        jmp CODE_SEG:load32
        jmp $
realmode_welcome_message: db 'Starting TurtleOS...', 0
realmode_print:
    .loop:
        mov bx, 0 ; same as (bh, 0 & bl, 0) || 10ah=0eh pager set.
        lodsb ; load a byte from 'si' where register is pointing into 'al' register and increment 'si' register.
        cmp al, 0 ; 0 is the null terminator.
            je .done ; jump to done if equal to
        call realmode_print_char
        jmp .loop
        .done:
            mov si, 0
            ret
realmode_print_char:
    mov ah, 0eh ; BIOS function for outputting char to screen for int 0x10
    int 0x10 ; BIOS interrupt
    ret



; GDT
gdt_start:
gdt_null:
    dd 0x0
    dd 0x0

; offset 0x8
gdt_code: ; CS Should Point To This Label
    dw 0xffff ; segment limiting first 0 to 15 bits
    dw 0 ; base first 0 to 15 bits
    db 0 ; base 16 to 23 bits
    db 0x9a ; access byte
    db 11001111b ; high 4 bit flags and the low 4 bit flags
    db 0 ; base 24 to 31 bits

; offset 0x10
gdt_data: ; should link to DS, SS, ES, FS, GS
    dw 0xffff ; segment limiting first 0 to 15 bits
    dw 0 ; base first 0 to 15 bits
    db 0 ; base 16 to 23 bits
    db 0x92 ; access byte
    db 11001111b ; high 4 bit flags and the low 4 bit flags
    db 0 ; base 24 to 31 bits
gdt_end:
; get the size between gdt_start & gtd_end
gdt_descriptor:
    dw gdt_end-gdt_start-1 ; gtd size
    dd gdt_start ; gdt offset

[BITS 32]
load32:
    mov eax, 1
    mov ecx, 100
    mov edi, 0x0100000
    call ata_lba_read
    jmp CODE_SEG:0x0100000

ata_lba_read:
    mov ebx, eax ; backing up lba
    shr eax, 24 ; shift eax to the right by 24 bits
    or eax, 0xE0
    mov dx, 0x1F6
    out dx, al

    mov eax, ecx
    mov dx, 0x1F2
    out dx, al

    mov eax, ebx
    mov dx, 0x1F3
    out dx, al

    mov dx, 0x1F4
    mov eax, ebx
    shr eax, 8
    out dx, al

    mov dx, 0x1F5
    mov eax, ebx
    shr eax, 16
    out dx, al

    mov dx, 0x1F7
    mov al, 0x20
    out dx, al

    .next_sector:
        push ecx
    .try_again:
        mov dx, 0x1F7
        in al,dx
        test al, 8
        jz .try_again

        mov ecx, 256
        mov dx, 0x1F0
        rep insw
        pop ecx
        loop .next_sector

        ret

times 510-($ - $$) db 0
dw 0xAA55