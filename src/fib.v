`default_nettype none
`timescale 1ns/1ns
module fib(
  input wire clk,
  input wire reset,

  inout wire [7:0] data,
  input wire address,

  input wire start,
  input wire we,
  input wire oe,

  output wire busy
);


wire [8:0] tmp_add = tmp + data;

reg [7:0] tmp;
reg [7:0] data_i;
reg we_i;
reg oe_i;
reg addr_i;

wire addr_c = busy ? addr_i : address;
wire oe_c = busy ? oe_i : oe;
wire we_c = busy ? we_i : we;

assign data = busy&&we_i ? data_i : 'z;

localparam STATE_IDLE = 0;
localparam STATE_READ_FIRST = 1;
localparam STATE_READ_SECOND = 2;
localparam STATE_WROTE = 3;
reg [2:0] state;

assign busy = state != STATE_IDLE;

always @(posedge clk) begin
  if ( reset ) begin
    data_i <= 0;
    addr_i <= 0;
    we_i <= 0;
    oe_i <= 0;
    state <= STATE_IDLE;
    tmp <= 0;
  end else if ( busy ) begin // busy = state != STATE_IDLE
    if ( state == STATE_READ_FIRST ) begin
      tmp <= data;
      addr_i <= ( addr_i == 0 ? 1 : 0 ); // don't want to rely on wrapping here
      state <= STATE_READ_SECOND;
    end else if ( state == STATE_READ_SECOND ) begin
      addr_i <= ( addr_i == 0 ? 1 : 0 ); // don't want to rely on wrapping here
      if ( tmp_add[8] == 0 ) begin // no overflow, keep going
        we_i <= 1;
        oe_i <= 0;
        data_i <= tmp_add[7:0];
        state <= STATE_WROTE;
      end else begin // overflow, we're done
        oe_i <= 0;
        state <= STATE_IDLE;
      end
    end else if ( state == STATE_WROTE ) begin
      we_i <= 0;
      oe_i <= 1;
      addr_i <= ( addr_i == 0 ? 1 : 0 ); // don't want to rely on wrapping here
      state <= STATE_READ_FIRST;
    end
  end else if ( start ) begin
    addr_i <= 0;
    oe_i <= 1;
    state <= STATE_READ_FIRST;
  end
end

register reg_a( .clk(clk), .reset(reset), .data(data), .we(we_c && addr_c == 0), .oe(oe_c && addr_c == 0) );
register reg_b( .clk(clk), .reset(reset), .data(data), .we(we_c && addr_c == 1), .oe(oe_c && addr_c == 1) );

endmodule


module register(
  input wire clk,
  input wire reset,

  inout wire [7:0] data,

  input wire we,
  input wire oe
);

reg [7:0] value;

assign data = oe ? value : 'z;

always @(posedge clk) begin
  if ( reset ) begin
    value <= 0;
  end else if ( we ) begin
    value <= data;
  end
end

endmodule
