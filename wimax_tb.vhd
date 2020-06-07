library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity wimax_tb is
end wimax_tb;

architecture behav of wimax_tb is

component integrated
	port(
      clk50, clk100, reset, ready, load: in std_logic;
	  data_in: in std_logic;
	  valid: out std_logic;
	  Q, I: out std_logic_vector(15 downto 0)
   );
end component;

--clock period
constant PERIOD1: time := 10 ns;
constant PERIOD2: time := 20 ns;
--internal signals
signal clk50: std_logic := '0';
signal clk100: std_logic := '1';
signal reset, valid, ready, load: std_logic;
constant data_in_reg: std_logic_vector(191 downto 0) := X"4B047DFA42F2A5D5F61C021A5851E9A309A24FD58086BD1E";
signal data_in: std_logic;
signal Q, I: std_logic_vector(15 downto 0);
--signal tmp1,tmp2 : std_logic_vector(15 downto 0);
file qfile: text;
file ifile: text;

begin
--unit under test
uut: integrated
	PORT MAP (
		clk50 => clk50,
		clk100 => clk100,
		reset => reset,
		data_in => data_in,
		load => load,
		Q => Q,
		I => I,
		ready => ready,
		valid => valid
		);
clk50 <= not clk50 after PERIOD2/2;
clk100 <= not clk100 after PERIOD1/2;

stimulus : process			--needs modification after modifying randomizer for streaming
	begin
		reset <= '1';
		ready <= '1';
		load <= '0';
		wait for (3*period2);
		reset <= '0';
		load <= '1';
		wait for (1*period2);
		load <= '0';
		for i in 0 to 95 loop
			data_in <= data_in_reg(95-i);
			wait for (1*period2);
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
	wait for (period2);
	wait until falling_edge(clk50);
	write(output, LF & "------------Test Starts-----------" & LF);
	file_open(qfile, "C:/Users/mustafamohammed_auc/Desktop/ASIC_final/q.txt",  read_mode);
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
	file_close(qfile);
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
	wait for (period2);
	wait until falling_edge(clk50);
	write(output, LF & "------------Test Starts-----------" & LF);
	file_open(ifile, "C:/Users/mustafamohammed_auc/Desktop/ASIC_final/i.txt",  read_mode);
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
	file_close(ifile);
	-- report"Ipassed"
		-- severity note;
end process;
end behav;