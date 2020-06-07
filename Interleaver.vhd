library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Interleaver is
	port(
		clk100, reset, ready, data_in: in std_logic;
		valid, data_out: out std_logic
	);
end Interleaver;

architecture Interleaver_arch of Interleaver is

type state_type_buffer is
	(word_one, word_two);
subtype vector is std_logic_vector(11 downto 0);
signal output: std_logic_vector(191 downto 0);
signal state_buffer, state_buffer_nxt: state_type_buffer;
signal pp_buffer: std_logic_vector(383 downto 0);
signal buffer_ctr1, buffer_ctr2: integer range 0 to pp_buffer'length-1;
signal opcounter: integer range 0 to output'length-1;
begin
	--buffer counter
	process(clk100, reset)
	begin
		if (reset = '1') then
			buffer_ctr1 <= 0;
		elsif (rising_edge(clk100) and ready = '1') then
			if (buffer_ctr1 < 383) then
				buffer_ctr1 <= buffer_ctr1 + 1;
			else
				buffer_ctr1 <= 0;
			end if;
		end if;
	end process;
	
	--pingpong buffer
	process(clk100, reset)
	begin
		if (reset = '1') then
			pp_buffer <= (others=>'0');
		elsif (rising_edge(clk100) and ready = '1') then
			pp_buffer(buffer_ctr1) <= data_in;
		end if;
	end process;

	--which word to read from buffer (state)
	process(clk100, reset)
	begin
		if (reset = '1') then
			state_buffer <= word_two;
		elsif rising_edge(clk100) then
			state_buffer <= state_buffer_nxt;
		end if;
	end process;
	
	--which word to read from buffer (state logic)
	process(buffer_ctr1)
	begin
		if(buffer_ctr1 > 191) then
			state_buffer_nxt <= word_one;
		else
			state_buffer_nxt <= word_two;
		end if;
	end process;

	--counter2
	process(clk100, reset)									--this is where to check valids
	begin
		if (reset = '1') then
			buffer_ctr2 <= 0;
			opcounter <= 0;
			valid <= '0';
		elsif rising_edge(clk100) then
			valid <= '0';
			opcounter <= 0;
			case state_buffer is
				when word_one =>
					if (buffer_ctr2 < 192) then
						buffer_ctr2 <= buffer_ctr2 + 1;
						if (buffer_ctr2 < 191) then
							opcounter <= opcounter + 1;
							valid <= '1';
						end if;
					elsif (buffer_ctr2 >383) then
						buffer_ctr2 <= 0;
					end if;
				when word_two =>
					if (buffer_ctr2 > 191 and buffer_ctr2 < 384) then	--different from FEC but pretty much the same
						if (buffer_ctr2 < 383) then
							buffer_ctr2 <= buffer_ctr2 + 1;
							if (buffer_ctr2 < 191) then
							opcounter <= opcounter + 1;
							end if;
						else
							buffer_ctr2 <= 0;
						end if;
						valid <= '1';
					end if;
			end case;
		end if;
	end process;

	--interleaving
	process(state_buffer, pp_buffer)
	begin
		case state_buffer is
			when word_one =>
				for i in 0 to 191 loop
					output(12*(i mod 16)+(i/16)) <= pp_buffer(i);
				end loop;
			when word_two =>
				for i in 192 to 383 loop
					output(12*((i-192) mod 16)+((i-192)/16)) <= pp_buffer(i);
				end loop;
		end case;
	end process;

	--Output
	process(clk100, reset)
	begin
		if (reset = '1') then
			data_out <= '0';
		elsif rising_edge(clk100) then
			data_out <= output(opcounter);
		end if;
	end process;
end Interleaver_arch;