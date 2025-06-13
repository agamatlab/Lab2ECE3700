module regfile(
    input           clk,
    input           WB,
    input   [4:0]   rs1_address,
    input   [4:0]   rs2_address,
    input   [4:0]   rd_address,
    input   [31:0]  write_data,
    output reg [31:0] rs1_data,
    output reg [31:0] rs2_data
);
    reg [31:0] regs [0:31];
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1)
            regs[i] = 32'b0;
    end

    always @(negedge clk) begin
        if (WB && rd_address != 5'd0)
            regs[rd_address] <= write_data;
    end

    always @(*) begin
        rs1_data = regs[rs1_address];
        rs2_data = regs[rs2_address];
    end
endmodule
