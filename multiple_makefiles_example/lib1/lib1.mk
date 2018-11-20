
include $(ROOTDIR)/common.mk

CFLAGS += -Wall
LIB1_SRC=C:/cygwin64/home/Administrator/tmp/lib1

SRC=$(wildcard $(LIB1_SRC)/*.c)
OBJ=$(patsubst %.c, $(BUILDDIR)/%.o, $(notdir $(SRC)))

all: $(OBJ)

clean:
	rm -f $(OBJ) 2>&1 > /dev/NULL
	rm -f $(DEP) 2>&1 > /dev/NULL
