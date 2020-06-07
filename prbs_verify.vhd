library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity prbs_verify is
   port(
      clk, reset, en, load: in std_logic;
	  pass: out std_logic
   );
end prbs_verify;

architecture prbs_verify_arch of prbs_verify is

constant seed_rom : std_logic_vector(14 downto 0) := "101010001110110";
constant in_data_rom : std_logic_vector(95 downto 0) := X"ACBCD2114DAE1577C6DBF4C9";
constant out_data_rom : std_logic_vector(95 downto 0) := X"558AC4A53A1724E163AC2BF9";
signal counter: integer range 0 to 96;
signal r_reg_out : std_logic_vector(95 downto 0) ;--:= (others=>'0');
signal r_next_out: std_logic_vector(95 downto 0);
signal data_in, data_out, load_s, load_sd, edge_detect : std_logic;
--signal ctr : std_logic_vector(1 downto 0);
--signal ctr_next : std_logic_vector(1 downto 0);


component prbs port(
	clk, reset, en, load: in std_logic;
    seed: in std_logic_vector(14 downto 0);
	data_in: in std_logic;
	data_out: out std_logic);
end component;

begin
P1 : prbs port map(
	clk => clk,
	reset => reset,
	en => en,
	load => load,
	seed => seed_rom,
	data_in => data_in,
	data_out => data_out);

--verify logic (shift left register)
process(clk, reset)
begin
	if (reset='1') then
		r_reg_out <= (others=>'0');
	elsif (rising_edge(clk) and en='1') then
		r_reg_out <= r_next_out;
		data_in <= in_data_rom(counter);
		if (edge_detect = '1') then
			counter <= 1;		
		elsif (counter <= 95) then
			counter <= counter + 1;
		end if;
	end if;
end process;

--load negative edge detection
process(clk, reset)
begin
	if (reset = '1') then
		load_s <= '0';
		load_sd <= '0';
	elsif (rising_edge(clk) and en='1') then
		load_s <= load;
		load_sd <= load_s;
	end if;
end process;
edge_detect <= not load_s and load_sd;

--nextstate logic
process(counter, r_reg_out, data_out, reset, load)
begin
	if (load = '1') then
		r_next_out <= (others=>'0');
	elsif (counter <= 95 and reset = '0') then
		r_next_out <= r_reg_out(94 downto 0) & data_out;
	else
		r_next_out <= r_reg_out;
	end if;
end process;

--verifying
process(counter, r_reg_out)
begin
	if (counter > 95) then
		if (r_reg_out = out_data_rom) then	
			pass <= '1';
		else
			pass <= '0';
		end if;
	end if;
end process;

end prbs_verify_arch;