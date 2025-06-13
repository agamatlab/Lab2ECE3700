module InstructionMemory(
    input  [31:0] pc,
    output [31:0] instruction
);
    reg [31:0] instMem [0:255];
    initial $readmemh("instructions.mem", instMem);
    assign instruction = instMem[pc[31:2]];
endmodule
