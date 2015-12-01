IDL=idl
TEST=cl_uts


.PHONY: all generate clean

generate: unary_tests.txt
	@echo "Generating unary tests..."
	@while read -r line; do \
		IFS=' ' read -r NAME CODES <<< $$line; \
		sed -e "s/HOST_OP/$${NAME}/g" -e "s/DEVICE_OP/$${NAME}/g" -e "s/CODES/$${CODES}/g" mg_cl_unary_ut__define.pro.sed > cl_"$${NAME}"_ut__define.pro; \
	done < unary_tests.txt

clean:
	@while read -r line; do \
		IFS=' ' read -r NAME CODES <<< $$line; \
		rm -f cl_"$${NAME}"_ut__define.pro; \
	done < unary_tests.txt

