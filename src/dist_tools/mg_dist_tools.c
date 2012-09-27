#include <stdio.h>
#include "idl_export.h"

static IDL_USER_INFO user_info;

IDL_VPTR IDL_mg_loginname(int argc, IDL_VPTR *argv) {
  return IDL_StrToSTRING(user_info.logname);
}


IDL_VPTR IDL_mg_homedir(int argc, IDL_VPTR *argv) {
  return IDL_StrToSTRING(user_info.homedir);
}


IDL_VPTR IDL_mg_pid(int argc, IDL_VPTR *argv) {   
  return IDL_StrToSTRING(user_info.pid);
}


IDL_VPTR IDL_mg_hostname(int argc, IDL_VPTR *argv) {           
  return IDL_StrToSTRING(user_info.host);
}


int IDL_Load(void) {  
  /*
   * These tables contain information on the functions and procedures
   * that make up the dist_tools DLM. The information contained in these
   * tables must be identical to that contained in dist_tools.dlm.
   */
  static IDL_SYSFUN_DEF2 function_addr[] = {
    { IDL_mg_loginname,     "MG_LOGINNAME",     0, 0, 0, 0 },  
    { IDL_mg_homedir,       "MG_HOMEDIR",       0, 0, 0, 0 },  
    { IDL_mg_pid,           "MG_PID",           0, 0, 0, 0 },  
    { IDL_mg_hostname,      "MG_HOSTNAME",      0, 0, 0, 0 },     
  };
  
  IDL_GetUserInfo(&user_info);
  
  /*
   * Register our routines. The routines must be specified exactly the same
   * as in cmdline_tools.dlm.
   */
  return IDL_SysRtnAdd(function_addr, TRUE, IDL_CARRAY_ELTS(function_addr));  
}
