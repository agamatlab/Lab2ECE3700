module decoder(
    input  [31:0] Instruction,
    output reg [6:0]  Opcode,
    output reg [6:0]  funct7,
    output reg [2:0]  funct3,
    output reg [4:0]  rs1,
    output reg [4:0]  rs2,
    output reg [4:0]  rd,
    output reg        BR_EQ,
    output reg        BR_NQ,
    output reg        LOAD,
    output reg        STORE
);
    wire [6:0] RType = 7'b0110011;
    wire [6:0] IType = 7'b0010011;
    wire [6:0] LType = 7'b0000011;
    wire [6:0] SType = 7'b0100011;
    wire [6:0] BType = 7'b1100011;

    always @(*) begin
        Opcode = Instruction[6:0];
        funct7 = 7'b0;
        funct3 = 3'b0;
        rs1    = 5'b0;
        rs2    = 5'b0;
        rd     = 5'b0;
        BR_EQ  = 1'b0;
        BR_NQ  = 1'b0;
        LOAD   = 1'b0;
        STORE  = 1'b0;

        case (Opcode)
            RType: begin
                funct7 = Instruction[31:25];
                rs2    = Instruction[24:20];
                rs1    = Instruction[19:15];
                funct3 = Instruction[14:12];
                rd     = Instruction[11:7];
            end

            IType: begin
                rs1    = Instruction[19:15];
                funct3 = Instruction[14:12];
                rd     = Instruction[11:7];
            end

            LType: begin
                rs1    = Instruction[19:15];
                rd     = Instruction[11:7];
                LOAD   = 1'b1;
            end

            SType: begin
                rs2    = Instruction[24:20];
                rs1    = Instruction[19:15];
                STORE  = 1'b1;
            end

            BType: begin
                rs1    = Instruction[19:15];
                rs2    = Instruction[24:20];
                funct3 = Instruction[14:12];
                if (funct3 == 3'b000)
                    BR_EQ = 1'b1;
                else if (funct3 == 3'b001)
                    BR_NQ = 1'b1;
            end

            default: begin
            end
        endcase
    end
endmodule
