.section .data

pilot_0_str:
    .string   "Pierre Gasly\0"
pilot_1_str:
    .string   "Charles Leclerc\0"
pilot_2_str:
    .string   "Max Verstappen\0"
pilot_3_str:                       
    .string   "Lando Norris\0"
pilot_4_str:
    .string   "Sebastian Vettel\0"
pilot_5_str:
    .string   "Daniel Ricciardo\0"
pilot_6_str: 
    .string   "Lance Stroll\0"
pilot_7_str:
    .string   "Carlos Sainz\0"
pilot_8_str:
    .string   "Antonio Giovinazzi\0"
pilot_9_str:
    .string   "Kevin Magnussen\0"
pilot_10_str:
    .string  "Alexander Albon\0"
pilot_11_str:
    .string  "Nicholas Latifi\0"
pilot_12_str:
    .string  "Lewis Hamilton\0"
pilot_13_str:
    .string  "Romain Grosjean\0"
pilot_14_str:
    .string  "George Russell\0"
pilot_15_str:
    .string  "Sergio Perez\0"
pilot_16_str:
    .string  "Daniil Kvyat\0"
pilot_17_str:
    .string  "Kimi Raikkonen\0"
pilot_18_str:
    .string  "Esteban Ocon\0"
pilot_19_str:
    .string  "Valtteri Bottas\0"

invalid_pilot_str:	
.string "Invalid\n"

count_char:
.long 0

count:
.int 0

freq_pilota:
.long 0

flag:
.int 1

id:
.int -1

virgola:
.ascii ","

invio:
.ascii "\n"

velMax:
.long 0

velMedia:
.long 0

rpmMax:
.long 0

temperaturaMax:
.long 0

flagid:
.int 0

IntToStr_len:
.long 0

rpm_long:
.long 0

temperatura_long:
.long 0

vel_long:
.long 0

id_long:
.int 0

# stringhe soglie
LOW:
.ascii "LOW"

MEDIUM:
.ascii "MEDIUM"

HIGH:
.ascii "HIGH"

IntToStr:
.ascii "00000\0"

tempo_len:
.long 0

tempo_str:
.ascii "0000000000000000000000"


.section .text
    .global telemetry

telemetry:

movl 4(%esp), %e\\\si      # stringa input
movl 8(%esp), %edi      # stringa output

# SALVO I REGISTRI GENERAL PURPOSE
pushl %eax
pushl %ebx  
pushl %ecx
pushl %edx

# IMPOSTO I REGISTRI A ZERO
xorl %eax, %eax
xorl %ebx, %ebx
xorl %ecx, %ecx
xorl %edx, %edx

