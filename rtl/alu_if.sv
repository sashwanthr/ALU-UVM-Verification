// ============================================================
// alu_if.sv — SystemVerilog Interface for ALU
// ============================================================
interface alu_if (input logic clk);
  logic [7:0] A;
  logic [7:0] B;
  logic [2:0] opcode;
  logic [7:0] result;
endinterface
