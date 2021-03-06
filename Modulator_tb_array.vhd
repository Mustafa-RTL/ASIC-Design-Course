library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity Modulator_tb is
end Modulator_tb;

architecture behav of Modulator_tb is

component Modulator
	port(
		clk50, clk100, reset, ready, data_in: in std_logic;
		valid: out std_logic;
		Q, I: out std_logic_vector(15 downto 0)
	);
end component;

--clock period
constant PERIOD1: time := 10 ns;
constant PERIOD2: time := 20 ns;
--internal signals
signal clk50: std_logic := '0';
signal clk100: std_logic := '0';
signal reset, valid, ready: std_logic;
constant data_in_reg: std_logic_vector(191 downto 0) := X"4B047DFA42F2A5D5F61C021A5851E9A309A24FD58086BD1E";
signal data_in: std_logic;
signal Q, I: std_logic_vector(15 downto 0);
--signal tmp1,tmp2 : std_logic_vector(15 downto 0);
file qfile: text open read_mode is "q.txt";
file ifile: text open read_mode is "i.txt";

begin
--unit under test
uut: Modulator
	PORT MAP (
		clk50 => clk50,
		clk100 => clk100,
		reset => reset,
		data_in => data_in,
		Q => Q,
		I => I,
		ready => ready,
		valid => valid
		);

clk50 <= not clk50 after PERIOD2/2;
clk100 <= not clk100 after PERIOD1/2;

stimulus : process
	begin
		reset <= '0';
		ready <= '1';
		for i in 0 to 191 loop
			data_in <= data_in_reg(191-i);
			wait for (1*period1);
		end loop;
		ready <= '0';
		wait;
end process stimulus;

--read qfile
process
variable VectorLine: Line;
variable Qvector: std_logic_vector(15 downto 0);
variable counter: integer range 0 to 1000;
begin
	wait until (valid='1');
	wait until falling_edge(clk50);
	write(output, LF & "------------Test Starts-----------" & LF);
	while not endfile (qfile) loop
		counter := counter + 1;
		readline(qfile, VectorLine);
		read(VectorLine, Qvector);
		wait for (period2/2);
		if (Q /= Qvector) then
			write(output, LF & "test failed Qbit" & integer'image(counter) & LF);
		else
			write(output, LF & "PASSED" & LF);
		end if;
		wait for (period2/2);
		next;
	end loop;
	-- report"Qpassed"
		-- severity note;
end process;

--read ifile
process
variable VectorLine: Line;
variable Ivector: std_logic_vector(15 downto 0);
variable counter: integer range 0 to 1000;
begin
	wait until (valid='1');
	wait until falling_edge(clk50);
	write(output, LF & "------------Test Starts-----------" & LF);
	while not endfile (ifile) loop
		counter := counter + 1;
		readline(ifile, VectorLine);
		read(VectorLine, Ivector);
		wait for (period2/2);
		if (I /= Ivector) then
			write(output, LF & "test failed Ibit" & integer'image(counter) & LF);
		else
			write(output, LF & "PASSED" & LF);
		end if;
		wait for (period2/2);
		next;
	end loop;
	-- report"Ipassed"
		-- severity note;
end process;
end behav;