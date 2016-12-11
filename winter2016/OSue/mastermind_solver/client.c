/**
 * @brief This file contains the implementation of assignment 1b, OSUE WS 2016
 * @details A automated client-side implementation of a mastermind solver/
 * @author Thomas Jirout, student number 1526606
 * @date Nov 4, 2016
 */

#include <stdio.h>
#include <stdlib.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <memory.h>
#include <unistd.h>
#include <stdbool.h>
#include <signal.h>

#define SLOTS (5)
#define BITS_PER_SLOT (3)
#define NUM_COLORS (8)
#define NUM_PEGS (5)

/**
 * The name of the current program
 */
static char * program = "client";

/**
 * Display usage information to the user
 */
void usage() {
    fprintf(stderr, "Usage: %s <server-hostname> <server-port>\n", program);
    exit(EXIT_FAILURE);
}

/**
 * Contains the socket for the server connection,
 */
static int sock = -1;

/**
 * Counts the played rounds in the current game
 */
static int playedRounds = 0;

/**
 * @brief Prints an error to stderr, includes program name as prefix
 * @details Uses global variable program
 * @param err The error message to be printed
 */
void printError(char err[]) {
    (void) fprintf(stderr, "%s: %s", program, err);
}

/**
 * Handles signals, in this case closes sock and exits program
 * @param sig Signal identifier
 */
static void signal_handler(int sig) {
    printError("Aborting...");

    if (sock >= 0) {
        (void) close(sock);
    }

    exit(EXIT_SUCCESS);
}

struct ServerResponse {
    bool gameLost;
    bool parityError;
    int whitePins; // Correct color
    int redPins; // Correct color at correct position
};

/**
 * Can be called to end the program with the correct error code, according to the response parameter
 * @param response The ServerResponse containing an error
 */
void handleServerResponseError(struct ServerResponse response) {
    int code = 1;

    if (response.parityError) {
        printError("Parity error");
        code += 1;
    }

    if (response.gameLost) {
        printError("Game lost");
        code += 2;
    }

    exit(code);
}

/**
 * Tries to convert a given hostname to an addr
 * @param hostname The given hostname
 * @param addr Contains the converted address after running this method
 * @return 0 on success, -1 on error
 */
int lookupHostname(char const * hostname, struct sockaddr_in* addr);

/**
 * Calulates the parity bit, by applying xor bit by bit
 * @param bits
 * @return parity bit
 */
uint16_t calculateParity(int bits);

/**
 * Submits a given guess to the server
 * @param sock The current socket
 * @param guess The current guess, from left to right
 */
void submitGuess(int sock, short guess[]);

/**
 * Retrieves and parses message from the server
 * @param sock The current socket
 * @return struct ServerResponse
 */
struct ServerResponse receiveFromServer(int sock);

/**
 * Detects which and how many colors are in the correct solution by polling the server.
 * Then stores the result in colorOccurrences
 *
 * @param sock The current socket
 * @param colorOccurrences An array of the length of the available colors. Contains number of occurrences per color after running this method.
 */
void detectColorOccurrences(int sock, int colorOccurrences[]);

/**
 * Detects the positions of the colors in the solution.
 * @param sock The current socket
 * @param colorOccurrences Contains number of occurrences per color in the solution
 * @param fixedPositions After running this method, this array contains the finalized values for the very position in the result
 */
void detectColorPositions(int sock, int colorOccurrences[], short fixedPositions[]);

/**
 * @brief Ends the game by closing socket and printing out the number of played rounds
 * @details uses public var playedRounds
 */
void endGame();

/**
 * @brief Contains the main workflow of the program
 * @details Setup error handling, create socket, connect to server, try to win by submitting guesses.
 * @param argc The number of arguments passed to the program
 * @param argv The arguments passed to the program
 * @return int status/exit code
 */
int main (int argc, char * argv[]) {
    struct sigaction s;

    s.sa_handler = signal_handler;
    s.sa_flags = 0;

    sigfillset(&s.sa_mask);
    sigaction(SIGINT, &s, NULL);
    sigaction(SIGTERM, &s, NULL);

    // Parse arguments
    if (argc != 3) {
        printError("Invalid number of arguments provided\n");
        usage();
    }

    char const * hostname = argv[1];
    long port = strtol(argv[2], NULL, 10);

    if (port <= 0 || port > 65536) {
        printError("Invalid port");
        return EXIT_FAILURE;
    }

    struct sockaddr_in addr;
    if (-1 == lookupHostname(hostname, &addr)) {
        printError("Could not look up hostname");
        return EXIT_FAILURE;
    }

    addr.sin_family = AF_INET;
    addr.sin_port = htons(port);

    // Establish socket connection
    sock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);

    if (sock == -1) {
        printError("Could not create socket");
        return EXIT_FAILURE;
    }

    if (-1 == connect(sock, (struct sockaddr *)&addr, sizeof addr)) {
        printError("Could not connect to server");
        (void) close(sock);
        return EXIT_FAILURE;
    }

