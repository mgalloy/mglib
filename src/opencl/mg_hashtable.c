#include "mg_hashtable.h"


static unsigned long mg_hashstr(const char *key) {
  unsigned long hash = 5381;
  int c;

  while((c = *key++))
    hash = ((hash << 5) + hash) + c;

  return hash;
}


MG_Table mg_table_new(int size_hint) {
  MG_Table table;
  int i;
  static int primes[] = { 509, 509, 1021, 2053, 4093,
                          8191, 16381, 32771, 65521, INT_MAX };

  for (i = 1; primes[i] < size_hint; i++)
    ;

  table = (MG_Table) malloc(sizeof(*table) + primes[i - 1] * sizeof(table->buckets[0]));
  table->size = primes[i - 1];
  table->cmp = strcmp;
  table->hash = mg_hashstr;
  table->buckets = (struct binding **)(table + 1);
  for (i = 0; i < table->size; i++) table->buckets[i] = 0;
  table->length = 0;
  table->timestamp = 0;

  return table;
}


void *mg_table_get(MG_Table table, const char *key) {
  int i;
  struct binding *p;

  i = (*table->hash)(key) % table->size;
  for (p = table->buckets[i]; p; p = p->link)
    if ((*table->cmp)(key, p->key) == 0)
      break;

  return p ? p->value : 0;
}


void *mg_table_put(MG_Table table, const char *key, void *value) {
  int i;
  struct binding *p;
  void *prev;

  i = (*table->hash)(key) % table->size;
  for (p = table->buckets[i]; p; p = p->link)
    if ((*table->cmp)(key, p->key) == 0)
      break;

  if (p == 0) {
    p = (struct binding *) malloc(sizeof(*p));
    p->key = key;
    p->link = table->buckets[i];
    table->buckets[i] = p;
    table->length++;
    prev = 0;
  } else prev = p->value;

  p->value = value;
  table->timestamp++;
  return prev;
}


int mg_table_length(MG_Table table) {
  return table->length;
}


void mg_table_free(MG_Table *table, void free_value(void *value)) {
  if ((*table)->length > 0) {
    int i;
    struct binding *p, *q;
    for (i = 0; i < (*table)->size; i++)
      for (p = (*table)->buckets[i]; p; p = q) {
        q = p->link;
        free_value(p->value);
        free(p);
      }
  }

  free(*table);
}
