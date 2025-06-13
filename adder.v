module adder(A, B, CIN, Y, C, V);
  // inputs
  input [31:0] A;
  input [31:0] B;
  input CIN;
  
  // outputs
  output [31:0] Y;
  output C;         // Carry out
  output V;         // Overflow
  
  // internal wires for carry propagation
  wire [32:0] carry;
  wire [31:0] sum;
  
  // Set initial carry-in
  assign carry[0] = CIN;
  
  // Ripple-carry adder implementation
  // For each bit position, generate sum and carry
  genvar i;
  generate
    for (i = 0; i < 32; i = i + 1) begin : ripple_carry
      // Sum is A XOR B XOR carry_in
      assign sum[i] = A[i] ^ B[i] ^ carry[i];
      
      // Carry is generated when at least two inputs are 1
      assign carry[i+1] = (A[i] & B[i]) | (A[i] & carry[i]) | (B[i] & carry[i]);
    end
  endgenerate
  
  // Output assignments
  assign Y = sum;
  assign C = carry[32]; // Final carry out
  
  // Overflow detection - occurs when the sign of the result differs from
  // the sign of the inputs when both inputs have the same sign
  assign V = (A[31] == B[31]) & (Y[31] != A[31]);
  
endmodule