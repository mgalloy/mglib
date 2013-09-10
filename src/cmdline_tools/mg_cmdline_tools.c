#include <stdio.h>
#include <stdlib.h>

#include "idl_export.h"

#define OUTF_BUFFER_BLOCKSIZE 1024

static int diverting = 0;
static FILE *outf_fp = 0;
static char *outf_buffer = 0;
static int outf_buffer_loc = 0;
static int outf_buffer_size = 0;

static IDL_MSG_DEF msg_arr[] = {
#define M_MG_WRONG_TYPE       0
  {  "M_MG_WRONG_TYPE",   "%NInput must be of type pointer or object." },
#define MG_INCORRECT_TYPE_ERROR -1
  { "MG_INCORRECT_TYPE_ERROR", "%Nincorrect type for parameter '%s'" },
  };
static IDL_MSG_BLOCK msg_block;

#define MG_ENSURE_TYPE(v,t,var) { if ((v)->type != t) IDL_MessageFromBlock(msg_block, MG_INCORRECT_TYPE_ERROR, IDL_MSG_RET, var); }


#ifdef WIN32
int MG_FileTermIsTty(void) {
  return 0;
}
#else
int MG_FileTermIsTty(void) {
  return IDL_FileTermIsTty();
}
#endif


static IDL_VPTR IDL_CDECL IDL_mg_termlines(int argc, IDL_VPTR *argv) {
  return IDL_GettmpLong(IDL_FileTermLines());
}


static IDL_VPTR IDL_CDECL IDL_mg_termcolumns(int argc, IDL_VPTR *argv) {
  return IDL_GettmpLong(IDL_FileTermColumns());
}


static IDL_VPTR IDL_CDECL IDL_mg_termistty(int argc, IDL_VPTR *argv) {
  return IDL_GettmpLong(MG_FileTermIsTty());
}


static IDL_VPTR IDL_CDECL IDL_mg_heapid(int argc, IDL_VPTR *argv) {
  IDL_ENSURE_SCALAR(argv[0]);

  if (argv[0]->type != IDL_TYP_PTR && argv[0]->type != IDL_TYP_OBJREF) {
    IDL_MessageFromBlock(msg_block, M_MG_WRONG_TYPE, IDL_MSG_RET);
  }

  return IDL_GettmpULong(argv[0]->value.hvid);
}


static void IDL_CDECL IDL_mg_print(int argc, IDL_VPTR *argv, char *argk) {
  int nargs;
  char *format, *cformat;
  IDL_VPTR origFormat, vcformat;

  typedef struct {
    IDL_KW_RESULT_FIRST_FIELD;
    IDL_VPTR format;
    int format_present;
  } KW_RESULT;

  static IDL_KW_PAR kw_pars[] = {
    { "FORMAT", IDL_TYP_STRING, 1, IDL_KW_VIN,
      IDL_KW_OFFSETOF(format_present), IDL_KW_OFFSETOF(format) },
    { NULL }
  };

  KW_RESULT kw;

  nargs = IDL_KWProcessByOffset(argc, argv, argk, kw_pars, NULL, 1, &kw);

  if (kw.format_present) {
    origFormat = argv[argc - 1];
    format = IDL_VarGetString(origFormat);
    cformat = (char *) calloc(strlen(format) + 5 + 1, sizeof(char));
    sprintf(cformat, "(%%\"%s\")", format);
    vcformat = IDL_StrToSTRING(cformat);
    argv[argc - 1] = vcformat;
  }

  IDL_Print(argc, argv, argk);

  if (kw.format_present) {
    argv[argc - 1] = origFormat;
    IDL_Deltmp(vcformat);
    free(cformat);
  }

  IDL_KW_FREE;
}


void mg_tout_outf_file(int flags, char *buf, int n) {
  char *output = (char *) malloc(strlen(buf) + 1);

  strncpy(output, buf, n);
  output[n] = '\0';
  
//  printf("%s", output);
//  if (flags & IDL_TOUT_F_NLPOST) printf("\n");
  fprintf(outf_fp, "%s", output);
  if (flags & IDL_TOUT_F_NLPOST) fprintf(outf_fp, "\n");

  free(output);
}


