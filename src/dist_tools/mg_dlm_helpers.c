// don't delete a constant either
#define MG_DELTMP(v) { if (((v)->flags) & (IDL_V_TEMP | IDL_V_CONST)) IDL_Deltmp(v); }
