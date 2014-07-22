void gsl_rng_env_setup();
IDL_PTRINT gsl_rng_alloc(IDL_PTRINT t);
void gsl_rng_free(IDL_PTRINT r);

void gsl_rng_set(IDL_PTRINT r, unsigned long seed);

unsigned long gsl_rng_get(IDL_PTRINT r);
double gsl_rng_uniform(IDL_PTRINT r);
double gsl_rng_uniform_pos(IDL_PTRINT r);
unsigned long gsl_rng_uniform_int(IDL_PTRINT r, unsigned long n);
