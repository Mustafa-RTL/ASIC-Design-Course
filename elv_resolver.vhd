library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity elv_resolver is 
	generic(noffloors: integer);
	port(
		clk, reset: in std_logic;
		floor: in std_logic_vector(3 downto 0);		
		up_btns, dn_btns, elv_btns: in std_logic_vector(noffloors-1 downto 0);
		req: out std_logic_vector(3 downto 0)	--adjust to generic
	);
end elv_resolver;

architecture resolver_arch of elv_resolver is
signal req_sig, req_next: std_logic_vector(req'length-1 downto 0);
signal req_reg: std_logic_vector(noffloors-1 downto 0);
type state_type is
	(idle, up, down);
signal elv_state, state_next: state_type;
signal c1, c2: integer range 0 to noffloors-1;

begin
	--state register
	process(clk, reset)
	begin
		if (reset = '1') then
			elv_state <= idle;
		elsif (rising_edge(clk)) then
			elv_state <= state_next;
		end if;
	end process;
	
	--combinational cct used for resolving multiple orders
	process(floor, elv_btns)
	begin
		c1 <= 0;
		c2 <= 0;
		for i in 0 to (noffloors - 1) loop
			if (i < to_integer(unsigned(floor))) then	
				if (elv_btns(i) = '1') then
					c1 <= to_integer(unsigned(floor)) - i;
				end if;
			end if;
		end loop;
		for i in (noffloors - 1) downto 0 loop
			if(i > to_integer(unsigned(floor))) then
				if (elv_btns(i) = '1') then
					c2 <= i - to_integer(unsigned(floor));
				end if;
			end if;
		end loop;
	end process;
	
	--next-state (based on req_reg)
	process(elv_state, req_reg, floor, elv_btns, c1, c2)
	begin
		state_next <= idle;
		case elv_state is
			when idle =>
				if (req_reg(to_integer(unsigned(floor))) = '1' or unsigned(req_reg) = 0) then
					state_next <= idle;
				elsif (unsigned(elv_btns) /= 0) then
					if (c1 > c2) then
						state_next <= up;
					elsif (c1 < c2) then
						state_next <= down;
					else
						state_next <= up;
					end if;	
				else
					for i in 0 to (noffloors - 1) loop
						if (i < to_integer(unsigned(floor))) then	
							if (req_reg(i) = '1') then
								state_next <= down;
							end if;
						end if;
					end loop;
					for i in (noffloors - 1) downto 0 loop
						if(i > to_integer(unsigned(floor))) then
							if (req_reg(i) = '1') then
								state_next <= up;
							end if;
						end if;
					end loop;
				end if;
			when up =>
				if (to_integer(unsigned(floor)) < noffloors-1) then
					for i in (noffloors - 1) downto 0 loop
						if(i > to_integer(unsigned(floor))) then
							if (req_reg(i) = '1') then
								state_next <= up;
							end if;
						end if;
					end loop;
				else
					state_next <= idle;     
				end if;
			when down =>
				if (to_integer(unsigned(floor)) > 0) then
					for i in 0 to (noffloors - 1) loop
						if (i < to_integer(unsigned(floor))) then	
							if (req_reg(i) = '1') then
								state_next <= down;
							end if;
						end if;
					end loop;
				else
					state_next <= idle;      
				end if;
		end case;
	end process;
	
	--arranging requests according to state					
	with elv_state select
		req_reg <= elv_btns or up_btns when up,
				   elv_btns or dn_btns when down,
				   elv_btns or up_btns or dn_btns when others;
	
	--inferring request register
	process(clk, reset)
	begin
		if (reset = '1') then
			req_sig <= (others => '0');
		elsif (rising_edge(clk)) then
			req_sig <= req_next;
		end if;
	end process;
	
	--next request
	process(elv_state, req_reg, floor, req_sig)
	begin
		req_next <= req_sig;
		if (elv_state = up) then
			for i in (noffloors - 1) downto 0 loop
				if (i > to_integer(unsigned(floor))) then	
					if (req_reg(i) = '1') then
						req_next <= std_logic_vector(to_unsigned(i,floor'length));
					end if;
				end if;
			end loop;
		elsif (elv_state = down) then
			for i in 0 to (noffloors - 1) loop
				if (i < to_integer(unsigned(floor))) then	
					if (req_reg(i) = '1') then
						req_next <= std_logic_vector(to_unsigned(i,floor'length));
					end if;
				end if;
			end loop;
		end if;
	end process;
req <= req_sig;
end resolver_arch;