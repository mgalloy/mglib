#ifndef __SCIPY_SPECIAL_CEPHES
#define __SCIPY_SPECIAL_CEPHES

/* Complex numeral.  */
typedef struct {
    double r;
    double i;
} cmplx;

extern double acosh(double x);
extern int    cephes_airy(double x, double *ai, double *aip, double *bi, double *bip);
extern double asin(double x);
extern double acos(double x);
extern double asinh(double x);
extern double atan(double x);
extern double atan2(double y, double x);
extern double atanh(double x);
extern double cephes_bdtrc(int k, int n, double p);
extern double cephes_bdtr(int k, int n, double p);
extern double cephes_bdtri(int k, int n, double y);
extern double cephes_beta(double a, double b);
extern double cephes_lbeta(double a, double b);
extern double cephes_btdtr(double a, double b, double x);
extern double cephes_cbrt(double x);
extern double chbevl(double x, double P[], int n);
extern double cephes_chdtrc(double df, double x);
extern double cephes_chdtr(double df, double x);
extern double cephes_chdtri(double df, double y);

/*
 * extern void clog ( cmplx *z, cmplx *w );
 * extern void cexp ( cmplx *z, cmplx *w );
 * extern void csin ( cmplx *z, cmplx *w );
 * extern void ccos ( cmplx *z, cmplx *w );
 * extern void ctan ( cmplx *z, cmplx *w );
 * extern void ccot ( cmplx *z, cmplx *w );
 * extern void casin ( cmplx *z, cmplx *w );
 * extern void cacos ( cmplx *z, cmplx *w );
 * extern void catan ( cmplx *z, cmplx *w );
 * extern void cadd ( cmplx *a, cmplx *b, cmplx *c );
 * extern void csub ( cmplx *a, cmplx *b, cmplx *c );
 * extern void cmul ( cmplx *a, cmplx *b, cmplx *c );
 * extern void cdiv ( cmplx *a, cmplx *b, cmplx *c );
 * extern void cmov ( void *a, void *b );
 * extern void cneg ( cmplx *a );
 */
/*extern double cabs ( cmplx *z ); */
/* extern void csqrt ( cmplx *z, cmplx *w ); */
extern double cosh(double x);
extern double cephes_dawsn(double xx);
extern void   eigens(double A[], double RR[], double E[], int N);
extern double cephes_ellie(double phi, double m);
extern double cephes_ellik(double phi, double m);
extern double cephes_ellpe(double x);
extern int    cephes_ellpj(double u, double m, double *sn, double *cn, double *dn, double *ph);
extern double cephes_ellpk(double x);
extern double exp(double x);
extern double exp10(double x);
extern double cephes_exp1m(double x);
extern double cephes_exp2(double x);
extern double cephes_expn(int n, double x);
extern double fac(int i);
extern double cephes_fdtrc(double a, double b, double x);
extern double cephes_fdtr(double a, double b, double x);
extern double cephes_fdtri(double a, double b, double y);

//extern int fftr ( double x[], int m0, double sine[] );

extern int    cephes_fresnl(double xxa, double *ssa, double *cca);
extern double cephes_Gamma(double x);
extern double cephes_lgam(double x);
extern double lgam_sgn(double x, int *sign);
extern double lgam1p(double x);
extern double cephes_gdtr(double a, double b, double x);
extern double cephes_gdtrc(double a, double b, double x);
extern int    gels(double A[], double R[], int M, double EPS, double AUX[]);
extern double cephes_hyp2f1(double a, double b, double c, double x);
extern double cephes_hyperg(double a, double b, double x);
extern double cephes_hyp2f0(double a, double b, double x, int type, double *err);
extern double cephes_i0(double x);
extern double cephes_i0e(double x);
extern double cephes_i1(double x);
extern double cephes_i1e(double x);
extern double cephes_igamc(double a, double x);
extern double cephes_igam(double a, double x);
extern double igam_fac(double a, double x);
extern double cephes_igami(double a, double y0);
extern double cephes_incbet(double aa, double bb, double xx);
extern double cephes_incbi(double aa, double bb, double yy0);
extern double cephes_iv(double v, double x);
extern double cephes_j0(double x);
extern double cephes_y0(double x);
extern double cephes_j1(double x);
extern double cephes_y1(double x);
extern double cephes_jn(int n, double x);
extern double cephes_jv(double n, double x);
extern double cephes_k0(double x);
extern double cephes_k0e(double x);
extern double cephes_k1(double x);
extern double cephes_k1e(double x);
extern double cephes_kn(int nn, double x);

//extern int levnsn ( int n, double r[], double a[], double e[], double refl[] );

extern double log(double x);
extern double log10(double x);

//extern double log2 ( double x );

extern long   lrand(void);
extern long   lsqrt(long x);
extern void   mtherr(const char *name, int code);
extern double cephes_nbdtrc(int k, int n, double p);
extern double cephes_nbdtr(int k, int n, double p);
extern double cephes_nbdtri(int k, int n, double p);
extern double cephes_ndtr(double a);
extern double cephes_erfc(double a);
extern double cephes_erf(double x);
extern double cephes_ndtri(double y0);
extern double cephes_pdtrc(int k, double m);
extern double cephes_pdtr(int k, double m);
extern double cephes_pdtri(int k, double y);
extern double cephes_psi(double x);
extern void   revers(double y[], double x[], int n);
extern double cephes_rgamma(double x);
extern double cephes_round(double x);
extern int    cephes_shichi(double x, double *si, double *ci);
extern int    cephes_sici(double x, double *si, double *ci);
extern double sin(double x);
extern double cos(double x);
extern double cephes_radian(double d, double m, double s);

//extern void sincos ( double x, double *s, double *c, int flg );

extern double cephes_sindg(double x);
extern double cephes_cosdg(double x);
extern double sinh(double x);
extern double cephes_spence(double x);
extern double sqrt(double x);
extern double cephes_stdtr(int k, double t);
extern double cephes_stdtri(int k, double p);
extern double cephes_onef2(double a, double b, double c, double x, double *err);
extern double cephes_threef0(double a, double b, double c, double x, double *err);
extern double cephes_struve(double v, double x);
extern double tan(double x);
extern double cot(double x);
extern double cephes_tandg(double x);
extern double cephes_cotdg(double x);
extern double tanh(double x);
extern double cephes_log1p(double x);
extern double log1pmx(double x);
extern double cephes_expm1(double x);
extern double cephes_cosm1(double x);
extern double cephes_yn(int n, double x);
extern double cephes_zeta(double x, double q);
extern double cephes_zetac(double x);
extern int    drand(double *a);

double        cephes_yv(double v, double x);

extern double lanczos_sum(double x);
extern double lanczos_sum_expg_scaled(double x);
extern double lanczos_sum_near_1(double dx);
extern double lanczos_sum_near_2(double dx);

#endif
