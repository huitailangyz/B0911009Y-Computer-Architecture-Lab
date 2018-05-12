// Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module lcd_module(clk, resetn, display_valid, display_name, display_value, display_number, input_valid, input_value, lcd_rst, lcd_cs, lcd_rs, lcd_wr, lcd_rd, lcd_data_io, lcd_bl_ctr, ct_int, ct_sda, ct_scl, ct_rstn);
  input clk;
  input resetn;
  input display_valid;
  input [39:0]display_name;
  input [31:0]display_value;
  output [5:0]display_number;
  output input_valid;
  output [31:0]input_value;
  output lcd_rst;
  output lcd_cs;
  output lcd_rs;
  output lcd_wr;
  output lcd_rd;
  inout [15:0]lcd_data_io;
  output lcd_bl_ctr;
  inout ct_int;
  inout ct_sda;
  output ct_scl;
  output ct_rstn;
endmodule
