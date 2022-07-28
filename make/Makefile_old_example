# Variables
CC=gcc
CFLAGS=-Wall
LIB_FLAGS=-L/usr/local/lib/ -lcgreen 

BUILDDIR=build

src=$(wildcard src/*.c) \
	$(wildcard tests/*.c)
VPATH := src:tests
obj=$(patsubst %.c, $(BUILDDIR)/%.o,$(notdir $(src)))
dep=$(obj:.o=.d)  # one dependency file for each source

	
unittests: dir $(obj)
	$(CC) $(obj) $(LIB_FLAGS) -o $(BUILDDIR)/unittests
	$(BUILDDIR)/unittests

dir:
	mkdir -p $(BUILDDIR)
	
$(BUILDDIR)/%.o: %.c Makefile
	$(CC) -c $(CFLAGS) $< -o $@

#-include $(dep)   # include all dep files in the makefile

# rule to generate a dep file by using the C preprocessor
# (see man cpp for details on the -MM and -MT options)
#%.d: %.c
#    @$(CC) $(CFLAGS) $< -MM -MT $(@:.d=.o) >$@
    
.PHONY: clean
clean:
	rm -f $(BUILDDIR)/unittests $(obj)
