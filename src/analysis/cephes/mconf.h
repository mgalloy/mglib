/*                                                     mconf.h
 *
 *     Common include file for math routines
 *
 *
 *
 * SYNOPSIS:
 *
 * #include "mconf.h"
 *
 *
 *
 * DESCRIPTION:
 *
 * This file contains definitions for error codes that are
 * passed to the common error handling routine mtherr()
 * (which see).
 *
 * The file also includes a conditional assembly definition
 * for the type of computer arithmetic (IEEE, Motorola
 * IEEE, or UNKnown).
 * 
 * For little-endian computers, such as IBM PC, that follow the
 * IEEE Standard for Binary Floating Point Arithmetic (ANSI/IEEE
 * Std 754-1985), the symbol IBMPC should be defined.  These
 * numbers have 53-bit significands.  In this mode, constants
 * are provided as arrays of hexadecimal 16 bit integers.
 *
 * Big-endian IEEE format is denoted MIEEE.  On some RISC
 * systems such as Sun SPARC, double precision constants
 * must be stored on 8-byte address boundaries.  Since integer
 * arrays may be aligned differently, the MIEEE configuration
 * may fail on such machines.
 *
 * To accommodate other types of computer arithmetic, all
 * constants are also provided in a normal decimal radix
 * which one can hope are correctly converted to a suitable
 * format by the available C language compiler.  To invoke
 * this mode, define the symbol UNK.
 *
 * An important difference among these modes is a predefined
 * set of machine arithmetic constants for each.  The numbers
 * MACHEP (the machine roundoff error), MAXNUM (largest number
 * represented), and several other parameters are preset by
 * the configuration symbol.  Check the file const.c to
 * ensure that these values are correct for your computer.
 *
 * Configurations NANS, INFINITIES, MINUSZERO, and DENORMAL
 * may fail on many systems.  Verify that they are supposed
 * to work on your computer.
 */

/*
 * Cephes Math Library Release 2.3:  June, 1995
 * Copyright 1984, 1987, 1989, 1995 by Stephen L. Moshier
 */

#ifndef CEPHES_MCONF_H
#define CEPHES_MCONF_H

#include "cephes_names.h"
#include "protos.h"
#include "polevl.h"

/* Constant definitions for math error conditions
 */

#define DOMAIN    1 /* argument domain error */
#define SING      2 /* argument singularity */
#define OVERFLOW  3 /* overflow range error */
#define UNDERFLOW 4 /* underflow range error */
#define TLOSS     5 /* total loss of precision */
#define PLOSS     6 /* partial loss of precision */
#define TOOMANY   7 /* too many iterations */
#define MAXITER   500

#define EDOM      33
#define ERANGE    34

/* Long double complex numeral.  */
/*
 * typedef struct
 * {
 * long double r;
 * long double i;
 * } cmplxl;
 */

/* Type of computer arithmetic */

/* UNKnown arithmetic, invokes coefficients given in
 * normal decimal format.  Beware of range boundary
 * problems (MACHEP, MAXLOG, etc. in const.c) and
 * roundoff problems in pow.c:
 * (Sun SPARCstation)
 */

/* Note: by defining UNK, we prevent the compiler from casting integers to
 * floating point numbers. If the endianness is detected incorrectly, this
 * causes problems on some platforms.
 */
#define UNK 1

/* Define to support tiny denormal numbers, else undefine. */
#define DENORMAL 1

#define gamma Gamma

#define CEPHES_E         2.718281828459045235360287471352662498  /* e */
#define CEPHES_LOG2E     1.442695040888963407359924681001892137  /* log_2 e */
#define CEPHES_LOG10E    0.434294481903251827651128918916605082  /* log_10 e */
#define CEPHES_LOGE2     0.693147180559945309417232121458176568  /* log_e 2 */
#define CEPHES_LOGE10    2.302585092994045684017991454684364208  /* log_e 10 */
#define CEPHES_PI        3.141592653589793238462643383279502884  /* pi */
#define CEPHES_PI_2      1.570796326794896619231321691639751442  /* pi/2 */
#define CEPHES_PI_4      0.785398163397448309615660845819875721  /* pi/4 */
#define CEPHES_1_PI      0.318309886183790671537767526745028724  /* 1/pi */
#define CEPHES_2_PI      0.636619772367581343075535053490057448  /* 2/pi */
#define CEPHES_EULER     0.577215664901532860606512090082402431  /* Euler constant */
#define CEPHES_SQRT2     1.414213562373095048801688724209698079  /* sqrt(2) */
#define CEPHES_SQRT1_2   0.707106781186547524400844362104849039  /* 1/sqrt(2) */

/*
 * Enable loop unrolling on GCC and use faster isnan et al.
 */
#if !defined(__clang__) && defined(__GNUC__) && defined(__GNUC_MINOR__)
#if __GNUC__ >= 5 || (__GNUC__ == 4 && __GNUC_MINOR__ >= 4)
#pragma GCC optimize("unroll-loops")
#define cephes_isnan(x) __builtin_isnan(x)
#define cephes_isinf(x) __builtin_isinf(x)
#define cephes_isfinite(x) __builtin_isfinite(x)
#endif
#endif
#ifndef cephes_isnan
#define cephes_isnan(x) isnan(x)
#define cephes_isinf(x) isinf(x)
#define cephes_isfinite(x) isfinite(x)
#endif

#define cephes_copysign copysign
#define cephes_asinh asinh

typedef double cephes_double;
typedef unsigned long cephes_uint32;

CEPHES_INLINE static float __cephes_inff(void) {
  const union { cephes_uint32 __i; float __f;} __bint = {0x7f800000UL};
  return __bint.__f;
}

CEPHES_INLINE static float __cephes_nanf(void) {
  const union { cephes_uint32 __i; float __f;} __bint = {0x7fc00000UL};
  return __bint.__f;
}

#define CEPHES_INFINITY ((cephes_double)__cephes_inff())
#define CEPHES_NAN ((cephes_double)__cephes_nanf())

#endif        /* CEPHES_MCONF_H */
