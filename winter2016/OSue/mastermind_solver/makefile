CC = gcc
DEFS = -D_XOPEN_SOURCE=500 -D_BSD_SOURCE
CFLAGS = -Wall -g -std=c99 -pedantic $(DEFS)

SERVERFILES = server.o
CLIENTFILES = client.o
OBJECTFILES = ${SERVERFILES} ${CLIENTFILES}

.PHONY: all clean

all: server client

server: $(SERVERFILES)
	$(CC) $(CFLAGS) -o $@ $^

client: $(CLIENTFILES)
	$(CC) $(CFLAGS) -o $@ $^

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -f $(OBJECTFILES) server client