loop_lettura:
    movb (%esi, %ecx), %al   # scorro la stringa
    cmpb $0, %al    # controllo di non aver letto il carattere \0
    je fine_loop_lettura


    cmpl $-1, id    # Se non è uguale ho trovato l'id e posso prendere i tempi, rpm, temperature etc..
    jne catch_dati  
    call trova_pilota 
    movl $0, count

    # Se non è stato trovata nessuna corrispondenza finisco il programma
    cmpl $0, flag
    je fine_programma

    xorl %edx, %edx
    xorl %ebx, %ebx

    catch_dati:
        cmpb $44, %al   # Check Virgola
        je incCount       # se trova la virgola salta per incrementare il count
        cmpb $10, %al   # Check '\n'
        je read_aCapo

        # Il count ci dira a quale virgola siamo e di conseguenza cosa leggere
        cmpb $0, count
        je input_tempo_str

        cmpb $1, count
        je input_id

        cmpb $2, count
        je input_velocità

        cmpb $3, count
        je input_rpm

        cmpb $4, count
        je input_temperatura

        input_tempo_str:
            leal tempo_str, %ebx     # prendo l'indirizzo della stringa del tempo
            movb %al, (%ebx, %edx)
            incl %edx
            incl tempo_len   # incremento conta caratteri
            jmp fine_letChar  # salto alla fine per rileggere il prossimo carattere


        input_id:
            
            pushl %ecx      
            xorl %ecx, %ecx     # resetto ecx 
            subb $48, %al   # converto il carattere in int
            movb %al, %cl

            
            movl id_long, %eax     # moltiplico id_long * 10   EAX*10
            movl $10, %ebx
            mull %ebx               

            # aggiungo il nuovo intero e carico in id_long
            addl %ecx, %eax
            movl %eax, id_long

            popl %ecx   

            jmp fine_letChar


        input_velocità:

            call Confronto_id
            cmpl $1, flagid
            jne fine_letChar

            pushl %ecx      
            xorl %ecx, %ecx # resetto ecx
            subb $48, %al   # converto il carattere in int
            movb %al, %cl

           
            movl vel_long, %eax   # moltiplico vel_long * 10     EAX*10
            movl $10, %ebx
            mull %ebx

            # aggiungo il nuovo intero e carico in vel_long
            addl %ecx, %eax
            movl %eax, vel_long

            popl %ecx  

            jmp fine_letChar


        input_rpm:
            pushl %ecx      
            xorl %ecx, %ecx # resetto ecx
            subb $48, %al   # converto il carattere in int
            movb %al, %cl

           
            movl rpm_long, %eax # moltiplico rpm_long * 10     EAX*10
            movl $10, %ebx
            mull %ebx

            # aggiungo il nuovo intero e carico in rpm_long
            addl %ecx, %eax
            movl %eax, rpm_long

            popl %ecx   

            jmp fine_letChar


        input_temperatura:
            pushl %ecx      
            xorl %ecx, %ecx # resetto ecx
            subb $48, %al   # converto il carattere in int
            movb %al, %cl

         
            movl temperatura_long, %eax  # moltiplico temperatura_long * 10     EAX*10
            movl $10, %ebx
            mull %ebx

            # aggiungo il nuovo intero e carico in temperatura_long
            addl %ecx, %eax
            movl %eax, temperatura_long

            popl %ecx   

            jmp fine_letChar


        incCount:  
            incl count          # incremento count
            xorl %edx, %edx
            xorl %ebx, %ebx
            jmp fine_letChar

        read_aCapo:
            
            call stampa         # se sono arrivato qui, stampo la rga

            # resetto i valori a fine stampa per la riga successiva
             movl $0, tempo_len
             movl $0, rpm_long
             movl $0, temperatura_long
             movl $0, vel_long
             movl $0, id_long
             movl $0, count      
             xorl %edx, %edx      
             xorl %ebx, %ebx

    fine_letChar:         # vado avanti col carattere
        incl %ecx

jmp loop_lettura   # salto all'inizio del ciclo

fine_loop_lettura:   

    # ################### #
    #  STAMPO ULTIMA RIGA #
    # ################### #

    # SCRIVO RPM MAX
    movl rpmMax, %ecx   # passo in ecx il numero da convertire
    call itoa

    leal IntToStr, %ecx   # carico in ecx l'indirizzo della stringa
    movl IntToStr_len, %edx # lunghezza stringa
    call WtoFile  

    # SCRIVO LA VIRGOLA
    leal virgola, %ecx   # carico in ecx l'indirizzo della stringa 
    movl $1, %edx # lunghezza stringa
    call WtoFile  

    # SCRIVO TEMPERATURA MAX
    movl temperaturaMax, %ecx   # passo in ecx il numero da convertire
    movl $0, IntToStr_len
    call itoa

    leal IntToStr, %ecx   # carico in ecx l'indirizzo della stringa 
    movl IntToStr_len, %edx # lunghezza stringa
    call WtoFile  

    # SCRIVO VIRGOLA
    leal virgola, %ecx   # carico in ecx l'indirizzo della stringa 
    movl $1, %edx # lunghezza stringa
    call WtoFile  

    # SCRIVO VEL MAX
    movl velMax, %ecx   # passo in ecx il numero da convertire
    movl $0, IntToStr_len
    call itoa

    leal IntToStr, %ecx   # carico in ecx l'indirizzo della stringa
    movl IntToStr_len, %edx # lunghezza stringa
    call WtoFile  

    # SCRIVO LA VIRGOLA
    leal virgola, %ecx   # carico in ecx l'indirizzo della stringa
    movl $1, %edx # lunghezza stringa
    call WtoFile  

    # SCRIVO VEL MEDIA
    xorl %edx, %edx         # resetto edx per poi inserire la lunghezza della stringa
    xorl %ebx, %ebx
    movl freq_pilota, %ebx
    movl velMedia, %eax
    divl %ebx      # calcolo la velocità media      DIVIDO VELOCITA PER LA FREQ DEL PILOTA
    movl %eax, velMedia
    movl $0, IntToStr_len
    movl velMedia, %ecx   # passo in ecx il numero da convertire
    call itoa

    leal IntToStr, %ecx   # carico in ecx l'indirizzo della stringa
    movl IntToStr_len, %edx # lunghezza stringa
    call WtoFile  

    # SCRIVO \N
    leal invio, %ecx   # carico in ecx l'indirizzo della stringa 
    movl $1, %edx # lunghezza stringa
    call WtoFile  # scrivo l'output sul file

