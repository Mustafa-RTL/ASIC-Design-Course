library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Rd_tb is								--does not work as intended in streaming
end Rd_tb;

architecture behav of Rd_tb is

component Randomizer
	port(
		clk50, reset, rand_in_ready, load: in std_logic;
		rand_in: in std_logic;
		rand_out_valid, rand_out: out std_logic
	);
end component;

--clock period
constant PERIOD: time := 20 ns;
--internal signals
signal clk50: std_logic := '0';
signal reset, load, rand_out_valid, rand_in_ready: std_logic;
constant data_in_reg: std_logic_vector(95 downto 0) := X"ACBCD2114DAE1577C6DBF4C9";
constant data_out_reg: std_logic_vector(95 downto 0) := X"558AC4A53A1724E163AC2BF9";
signal rand_in, rand_out: std_logic;
signal tmp : std_logic_vector(95 downto 0);

begin
--unit under test
uut: Randomizer
	PORT MAP (
		clk50 => clk50,
		reset => reset,
		load => load,
		rand_in => rand_in,
		rand_out => rand_out,
		rand_in_ready => rand_in_ready,
		rand_out_valid => rand_out_valid
		);

clk50 <= not clk50 after PERIOD/2;

stimulus : process
	begin
		reset <= '1';
		rand_in_ready <= '1';
		load <= '0';
		wait for (3*period);
		reset <= '0';
		load <= '1';
		wait for (1*period);
		load <= '0';
		for i in 0 to 95 loop
			rand_in <= data_in_reg(95-i);
			wait for (1*period);
		end loop;
		rand_in_ready <= '0';
		wait;
end process stimulus;

--verifier
process
begin
	--check reset
	wait until (reset = '1');
	wait until falling_edge(clk50);
	assert (rand_out='0')
		report "reset failed"
		severity note;
	--verify data
	wait until (load='1');
	wait until (load='0');
	wait until falling_edge(clk50);
	for j in 0 to 95 loop
		if (rand_out_valid = '1') then
			tmp(95-j) <= rand_out;
		end if;
		wait for (1*period);
	end loop;
	wait until falling_edge(clk50);
	assert (data_out_reg=tmp)
		report"TEST FAILED"
		severity note;
end process;
end behav;