#include <stdlib.h>
#include <stdio.h>

#include "structure.h"

void init_structure(Structure *_structure) {
    char const message[] = "And everything";
    _structure->meaning_of_life = 42;
    _structure->message = (char const*) malloc(15 * sizeof(message));
    strcpy(_structure->message, message);
}

void dealloc_structure(Structure *_structure) {
    void * const pointer = (void*) _structure->message;
    _structure->message = (char const*)0;
    _structure->meaning_of_life = 0;
    free(pointer);
}
