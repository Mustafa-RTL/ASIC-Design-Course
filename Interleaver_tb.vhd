library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Interleaver_tb is				--output is delayed one buffer cycle which introduces problems with streaming
end Interleaver_tb;						--can be managed by setting valid signal all the time, output will be correct but delayed one whole buffer cycle

architecture behav of Interleaver_tb is

component Interleaver
	port(
		clk100, reset, ready, data_in: in std_logic;
		valid, data_out: out std_logic
	);
end component;

--clock period
constant PERIOD2: time := 10 ns;
--internal signals
signal clk100: std_logic := '0';
signal reset, valid, ready: std_logic;
constant data_in_reg: std_logic_vector(191 downto 0) := X"2833E48D392026D5B6DC5E4AF47ADD29494B6C89151348CA";
constant data_out_reg: std_logic_vector(191 downto 0) := X"4B047DFA42F2A5D5F61C021A5851E9A309A24FD58086BD1E";
signal data_in, data_out: std_logic;
signal tmp1, tmp2 : std_logic_vector(191 downto 0);

begin
--unit under test
uut: Interleaver
	PORT MAP (
		clk100 => clk100,
		reset => reset,
		data_in => data_in,
		data_out => data_out,
		ready => ready,
		valid => valid
		);

clk100 <= not clk100 after PERIOD2/2;

stimulus : process
	begin
		-- ready <= '0';
		-- reset <= '1';
		-- wait for (3*period2);
		reset <= '0';
		ready <= '1';
		for i in 0 to 191 loop
			data_in <= data_in_reg(191-i);
			wait for (1*period2);
		end loop;
		-- for i in 0 to 191 loop
			-- data_in <= data_in_reg(191-i);
			-- wait for (1*period2);
		-- end loop;
		ready <= '0';
		wait;
end process stimulus;

--verifier
process
begin
	--check reset
	-- wait until (reset = '1');
	-- wait until falling_edge(clk100);
	-- assert (data_out='0')
		-- report "reset failed"
		-- severity note;
	-- --verify data
	-- wait until (ready='1');
	-- wait for (384*period2);
	wait until (valid = '1');
	wait until falling_edge(clk100);
	for j in 0 to 191 loop
		if (valid = '1') then
			tmp1(191-j) <= data_out;
		end if;
		wait for (1*period2);
	end loop;
	-- for j in 0 to 191 loop
		-- if (valid = '1') then
			-- tmp2(191-j) <= data_out;
		-- end if;
		-- wait for (1*period2);
	-- end loop;
	--wait until falling_edge(clk100);
	assert (data_out_reg=tmp1)
		report"TEST FAILED"
		severity note;
end process;
end behav;