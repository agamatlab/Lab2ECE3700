module decoder(Instruction, Opcode, IMM, funct7,rs2,rs1,rd,funct3, BR_EQ, BR_NQ, LOAD, STORE);

    input [31:0] Instruction;
    output reg [6:0] Opcode;
    output [31:0] IMM;
    output reg [6:0] funct7;
    output reg [2:0] funct3;
    output reg [4:0] rs1;
    output reg [4:0] rs2;
    output reg [4:0] rd;
    output reg BR_EQ = 1'b0;
    output reg BR_NQ = 1'b0;
    output reg LOAD = 1'b0;
    output reg STORE = 1'b0;


    wire [6:0] RType = 7'b0110011;
    wire [6:0] IType = 7'b0010011; // Not including Load
    wire [6:0] LType = 7'b0000011; // Load type
    wire [6:0] SType = 7'b0100011; // Store type
    wire [6:0] BType = 7'b1100011; // Branch type

    reg [31:0] tempIMM;


    always @(*) begin
        LOAD = 1'b0;
        STORE = 1'b0;
        
        case (Opcode)
            RType: begin
                funct7 = Instruction[31:25];
                rs2= Instruction[24:20];
                rs1= Instruction[19:15];
                funct3= Instruction[14:12];
                rd= Instruction[11:7];
            end

            IType, LType: begin
                tempIMM = { {20{Instruction[31]}} ,Instruction[31:20]};
                rs1= Instruction[19:15];
                funct3= Instruction[14:12];
                rd= Instruction[11:7];
                
                if (Opcode == LType) begin
                    LOAD = 1'b1;
                    funct3= 3'b000;
                    Opcode = 7'b0110011;

                    if (tempIMM[31] == 1'b1) begin // if negative
                        funct7= 7'b0100000;
                    end else begin // If positive
                        funct7= 7'b0000000;
                    end
                
                end
            end 
   
            SType: begin
                tempIMM = { {20{Instruction[31]}} ,Instruction[31:25], Instruction[11:7]};
                rs2= Instruction[24:20];
                rs1= Instruction[19:15];
                funct3= 3'b000;
                Opcode = 7'b0110011;

                if (tempIMM[31] == 1'b1) begin // if negative
                    funct7= 7'b0100000;
                end else begin // If positive
                    funct7= 7'b0000000;
                end

                STORE = 1'b1;

            end

            BType: begin
                tempIMM = { {21{Instruction[31]}} ,Instruction[7], Instruction[30:25], Instruction[10:8]};
                rs2= Instruction[24:20];
                rs1= Instruction[19:15];

                funct3 = 3'b000; // subtraction opeation
                funct7 = 7'b0100000;
                Opcode = 7'b0110011;

                if (funct3 == 3'b000) begin
                    BR_EQ = 1'b1;
                end else if (funct3 == 3'b001) begin
                    BR_NQ = 1'b1;
                end
                
            end

            default: begin
                tempIMM = 0;
                rs1=0;
                rs2=0;
                rd=0;
                funct3=0;
                funct7=0;
            end
        endcase
        
    end

endmodule
