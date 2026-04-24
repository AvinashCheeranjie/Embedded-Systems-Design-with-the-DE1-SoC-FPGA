#include "system.h"
#include <stdio.h>

#define BASE SDRAM_CONTROLLER_0_BASE
#define SDRAM_MAXNUM_WORDS SDRAM_CONTROLLER_0_SPAN/2
	 //the size of the SDRAM on DE1-SoC is 64MB =67108864 Byte (SDRAM_SPAN)

#define Testing_MAXNUM_WORDS   SDRAM_CONTROLLER_0_SPAN/2

//To test part of the memory, for example, to test the first 1/10 of the memory:
//#define Testing_MAXNUM_WORDS   SDRAM_CONTROLLER_0_SPAN/20


int main() {
	printf("Hello from MT3TB4 Group 14!\n\n\n");
	printf("Testing %d  words out of Maximum %d words On SDRAM......\n\n\n", Testing_MAXNUM_WORDS, SDRAM_MAXNUM_WORDS);

	int i;
	int char_err_num = 0, short_err_num = 0, int_err_num = 0;

	char * char_ptr;
	char aChar;
	short *short_ptr;
	short aShort;
	int *int_ptr;
	int aInt;

	int charsize, shortsize, intsize;
	charsize = sizeof(aChar);
	shortsize = sizeof(aShort);
	intsize = sizeof(aInt);

	printf("the sizeof char, short, int in bytes are: %d, %d, %d\n", charsize, shortsize, intsize);


	//----------------TEST CHAR-----------------------------------

	printf("\n writing chars.....\n");
	for (i = 1; i <= Testing_MAXNUM_WORDS * 2; i++) {
		*(char*) (BASE + i) = i % 128; // to be safe, use 128 rather than 256
	}

	printf("\n testing chars.....\n");
	for (i = 1; i <= Testing_MAXNUM_WORDS * 2; i++) {
		if (*(char*) (BASE + i) != i % 128) { // or .....(char)i,   if not i%128
			char_err_num++;
		}
	}
	printf("\nTesting  Char: the total numbers of error is : %i\n", char_err_num);


	//----------------TEST SHORT-----------------------------------

	printf(" \n writing short......\n");
	for (i = 1; i <= Testing_MAXNUM_WORDS; i++) {
		*(short*) (BASE + i * 2) = i % 32767; // short, uses two bytes
	}

	printf(" \n testing short......\n");

//
//
//

	printf("\nTesting Short: the total numbers of error is : %i\n",
			short_err_num);

	//----------------TEST INT    -----------------------------------

	printf(" \n writing integer......\n");
	for (i = 1; i <= Testing_MAXNUM_WORDS / 2; i++) {
		*(int*) (BASE + i * 4) = i; // int, use 4 bytes

	}


	printf(" \n testing integer......\n");

//
//
//

	printf("\nTesting int: the total numbers of error is : %i\n", int_err_num);


	printf("\nMemory test complete. # Char errors: %i. # Short errors: %i. # int errors: %i.", char_err_num, short_err_num, int_err_num);

	if(!char_err_num && !short_err_num && !int_err_num == 1){
		printf("\nMemory test passed.");
	}else{
		printf("\nMemory test failed.");
	}

	return 0;
}

