nasm -f elf ./list.asm -o ./list.o
ld -s -o list list.o  -melf_i386
gdb ./list
clear
