import cocotb
from cocotb.binary import BinaryValue
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, ClockCycles
import random

async def reset(dut):
  dut.reset <= 1

  await ClockCycles(dut.clk, 5)
  dut.reset <= 0;

@cocotb.test()
async def test_register(dut):
  clock = Clock(dut.clk, 10, units="us")
  cocotb.fork(clock.start())

  dut.data <= BinaryValue("z")
  dut.oe <= 0
  dut.we <= 0
  await reset(dut)

  assert( dut.value == 0 )

  dut.oe <= 1
  await ClockCycles(dut.clk, 1)
  assert( dut.data == 0 )

  dut.oe <= 0
  await ClockCycles(dut.clk, 1)

  dut.oe <= 0
  dut.we <= 1
  dut.data <= 42;
  await ClockCycles(dut.clk, 1)
  dut.we <= 0
  dut.data <= BinaryValue("z");
  await ClockCycles(dut.clk, 2)
  
  assert( dut.value == 42 )
  dut.oe <= 1
  await ClockCycles(dut.clk, 1)
  assert( dut.data == 42 )

  dut.oe <= 0
  await ClockCycles(dut.clk, 1)
