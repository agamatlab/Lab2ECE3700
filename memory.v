module memory(address, write_data, mem_read, mem_write, read_data);
    reg [31:0] memory [255:0];
    input [31:0] address;
    input [31:0] write_data;
    input mem_read;
    input mem_write;
    output reg [31:0] read_data;

    always @(*) begin
        if (mem_read == 1'b1) begin
            read_data = memory[address];
        end else if (mem_write == 1'b1) begin
           memory[address] = write_data;
        end
    end

    
endmodule