//    printf("Successfully connected to server!\n");

    // Guess and win
    int colorOccurrences[NUM_COLORS];
    short fixedPositions[NUM_PEGS];

    for (int i = 0; i < NUM_PEGS; i++) {
        fixedPositions[i] = -1;
    }

    detectColorOccurrences(sock, colorOccurrences);
    detectColorPositions(sock, colorOccurrences, fixedPositions);

    submitGuess(sock, fixedPositions);
    (void) receiveFromServer(sock);

    return EXIT_SUCCESS;
}

void submitGuess(int sock, short guess[]) {
    uint16_t buffer[1];
    buffer[0] = 0;

    for (int i = 0; i < SLOTS; i++) {
        buffer[0] = buffer[0] | (guess[i] << i * BITS_PER_SLOT);
    }

    uint16_t parity = calculateParity(buffer[0]) << (SLOTS * BITS_PER_SLOT);
    buffer[0] = buffer[0] | parity;

    if (-1 == send(sock, &buffer[0], sizeof buffer, 0)) {
        printError("Could not submit guess to server");
        (void) close(sock);
        exit(EXIT_FAILURE);
    }
}

struct ServerResponse receiveFromServer(int sock) {
    uint8_t buffer[1];

    // No loop required here, as minimum bytes that can be received
    // is actual size that we want
    if (recv(sock, &buffer, 1, 0) != 1) {
        printError("Received illegal response (response size not 1 byte)");
        (void) close(sock);
        exit(EXIT_FAILURE);
    }

    struct ServerResponse response;
    response.gameLost = (buffer[0] >> 7) == 1;
    response.parityError = ((buffer[0] >> 6) & 1) == 1;

    // correct Colors
    response.whitePins = (buffer[0] >> 3) & 0x7;

    // correct colors and position
    response.redPins = buffer[0] & 0x7;

    playedRounds++;

    if (response.redPins == NUM_PEGS) {
        endGame();
    }

    return response;
}

void endGame() {
    if (sock >= 0)
        (void) close(sock);

    (void) printf("%d", playedRounds);
    exit(EXIT_SUCCESS);
}

void detectColorOccurrences(int sock, int colorOccurrences[]) {
    int foundOccurrences = 0;
    for (short i = 0; i < NUM_COLORS; i++) {
        if (foundOccurrences == NUM_PEGS) {
            break;
        }

        short guess[] = {i, i, i, i, i};
        submitGuess(sock, guess);

        struct ServerResponse parsed = receiveFromServer(sock);
        foundOccurrences += parsed.redPins;
        colorOccurrences[i] = parsed.redPins;
    }
}

void detectColorPositions(int sock, int colorOccurrences[], short fixedPositions[]) {
    // A color that's not present in the solution
    short dummyColor;
    for(short i = 0; i < NUM_COLORS; i++) {
        if (colorOccurrences[i] == 0) {
            dummyColor = i;
            break;
        }
    }

    int totalPegsLeft = NUM_PEGS;

    // Start detecting color positions, iterating over each color
    for(short color = 0; color < NUM_COLORS; color++) {
        int occurrences = colorOccurrences[color];
        int positionsRemainingToTry = totalPegsLeft;
        int foundOccurrences = 0;

        for (int searchIndex = 0; searchIndex < NUM_PEGS; searchIndex++) {
            if (foundOccurrences >= occurrences) {
                break;
            }

            // If there's no fixed color yet at current search index,
            // place current color at this index
            if (fixedPositions[searchIndex] == -1) {
                int occurrencesRemaining = occurrences - foundOccurrences;
                if (occurrencesRemaining == totalPegsLeft
                        || occurrencesRemaining == positionsRemainingToTry) {
                    // No guessing required, we know that in this case the number has to go in here
                    fixedPositions[searchIndex] = color;

                    totalPegsLeft--;
//                    printf("Filled color %d at position %d\n", color, searchIndex);
                } else {
                    // Build guess
                    short guess[] = {dummyColor, dummyColor, dummyColor, dummyColor, dummyColor};
                    guess[searchIndex] = color;

                    submitGuess(sock, guess);
                    struct ServerResponse result = receiveFromServer(sock);

                    if (result.parityError || result.gameLost) {
                        (void) close(sock);
                        handleServerResponseError(result);
                        return;
                    } else if (result.redPins == 1) {
                        // correct position for color found
                        fixedPositions[searchIndex] = color;
                        foundOccurrences++;
                        totalPegsLeft--;

//                        printf("Found color %d at position %d\n", color, searchIndex);
                    }

                    positionsRemainingToTry--;
                }
            }
        }
    }
}

uint16_t calculateParity(int bits) {
    int n = SLOTS * BITS_PER_SLOT;
    uint16_t parity = 0;

    for (int i = 0; i < n; i++) {
        parity ^= (bits >> i) & 0x1;
    }

    return parity;
}

int lookupHostname(char const * hostname, struct sockaddr_in* addr) {
    struct addrinfo hints;
    struct addrinfo * ai;

    (void) memset(&hints, 0, sizeof hints);
    hints.ai_family = AF_INET;

    if (-1 == getaddrinfo(hostname, NULL, &hints, &ai)) {
        return -1;
    }

    (void) memcpy(addr, (struct sockaddr_in *)ai->ai_addr, sizeof *addr);

    freeaddrinfo(ai);
    return 0;
}


