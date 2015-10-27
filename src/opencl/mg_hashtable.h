#include <limits.h>
#include <stdlib.h>
#include <string.h>

// simple hash table implementation


// storage declarations

struct MG_Table {
  int size;
  int (*cmp)(const char *x, const char *y);
  unsigned long (*hash)(const char *key);
  int length;
  unsigned timestamp;
  struct binding {
    struct binding *link;
    const char *key;
    void *value;
  } **buckets;
};

typedef struct MG_Table *MG_Table;


// API

static unsigned long mg_hashstr(const char *key);
MG_Table mg_table_new(int size_hint);
void *mg_table_get(MG_Table table, const char *key);
void *mg_table_put(MG_Table table, const char *key, void *value);
int mg_table_length(MG_Table table);
void mg_table_free(MG_Table *table, void free_value(void *value));