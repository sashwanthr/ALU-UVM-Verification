// ============================================================
// design.sv — 8-bit ALU (Add / Sub / AND)
// ============================================================
module alu (
  input  logic        clk,
  input  logic [7:0]  A,
  input  logic [7:0]  B,
  input  logic [2:0]  opcode,
  output logic [7:0]  result
);

  always_comb begin
    case (opcode)
      3'b000:  result = A + B;   // Addition
      3'b001:  result = A - B;   // Subtraction
      3'b010:  result = A & B;   // Bitwise AND
      default: result = 8'd0;
    endcase
  end

endmodule
