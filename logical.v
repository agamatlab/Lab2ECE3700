module logical(A, B, OA, Y);
  // inputs
  input [31:0] A, B;
  input OA;
  // outputs
  output [31:0] Y;
  
  assign Y = OA ? (A & B) : (A | B);
  /* ADD YOUR CODE ABOVE THIS LINE */
endmodule