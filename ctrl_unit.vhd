library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ctrl_unit is 
	generic(noffloors: integer;
		transition_time_sec: integer			--ONLY UP TO 10 SECS
		);
	port(
		clk, reset: in std_logic;
		req: in std_logic_vector(3 downto 0);	--adjust to generic
		floor: out std_logic_vector(3 downto 0);
		OD: out std_logic
	);
end ctrl_unit;

architecture ctrl_unit_arch of ctrl_unit is
type state_type is
	(idle, up, down, open_door);
signal state_reg, state_next: state_type;
signal floor_num, floor_num_new: natural range 0 to noffloors-1;
signal clk_en: std_logic;
signal secs_ctr, secs_ctr_new: std_logic_vector(28 downto 0);

begin
	--state register
	process(clk, reset)
	begin
		if (reset = '1') then
			state_reg <= idle;
		elsif (rising_edge(clk)) then
			state_reg <= state_next;
		end if;
	end process;
	
	--next-state logic
	process(state_reg, floor_num, req, clk_en)
	begin
		state_next <= idle;
		case state_reg is
			when idle =>
				if (floor_num < unsigned(req)) then
					state_next <= up;
				elsif (floor_num > unsigned(req)) then
					state_next <= down;
				end if;
			when up =>
				if (floor_num < unsigned(req)) then
					state_next <= up;
				elsif (floor_num = unsigned(req)) then
					state_next <= open_door;
				end if;
			when down =>
				if (floor_num > unsigned(req)) then
					state_next <= down;
				elsif (floor_num = unsigned(req)) then
					state_next <= open_door;
				end if;
			when open_door =>
				if(clk_en = '0') then
					state_next <= open_door;
				end if;
		end case;
	end process;
	
	--clock enable counter
	process(clk, reset)
	begin
		if (reset = '1') then
			secs_ctr <= (others=>'0');
		elsif (rising_edge(clk)) then
			secs_ctr <= secs_ctr_new;
		end if;
	end process;
	secs_ctr_new <= std_logic_vector(unsigned(secs_ctr)+1) when(unsigned(secs_ctr) < transition_time_sec*50*10**6-1) else (others=>'0');
	clk_en <= '1' when (unsigned(secs_ctr) = 0) else '0';
	
	--floor_num reg
	process(clk, reset)
	begin
		if (reset = '1') then
			floor_num <= 0;
		elsif (rising_edge(clk)) then
			floor_num <= floor_num_new;
		end if;
	end process;
	
	--Moore output logic
	process(state_reg, floor_num, clk_en)
	begin
		floor_num_new <= floor_num;
		OD <= '0';
		case state_reg is
			when idle =>
			when up =>
				if (clk_en = '1') then
					floor_num_new <= floor_num + 1;
				end if;
			when down =>
				if (clk_en = '1') then
					floor_num_new <= floor_num - 1;
				end if;
			when open_door =>
				OD <= '1';
		end case;
	end process;
	floor <= std_logic_vector(to_unsigned(floor_num, floor'length));

end ctrl_unit_arch;