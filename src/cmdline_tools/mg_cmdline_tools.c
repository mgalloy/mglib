#include <stdio.h>
#include <stdlib.h>

#include "idl_export.h"


static IDL_MSG_DEF msg_arr[] = {  
#define M_MG_WRONG_TYPE       0  
  {  "M_MG_WRONG_TYPE",   "%NInput must be of type pointer or object." }, 
  };
static IDL_MSG_BLOCK msg_block; 


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


int IDL_Load(void) {  
  /*
     These tables contain information on the functions and procedures
     that make up the cmdline_tools DLM. The information contained in these
     tables must be identical to that contained in cmdline_tools.dlm.
  */
  static IDL_SYSFUN_DEF2 function_addr[] = {
    { IDL_mg_termlines,     "MG_TERMLINES",     0, 0, 0, 0 },
    { IDL_mg_termcolumns,   "MG_TERMCOLUMNS",   0, 0, 0, 0 },
    { IDL_mg_termistty,     "MG_TERMISTTY",     0, 0, 0, 0 },   
    { IDL_mg_heapid,        "MG_HEAPID",        1, 1, 0, 0 },   
  };

  static IDL_SYSFUN_DEF2 procedure_addr[] = {
    { (IDL_SYSRTN_GENERIC) IDL_mg_print,    "MG_PRINT",    0, IDL_MAXPARAMS, IDL_SYSFUN_DEF_F_KEYWORDS, 0 },   
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
