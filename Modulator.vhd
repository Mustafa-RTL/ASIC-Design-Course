library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Modulator is
	port(
		clk50, clk100, reset, ready, data_in: in std_logic;
		valid: out std_logic;
		Q, I: out std_logic_vector(15 downto 0)
	);
end Modulator;

architecture Modulator_arch of Modulator is

subtype vector is std_logic_vector(15 downto 0);
constant sqrt2: vector:= "0101101001111110";
constant neg_sqrt2: vector:= "1010010110000001";
type state_type is
	(Q_state,I_state);
signal state_out, state_out_nxt: state_type;
signal Qo, Io: integer range -1 to 1;
begin
	--output states
	process(clk100, reset)
	begin
		if (reset = '1') then
			state_out <= Q_state;
		elsif (rising_edge(clk100) and ready = '1') then
			state_out <= state_out_nxt;
		end if;
	end process;

	--output states logic
	process(state_out)
	begin
		case state_out is
			when Q_state =>
				state_out_nxt <= I_state;
			when I_state =>
				state_out_nxt <= Q_state;
		end case;
	end process;

	--output signals
	process(clk100, reset)
	begin
		if (reset = '1') then
			valid <= '0';
			Qo <= 0;
			Io <= 0;
		elsif rising_edge(clk100) then
			valid <= '0';
			--Qo <= 0;
			--Io <= 0;
			if (ready = '1') then
				case state_out is
					when Q_state =>
						if (data_in = '0') then
							Qo <= 1;
							valid <= '1';
						elsif (data_in = '1') then
							Qo <= -1;
							valid <= '1';
						end if;
					when I_state =>
						if (data_in = '0') then
							Io <= 1;
							valid <= '1';
						elsif (data_in = '1') then
							Io <= -1;
							valid <= '1';
						end if;
				end case;
			end if;
		end if;
	end process;

	--output Q&I
	process(clk50, reset)
	begin
		if (reset = '1') then
			Q <= (others=>'0');
			I <= (others=>'0');
		elsif rising_edge(clk50) then
			case Qo is
				when 1 =>
					if (Io = 1) then
						Q <= sqrt2;
						I <= sqrt2;
					elsif (Io = -1) then
						Q <= sqrt2;
						I <= neg_sqrt2;
					end if;
				when -1 =>
					if (Io = 1) then
						Q <= neg_sqrt2;
						I <= sqrt2;
					elsif (Io = -1) then
						Q <= neg_sqrt2;
						I <= neg_sqrt2;
					end if;
				when others =>
			end case;
		end if;
	end process;
end Modulator_arch;