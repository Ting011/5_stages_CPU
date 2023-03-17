all: test_ALU.out
	vvp -n test_ALU.out
test_ALU.out: test_ALU.v
	iverilog -o test_ALU.out test_ALU.v ALU.v

clean:
	del test_ALU.out test.vcd