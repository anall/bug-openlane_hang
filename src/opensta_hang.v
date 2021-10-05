`default_nettype none
`timescale 1ns/1ns
module opensta_hang(
  input wire clk,

  inout wire data,

  input wire we,
  input wire oe,
);

reg busy;
wire data_c = we ? ( busy ? 1 : data ) : 'z;
assign data = (oe&~busy) ? data_c : 'z;

endmodule
