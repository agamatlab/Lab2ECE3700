module memory(
    input           clk,
    input  [31:0]   address,
    input  [31:0]   write_data,
    input           mem_read,
    input           mem_write,
    output reg [31:0] read_data
);
    reg [7:0] regs [0:255];
    integer i;
    wire [7:0] addr8 = address[7:0];

    initial begin
        for (i = 0; i < 256; i = i + 1)
            regs[i] = 8'd0;
    end

    always @(posedge clk) begin
        if (mem_write) begin
            regs[addr8]     <= write_data[7:0];
            regs[addr8+1]   <= write_data[15:8];
            regs[addr8+2]   <= write_data[23:16];
            regs[addr8+3]   <= write_data[31:24];
        end
    end

    always @(*) begin
        if (mem_read) begin
            read_data = { regs[addr8+3],
                          regs[addr8+2],
                          regs[addr8+1],
                          regs[addr8]   };
        end else begin
            read_data = 32'b0;
        end
    end
endmodule
