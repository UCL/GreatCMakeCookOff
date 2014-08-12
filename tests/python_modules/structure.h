#ifndef STRUCTURE_H
#define STRUCTURE_H

typedef struct {
    int meaning_of_life;
    char const* message;
} Structure;

void init_structure(Structure *_structure);
void dealloc_structure(Structure *_structure);
#endif
