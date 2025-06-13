module control(
    input  [6:0] OP,
    input  [6:0] funct7,
    input  [2:0] funct3,
    output reg ALUSrc,
    output reg BSEL,
    output reg CISEL,
    output reg LOGICAL_OA,
    output reg LogicalOp,
    output reg MemRead,
    output reg MemWrite,
    output reg RegWrite,
    output reg Branch,
    output reg Jump,
    output reg MemtoReg
);
    localparam BSEL_B  = 1'b0;
    localparam BSEL_BN = 1'b1;
    localparam OP_ARTH   = 7'b0110011;
    localparam OP_ADDI   = 7'b0010011;
    localparam OP_LOAD   = 7'b0000011;
    localparam OP_SW     = 7'b0100011;
    localparam OP_BRANCH = 7'b1100011;

    always @(*) begin
        case(OP)
            OP_ARTH: begin
                ALUSrc     = 1'b0;
                MemRead    = 1'b0;
                MemWrite   = 1'b0;
                RegWrite   = 1'b1;
                Branch     = 1'b0;
                Jump       = 1'b0;
                MemtoReg   = 1'b0;
                case(funct3)
                    3'b000: begin
                        LogicalOp  = 1'b0;
                        LOGICAL_OA = 1'b0;
                        if(funct7 == 7'b0000000) begin
                            BSEL  = BSEL_B;
                            CISEL = 1'b0;
                        end else begin
                            BSEL  = BSEL_BN;
                            CISEL = 1'b1;
                        end
                    end
                    3'b110: begin
                        LogicalOp  = 1'b1;
                        LOGICAL_OA = 1'b0;
                        BSEL       = BSEL_B;
                        CISEL      = 1'b0;
                    end
                    3'b111: begin
                        LogicalOp  = 1'b1;
                        LOGICAL_OA = 1'b1;
                        BSEL       = BSEL_B;
                        CISEL      = 1'b0;
                    end
                    default: begin
                        LogicalOp  = 1'b0;
                        LOGICAL_OA = 1'b0;
                        BSEL       = BSEL_B;
                        CISEL      = 1'b0;
                        RegWrite   = 1'b0;
                    end
                endcase
            end

            OP_ADDI: begin
                ALUSrc     = 1'b1;
                BSEL       = BSEL_B;
                CISEL      = 1'b0;
                LOGICAL_OA = 1'b0;
                LogicalOp  = 1'b0;
                MemRead    = 1'b0;
                MemWrite   = 1'b0;
                RegWrite   = 1'b1;
                Branch     = 1'b0;
                Jump       = 1'b0;
                MemtoReg   = 1'b0;
            end

            OP_LOAD: begin
                ALUSrc     = 1'b1;
                BSEL       = BSEL_B;
                CISEL      = 1'b0;
                LOGICAL_OA = 1'b0;
                LogicalOp  = 1'b0;
                MemRead    = 1'b1;
                MemWrite   = 1'b0;
                RegWrite   = 1'b1;
                Branch     = 1'b0;
                Jump       = 1'b0;
                MemtoReg   = 1'b1;
            end

            OP_SW: begin
                ALUSrc     = 1'b1;
                BSEL       = BSEL_B;
                CISEL      = 1'b0;
                LOGICAL_OA = 1'b0;
                LogicalOp  = 1'b0;
                MemRead    = 1'b0;
                MemWrite   = 1'b1;
                RegWrite   = 1'b0;
                Branch     = 1'b0;
                Jump       = 1'b0;
                MemtoReg   = 1'b0;
            end

            OP_BRANCH: begin
                ALUSrc     = 1'b0;
                BSEL       = BSEL_B;
                CISEL      = 1'b0;
                LOGICAL_OA = 1'b0;
                LogicalOp  = 1'b0;
                MemRead    = 1'b0;
                MemWrite   = 1'b0;
                RegWrite   = 1'b0;
                Branch     = 1'b1;
                Jump       = 1'b0;
                MemtoReg   = 1'b0;
            end

            default: begin
                ALUSrc     = 1'b0;
                BSEL       = BSEL_B;
                CISEL      = 1'b0;
                LOGICAL_OA = 1'b0;
                LogicalOp  = 1'b0;
                MemRead    = 1'b0;
                MemWrite   = 1'b0;
                RegWrite   = 1'b0;
                Branch     = 1'b0;
                Jump       = 1'b0;
                MemtoReg   = 1'b0;
            end
        endcase
    end
endmodule
