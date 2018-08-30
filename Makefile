#!/usr/bin/make

MACHINE=$(shell uname -m)
ifndef KERNEL_DIR
KERNEL_DIR:=/lib/modules/`uname -r`/build
endif

file_exist=$(shell test -f $(1) && echo yes || echo no)

# test for 2.6 or 2.4 kernel
ifeq ($(call file_exist,$(KERNEL_DIR)/Rules.make), yes)
PATCHLEVEL:=4
else
PATCHLEVEL:=6
endif

ifdef APPSONLY
CFLAGS:=-Wall -Wstrict-prototypes -Wno-trigraphs -O2 -s -I. -fno-strict-aliasing -fno-common -fomit-frame-pointer 
endif

KERNOBJ:=cloop.o

# Name of module
ifeq ($(PATCHLEVEL),6)
MODULE:=cloop.ko
else
MODULE:=cloop.o
endif


all: $(MODULE)

module: $(MODULE)


# For Kernel >= 2.6, we now use the "recommended" way to build kernel modules
obj-m := cloop.o
# cloop-objs := cloop.o

$(MODULE): cloop.c cloop.h
	@echo "Building for Kernel Patchlevel $(PATCHLEVEL)"
	$(MAKE) modules -C $(KERNEL_DIR) M=$(CURDIR)

clean:
	rm -rf *.o *.ko Module.symvers .tmp* modules.order cloop.mod.c .cloop*

dist: clean
	cd .. ; \
	tar -cf - cloop/{Makefile,*.[ch],CHANGELOG,README} | \
	bzip2 -9 > $(HOME)/redhat/SOURCES/cloop.tar.bz2

