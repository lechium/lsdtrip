BINDIR   ?= bin
PREFIX   ?= usr
DESTDIR  ?= /
SRC      := $(wildcard *.m) $(wildcard FindProcess/*.m)
OBJ      := $(SRC:.m=.o)
CFLAGS   := -ObjC -O2 -g -fno-rtti -fvisibility=hidden  -fvisibility-inlines-hidden -IFindProcess
CPPFLAGS := $(CFLAGS)
LDFLAGS  := -framework Foundation -framework MobileCoreServices -framework UIKit -IFindProcess
LDID     := ldid
TARGET   := lsdtrip

CC      = xcrun -sdk appletvos clang -arch arm64

.PHONY: all clean

all: $(TARGET)

%.o: %.m %.d Makefile
	$(CC) -c $(CFLAGS) -o $@ $<

$(DESTDIR)/$(PREFIX)/$(BINDIR):
	mkdir -p $@

$(TARGET).bin: $(OBJ)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^

$(TARGET): $(TARGET).bin
	$(LDID) -Sent.plist $^
	cp $^ $@

install: all | $(DESTDIR)/$(PREFIX)/$(BINDIR)
	cp $(TARGET) $(DESTDIR)/$(PREFIX)/$(BINDIR)/

clean:
	rm -rf $(TARGET) $(TARGET).bin *.o *.d

%.d: %.m
	@echo generating depends for $<
	@set -e; rm -f $@; \
	$(CC) -M $(CPPFLAGS) $< > $@.$$$$; \
	sed 's,\($*\)\.o[ :]*,\1.o $@ : ,g' < $@.$$$$ > $@; \
	rm -f $@.$$$$

-include $(SRC:.m=.d)
