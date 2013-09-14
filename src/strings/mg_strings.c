/*
  String routines matching IDL's interface, but adding extra features and
  speed. Uses TRE (http://laurikari.net/tre/) for regular expressions.
*/

#include <stdlib.h>
#include <stdio.h>
#include <limits.h>

#include "idl_export.h"
#include "tre/tre.h"



// define the structure for a match
struct mg_regmatch {
  struct mg_regmatch *next;
  int cost;
  regoff_t rm_so;
  regoff_t rm_eo;
};
typedef struct mg_regmatch mg_regmatch_t;


static IDL_VPTR IDL_CDECL IDL_mg_strsplit(int argc, IDL_VPTR *argv) {
  return IDL_GettmpLong(5);
}

static mg_regmatch_t *mg_getamatches(regex_t *preg,
                                     char *input, int offset, int input_length,
                                     int cost_ins, int cost_del, int cost_subst,
                                     int max_cost, int max_del, int max_err,
                                     int max_ins, int max_subst,
                                     int find_all) {

  regamatch_t amatch;
  regaparams_t match_params;
  regmatch_t pmatch[1];

  mg_regmatch_t *current_match = NULL;
  mg_regmatch_t *match = NULL;
  mg_regmatch_t *before_match = NULL;
  mg_regmatch_t *after_match = NULL;

  int search_status;

  // initialize the match params and match
  tre_regaparams_default(&match_params);
  match_params.cost_ins = cost_ins;
  match_params.cost_del = cost_del;
  match_params.cost_subst = cost_subst;
  match_params.max_cost = max_cost;
  match_params.max_del = max_del;
  match_params.max_err = max_err;
  match_params.max_ins = max_ins;
  match_params.max_subst = max_subst;

  amatch.pmatch = pmatch;
  amatch.nmatch = 1;

  search_status = tre_reganexec(preg, input, input_length,
                                &amatch, match_params, 0);

  // return NULL pointer if nothing found
  if (search_status || (pmatch[0].rm_so == pmatch[0].rm_eo)) {
    return (mg_regmatch_t *)NULL;
  }

  match = (mg_regmatch_t *) malloc(sizeof(mg_regmatch_t));

  match->cost = amatch.cost;
  match->rm_so = offset + pmatch[0].rm_so;
  match->rm_eo = offset + pmatch[0].rm_eo;
  match->next = NULL;

  if (find_all) {
    // search before match
    if (pmatch[0].rm_so != 0) {
      before_match = mg_getamatches(preg,
                                    input, offset, pmatch[0].rm_so,
                                    cost_ins, cost_del, cost_subst,
                                    max_cost, max_del, max_err,
                                    max_ins, max_subst,
                                    find_all);
    }

    // search after match
    if (pmatch[0].rm_eo < input_length) {
      after_match = mg_getamatches(preg,
                                   &input[pmatch[0].rm_eo],
                                   offset + pmatch[0].rm_eo,
                                   input_length - pmatch[0].rm_eo,
                                   cost_ins, cost_del, cost_subst,
                                   max_cost, max_del, max_err,
                                   max_ins, max_subst,
                                   find_all);
    }

    // merge lists
    match->next = after_match;
    if (before_match == NULL) return match;

    current_match = before_match;
    while (current_match->next) {
      current_match = current_match->next;
    }
    current_match->next = match;
    match = before_match;
    return match;
  } else {
    return match;
  }
}



