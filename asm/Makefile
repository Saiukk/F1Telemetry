EXE= telemetry
EXE2= main
AS_FLAG = --32 -gstabs

all: Eseguo		#creo una operazione per tutte e due i comandi

$(EXE).o:
	
	as $(AS_FLAG) src/$(EXE).s -o obj/$(EXE).o

CompiloC: $(EXE).o 	#Non fa questo comando finche (EXE).o non è stato fatto 
	gcc -c -m32 src/$(EXE2).c -o obj/$(EXE2).o

Eseguo: CompiloC
	gcc -m32 obj/$(EXE2).o obj/$(EXE).o  -o bin/telemetry

clear:
	rm -f obj/$(EXE).o obj/$(EXE2).o bin/telemetry







