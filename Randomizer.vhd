library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Randomizer is
   port(
      clk50, reset, rand_in_ready: in std_logic;
	  rand_in: in std_logic;
	  rand_out_valid, rand_out: out std_logic
   );
end Randomizer;

architecture prbs_arch of Randomizer is

constant seed: std_logic_vector(14 downto 0):= "101010001110110";
signal r_reg : std_logic_vector(14 downto 0);
signal r_next : std_logic_vector(14 downto 0);
signal load : std_logic;
begin
	--seed load & nextstate logic
	process(load,r_reg)
	begin
		if (load='1') then
			r_next <= seed;
		else
			r_next <= r_reg(13 downto 0) & (r_reg(14) xor r_reg(13));
		end if;
	end process;
	-- register
	process(clk50,reset)
	begin
		if (reset='1') then						--active high reset
			r_reg <= (others=>'0');
			rand_out <= '0';
			rand_out_valid <= '0';
			load <= '1';
		elsif rising_edge(clk50) then
			rand_out_valid <= '0';
			if (rand_in_ready = '1') then
				r_reg <= r_next;
				rand_out <= rand_in xor (r_reg(14) xor r_reg(13));
				rand_out_valid <= '1';
				load <= '0';
			end if;
		end if;
	end process;
end prbs_arch;