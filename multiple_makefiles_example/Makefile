
ROOTDIR=$(CURDIR)
BUILDDIR=$(CURDIR)/build
SRC=$(wildcard *.c)

export BUILDDIR
export ROOTDIR

.DEFAULT_GOAL := unittests

include common.mk

unittests: dir externals $(OBJ)
	@echo "[+] Linking object files..."
	$(CC) $(BUILDDIR)/*.o $(LIB_FLAGS) -o $(BUILDDIR)/unittests
	@echo "[+] Executing tests..."
	$(BUILDDIR)/unittests

externals:
	@echo "[+] Compiling externals"
	@$(MAKE) -C lib1 -f lib1.mk

dir:
	mkdir -p $(BUILDDIR)

clean: 
	rm -f $(OBJ) 2>&1 > /dev/NULL
	rm -f $(DEP) 2>&1 > /dev/NULL
	rm -f $(BUILDDIR)/unittests.exe 2>&1 > /dev/NULL
	@$(MAKE) -C lib1 -f lib1.mk clean

