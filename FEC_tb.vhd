library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FEC_tb is						--works in streaming but problems with valid signal
end FEC_tb;

architecture behav of FEC_tb is

component FEC
	port(
		clk50, clk100, reset, ready, data_in: in std_logic;
		valid, data_out: out std_logic
	);
end component;

--clock period
constant PERIOD1: time := 20 ns;
constant PERIOD2: time := 10 ns;
--internal signals
signal clk50: std_logic := '0';
signal clk100: std_logic := '1';
signal reset, valid, ready: std_logic;
constant data_in_reg: std_logic_vector(95 downto 0) := X"558AC4A53A1724E163AC2BF9";
constant data_out_reg: std_logic_vector(191 downto 0) := X"2833E48D392026D5B6DC5E4AF47ADD29494B6C89151348CA";
signal data_in, data_out: std_logic;
signal tmp, tmp2, tmp3: std_logic_vector(191 downto 0);

begin
--unit under test
uut: FEC
	PORT MAP (
		clk50 => clk50,
		clk100 => clk100,
		reset => reset,
		data_in => data_in,
		data_out => data_out,
		ready => ready,
		valid => valid
		);

clk50 <= not clk50 after PERIOD1/2;
clk100 <= not clk100 after PERIOD2/2;

stimulus : process
	begin
		ready <= '0';
		reset <= '1';
		wait for (3*period1);
		reset <= '0';
		ready <= '1';
		for i in 0 to 95 loop
			data_in <= data_in_reg(95-i);
			wait for (1*period1);
		end loop;
		-- for i in 0 to 95 loop
			 -- data_in <= data_in_reg(95-i);
			 -- wait for (1*period1);
		-- end loop;
		 -- for i in 0 to 95 loop
			 -- data_in <= data_in_reg(95-i);
			 -- wait for (1*period1);
		 -- end loop;
		 -- for i in 0 to 95 loop
			 -- data_in <= data_in_reg(95-i);
			 -- wait for (1*period1);
		 -- end loop;
		ready <= '0';
		
		wait;
end process stimulus;

--verifier
process
begin
	--check reset
	wait until (valid = '1');
	wait until falling_edge(clk100);
	for j in 0 to 191 loop
		if (valid = '1') then
			tmp(191-j) <= data_out;
		end if;
		wait for (1*period2);
	end loop;
	-- for j in 0 to 191 loop
		-- if (valid = '1') then
			-- tmp2(191-j) <= data_out;
		-- end if;
		-- wait for (1*period2);
	-- end loop;
	-- wait until (valid = '1');
	-- wait until falling_edge(clk100);
	-- for j in 0 to 191 loop
		-- if (valid = '1') then
			-- tmp3(191-j) <= data_out;
		-- end if;
		-- wait for (1*period2);
	-- end loop;
	wait until falling_edge(clk100);
	assert (data_out_reg=tmp)
		report"TEST FAILED"
		severity note;
end process;
end behav;