static IDL_VPTR IDL_mg_gsl_randomu(int argc, IDL_VPTR *argv, char *argk) {
  unsigned long int seed = IDL_ULong64Scalar(argv[0]);;
  IDL_LONG i, n1 = IDL_LongScalar(argv[1]);
  gsl_rng_type *type = gsl_rng_mt19937;
  gsl_rng *r;
  double *result = (double *) malloc(n1 * sizeof(double));
  IDL_MEMINT dim[1] = { n1 };

  gsl_rng_env_setup();
  r = gsl_rng_alloc(type);
  gsl_rng_set(r, seed);

  for (i = 0; i < n1; i++) {
    result[i] = gsl_rng_uniform(r);
  }

  gsl_rng_free(r);

  return IDL_ImportArray(1, dim, 5, (UCHAR *) result, 0, 0);
}