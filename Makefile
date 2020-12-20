main: main.o
	ld main.o -o main
main.o : main.asm
	nasm main.asm -felf64
file: file.o
	ld file.o -o file
file.o : file.asm
	nasm file.asm -felf64