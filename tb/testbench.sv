`timescale 1ns/1ps

import uvm_pkg::*;
`include "uvm_macros.svh"

// ============================================================
// Sequence Item
// ============================================================
class alu_seq_item extends uvm_sequence_item;

  rand logic [7:0] A;
  rand logic [7:0] B;
  rand logic [2:0] opcode;
  logic [7:0]      result;

  // Only generate opcodes 0–2 (ADD, SUB, AND)
  constraint opcode_c {
    opcode inside {[0:2]};
  }

  `uvm_object_utils(alu_seq_item)

  function new(string name = "alu_seq_item");
    super.new(name);
  endfunction

endclass


// ============================================================
// Sequence
// ============================================================
class alu_sequence extends uvm_sequence #(alu_seq_item);

  `uvm_object_utils(alu_sequence)

  function new(string name = "alu_sequence");
    super.new(name);
  endfunction

  task body();
    alu_seq_item txn;
    repeat (10) begin
      txn = alu_seq_item::type_id::create("txn");
      start_item(txn);
      assert (txn.randomize());
      finish_item(txn);
    end
  endtask

endclass


// ============================================================
// Driver
// ============================================================
class alu_driver extends uvm_driver #(alu_seq_item);

  virtual alu_if vif;

  `uvm_component_utils(alu_driver)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db #(virtual alu_if)::get(this, "", "vif", vif))
      `uvm_fatal("DRV", "Could not get vif from config DB")
  endfunction

  task run_phase(uvm_phase phase);
    alu_seq_item txn;
    forever begin
      seq_item_port.get_next_item(txn);
      @(posedge vif.clk);
      vif.A      <= txn.A;
      vif.B      <= txn.B;
      vif.opcode <= txn.opcode;
      @(posedge vif.clk);
      seq_item_port.item_done();
    end
  endtask

endclass


// ============================================================
// Monitor
// ============================================================
class alu_monitor extends uvm_monitor;

  virtual alu_if vif;
  uvm_analysis_port #(alu_seq_item) ap;

  `uvm_component_utils(alu_monitor)

  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db #(virtual alu_if)::get(this, "", "vif", vif))
      `uvm_fatal("MON", "Could not get vif from config DB")
  endfunction

  task run_phase(uvm_phase phase);
    alu_seq_item txn;
    forever begin
      @(posedge vif.clk);
      #1;  // small delta to let combinational outputs settle
      txn        = alu_seq_item::type_id::create("txn");
      txn.A      = vif.A;
      txn.B      = vif.B;
      txn.opcode = vif.opcode;
      txn.result = vif.result;
      ap.write(txn);
    end
  endtask

endclass


// ============================================================
// Scoreboard
// ============================================================
class alu_scoreboard extends uvm_component;

  uvm_analysis_imp #(alu_seq_item, alu_scoreboard) imp;

  `uvm_component_utils(alu_scoreboard)

  function new(string name, uvm_component parent);
    super.new(name, parent);
    imp = new("imp", this);
  endfunction

  function void write(alu_seq_item txn);
    logic [7:0] expected;

    case (txn.opcode)
      3'b000:  expected = txn.A + txn.B;
      3'b001:  expected = txn.A - txn.B;
      3'b010:  expected = txn.A & txn.B;
      default: expected = 8'd0;
    endcase

    if (expected == txn.result)
      `uvm_info("SCOREBOARD",
        $sformatf("PASS  A=%0d  B=%0d  opcode=%0d  expected=%0d  actual=%0d",
          txn.A, txn.B, txn.opcode, expected, txn.result),
        UVM_LOW)
    else
      `uvm_error("SCOREBOARD",
        $sformatf("FAIL  A=%0d  B=%0d  opcode=%0d  expected=%0d  actual=%0d",
          txn.A, txn.B, txn.opcode, expected, txn.result))
  endfunction

endclass


// ============================================================
// Agent
// ============================================================
class alu_agent extends uvm_agent;

  alu_driver                     drv;
  alu_monitor                    mon;
  uvm_sequencer #(alu_seq_item)  seqr;

  `uvm_component_utils(alu_agent)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    drv  = alu_driver::type_id::create("drv",  this);
    mon  = alu_monitor::type_id::create("mon",  this);
    seqr = uvm_sequencer #(alu_seq_item)::type_id::create("seqr", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    drv.seq_item_port.connect(seqr.seq_item_export);
  endfunction

endclass


// ============================================================
// Environment
// ============================================================
class alu_env extends uvm_env;

  alu_agent      agent;
  alu_scoreboard sb;

  `uvm_component_utils(alu_env)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agent = alu_agent::type_id::create("agent", this);
    sb    = alu_scoreboard::type_id::create("sb",  this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    agent.mon.ap.connect(sb.imp);
  endfunction

endclass


// ============================================================
// Test
// ============================================================
class alu_test extends uvm_test;

  alu_env env;

  `uvm_component_utils(alu_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = alu_env::type_id::create("env", this);
  endfunction

  task run_phase(uvm_phase phase);
    alu_sequence seq;
    phase.raise_objection(this);
    seq = alu_sequence::type_id::create("seq");
    seq.start(env.agent.seqr);
    phase.drop_objection(this);
  endtask

endclass


// ============================================================
// Top Module
// ============================================================
module top;

  logic clk;

  // 10 ns clock (100 MHz)
  initial  clk = 0;
  always #5 clk = ~clk;

  alu_if vif (.clk(clk));

  alu dut (
    .clk   (clk),
    .A     (vif.A),
    .B     (vif.B),
    .opcode(vif.opcode),
    .result(vif.result)
  );

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, top);
    uvm_config_db #(virtual alu_if)::set(null, "*", "vif", vif);
    run_test("alu_test");
  end

endmodule
