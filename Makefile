STRIP ?= strip
STRIP_FLAGS_STATIC    = --strip-debug
STRIP_FLAGS_DYNAMIC   = --strip-unneeded
STATIC_KPKG_LDFLAGS  ?= -L/usr/lib/x86_64-linux-gnu

CC ?= cc
CFLAGS ?= -O2 -Wall -std=c11 -I/usr/include -I/usr/include/x86_64-linux-gnu

DYNAMIC_KPKG_LDFLAGS := -lz -larchive -llzma -lbz2 -llz4 -llz4 -lcurl -lssl -lcrypto -lssl -lacl -lnghttp2 -lzstd -lsqlite3 -lexpat -ldl -lpthread -lm -lc

CURL_LGFLAGS         := -Wl,-Bstatic,-pie -lcurl -lnghttp2 -lssh2 -lnspr4
STATIC_KPKG_LDFLAGS  += -lcrypto -lnettle -lssl -larchive -lbz2 -llzma -llz4 -llzo2 -lzstd -lz -lreadline -lncurses -lacl -lsqlite3 -lexpat -lpthread -ldl -lm -lc

all: support.o sqlite_callbacks.o sqlite_backend.o file_operation.o kpkg.o
	$(CC) $(CFLAGS) -o kpkg sqlite_backend.o sqlite_callbacks.o support.o file_operation.o kpkg.o $(CURL_LGFLAGS) $(STATIC_KPKG_LDFLAGS)
	$(STRIP) $(STRIP_FLAGS_STATIC) kpkg

kpkg_dynamic: support.o sqlite_callbacks.o sqlite_backend.o file_operation.o kpkg.o
	$(CC) $(CFLAGS) -o kpkg_dynamic sqlite_backend.o sqlite_callbacks.o support.o file_operation.o kpkg.o $(DYNAMIC_KPKG_LDFLAGS)
	$(STRIP) $(STRIP_FLAGS_DYNAMIC) kpkg_dynamic

file_operation.o: file_operation.c datastructs.h sqlite_callbacks.h
	$(CC) $(CFLAGS) -c file_operation.c -o file_operation.o

sqlite_backend.o: sqlite_backend.c datastructs.h sqlite_callbacks.h
	$(CC) $(CFLAGS) -c sqlite_backend.c -o sqlite_backend.o

sqlite_callbacks.o: sqlite_callbacks.c datastructs.h sqlite_callbacks.h
	$(CC) $(CFLAGS) -c sqlite_callbacks.c -o sqlite_callbacks.o

support.o: support.c datastructs.h sqlite_callbacks.h
	$(CC) $(CFLAGS) -c support.c -o support.o

kpkg.o: sqlite_backend.h datastructs.h sqlite_callbacks.h version.h
	$(CC) $(CFLAGS) -c kpkg.c -o kpkg.o

version.h:
	echo "#define VERSION `git shortlog | grep -E '^[ ]+\w+' | wc -l`" > version.h

clean:
	rm -f file_operation.o sqlite_backend.o sqlite_callbacks.o support.o kpkg.o version.h kpkg kpkg_dynamic
