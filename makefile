CC = gcc
EXEC = triexec
SRC = $(wildcard *.c)
OBJ = $(SRC:.c=.o)

all : $(EXEC)

$(EXEC) : $(OBJ)
	$(CC) -o $@ $^

%.o : %.c
	$(CC) -o $@ -c $<
	
clean : 
	rm *.o
	rm $(EXEC)