// IDL types
#define MG_GET_TYPE(TYPE, TYPE_CODE, IDL_MEMBER)             \
IDL_VPTR MG_get_ ## TYPE(TYPE var) {                         \
  IDL_VPTR idl_var = IDL_Gettmp();                           \
  if (idl_var == (IDL_VPTR) NULL)                            \
    IDL_Message(IDL_M_NAMED_GENERIC,IDL_MSG_LONGJMP,         \
                "could not create temporary variable");      \
                                                             \
  idl_var->type = TYPE_CODE;                                 \
  idl_var->value.IDL_MEMBER = var;                           \
                                                             \
  return idl_var;                                            \
}

MG_GET_TYPE(UCHAR, IDL_TYP_BYTE, c)
MG_GET_TYPE(IDL_INT, IDL_TYP_INT, i)
MG_GET_TYPE(IDL_LONG, IDL_TYP_LONG, l)
MG_GET_TYPE(float, IDL_TYP_FLOAT, f)
MG_GET_TYPE(double, IDL_TYP_DOUBLE, d)
MG_GET_TYPE(IDL_COMPLEX, IDL_TYP_COMPLEX, cmp)
//MG_GET_TYPE(IDL_STRING, IDL_TYP_STRING, str)
//MG_GET_TYPE(IDL_SREF, IDL_TYP_STRUCT, s)
MG_GET_TYPE(IDL_DCOMPLEX, IDL_TYP_DCOMPLEX, dcmp)
//MG_GET_TYPE(IDL_HVID, IDL_TYP_PTR, hvid)
//MG_GET_TYPE(IDL_HVID, IDL_TYP_OBJREF, hvid)
MG_GET_TYPE(IDL_UINT, IDL_TYP_UINT, ui)
MG_GET_TYPE(IDL_ULONG, IDL_TYP_ULONG, ul)
MG_GET_TYPE(IDL_LONG64, IDL_TYP_LONG64, l64)
MG_GET_TYPE(IDL_ULONG64, IDL_TYP_ULONG64, ul64)

// C pointers
MG_GET_TYPE(IDL_PTRINT, IDL_TYP_PTRINT, ptrint)

// standard C strings
#define MG_get_IDL_STRING_s(var) IDL_StrToSTRING(var)
typedef char * IDL_STRING_s;

static IDL_MSG_DEF msg_arr[] = {
#define MG_INCORRECT_TYPE_ERROR 0
  { "MG_INCORRECT_TYPE_ERROR",	  "%Nincorrect type for parameter '%s'" },
};

IDL_MSG_BLOCK msg_block;

#define MG_ENSURE_TYPE(v,t,var) { if ((v)->type != t) IDL_MessageFromBlock(msg_block, MG_INCORRECT_TYPE_ERROR, IDL_MSG_RET, var); }
