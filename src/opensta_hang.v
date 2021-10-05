`default_nettype none
`timescale 1ns/1ns
module opensta_hang(
  input wire clk,
  input wire reset,

  inout wire data,

  input wire start,
  input wire we,
  input wire oe,
);

wire data_c = we ? ( busy ? 1 : data ) : 'z;
assign data = (oe&~busy) ? data_c : 'z;

reg busy;

always @(posedge clk) begin
  if ( reset ) begin
    busy <= 0;
  end else begin
    busy <= 1;
  end
end

endmodule
