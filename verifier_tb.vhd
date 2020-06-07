library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity verifier_tb is
end verifier_tb;

architecture behav1 of verifier_tb is

component prbs_verify
	port(
		clk, reset, en, load: in std_logic;
		pass: out std_logic
	);
end component;

--clock period
constant PERIOD: time := 100 ns;
--internal signals
signal clk: std_logic := '0';
signal reset: std_logic := '0';
signal en: std_logic := '1';
signal load, pass: std_logic;

begin
--unit under test
uut: prbs_verify
	PORT MAP (
		clk => clk,
		reset => reset,
		en => en,
		load => load,
		pass => pass
		);

clk <= not clk after PERIOD/2;

stimulus : process
	begin
	reset <= '1';
	en <= '1';
	load <= '0';
	wait for (3*period);
	reset <= '0';
	load <= '1';
	wait for (1*period);
	load <= '0';
	wait;
end process stimulus;

--verifier
process
begin
	wait on pass;
	assert (pass='1')
		report"VERIFIER FAILED"
		severity note;
end process;
end behav1;