fine_programma:
    # RESET
    popl %edx
    popl %ecx
    popl %ebx
    popl %eax
ret


# TROVARE L'ID del Pilota
.type trova_pilota, @function
trova_pilota:
    movb (%esi, %ecx), %al   # scorro la stringa come sopra
    cmpb $10, %al    # Check \n
    je fine_lettura

    # Vedo se il pilota è quello giusto (usando il count)
    cmpl $0, count
    jne pilot1
    leal pilot_0_str, %edx      # confronto con il pilota 0
    cmpb %al, (%edx,%ecx)
    jne errore_pilota      # se non ho una correlazione salto al errore pilota

    # se ho correlazione vado avanti con la stringa
    incl %ecx
    jmp trova_pilota  

    pilot1:
    # Vedo se il pilota è quello giusto (usando il count)
    cmpl $1, count
    jne pilot2
    leal pilot_1_str, %edx      # confronto con il pilota 1
    cmpb %al, (%edx,%ecx)
    jne errore_pilota     # se non ho una correlazione salto al errore pilota

    # se ho correlazione vado avanti con la stringa
    incl %ecx
    jmp trova_pilota  

    pilot2:
    
    cmpl $2, count
    jne pilot3
    leal pilot_2_str, %edx      
    cmpb %al, (%edx,%ecx)
    jne errore_pilota    

   
    incl %ecx
    jmp trova_pilota  

    pilot3:
    
    cmpl $3, count
    jne pilot4
    leal pilot_3_str, %edx      
    cmpb %al, (%edx,%ecx)
    jne errore_pilota      

    
    incl %ecx
    jmp trova_pilota  

    pilot4:
    # cerco il pilota
    cmpl $4, count
    jne pilot5
    leal pilot_4_str, %edx     
    cmpb %al, (%edx,%ecx)
    jne errore_pilota      

    
    incl %ecx
    jmp trova_pilota  

    pilot5:
    
    cmpl $5, count
    jne pilot6
    leal pilot_5_str, %edx      
    cmpb %al, (%edx,%ecx)
    jne errore_pilota      

    
    incl %ecx
    jmp trova_pilota  

    pilot6:
   
    cmpl $6, count
    jne pilot7
    leal pilot_6_str, %edx    
    cmpb %al, (%edx,%ecx)
    jne errore_pilota     

   
    incl %ecx
    jmp trova_pilota  

    pilot7:
   
    cmpl $7, count
    jne pilot8
    leal pilot_7_str, %edx      
    cmpb %al, (%edx,%ecx)
    jne errore_pilota      

    
    incl %ecx
    jmp trova_pilota  

    pilot8:
    
    cmpl $8, count
    jne pilot9
    leal pilot_8_str, %edx      
    cmpb %al, (%edx,%ecx)
    jne errore_pilota      

   
    incl %ecx
    jmp trova_pilota  

    pilot9:
    
    cmpl $9, count
    jne pilot10
    leal pilot_9_str, %edx      
    cmpb %al, (%edx,%ecx)
    jne errore_pilota     

    
    incl %ecx
    jmp trova_pilota  

    pilot10:
    
    cmpl $10, count
    jne pilot11
    leal pilot_10_str, %edx      
    cmpb %al, (%edx,%ecx)
    jne errore_pilota     

    
    incl %ecx
    jmp trova_pilota  


    pilot11:
    
    cmpl $11, count
    jne pilot12
    leal pilot_11_str, %edx     
    cmpb %al, (%edx,%ecx)
    jne errore_pilota      
    
    incl %ecx
    jmp trova_pilota  

    pilot12:
    
    cmpl $12, count
    jne pilot13
    leal pilot_12_str, %edx      
    cmpb %al, (%edx,%ecx)
    jne errore_pilota     

    
    incl %ecx
    jmp trova_pilota  

    pilot13:
    
    cmpl $13, count
    jne pilot14
    leal pilot_13_str, %edx      
    cmpb %al, (%edx,%ecx)
    jne errore_pilota      

    
    incl %ecx
    jmp trova_pilota  

    pilot14:
    
    cmpl $14, count
    jne pilot15
    leal pilot_14_str, %edx      
    cmpb %al, (%edx,%ecx)
    jne errore_pilota      

    
    incl %ecx
    jmp trova_pilota 

    pilot15:
    
    cmpl $15, count
    jne pilot16
    leal pilot_15_str, %edx      
    cmpb %al, (%edx,%ecx)
    jne errore_pilota      

    
    incl %ecx
    jmp trova_pilota  

    pilot16:
    
    cmpl $16, count
    jne pilot17
    leal pilot_16_str, %edx      
    cmpb %al, (%edx,%ecx)
    jne errore_pilota     

    
    incl %ecx
    jmp trova_pilota  

    pilot17:
    
    cmpl $17, count
    jne pilot18
    leal pilot_17_str, %edx      
    cmpb %al, (%edx,%ecx)
    jne errore_pilota      

    
    incl %ecx
    jmp trova_pilota  

    pilot18:
    
    cmpl $18, count
    jne pilot19
    leal pilot_18_str, %edx      
    cmpb %al, (%edx,%ecx)
    jne errore_pilota      

   
    incl %ecx
    jmp trova_pilota  

    pilot19:
   
    cmpl $19, count
    jne invalid_pilot
    leal pilot_19_str, %edx      
    cmpb %al, (%edx,%ecx)
    jne invalid_pilot     

    
    incl %ecx
    jmp trova_pilota  


    invalid_pilot:

    # SCRIVO INVALID SUL FILE
    
    leal invalid_pilot_str, %ecx   # carico in ecx l'indirizzo della stringa 
    movl $8, %edx # lunghezza stringa
    
    call WtoFile  # scrivo l'output sul file

    movl $0, flag   # flag per terminare il programma
    jmp end_leggiNome


    # PILOTA NON CORRETTO
    errore_pilota:     
    addl $1,count   # SALTO IL PILOTA CORRENTE
    movl $0, %ecx   # Riparto dall'inizio
    
    jmp trova_pilota  

