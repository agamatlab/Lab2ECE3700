module memory(
    input   [31:0] address,
    input   [31:0] write_data,
    input          mem_read,
    input          mem_write,
    output reg [31:0] read_data
);
    reg [7:0] regs [0:255];
    integer i;
    initial begin
        for (i = 0; i < 256; i = i + 1)
            regs[i] = 8'd0;
    end

    always @(*) begin
        if (mem_write) begin
            regs[address]     = write_data[7:0];
            regs[address+1]   = write_data[15:8];
            regs[address+2]   = write_data[23:16];
            regs[address+3]   = write_data[31:24];
        end
    end

    always @(*) begin
        if (mem_read)
            read_data = {regs[address+3],
                         regs[address+2],
                         regs[address+1],
                         regs[address]};
        else
            read_data = 32'b0;
    end
endmodule
