module regfile(
    input clk,
    input WB,
    input[4:0] rs1_address,
    input [4:0] rs2_address,
    input [4:0] rd_address,
    input [31:0] write_data,
    output reg [31:0] rs1_data,
    output reg [31:0] rs2_data);
    
    reg [31:0] regfile[0:31];
    always @(*) begin
        rs1_data <= (rs1_address == 5'b0) ? 32'b0 : regfile[rs1_address];
        rs2_data <= (rs2_address == 5'b0) ? 32'b0 : regfile[rs2_address];
    end

    always @(posedge clk) begin
        if (WB && rd_address != 5'b0 ) begin 
            regfile[rd_address] <= write_data;
        end
    end

endmodule