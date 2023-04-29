BINDIR   ?= bin
PREFIX   ?= usr
DESTDIR  ?= /
BUILDDIR := ./build
SRC      := $(wildcard *.m) $(wildcard FindProcess/*.m)
OBJ      := $(SRC:%.m=$(BUILDDIR)/%.o)
CFLAGS   := -ObjC -O2 -g -fno-rtti -fvisibility=hidden  -fvisibility-inlines-hidden -IFindProcess
CPPFLAGS := $(CFLAGS)
LDFLAGS  := -framework Foundation -framework MobileCoreServices -framework UIKit -IFindProcess
LDFLAGS_MAC := -framework Foundation -framework CoreServices -framework AppKit -IFindProcess
LDID     := ldid
TARGET   := lsdtrip

CC      = xcrun -sdk appletvos clang -arch arm64

.PHONY: all clean

all: $(TARGET)

$(BUILDDIR)/%.o: %.m $(BUILDDIR)/%.d Makefile
	@mkdir -p $(dir $@)
	@$(CC) -c $(CFLAGS) -o $@ $<

$(DESTDIR)/$(PREFIX)/$(BINDIR):
	mkdir -p $@

$(BUILDDIR)/$(TARGET).bin: $(OBJ)
	@$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^

$(TARGET): $(BUILDDIR)/$(TARGET).bin
	@$(LDID) -Sent.plist $^
	@cp $^ $@

install: all | $(DESTDIR)/$(PREFIX)/$(BINDIR)
	cp $(TARGET) $(DESTDIR)/$(PREFIX)/$(BINDIR)/

clean:
	rm -rf $(TARGET) $(BUILDDIR)/$(TARGET).bin $(BUILDDIR)/*.o $(BUILDDIR)/*.d $(BUILDDIR)/**/*.o $(BUILDDIR)/**/*.d

$(BUILDDIR)/%.d: %.m
	@mkdir -p $(dir $@)
	@echo generating depends for $<
	@set -e; rm -f $@; \
	$(CC) -M $(CPPFLAGS) $< > $@.$$$$; \
	sed 's,\($*\)\.o[ :]*,\1.o $@ : ,g' < $@.$$$$ > $@; \
	rm -f $@.$$$$

-include $(SRC:.m=.d)
