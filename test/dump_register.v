module dump();
    initial begin
        $dumpfile ("register.vcd");
        $dumpvars (0, register);
        #1;
    end
endmodule