fine_lettura:
    movl count, %eax
    movl %eax, id       # sposto l'id (count) in eax e lo metto nell'etichetta corrispondente

    # prendo il prossimo carattere per il return
    xorl %eax, %eax
    incl %ecx
    movb (%esi, %ecx), %al  # prendo il carattere che mi servirà una volta fatta la ret

end_leggiNome:
ret


# FUNZIONE CHE CONFRONTA GLI ID E SE SERVE SETTA LE VARIABILI
.type Confronto_id, @function
Confronto_id:

    # SALVO I REGISTRI GENERAL PURPOSE
    pushl %eax
    pushl %ebx
    pushl %ecx
    pushl %edx

    xorl %ecx, %ecx     # resetto %ecx

    movl id_long, %ecx
    cmpl %ecx, id   # confronto l'id convertito con quello del pilota che mi serve
    jne id_non_uguale

    # se gli id corrispondono
    movl $1, flagid    # ho preso l'id giusto vado avanti con la lettura
    jmp return_vero
    
    id_non_uguale:
    movl $0, flagid     # se l'id è sbagliato setto la flag a 0 (falso)

    popl %edx
    popl %ecx
    popl %ebx
    popl %eax

    ciclo_riga_sbagliata:
        movb (%esi,%ecx),%al

        cmpb $10, %al   # leggo \n finisco lo spostamento
        je resetto
        cmpb $0, %al   # letto \0 fine stringa
        je fine_stringa

        incl %ecx

        jmp ciclo_riga_sbagliata


    fine_stringa:
        decl %ecx   # decremento perchè all'uscita della funzione ci sarà un incremento di ecx per controllare il fine stringa
        jmp return
        
    resetto:

    # Se è sbagliato resetto il tempo e id che ho preso nei registri
        movl $0, tempo_len
        movl $0, id_long    
        xorl %edx, %edx
        xorl %ebx, %ebx
        movl $0, count      # ripristino il count
        jmp return