void mg_tout_outf_buffer(int flags, char *buf, int n) {
  int n_extra_chars = flags & IDL_TOUT_F_NLPOST ? 1 : 0;
  int new_size = 2 * outf_buffer_size;
  char *tmp_buffer;

  // make a new buffer if the old one is too small
  if (outf_buffer_loc + n + n_extra_chars > outf_buffer_size) {
    // find the required size
    while(outf_buffer_loc + n + n_extra_chars > new_size) new_size *= 2;
    outf_buffer_size = new_size;
    tmp_buffer = (char *) malloc(outf_buffer_size);
    strncpy(tmp_buffer, outf_buffer, outf_buffer_loc);

    free(outf_buffer);
    outf_buffer = tmp_buffer;
    tmp_buffer = 0;
  }

  strncpy(outf_buffer + outf_buffer_loc, buf, n);
  if (flags & IDL_TOUT_F_NLPOST) {
    sprintf(outf_buffer + outf_buffer_loc + n, "\n");
  }
  outf_buffer_loc += n + n_extra_chars;
}


static void IDL_CDECL IDL_mg_tout_push(int argc, IDL_VPTR *argv) {
  if (diverting) {
    IDL_ToutPop();
  } else diverting = 1;

  if (argc > 0) {
    IDL_ENSURE_STRING(argv[0]);
    outf_fp = fopen(IDL_VarGetString(argv[0]), "w");
    IDL_ToutPush(mg_tout_outf_file);
  } else {
    outf_buffer_loc = 0;
    outf_buffer_size = OUTF_BUFFER_BLOCKSIZE;
    outf_buffer = (char *) malloc(OUTF_BUFFER_BLOCKSIZE);
    IDL_ToutPush(mg_tout_outf_buffer);
  }

}


static IDL_VPTR IDL_CDECL IDL_mg_tout_pop(int argc, IDL_VPTR *argv) {
  char *output;
  IDL_VPTR result;

  IDL_ToutPop();

  if (outf_buffer_size == 0) {
    fclose(outf_fp);
    return IDL_GettmpLong(-1);
  } else {
    output = (char *) malloc(outf_buffer_loc);
    strncpy(output, outf_buffer, outf_buffer_loc);
    output[outf_buffer_loc - 1] = '\0';

    free(outf_buffer);
    outf_buffer_loc = 0;
    outf_buffer_size = 0;

    result = IDL_StrToSTRING(output);

    free(output);

    return(result);
  }
}


// char *IDL_OutputFormatFunc(int type)
static IDL_VPTR IDL_IDL_OutputFormatFunc(int argc, IDL_VPTR *argv, char *argk) {
  char *result;
  IDL_ENSURE_SIMPLE(argv[0]);
  IDL_ENSURE_SCALAR(argv[0])
  MG_ENSURE_TYPE(argv[0], IDL_TYP_LONG, "int type")
  result = (char *) IDL_OutputFormatFunc(argv[0]->value.l);   // int type
  return IDL_StrToSTRING(result);
}

// int IDL_OutputFormatLenFunc(int type)
static IDL_VPTR IDL_IDL_OutputFormatLenFunc(int argc, IDL_VPTR *argv, char *argk) {
  IDL_LONG result;
  IDL_ENSURE_SIMPLE(argv[0]);
  IDL_ENSURE_SCALAR(argv[0])
  MG_ENSURE_TYPE(argv[0], IDL_TYP_LONG, "int type")
  result = (IDL_LONG) IDL_OutputFormatLenFunc(argv[0]->value.l);   // int type
  return IDL_GettmpLong(result);
}

// int IDL_TypeSizeFunc(int type)
static IDL_VPTR IDL_IDL_TypeSizeFunc(int argc, IDL_VPTR *argv, char *argk) {
  IDL_LONG result;
  IDL_ENSURE_SIMPLE(argv[0]);
  IDL_ENSURE_SCALAR(argv[0])
  MG_ENSURE_TYPE(argv[0], IDL_TYP_LONG, "int type")
  result = (IDL_LONG) IDL_TypeSizeFunc(argv[0]->value.l);   // int type
  return IDL_GettmpLong(result);
}

