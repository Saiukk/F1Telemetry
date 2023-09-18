#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>
#include <stdint.h>
#include <sys/time.h>
#include <sys/stat.h>

/* Nome funzione Assembly dichiarata con extern */
extern int telemetry(char* input,char* output); 
/* ************************************* */

size_t get_size(char* filename);

char* retrieve_input(char* filename,char* input,size_t size);                  // funzione di supporto che prende in input il nome del file
                                                                               // e modifica la stringa input da passare come parametro alla funzione assembly
void  write_output(char* filename,char* output);                               // Scrive il risultato su un file di output





int main(int argc, char *argv[]) {

char* inputFilename     = argv[1];      // recupero la stringa del nome del file di input
char* outputFilename    = argv[2];      // recupero la stringa del nome del file di output
char* inputString;                      // stringa che conterrà il contenuto del file di input
char* outputString;                     // stringa che conterrà il contenuto del file di output
size_t size;                            // variabile che conterrà la dimensione del file di input
    
    //***********************************************************
    // Alloco lo spazio delle stringhe in base al file di input
    //***********************************************************    
    size=get_size(argv[1]);                 // recupero la dimensione del file di input
    inputString=malloc(sizeof(char)*size);  // alloco lo spazio per la stringa che conterrà il contenuto del file di input
    outputString=malloc(sizeof(char)*size); // alloco lo spazio per la stringa di output della funzione assembly


    //**********************************
    // Recupera input dal file
    //**********************************
    
    retrieve_input(inputFilename,inputString,size);
    
    //**********************************
    // Chiamata funzione assembly
    //**********************************
    telemetry(inputString,outputString);
    
    //printf("%s",outputString);



    //**********************************
    // Scrivi output della funzione sul file di output
    //**********************************

    write_output(outputFilename,outputString);

    // elimino dalla memoria lo spazio allocato dalle stringhe
    free(inputString);
    free(outputString);
    return 0;
}


size_t get_size(char* filename){

size_t size;
struct stat st; 

    stat(filename, &st);                                        // funzione per recuperare info del file e salvarle in struttura st
    size = st.st_size+1;                                        // aggiungo un carattere per  aggiungere il  tappo \0 a fine stringa

return size;
}


void write_output(char* filename, char* output){

FILE *outputFile = fopen (filename, "w");               // apre il file da scrivere. Se non esiste lo crea. Se esiste lo resetta

    fprintf (outputFile, "%s", output);                 // scrive sul file
    fclose (outputFile);                                // chiude il file

}

char* retrieve_input(char* filename,char* input,size_t size){

    FILE *inputFile = fopen(filename, "r");                                         
    int i=0;
    char c;
        
        if (inputFile == 0)
        {
            fprintf(stderr, "failed to open the input file. Syntax ./test <input_file> <output_file>\n");
            exit(1);
        } 
    

    while ( EOF != (c = fgetc( inputFile )) && i < size ){     // copio dal file alla stringa, parametro della funzione assembly
        input[ i ] = c;
        i++;
    }
    
    input[strlen(input)]='\0';                          // tappo!
    
    fclose(inputFile);
return input;

}