return_vero:

    # ritorno i registri
    popl %edx
    popl %ecx
    popl %ebx
    popl %eax

return: 
ret


.type stampa, @function
stampa:

    # SALVO i REGISTRI 
    pushl %eax
    pushl %ebx
    pushl %ecx
    pushl %edx

    incl freq_pilota  # Tiene conto per trovare la velocità media

    # tempo
    tempo:
        # SCRIVO TEMPO
        
        leal tempo_str, %ecx   # carico in ecx l'indirizzo della stringa 
        movl tempo_len, %edx     # lunghezza stringa
        call WtoFile  # scrivo l'output sul file

    
    rpm:
        # SCRIVO LA VIRGOLA
        leal virgola, %ecx   # carico in ecx l'indirizzo della stringa 
        movl $1, %edx # lunghezza stringa
        call WtoFile  

    # TROVO IL MASSIMO DI RPM
        movl rpm_long, %ecx
        cmpl rpmMax, %ecx   
        jng low_rpm
        movl %ecx, rpmMax

        low_rpm:
            cmpl $5000, %ecx
            jg medium_rpm

            # SCRIVO LOW
            leal LOW, %ecx   # carico in ecx l'indirizzo della stringa
            movl $3, %edx # lunghezza stringa
            call WtoFile  

            jmp temperatura

            medium_rpm:
                cmpl $10000, %ecx
                jg high_rpm

                # SCRIVO  MEDIUM
                leal MEDIUM, %ecx   # carico in ecx l'indirizzo della stringa 
                movl $6, %edx # lunghezza stringa
                call WtoFile  

                jmp temperatura

                high_rpm:

                    # SCRIVO HIGH
                    leal HIGH, %ecx   # carico in ecx l'indirizzo della stringa
                    movl $4, %edx # lunghezza stringa
                    call WtoFile  

    temperatura:
        # SCRIVO LA VIRGOLA
        leal virgola, %ecx   # carico in ecx l'indirizzo della stringa che voglio stampare
        movl $1, %edx # lunghezza messaggio
        call WtoFile 

    # TROVO LA MASSIMA TEMPERATURA
        movl temperatura_long, %ecx
        cmpl temperaturaMax, %ecx   
        jng low_temperatura
        movl %ecx, temperaturaMax

        low_temperatura:
            cmpl $90, %ecx
            jg medium_temperatura

            # SCRIVO LOW
            leal LOW, %ecx   # carico in ecx l'indirizzo della stringa
            movl $3, %edx # lunghezza stringa
            call WtoFile  

            jmp velocità_Max

            medium_temperatura:
                cmpl $110, %ecx
                jg high_temperatura

                # SCRIVO MEDIUM
                leal MEDIUM, %ecx   # carico in ecx l'indirizzo della stringa
                movl $6, %edx # lunghezza stringa
                call WtoFile 

                jmp velocità_Max

                high_temperatura:

                # SCRIVO HIGH
                leal HIGH, %ecx   # carico in ecx l'indirizzo della stringa
                movl $4, %edx # lunghezza stringa
                call WtoFile    

    velocità_Max:
        # SCRIVO LA VIRGOLA
        leal virgola, %ecx   # carico in ecx l'indirizzo della stringa 
        movl $1, %edx # lunghezza stringa
        call WtoFile  
    
    # TROVO LA MASSIMA Velocità
    
        movl vel_long, %ecx
        addl %ecx, velMedia    # SOMMO LE Velocità per la media
        cmpl velMax, %ecx  
        jng low_Velocità
        movl %ecx, velMax

        low_Velocità:
            cmpl $100, %ecx
            jg medium_Velocità
            # SCRIVO LOW
            
            leal LOW, %ecx   # carico in ecx l'indirizzo della stringa 
            movl $3, %edx # lunghezza stringa
            call WtoFile 

            jmp fine_stampa

            medium_Velocità:
                cmpl $250, %ecx
                jg high_Velocità
                # SCRIVO MEDIUM
                
                leal MEDIUM, %ecx   # carico in ecx l'indirizzo della stringa
                movl $6, %edx # lunghezza stringa
                call WtoFile 

                jmp fine_stampa

                high_Velocità:
                # SCRIVO HIGH
               
                leal HIGH, %ecx   # carico in ecx l'indirizzo della stringa
                movl $4, %edx # lunghezza stringa
                call WtoFile  
    
    fine_stampa:  

    # STAMPA \N
    
    leal invio, %ecx   # carico in ecx l'indirizzo della stringa
    movl $1, %edx # lunghezza stringa
    call WtoFile  

    # Riporto i registri a prima della funzione
    popl %edx
    popl %ecx
    popl %ebx
    popl %eax