// char *IDL_TypeNameFunc(int type)
static IDL_VPTR IDL_IDL_TypeNameFunc(int argc, IDL_VPTR *argv, char *argk) {
  char *result;
  IDL_ENSURE_SIMPLE(argv[0]);
  IDL_ENSURE_SCALAR(argv[0])
  MG_ENSURE_TYPE(argv[0], IDL_TYP_LONG, "int type")
  result = (char *) IDL_TypeNameFunc(argv[0]->value.l);   // int type
  return IDL_StrToSTRING(result);
}

// void IDL_TTYReset()
static void IDL_IDL_TTYReset(int argc, IDL_VPTR *argv, char *argk) {
  IDL_TTYReset();
}

// IDL_LONG64 IDL_SysRtnNumEnabled(int is_function, int enabled)
static IDL_VPTR IDL_IDL_SysRtnNumEnabled(int argc, IDL_VPTR *argv, char *argk) {
  IDL_LONG64 result;
  IDL_ENSURE_SIMPLE(argv[0]);
  IDL_ENSURE_SCALAR(argv[0])
  MG_ENSURE_TYPE(argv[0], IDL_TYP_LONG, "int is_function")
  IDL_ENSURE_SIMPLE(argv[1]);
  IDL_ENSURE_SCALAR(argv[1])
  MG_ENSURE_TYPE(argv[1], IDL_TYP_LONG, "int enabled")
  result = (IDL_LONG64) IDL_SysRtnNumEnabled(argv[0]->value.l,   // int is_function
                                             argv[1]->value.l);   // int enabled
  return IDL_GettmpLong64(result);
}


int IDL_Load(void) {
  /*
     These tables contain information on the functions and procedures
     that make up the cmdline_tools DLM. The information contained in these
     tables must be identical to that contained in cmdline_tools.dlm.
  */
  static IDL_SYSFUN_DEF2 function_addr[] = {
    { IDL_mg_termlines,            "MG_TERMLINES",            0, 0, 0, 0 },
    { IDL_mg_termcolumns,          "MG_TERMCOLUMNS",          0, 0, 0, 0 },
    { IDL_mg_termistty,            "MG_TERMISTTY",            0, 0, 0, 0 },
    { IDL_mg_heapid,               "MG_HEAPID",               1, 1, 0, 0 },
    { IDL_mg_tout_pop,             "MG_TOUT_POP",             0, 0, 0, 0 },
    { IDL_IDL_OutputFormatFunc,    "MG_OUTPUTFORMATFUNC",     1, 1, 0, 0 },
    { IDL_IDL_OutputFormatLenFunc, "MG_OUTPUTFORMATLENFUNC",  1, 1, 0, 0 },
    { IDL_IDL_TypeSizeFunc,        "MG_TYPESIZEFUNC",         1, 1, 0, 0 },
    { IDL_IDL_TypeNameFunc,        "MG_TYPENAMEFUNC",         1, 1, 0, 0 },
    { IDL_IDL_SysRtnNumEnabled,    "MG_SYSRTNNUMENABLED",     2, 2, 0, 0 },
  };

  static IDL_SYSFUN_DEF2 procedure_addr[] = {
    { (IDL_SYSRTN_GENERIC) IDL_mg_print,     "MG_PRINT",     0, IDL_MAXPARAMS, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },
    { (IDL_SYSRTN_GENERIC) IDL_mg_tout_push, "MG_TOUT_PUSH", 0, 1, 0, 0 },
    { (IDL_SYSRTN_GENERIC) IDL_IDL_TTYReset, "MG_TTYRESET",  0, 0, 0, 0 },
  };

  if (!(msg_block = IDL_MessageDefineBlock("MG_Cmdline_tools_DLM",
                                           IDL_CARRAY_ELTS(msg_arr),
                                           msg_arr))) return IDL_FALSE;

  /*
     Register our routines. The routines must be specified exactly the same
     as in cmdline_tools.dlm.
  */
  return IDL_SysRtnAdd(procedure_addr, FALSE, IDL_CARRAY_ELTS(procedure_addr))
      && IDL_SysRtnAdd(function_addr, TRUE, IDL_CARRAY_ELTS(function_addr));
}
