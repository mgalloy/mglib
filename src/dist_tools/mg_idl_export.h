// OS X 10.9 Mavericks defines strlcpy and strlcat as macros, so they must be
// undefined before idl_export.h redefines them

#include <string.h>

#ifdef strlcpy
#undef strlcpy
#endif

#ifdef strlcat
#undef strlcat
#endif

#include "idl_export.h"
