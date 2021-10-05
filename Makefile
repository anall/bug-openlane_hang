export COCOTB_REDUCED_LOG_FMT=1

all: test_register test_fib

test_gl:
	rm -rf sim_build/
	mkdir sim_build/
	iverilog -o sim_build/sim.vvp -s fib -s dump -g2012 gl/fib.lvs.powered.v test/dump_fib.v -I $(PDK_ROOT)/sky130A
	PYTHONOPTIMIZE=${NOASSERT} MODULE=test.test_fib_gl vvp -M $$(cocotb-config --prefix)/cocotb/libs -m libcocotbvpi_icarus sim_build/sim.vvp

test_fib:
	rm -rf sim_build/
	mkdir sim_build/
	iverilog -o sim_build/sim.vvp -s fib -s dump -g2012 src/fib.v test/dump_fib.v
	PYTHONOPTIMIZE=${NOASSERT} MODULE=test.test_fib vvp -M $$(cocotb-config --prefix)/cocotb/libs -m libcocotbvpi_icarus sim_build/sim.vvp

test_register:
	rm -rf sim_build/
	mkdir sim_build/
	iverilog -o sim_build/sim.vvp -s register -s dump -g2012 src/fib.v test/dump_register.v
	PYTHONOPTIMIZE=${NOASSERT} MODULE=test.test_register vvp -M $$(cocotb-config --prefix)/cocotb/libs -m libcocotbvpi_icarus sim_build/sim.vvp

show_synth_%: src/%.v
	yosys -p "read_verilog $<; proc; opt; show -colors 2 -width -signed"

show_gl: fib.vcd fib_gl.gtkw
	gtkwave fib.vcd fib_gl.gtkw

show_%: %.vcd %.gtkw
	gtkwave $^ 

clean:
	rm -rf *.vcd sim_build test/__pycache__
