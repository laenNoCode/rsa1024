main: main.o
	ld main.o -o main
main.o : main.asm
	nasm main.asm -felf64
