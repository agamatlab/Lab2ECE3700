`include "adder.v"
`include "logical.v"

module alu(
    input  [31:0] A,
    input  [31:0] B,
    input  [31:0] imm,
    input         ALUSrc,
    input         BSEL,
    input         CISEL,
    input         LOGICAL_OA,
    input         LogicalOp,
    output reg [31:0] Y,
    output reg        C,
    output reg        V,
    output reg        N,
    output reg        Z
);

  wire [31:0] B_mux  = ALUSrc ? imm : B;
  wire [31:0] B_alu  = BSEL  ? ~B_mux : B_mux;
  wire [31:0] add_out;
  wire [31:0] log_out;
  wire         add_c, add_v;

  adder ad0( .A(A), .B(B_alu), .CIN(CISEL), .Y(add_out), .C(add_c), .V(add_v) );
  logical lo0( .A(A), .B(B_mux), .OA(LOGICAL_OA), .Y(log_out) );

  always @(*) begin
    if (LogicalOp) begin
      Y = log_out;
      C = 1'b0;
      V = 1'b0;
    end else begin
      Y = add_out;
      C = add_c;
      V = add_v;
    end
    N = Y[31];
    Z = (Y == 32'd0);
  end

endmodule