ret


# SCRIVE IN EDI QUELLO CHE c'è scritto in ecx per edx volte
.type WtoFile, @function
WtoFile:

# AZZERO I REGISTRI
xorl %eax, %eax
xorl %ebx, %ebx

loop_CtoOutput:
    cmpl $0, %edx   # controllo se ho già preso tutti i caratteri
    je end_WtoFile

    # SALVO EDX, mi serve un ulteriore registro
    pushl %edx
    xorl %edx, %edx  # resetto edx

    movl count_char, %edx
    movb (%ecx, %eax), %bl
    movb %bl, (%edi, %edx)   # sposto il carattere in %edi

    # RIPRISTINO EDX
    popl %edx   
    
    incl %eax   # incremento per spostarmi nella stringa
    incl count_char     # incremento il contatore dei caratteri di %edx
    decl %edx   # decremento la lunghezza della stringa
    jmp loop_CtoOutput  # riparto da capo

end_WtoFile:
ret


# INTEGER TO ASCII FUNCTION
.type itoa, @function
itoa:

# faccio la divisione per 10 e prendo il resto, finche non arrivo a 0
# metto tutti i resti in ecx, aggiungendo 48 per farli diventare il loro corrispettivo carattere ascii

leal IntToStr, %esi
movl %ecx, %eax

# conta il numero di caratteri da inserire nella stringa
loopContatore:
    cmpl $0, %eax    # se il risultato della divisione dei 2 numeri è 0
    jz risZero

    xorl %edx, %edx     # resetto il registro che conterrà il resto
    movl $10, %ebx  # imposto il divisore a 10
    divl %ebx   # faccio la divisione per 10, il risualtato sarà in eax
    incl IntToStr_len
    cmpl $0, %eax    # guardo se sono arrivato all'ultimo carattere
    jz end_contatore
    jmp loopContatore

risZero:
    movl $0, %ecx
    movl $1, IntToStr_len

end_contatore:
    movl %ecx, %eax
    pushl IntToStr_len

# prende i numeri in ecx e li converte in caratteri e li inserisce nella stringa risultato
loopConversione_itoa:

    # memorizzo temporaneamente in %eax il valore di risultato_len
    movl IntToStr_len, %ecx
    cmpl $0, %ecx   # controllo se ho ancora caratteri da stampare

    jz end_conversione_itoa

    xorl %edx, %edx     # resetto il registro in modo tale che non interferisca con la divisione

    movl $10, %ebx  # imposto il divisore a 10
    divl %ebx   # [%edx:%eax]/%ebx = %eax	%edx = resto
    addl $48, %edx  # converto il carattere da intero ad ascii

    # memorizzo temporaneamente in %eax il valore di risultato_len
    movl IntToStr_len, %ecx
    decl %ecx   # IMPORTANTE!! decremento la posizione in cui inserire il carattere, perché il contreggio inizia da 0
    
    # USO MOVB PERCHÉ ALTRIMENTI SI PRENDE COSE STRANE
    movb %dl, (%esi,%ecx)   # sposto il carattere estratto nella sua posizione della stringa risultato

    decl IntToStr_len  # decremento il numero di caratteri che devo prendere
    
    jmp loopConversione_itoa

end_conversione_itoa:
    popl IntToStr_len  # ripristino il numero di caratteri che dovrò stampare
ret




