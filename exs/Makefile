.SUFFIXES: .$(EXT) .asm
COMP=../diy # compiler
EXT=diy # file extension: .$(EXT)
LIB=diy # runtime library: lib$(LIB).a
RUN=../run # runtime directory
DIY_RUN=../diy_run # diy runtime dir
AS=nasm -felf32 # assembler command
LD=ld -melf_i386 # loader command

SRC=hello.diy ack.diy mean.diy factorial.diy 
EXE=$(SRC:%.diy=%)

all:: compiler runtime $(EXE)

compiler::
	make -C ..

runtime::
	make -C $(RUN)

%:%.$(EXT)
	$(COMP) $<
	$(AS) $*.asm -o $*.o
	$(LD) -o $@ $*.o -L$(RUN) -L$(DIY_RUN) -l$(LIB)

clean::
	rm -f *.o *.asm *.s *~ $(EXE)
