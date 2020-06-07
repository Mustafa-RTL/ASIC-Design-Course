library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FEC is
	port(
		clk50, clk100, reset, ready, data_in: in std_logic;
		valid, data_out: out std_logic
	);
end FEC;

architecture fec_arch of FEC is

type state_type_buffer is
	(word_one, word_two);
type state_type_output is
	(X,Y);
signal state_out, state_out_nxt: state_type_output;
signal state_buffer, state_buffer_nxt: state_type_buffer;
signal pp_buffer: std_logic_vector(191 downto 0);
signal shft_reg, shft_reg_nxt: std_logic_vector(5 downto 0);
signal Xo,Yo: std_logic;
signal buffer_ctr1, buffer_ctr2: integer range 0 to pp_buffer'length-1;
begin
	--counter1
	process(clk50, reset)
	begin
		if (reset = '1') then
			buffer_ctr1 <= 0;
		elsif (rising_edge(clk50) and ready = '1') then
			buffer_ctr1 <= buffer_ctr1 + 1;
		end if;
	end process;

	--counter2
	process(clk50, reset)
	begin
		if (reset = '1') then
			buffer_ctr2 <= 1;
			valid <= '0';
		elsif rising_edge(clk50) then
			valid <= '0';
			case state_buffer is
				when word_one =>
					if (buffer_ctr2 < 96) then
						buffer_ctr2 <= buffer_ctr2 + 1;
						valid <= '1';
					end if;
				when word_two =>
					if (buffer_ctr2 > 95 and buffer_ctr2 < 192) then
						buffer_ctr2 <= buffer_ctr2 + 1;
						valid <= '1';
					end if;
			end case;
		end if;
	end process;
	
	--pingpong buffer
	process(clk50, reset)
	begin
		if (reset = '1') then
			pp_buffer <= (others=>'0');
		elsif (rising_edge(clk50) and ready = '1') then
			pp_buffer(buffer_ctr1) <= data_in;
		end if;
	end process;

	--which word to read from buffer (state)
	process(clk50, reset)
	begin
		if (reset = '1') then
			state_buffer <= word_two;
		elsif rising_edge(clk50) then
			state_buffer <= state_buffer_nxt;
		end if;
	end process;
	
	--which word to read from buffer (state logic)
	process(buffer_ctr1)
	begin
		if(buffer_ctr1 > 95) then
			state_buffer_nxt <= word_one;
		else
			state_buffer_nxt <= word_two;
		end if;
	end process;
	
	--shift register
	process(clk50, reset)
	begin
		if (reset = '1') then
			shft_reg <= (others=>'0');
		elsif rising_edge(clk50) then
			shft_reg <= shft_reg_nxt;
		end if;
	end process;
	
	--shifting
	process(pp_buffer, buffer_ctr1)
	begin
		if (buffer_ctr1 = 96) then
			shft_reg_nxt <= pp_buffer(95 downto 90);
		elsif (buffer_ctr1 = 0) then
			shft_reg_nxt <= pp_buffer(191 downto 186);
		else
			shft_reg_nxt <= pp_buffer(buffer_ctr2-1) & shft_reg(5 downto 1);
		end if;
	end process;
	
	--Xo & Yo
	process(shft_reg, buffer_ctr2, pp_buffer)
	begin
		Xo <= pp_buffer(buffer_ctr2-1) xor shft_reg(0) xor shft_reg(1) xor shft_reg(2) xor shft_reg(5);
		Yo <= pp_buffer(buffer_ctr2-1) xor shft_reg(1) xor shft_reg(2) xor shft_reg(4) xor shft_reg(5);
	end process;

	--output states
	process(clk100, reset)
	begin
		if (reset = '1') then
			state_out <= X;
		elsif rising_edge(clk100) then
			state_out <= state_out_nxt;
		end if;
	end process;

	--output states logic
	process(state_out)
	begin
		case state_out is
			when X =>
				state_out_nxt <= Y;
			when Y =>
				state_out_nxt <= X;
		end case;
	end process;

	--output
	process(clk100, reset)
	begin
		if (reset = '1') then
			data_out <= '0';
		elsif (rising_edge(clk100) and state_out = X) then
			data_out <= xo;
		elsif (rising_edge(clk100) and state_out = Y) then
			data_out <= yo;
		end if;
	end process;
end fec_arch;