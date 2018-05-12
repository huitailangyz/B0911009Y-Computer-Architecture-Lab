-- Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity lcd_module is
  Port ( 
    clk : in STD_LOGIC;
    resetn : in STD_LOGIC;
    display_valid : in STD_LOGIC;
    display_name : in STD_LOGIC_VECTOR ( 39 downto 0 );
    display_value : in STD_LOGIC_VECTOR ( 31 downto 0 );
    display_number : out STD_LOGIC_VECTOR ( 5 downto 0 );
    input_valid : out STD_LOGIC;
    input_value : out STD_LOGIC_VECTOR ( 31 downto 0 );
    lcd_rst : out STD_LOGIC;
    lcd_cs : out STD_LOGIC;
    lcd_rs : out STD_LOGIC;
    lcd_wr : out STD_LOGIC;
    lcd_rd : out STD_LOGIC;
    lcd_data_io : inout STD_LOGIC_VECTOR ( 15 downto 0 );
    lcd_bl_ctr : out STD_LOGIC;
    ct_int : inout STD_LOGIC;
    ct_sda : inout STD_LOGIC;
    ct_scl : out STD_LOGIC;
    ct_rstn : out STD_LOGIC
  );

end lcd_module;

architecture stub of lcd_module is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
begin
end;
