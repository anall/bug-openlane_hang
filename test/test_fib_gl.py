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
  dut.VGND <= 0
  dut.VPWR <= 1

  clock = Clock(dut.clk, 10, units="us")
  cocotb.fork(clock.start())

  dut.data <= BinaryValue("z")
  dut.oe <= 0
  dut.we <= 0
  dut.start <= 0
  dut.address <= 0
  await reset(dut)

  dut.we <= 1
  dut.data <= 1
  await ClockCycles(dut.clk, 1)
  dut.address <= 1
  await ClockCycles(dut.clk, 1)
  dut.data <= BinaryValue("z")
  dut.we <= 0

  await ClockCycles(dut.clk, 1)

  dut.start <= 1;
  await ClockCycles(dut.clk, 1)
  dut.start <= 0
  await ClockCycles(dut.clk, 1)

  n = 0
  while ( dut.busy == 1 ):
    n = n + 1
    assert( n < 1000 )
    await ClockCycles(dut.clk, 1)

  await ClockCycles(dut.clk, 2)
  
  dut.oe <= 1
  dut.address <= 0
  await ClockCycles(dut.clk, 1)

  assert( dut.data == 233 )

  dut.address <= 1
  await ClockCycles(dut.clk, 1)
  assert( dut.data == 144 )

  dut.oe <= 0
  await ClockCycles(dut.clk, 1)

