library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity integrated is
   port(
      clk50, clk100, reset, ready, load: in std_logic;
	  data_in: in std_logic;
	  valid: out std_logic;
	  Q, I: out std_logic_vector(15 downto 0)
   );
end integrated;

architecture wimax_arch of integrated is

component Randomizer
	port(
		clk50, reset, rand_in_ready, load: in std_logic;
		rand_in: in std_logic;
		rand_out_valid, rand_out: out std_logic
	);
end component;

component FEC
	port(
		clk50, clk100, reset, ready, data_in: in std_logic;
		valid, data_out: out std_logic
	);
end component;

component Interleaver
	port(
		clk100, reset, ready, data_in: in std_logic;
		valid, data_out: out std_logic
	);
end component;

component Modulator
	port(
		clk50, clk100, reset, ready, data_in: in std_logic;
		valid: out std_logic;
		Q, I: out std_logic_vector(15 downto 0)
	);
end component;

signal Rd_valid, Fec_valid, Interleaver_valid: std_logic;
signal Rd_out, Fec_out, Interleaver_out: std_logic;

begin
--randomizer
Rd: Randomizer
	PORT MAP (
		clk50 => clk50,
		reset => reset,
		load => load,
		rand_in => data_in,
		rand_out => Rd_out,
		rand_in_ready => ready,
		rand_out_valid => Rd_valid
		);

--Fec
F: FEC
	PORT MAP (
		clk50 => clk50,
		clk100 => clk100,
		reset => reset,
		data_in => Rd_out,
		data_out => Fec_out,
		ready => Rd_valid,
		valid => Fec_valid
		);

--Interleaver
interl: Interleaver
	PORT MAP (
		clk100 => clk100,
		reset => reset,
		data_in => Fec_out,
		data_out => Interleaver_out,
		ready => Fec_valid,
		valid => Interleaver_valid
		);

--modulator
modul: Modulator
	PORT MAP (
		clk50 => clk50,
		clk100 => clk100,
		reset => reset,
		data_in => Interleaver_out,
		Q => Q,
		I => I,
		ready => Interleaver_valid,
		valid => valid
		);

end wimax_arch;