########################################
#  'ar002' -- compression archiver     #
#  makefile for gcc                    #
########################################

CC = gcc
SRCS = ar.c io.c encode.c decode.c maketree.c maketbl.c huf.c
OBJS = ar.o io.o encode.o decode.o maketree.o maketbl.o huf.o

ar002: $(OBJS)
	gcc $(OBJS) -o ar002

.c.o:
	$(CC) -c -Wall $<

$(OBJS): ar.h