static IDL_VPTR IDL_CDECL IDL_mg_stregex(int argc, IDL_VPTR *argv, char *argk) {
  typedef struct {
    IDL_KW_RESULT_FIRST_FIELD;
    IDL_LONG all;
    IDL_LONG approximate;
    IDL_LONG boolean;
    IDL_VPTR costs;
    int costs_present;
    IDL_LONG cost_del;
    int cost_del_present;
    IDL_LONG cost_ins;
    int cost_ins_present;
    IDL_LONG cost_subst;
    int cost_subst_present;
    IDL_LONG extract;
    IDL_LONG fold_case;
    IDL_VPTR length;
    int length_present;
    IDL_LONG max_cost;
    int max_cost_present;
    IDL_LONG max_del;
    int max_del_present;
    IDL_LONG max_err;
    int max_err_present;
    IDL_LONG max_ins;
    int max_ins_present;
    IDL_LONG max_subst;
    int max_subst_present;
    IDL_LONG subexpr;  // TODO: handle SUBEXPR keyword
  } KW_RESULT;

  // make sure to list keyword in alphabetical order
  static IDL_KW_PAR kw_pars[] = {
    { "ALL", IDL_TYP_LONG, 1, IDL_KW_ZERO | IDL_KW_VALUE | 1,
      0, IDL_KW_OFFSETOF(all) },
    { "APPROXIMATE", IDL_TYP_LONG, 1, IDL_KW_ZERO | IDL_KW_VALUE | 1,
      0, IDL_KW_OFFSETOF(approximate) },
    { "BOOLEAN", IDL_TYP_LONG, 1, IDL_KW_ZERO | IDL_KW_VALUE | 1,
      0, IDL_KW_OFFSETOF(boolean) },
    { "COSTS", IDL_TYP_UNDEF, 1, IDL_KW_OUT | IDL_KW_ZERO,
      IDL_KW_OFFSETOF(costs_present), IDL_KW_OFFSETOF(costs) },
    { "COST_DEL", IDL_TYP_LONG, 1, 0,
      IDL_KW_OFFSETOF(cost_del_present), IDL_KW_OFFSETOF(cost_del) },
    { "COST_INS", IDL_TYP_LONG, 1, 0,
      IDL_KW_OFFSETOF(cost_ins_present), IDL_KW_OFFSETOF(cost_ins) },
    { "COST_SUBST", IDL_TYP_LONG, 1, 0,
      IDL_KW_OFFSETOF(cost_subst_present), IDL_KW_OFFSETOF(cost_subst) },
    { "EXTRACT", IDL_TYP_LONG, 1, IDL_KW_ZERO | IDL_KW_VALUE | 1,
      0, IDL_KW_OFFSETOF(extract) },
    { "FOLD_CASE", IDL_TYP_LONG, 1, IDL_KW_ZERO | IDL_KW_VALUE | 1,
      0, IDL_KW_OFFSETOF(fold_case) },
    { "LENGTH", IDL_TYP_UNDEF, 1, IDL_KW_OUT | IDL_KW_ZERO,
      IDL_KW_OFFSETOF(length_present), IDL_KW_OFFSETOF(length) },
    { "MAX_COST", IDL_TYP_LONG, 1, 0,
      IDL_KW_OFFSETOF(max_cost_present), IDL_KW_OFFSETOF(max_cost) },
    { "MAX_DEL", IDL_TYP_LONG, 1, 0,
      IDL_KW_OFFSETOF(max_del_present), IDL_KW_OFFSETOF(max_del) },
    { "MAX_ERR", IDL_TYP_LONG, 1, 0,
      IDL_KW_OFFSETOF(max_err_present), IDL_KW_OFFSETOF(max_err) },
    { "MAX_INS", IDL_TYP_LONG, 1, 0,
      IDL_KW_OFFSETOF(max_ins_present), IDL_KW_OFFSETOF(max_ins) },
    { "MAX_SUBST", IDL_TYP_LONG, 1, 0,
      IDL_KW_OFFSETOF(max_subst_present), IDL_KW_OFFSETOF(max_subst) },
    { "SUBEXPR", IDL_TYP_LONG, 1, IDL_KW_ZERO | IDL_KW_VALUE | 1,
      0, IDL_KW_OFFSETOF(subexpr) },
    { NULL }
  };

  KW_RESULT kw;

  int nargs = IDL_KWProcessByOffset(argc, argv, argk, kw_pars, (IDL_VPTR *) NULL, 1, &kw);

  if (kw.all && kw.boolean) {
    IDL_Message(IDL_M_NAMED_GENERIC, IDL_MSG_LONGJMP,
                "conflicting keywords, ALL and BOOLEAN");
  }

  if (kw.extract && kw.boolean) {
    IDL_Message(IDL_M_NAMED_GENERIC, IDL_MSG_LONGJMP,
                "conflicting keywords, EXTRACT and BOOLEAN");
  }

  if (kw.length_present && kw.boolean) {
    IDL_Message(IDL_M_NAMED_GENERIC, IDL_MSG_LONGJMP,
                "conflicting keywords, LENGTH and BOOLEAN");
  }

  char *input = IDL_VarGetString(argv[0]);
  char *re = IDL_VarGetString(argv[1]);
  regex_t preg;
  int compile_status = tre_regcomp(&preg, re,
                                   REG_EXTENDED
                                     | (kw.fold_case ? REG_ICASE : 0));
  if (compile_status != 0) {
    switch (compile_status) {
      case REG_BADPAT:
        IDL_Message(IDL_M_NAMED_GENERIC, IDL_MSG_LONGJMP,
                    "regex contained an invalid multibyte sequence");
      case REG_ECOLLATE:
        IDL_Message(IDL_M_NAMED_GENERIC, IDL_MSG_LONGJMP,
                    "invalid collating element referenced in regex");
      case REG_ECTYPE:
        IDL_Message(IDL_M_NAMED_GENERIC, IDL_MSG_LONGJMP,
                    "unknown character class name in regex");
      case REG_EESCAPE:
        IDL_Message(IDL_M_NAMED_GENERIC, IDL_MSG_LONGJMP,
                    "last character of regex was a backslash");
      case REG_ESUBREG:
        IDL_Message(IDL_M_NAMED_GENERIC, IDL_MSG_LONGJMP,
                    "invalid back reference in regex");
      case REG_EBRACK:
        IDL_Message(IDL_M_NAMED_GENERIC, IDL_MSG_LONGJMP,
                    "unbalanced [] in regex");
      case REG_EPAREN:
        IDL_Message(IDL_M_NAMED_GENERIC, IDL_MSG_LONGJMP,
                    "unbalanced parentheses in regex");
      case REG_EBRACE:
        IDL_Message(IDL_M_NAMED_GENERIC, IDL_MSG_LONGJMP,
                    "unbalanced braces in regex");
      case REG_BADBR:
        IDL_Message(IDL_M_NAMED_GENERIC, IDL_MSG_LONGJMP,
                    "content invalid in regex");
      case REG_ERANGE:
        IDL_Message(IDL_M_NAMED_GENERIC, IDL_MSG_LONGJMP,
                    "invalid character range in regex");
      case REG_ESPACE:
        IDL_Message(IDL_M_NAMED_GENERIC, IDL_MSG_LONGJMP,
                    "out of memory in regex");
      case REG_BADRPT:
        IDL_Message(IDL_M_NAMED_GENERIC, IDL_MSG_LONGJMP,
                    "invalid use of repetition operators in regex");
      default:
        IDL_Message(IDL_M_NAMED_GENERIC, IDL_MSG_LONGJMP, "invalid regex");
    }
  }

  regamatch_t amatch;
  regaparams_t match_params;
  regmatch_t pmatch[1];
  size_t length;

  IDL_VPTR result_vptr;
  IDL_STRING *extracts;
  int *starts;
  IDL_VPTR lengths_vptr;
  int *lengths;
  IDL_VPTR costs_vptr;
  int *costs;

  int m = 0, nmatches = 0;
  mg_regmatch_t *matches = NULL;
  mg_regmatch_t *current_match = NULL;

  int search_status = 0;
  int offset = 0;
  int find_all = 1;

  int cost_ins = kw.cost_ins_present ? kw.cost_ins : 1;
  int cost_del = kw.cost_del_present ? kw.cost_del : 1;
  int cost_subst = kw.cost_subst_present ? kw.cost_subst : 1;

  int max_cost = kw.max_cost_present ? kw.max_cost : INT_MAX;
  int max_del = kw.max_del_present ? kw.max_del : INT_MAX;
  int max_err = kw.max_err_present ? kw.max_err : INT_MAX;
  int max_ins = kw.max_ins_present ? kw.max_ins : INT_MAX;
  int max_subst = kw.max_subst_present ? kw.max_subst : INT_MAX;

  if (kw.approximate) {
    matches = mg_getamatches(&preg,
                             input, offset, strlen(input),
                             cost_ins, cost_del, cost_subst,
                             max_cost, max_del, max_err,
                             max_ins,  max_subst,
                             kw.all);
    current_match = matches;

    // count up number of matches
    while (current_match) {
      nmatches++;
      current_match = current_match->next;
    }
  } else {
    while (search_status == 0 && offset <= strlen(input) && find_all) {

      search_status = tre_regexec(&preg, &input[offset], (size_t) 1, pmatch, 0);

      if (search_status == 0) {
        nmatches++;

        if (current_match == NULL) {
          current_match = (mg_regmatch_t *) malloc(sizeof(mg_regmatch_t));
          matches = current_match;
        } else {
          current_match->next = (mg_regmatch_t *) malloc(sizeof(mg_regmatch_t));
          current_match = current_match->next;
        }

        current_match->cost = 0;
        current_match->rm_so = offset + pmatch[0].rm_so;
        current_match->rm_eo = offset + pmatch[0].rm_eo;
        current_match->next = NULL;

        offset += pmatch[0].rm_eo;
      }

      find_all = kw.all;
    }
  }

  if (kw.boolean) {
    result_vptr = IDL_GettmpByte(nmatches > 0 ? 1 : 0);
  } else {
    if (nmatches > 0) {
      if (kw.extract) {
        extracts = (IDL_STRING *)IDL_MakeTempVector(IDL_TYP_STRING,
                                                    (IDL_MEMINT)nmatches,
                                                    IDL_ARR_INI_ZERO,
                                                    &result_vptr);
      } else {
        starts = (int *)IDL_MakeTempVector(IDL_TYP_LONG, (IDL_MEMINT)nmatches,
                                           IDL_ARR_INI_NOP, &result_vptr);
      }
      lengths = (int *)IDL_MakeTempVector(IDL_TYP_LONG, (IDL_MEMINT)nmatches,
                                          IDL_ARR_INI_NOP, &lengths_vptr);
      costs = (int *)IDL_MakeTempVector(IDL_TYP_LONG, (IDL_MEMINT)nmatches,
                                        IDL_ARR_INI_NOP, &costs_vptr);

      current_match = matches;
      for(m = 0; m < nmatches; m++) {
        lengths[m] = current_match->rm_eo - current_match->rm_so;
        costs[m] = current_match->cost;

        if (kw.extract) {
          char *e = (char *) malloc(lengths[m] + 1);
          strncpy(e, input + current_match->rm_so, lengths[m]);
          e[lengths[m]] = '\0';
          IDL_StrEnsureLength(&(extracts[m]), lengths[m]);
          IDL_StrDelete(&(extracts[m]), 1);
          IDL_StrStore(&(extracts[m]), e);
          free(e);

          extracts[m].slen = lengths[m];
        } else {
          starts[m] = current_match->rm_so;
        }

        // advance to next match
        current_match = current_match->next;
      }
    } else {
      result_vptr = IDL_GettmpLong(-1);
      lengths_vptr = IDL_GettmpLong(-1);
    }

    // copy over lengths if LENGTH keyword was passed as a named variable
    if (kw.length_present) {
      IDL_VarCopy(lengths_vptr, kw.length);
    } else IDL_Deltmp(lengths_vptr);

    // copy over costs if COSTS keyword was passed as a named variable
    if (kw.costs_present) {
      IDL_VarCopy(costs_vptr, kw.costs);
    } else IDL_Deltmp(costs_vptr);
  }

  // free match linked list
  current_match = matches;
  while (matches) {
    matches = matches->next;
    free(current_match);
    current_match = matches;
  }

  // free the compiled regex
  tre_regfree(&preg);

  // free the keyword processing information
  IDL_KW_FREE;

  return result_vptr;
}


