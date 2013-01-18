#include <stdio.h>

#include "idl_export.h"
#include "mkdio.h"

/*
  The markdown DLM uses David Parsons' DISCOUNT implementation of John
  Gruber's Markdown markup language. Is is released under a BSD-style
  license.
*/

static IDL_VPTR IDL_mg_markdown(int argc, IDL_VPTR *argv) {
	char *doc;

	// do error checking on parameter and convert an IDL_VPTR to a char*
	char *buf = IDL_VarGetString(argv[0]);

	// get a markdown tree for the char*
	MMIOT *tree = mkd_string(buf, strlen(buf), 0);

	// compile the tree
	int status = mkd_compile(tree, 0);

	// get the HTML document out of the markdown tree
	int doc_size = mkd_document(tree, &doc);

	return IDL_StrToSTRING(doc);
}


int IDL_Load(void) {
  static IDL_SYSFUN_DEF2 function_addr[] = {
    { IDL_mg_markdown, "MG_MARKDOWN", 1, 1, 0, 0 },
  };

  return IDL_SysRtnAdd(function_addr, TRUE, IDL_CARRAY_ELTS(function_addr));
}
