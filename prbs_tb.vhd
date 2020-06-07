library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity prbs_tb is
end prbs_tb;

architecture behav of prbs_tb is

component prbs
	port(
		clk, reset, en, load: in std_logic;
		seed: in std_logic_vector(14 downto 0);
		data_in: in std_logic;
		data_out: out std_logic
	);
end component;

--clock period
constant PERIOD: time := 100 ns;
--internal signals
signal clk: std_logic := '0';
signal reset, en, load: std_logic;
signal seed: std_logic_vector(14 downto 0) := "101010001110110";
constant data_in_reg: std_logic_vector(95 downto 0) := X"ACBCD2114DAE1577C6DBF4C9";
constant data_out_reg: std_logic_vector(95 downto 0) := X"558AC4A53A1724E163AC2BF9";
signal data_in, data_out: std_logic;
signal tmp : std_logic_vector(95 downto 0);

begin
--unit under test
uut: prbs
	PORT MAP (
		clk => clk,
		reset => reset,
		en => en,
		load => load,
		seed => seed,
		data_in => data_in,
		data_out => data_out
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
		for i in 0 to 95 loop
			--wait for (1*period);
			data_in <= data_in_reg(95-i);
			wait for (1*period);
		end loop;
		wait;
end process stimulus;

--verifier
process
begin
	--check reset
	wait until (reset = '1');
	wait until falling_edge(clk);
	assert (data_out='0')
		report "reset failed"
		severity note;
	--verify data
	wait until (load='1');
	wait until (load='0');
	wait until falling_edge(clk);
	for j in 0 to 95 loop
		tmp(95-j) <= data_out;
		wait for (1*period);
	end loop;
	wait until falling_edge(clk);
	assert (data_out_reg=tmp)
		report"TEST FAILED"
		severity note;
end process;
end behav;