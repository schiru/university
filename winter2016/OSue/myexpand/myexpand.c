/**
 * @brief This file contains the implementation of assignment 1a, OSUE WS 2016
 * @details An implementation that mimics the built in command myexpand
 * @author Thomas Jirout, student number 1526606
 * @date Okt 16, 2016
 */
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <getopt.h>
#include <stdbool.h>

/**
 * Number of spaces per tabstop, default 8
 */
static int tabstops = 8;

/**
 * The current filename
 */
static char* filename;

/**
 * The name of the current command
 */
static char* command = "";

/**
 * @brief Add spaces to stdout using putchar
 * @details Adds spaces until the next tabstop is reached
 * @param  currentIndex The start index
 * @param  tabSpaces    Number of spaces per tabstop
 * @return              The end index of the created tabstop
 */
static int putSpaces(int currentIndex, int tabSpaces) {
	int tabEndIndex = tabSpaces * ((currentIndex / tabSpaces) + 1);
	int spacesToPut = tabEndIndex - currentIndex;
	for (int i = 0; i < spacesToPut; i++) {
		putchar(' ');
	}

	return tabEndIndex;
}

/**
 * @brief Process input stream and convert tabs to spaces
 * @details Uses global tabstops
 * @param stream The current stream
 */
static void processStream(FILE* stream) {
	char buffer[255];

	while (fgets(buffer, sizeof(buffer), stream)) {
		char* pos = buffer;
		char currentChar;
		int index = 0;
		while (*pos != '\0') {
			currentChar = *pos;

			if (currentChar == '\t') {
				index = putSpaces(index, tabstops);
			}
			else {
				putchar(currentChar);
				index++;
			}

			pos++;
		}
	}
}

/**
 * Display usage information to the user
 */
void usage() {
	fprintf(stderr, "Usage: %s [-t tabstop] [file ...]\n", command);
	exit(EXIT_FAILURE);
}

/**
 * Parse arguments, open file stream and start processing of stream
 * @param  argc Number of arguments passed to the program
 * @param  argv The passed arguments to the program
 * @return      The error/exit code
 */
int main(int argc, char * argv[])
{
	if (argc > 0) { command = argv[0]; }
    int c = getopt(argc, argv, "t:");
	while(c != -1)
	{
		switch (c)
		{
			case 't':
				tabstops = strtol(optarg, NULL, 10);
				if (tabstops <= 0) {
					fprintf(stderr, "%s: Illegal tabstop spec\n", command);
					return EXIT_FAILURE;
				}
				break;
			case '?':
				usage();
				return EXIT_FAILURE;
			default:
				usage();
				break;
		}

		c = getopt(argc, argv, "t:");
	}

	if (argv[optind] != NULL) {
		FILE* stream;

		// Process all specified files
		while ((filename = argv[optind]) != NULL) {
			if (access(filename, R_OK) != -1) {
				stream = fopen(filename, "r");
				if (stream == NULL) {
					fprintf(stderr, "%s: %s File could not be opened\n", command, filename);
					return EXIT_FAILURE;
				}
			} else {
				fprintf(stderr, "%s: %s File does not exist or cannot be read\n", command, filename);
				return EXIT_FAILURE;
			}

			processStream(stream);

			fclose(stream);
			optind++;
		}
	} else {
		// No file supplied, fall back to stdin
		processStream(stdin);
	}

	return EXIT_SUCCESS;
}
