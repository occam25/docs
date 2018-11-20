
CC=gcc
CFLAGS=-g#-Wall
LIB_FLAGS=-L/usr/local/lib/ -lcgreen

OBJ=$(patsubst %.c, $(BUILDDIR)/%.o, $(notdir $(SRC)))


$(BUILDDIR)/%.o: %.c
	$(CC) $(CFLAGS) -MMD -c $< -o $@
	
DEP = $(OBJ:%.o=%.d)
-include $(DEP)   # include all dep files in the makefile

# rule to generate a dep file by using the C preprocessor
# (see man cpp for details on the -MM and -MT options)
#%.d: %.c
#	@$(CC) $(CFLAGS) $< -MM -MT $(@:.d=.o) >$@
