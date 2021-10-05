module dump();
    initial begin
        $dumpfile ("fib.vcd");
        $dumpvars (0, fib);
        #1;
    end
endmodule

