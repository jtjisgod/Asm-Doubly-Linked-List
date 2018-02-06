count       equ 0x0
now         equ 0x4
first       equ 0x8

prev        equ 0x00
value       equ 0x04
next        equ 0x08

section .data
    heap_base: dd 0x00000000
    heap_used: dd 0x00000000
    heap_reta: dd 0x00000000
    listStruct: ; 리스트 구조
        dd 0x00000000 ; List Count
        dd 0x00000000 ; now
        dd 0x00000000 ; first
    ; listElement: ; 리스트 엘레먼트
    ;     dd 0x00000000 ; Prev
    ;     dd 0x00000000 ; Next
    ;     dd 0x00000000 ; Value

section .text
  global _start

_start:

    call malloc

    call test_append

    mov eax, retp1
    mov [heap_reta], eax
    jmp test_get
    retp1:

    push 0x00000000

    mov esi, 0x02
    mov edi, 0x55
    call action_insert

    mov eax, retp2
    mov [heap_reta], eax
    jmp test_get
    retp2:

    push 0x00000000

    mov esi, 0x02
    call action_remove

    mov eax, retp3
    mov [heap_reta], eax
    jmp test_get
    retp3:

    ; mov esi, 0x02
    ; call action_prev
    ; push
    ;
    ; mov esi, 0x02
    ; call action_next
    ; push

    jmp $

test_append:
    ; Append : A
    mov esi, 0x41
    call action_append
    ; Append : B
    mov esi, 0x42
    call action_append
    ; Append : C
    mov esi, 0x43
    call action_append
    ; Append : D
    mov esi, 0x44
    call action_append
    ret

test_get:
    mov esi, 0x03 ; C
    call action_get
    push eax

    mov esi, 0x04 ; D
    call action_get
    push eax

    mov esi, 0x01; A
    call action_get
    push eax

    mov esi, 0x02 ; B
    call action_get
    push eax

    mov eax, [heap_reta]
    jmp eax

malloc:
    ; Allocate Heap Memory ( Maybe 0x2000 )
    mov eax, 45
    xor ebx, ebx
    int 0x80
    mov [heap_base], eax
    mov [heap_used], eax

    ;Now allocate some space (8192 bytes)
    mov eax, 45
    mov ebx, [heap_base]
    add ebx, 0x2000
    int 0x80

    ret

action_getLast:
    ; mov ebx, [listStruct+count]
    mov ecx, [listStruct+first]
    or ecx, ecx
    jz action_getLast_end_
action_getLast_:
    mov eax, [ecx+next]
    or eax, 0x00
    jz action_getLast_end
    mov ecx, [ecx+next]
    jmp action_getLast_
action_getLast_end_:
    mov ecx, listStruct
    jmp action_getLast_end
action_getLast_end:
    mov eax, ecx
    ret



action_get_n:
    mov edx, esi
    ; inc edx
    mov ecx, [listStruct+first]
    or edx, edx
    jz action_get_n_end
action_get_n_:
    mov ecx, [ecx+next]
    dec edx
    jz action_get_n_end
    jmp action_get_n_
action_get_n_end:
    mov eax, ecx
    ret



action_append:
    call action_getLast ; return = 시작 부분 pointer
    mov edx, [heap_used]
    mov ecx, edx
    add ecx, 0x4*3 ; prev, next, value
    mov [heap_used], ecx
    mov [eax+next], edx; Prev's Next
    mov [edx+prev], eax; Prev
    mov [edx+value], esi; Value
action_append_end:
    mov edi, listStruct + count
    mov eax, [edi]
    inc ecx
    inc eax
    mov [edi], eax
    ret



action_get:
    dec esi
    call action_get_n
    mov eax, [eax+value]
    ret



action_remove:
    ;esi
    call action_get_n

    push eax
    mov ebx, eax
    add ebx, next
    push ebx

    add esi, 2
    call action_get_n
    push eax
    mov ebx, eax
    add ebx, prev
    push ebx

    ; |Next|NextAddr|Prev|PrevAddr|

    pop eax
    pop ebx
    pop ecx
    pop edx
    mov [eax], edx
    mov [ecx], ebx
action_remove_end:
    mov eax, [listStruct + count]
    inc eax
    mov [listStruct + count], eax
    ret



action_insert:

    call action_get_n
    inc esi

    mov ebx, [eax+next] ; Prev's Next
    push ebx
    mov ebx, eax
    add ebx, next
    push ebx

    call action_get_n
    mov ebx, [eax+prev] ; Prev's Next
    push ebx
    mov ebx, eax
    add ebx, prev
    push ebx

    ; |Next|NextAddr|Prev|PrevAddr|

    mov edx, [heap_used]
    mov ecx, edx ; new Element's Pointer
    add ecx, 0x4*3 ; prev, next, value -- Size Up
    mov [heap_used], ecx ; Save

    pop eax
    mov [eax], edx
    pop eax
    mov [edx+prev], eax
    pop eax
    mov [eax], edx
    pop eax
    mov [edx+next], eax

    mov [edx+value], edi

action_insert_end:
    mov eax, [listStruct + count]
    dec eax
    mov [listStruct + count], eax
    ret
