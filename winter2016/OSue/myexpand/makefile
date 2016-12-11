CC = gcc
DEFS = -D_XOPEN_SOURCE=500 -D_BSD_SOURCE
CFLAGS = -Wall -g -std=c99 -pedantic $(DEFS)

OBJECTFILES = myexpand.o

.PHONY: all clean

all: myexpand

myexpand: $(OBJECTFILES)
	$(CC) $(CFLAGS) -o $@ $^

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

myexpand.o: myexpand.c

clean: 
	rm -f $(OBJECTFILES) myexpand