static IDL_VPTR IDL_CDECL IDL_mg_tre_config(int argc, IDL_VPTR *argv, char *argk) {
  typedef struct {
    IDL_KW_RESULT_FIRST_FIELD;
    IDL_LONG approximate;
    IDL_LONG multi_byte;
    IDL_LONG system_regex;
    IDL_LONG version;
    IDL_LONG wide_character;
  } KW_RESULT;

  // make sure to list keyword in alphabetical order
  static IDL_KW_PAR kw_pars[] = {
    { "APPROXIMATE", IDL_TYP_LONG, 1, IDL_KW_ZERO | IDL_KW_VALUE | 1,
      0, IDL_KW_OFFSETOF(approximate) },
    { "MULTI_BYTE", IDL_TYP_LONG, 1, IDL_KW_ZERO | IDL_KW_VALUE | 1,
      0, IDL_KW_OFFSETOF(multi_byte) },
    { "SYSTEM_REGEX", IDL_TYP_LONG, 1, IDL_KW_ZERO | IDL_KW_VALUE | 1,
      0, IDL_KW_OFFSETOF(system_regex) },
    { "VERSION", IDL_TYP_LONG, 1, IDL_KW_ZERO | IDL_KW_VALUE | 1,
      0, IDL_KW_OFFSETOF(version) },
    { "WIDE_CHARACTER", IDL_TYP_LONG, 1, IDL_KW_ZERO | IDL_KW_VALUE | 1,
      0, IDL_KW_OFFSETOF(wide_character) },
    { NULL }
  };

  KW_RESULT kw;

  int nargs = IDL_KWProcessByOffset(argc, argv, argk, kw_pars, (IDL_VPTR *) NULL, 1, &kw);
  int nkeywords = kw.approximate + kw.multi_byte + kw.system_regex
                    + kw.wide_character + kw.version;
  if (nkeywords == 0 || nkeywords > 1) {
    IDL_Message(IDL_M_NAMED_GENERIC, IDL_MSG_LONGJMP,
                "one keyword required to be set");
  }

  int status, query;
  int result;
  char *version;

  if (kw.approximate) query = TRE_CONFIG_APPROX;
  if (kw.multi_byte) query = TRE_CONFIG_MULTIBYTE;
  if (kw.system_regex) query = TRE_CONFIG_SYSTEM_ABI;
  if (kw.wide_character) query = TRE_CONFIG_WCHAR;

  if (kw.version) {
    status = tre_config(query, &version);
    if (status) {
      IDL_Message(IDL_M_NAMED_GENERIC, IDL_MSG_LONGJMP,
                  "invalid configuration request");
    }
    IDL_KW_FREE;
    return IDL_StrToSTRING(version);
  } else {
    status = tre_config(query, &result);
    if (status) {
      IDL_Message(IDL_M_NAMED_GENERIC, IDL_MSG_LONGJMP,
                  "invalid configuration request");
    }
    IDL_KW_FREE;
    return IDL_GettmpLong(result);
  }
}


static IDL_VPTR IDL_CDECL IDL_mg_tre_version(int argc, IDL_VPTR *argv) {
  return IDL_StrToSTRING(tre_version());
}


int IDL_Load(void) {
  static IDL_SYSFUN_DEF2 function_addr[] = {
    { IDL_mg_tre_version, "MG_TRE_VERSION", 0, 0, 0, 0 },
    { IDL_mg_tre_config,  "MG_TRE_CONFIG",  0, 0, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },
    { IDL_mg_stregex,     "MG_STREGEX",     2, 2, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },
    { IDL_mg_strsplit,    "MG_STRSPLIT",    2, 2, 0, 0 },
  };

  return IDL_SysRtnAdd(function_addr, TRUE, IDL_CARRAY_ELTS(function_addr));
}
