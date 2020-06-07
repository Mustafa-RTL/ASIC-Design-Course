library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity prbs is
   port(
      clk, reset, en, load: in std_logic;
      seed: in std_logic_vector(14 downto 0);
	  data_in: in std_logic;
	  data_out: out std_logic
   );
end prbs;

architecture prbs_arch of prbs is

signal r_reg : std_logic_vector(14 downto 0); --:= "101010001110110";
signal r_next : std_logic_vector(14 downto 0);
begin
	--seed load & nextstate logic
	process(load,r_reg,seed)
	begin
		if (load='1') then
			r_next <= seed;
		else
			r_next <= r_reg(13 downto 0) & (r_reg(14) xor r_reg(13));
		end if;
	end process;
	-- register
	process(clk,reset)
	begin
		if (reset='1') then						--active high reset
			r_reg <= (others=>'0');
			data_out <= '0';
		elsif (rising_edge(clk) and en='1') then
			r_reg <= r_next;
			data_out <= data_in xor (r_reg(14) xor r_reg(13));		-- output has to be synchronous!!!!!!!
		end if;
	end process;
end prbs_arch;