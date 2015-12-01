IDL=idl
TEST=cl_uts


.PHONY: all generate clean

generate: unary_tests.txt
	@echo "Generating array init tests..."
	@while read -r line; do \
		IFS=' ' read -r NAME CODE <<< $$line; \
		sed -e "s/ARR/$${NAME}/g" -e "s/TYPE_CODE/$${CODE}/g" mg_cl_array_init_ut__define.pro.sed > mg_cl_"$${NAME}"_ut__define.pro; \
	done < array_init_tests.txt
	
	@echo "Generating indgen tests..."
	@while read -r line; do \
		IFS=' ' read -r NAME CODE <<< $$line; \
		sed -e "s/ARR/$${NAME}/g" -e "s/TYPE_CODE/$${CODE}/g" mg_cl_indgen_ut__define.pro.sed > mg_cl_"$${NAME}"_ut__define.pro; \
	done < indgen_tests.txt
	
	@echo "Generating unary tests..."
	@while read -r line; do \
		IFS=' ' read -r NAME CODES <<< $$line; \
		sed -e "s/HOST_OP/$${NAME}/g" -e "s/DEVICE_OP/$${NAME}/g" -e "s/CODES/$${CODES}/g" mg_cl_unary_ut__define.pro.sed > mg_cl_"$${NAME}"_ut__define.pro; \
	done < unary_tests.txt

clean:
	@while read -r line; do \
		IFS=' ' read -r NAME CODE <<< $$line; \
		rm -f mg_cl_"$${NAME}"_ut__define.pro; \
	done < array_init_tests.txt
	
	@while read -r line; do \
		IFS=':' read -r OPS <<< $$line; \
		IFS=' ' read -r NAME CODE <<< $$line; \
		rm -f mg_cl_"$${NAME}"_ut__define.pro; \
	done < indgen_tests.txt
	
	@while read -r line; do \
		IFS=' ' read -r NAME CODES <<< $$line; \
		rm -f mg_cl_"$${NAME}"_ut__define.pro; \
	done < unary_tests.txt

