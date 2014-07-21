void gsl_rng_env_setup();
unsigned long gsl_rng_alloc(unsigned long T);
void gsl_rng_free (unsigned long r);

void gsl_rng_set(unsigned long r, unsigned long seed);

unsigned long gsl_rng_get(unsigned long r);
double gsl_rng_uniform(unsigned long r);
double gsl_rng_uniform_pos(unsigned long r);
unsigned long gsl_rng_uniform_int(unsigned long r, unsigned long n);
