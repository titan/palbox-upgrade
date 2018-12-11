NAME = upgrade
BUILDDIR=/dev/shm/$(NAME)
TARGET = $(BUILDDIR)/upgrade.elf

BUILDSRC:=$(BUILDDIR)/Makefile
CORESRC:=$(BUILDDIR)/upgrade.c
NETSRC:=$(BUILDDIR)/ec20.c
PROTOSRC:=$(BUILDDIR)/packet.c
REPLSRC:=$(BUILDDIR)/repl.c
UTILSRC:=$(BUILDDIR)/hash.c $(BUILDDIR)/utility.c $(BUILDDIR)/base64.c $(BUILDDIR)/ring.c $(BUILDDIR)/stack.c $(BUILDDIR)/defination.h
EC20BOOTFSMSRC:=$(BUILDDIR)/ec20-boot-fsm.c
EC20UDPFSMSRC:=$(BUILDDIR)/ec20-udp-fsm.c
EC20HTTPFSMSRC:=$(BUILDDIR)/ec20-http-fsm.c
EC20SYNTAXFSMSRC:=$(BUILDDIR)/ec20-syntax-fsm.c
EC20LEXFSMSRC:=$(BUILDDIR)/ec20-lex-fsm.c
REPLFSMSRC:=$(BUILDDIR)/repl-fsm.c
REPLLEXFSMSRC:=$(BUILDDIR)/repl-lex-fsm.c
DRIVERSRC:=$(BUILDDIR)/w25x16.c $(BUILDDIR)/uart.c $(BUILDDIR)/led.c
LIBRARY:=$(BUILDDIR)/libopencm3

DEPENDS = $(BUILDSRC) $(CORESRC) $(NETSRC) $(PROTOSRC) $(DRIVERSRC) $(REPLSRC) $(UTILSRC) $(LIBRARY) $(REPLFSMSRC) $(REPLLEXFSMSRC) $(DRIVERSRC) $(EC20BOOTFSMSRC) $(EC20UDPFSMSRC) $(EC20HTTPFSMSRC) $(EC20SYNTAXFSMSRC) $(EC20LEXFSMSRC)

include .config

all: $(TARGET)

$(TARGET): $(DEPENDS)
	cd $(BUILDDIR); make; cd -

$(CORESRC): core.org | prebuild
	org-tangle $<

$(NETSRC): network.org | prebuild
	org-tangle $<

$(PROTOSRC): proto.org | prebuild
	org-tangle $<

$(DRIVERSRC): driver.org | prebuild
	org-tangle $<

$(REPLSRC): repl.org | prebuild
	org-tangle $<

$(UTILSRC): utility.org | prebuild
	org-tangle $<

$(REPLFSMSRC): repl-fsm.txt | prebuild
	fsm-generator.py $< -d $(BUILDDIR) --prefix repl --style table

$(REPLLEXFSMSRC): repl-lex-fsm.txt | prebuild
	fsm-generator.py $< -d $(BUILDDIR) --prefix repl_lex --style table

$(EC20BOOTFSMSRC): ec20-boot-fsm.txt | prebuild
	fsm-generator.py $< -d $(BUILDDIR) --prefix ec20_boot --style table
#	fsm-generator.py $< -d $(BUILDDIR) --prefix ec20_boot --style table --debug
#	sed -i '1a#include "repl.h"' $@
#	sed -i '1d' $@
#	sed -i 's/printf(\"(\");/output_string(\"(\");/g' $@
#	sed -i 's/printf/output_string/g' $@
#	sed -i 's/\\n/\\r\\n/g' $@

$(EC20UDPFSMSRC): ec20-udp-fsm.txt | prebuild
	fsm-generator.py $< -d $(BUILDDIR) --prefix ec20_udp --style table
#	fsm-generator.py $< -d $(BUILDDIR) --prefix ec20_udp --style table --debug
#	sed -i '1a#include "repl.h"' $@
#	sed -i '1d' $@
#	sed -i 's/printf(\"(\");/output_string(\"(\");/g' $@
#	sed -i 's/printf/output_string/g' $@
#	sed -i 's/\\n/\\r\\n/g' $@

$(EC20HTTPFSMSRC): ec20-http-fsm.txt | prebuild
	fsm-generator.py $< -d $(BUILDDIR) --prefix ec20_http --style table
#	fsm-generator.py $< -d $(BUILDDIR) --prefix ec20_http --style table --debug
#	sed -i '1a#include "repl.h"' $@
#	sed -i '1d' $@
#	sed -i 's/printf(\"(\");/output_string(\"(\");/g' $@
#	sed -i 's/printf/output_string/g' $@
#	sed -i 's/\\n/\\r\\n/g' $@

$(EC20SYNTAXFSMSRC): ec20-syntax-fsm.txt | prebuild
	fsm-generator.py $< -d $(BUILDDIR) --prefix ec20_syntax --style table
#	fsm-generator.py $< -d $(BUILDDIR) --prefix ec20_syntax --style table --debug
#	sed -i '1a#include "repl.h"' $@
#	sed -i '1d' $@
#	sed -i 's/printf(\"(\");/output_string(\"(\");/g' $@
#	sed -i 's/printf/output_string/g' $@
#	sed -i 's/\\n/\\r\\n/g' $@

$(EC20LEXFSMSRC): ec20-lex-fsm.txt | prebuild
	fsm-generator.py $< -d $(BUILDDIR) --prefix ec20_lex --style table
#	fsm-generator.py $< -d $(BUILDDIR) --prefix ec20_lex --style table --debug
#	sed -i '1a#include "repl.h"' $@
#	sed -i '1d' $@
#	sed -i 's/printf(\"(\");/output_string(\"(\");/g' $@
#	sed -i 's/printf/output_string/g' $@
#	sed -i 's/\\n/\\r\\n/g' $@

$(BUILDSRC): build.org | prebuild
	org-tangle $<
	sed -i 's/        /\t/g' $@
	sed -i 's/        /\t/g' $(BUILDDIR)/libopencm3.rules.mk
	sed -i 's/        /\t/g' $(BUILDDIR)/libopencm3.target.mk

$(LIBRARY):
	ln -sf $(LIBOPENCM3_PATH) $(BUILDDIR)

flash: $(TARGET)
	cd $(BUILDDIR); make flash V=1; cd -

prebuild:
ifeq "$(wildcard $(BUILDDIR))" ""
	@mkdir -p $(BUILDDIR)
endif

clean:
	rm -rf $(BUILDDIR)

.PHONY: all clean flash prebuild
