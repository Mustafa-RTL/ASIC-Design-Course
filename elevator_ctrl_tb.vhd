library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all
use ieee.numeric_std.all;

entity elevator_ctrl_tb is
end elevator_ctrl_tb;

architecture behav_arch of elevator_ctrl_tb is
component elv_top
	generic(noffloors: integer;
		transition_time_sec: integer
	);
	port(
		clk, reset: in std_logic;		
		up_btns, dn_btns, elv_btns: in std_logic_vector(noffloors-1 downto 0);
		OD: out std_logic;
		ssout: out std_logic_vector(6 downto 0)
	);
end component;
type cu_state_type is (idle, up, down, open_door);
type resolver_state_type is (idle, up, down);
alias floor is <<signal .elevator_ctrl_tb.uut : std_logic_vector(3 downto 0)>>;
alias request is <<signal .elevator_ctrl_tb.uut : std_logic_vector(3 downto 0)>>;
alias cu_state is <<signal .elevator_ctrl_tb.uut.cu.state_reg : cu_state_type>>;
alias resolver_state is <<signal .elevator_ctrl_tb.uut.r.elv_state : resolver_state_type>>;

constant noffloors: integer:= 10;
constant transition_time_sec:= 2;
signal clk, reset: in std_logic;		
signal up_btns, dn_btns, elv_btns: in std_logic_vector(noffloors-1 downto 0);
signal OD: out std_logic;
signal ssout: out std_logic_vector(6 downto 0)

begin
	--instantiate uut
	uut: elv_top
		generic map(
			noffloors => noffloors,
			transition_time_sec => transition_time_sec)
		port map(
			clk => clk,
			reset => reset,
			up_btns => up_btns,
			dn_btns => dn_btns,
			elv_btns => elv_btns,
			od => od,
			ssout => ssout
		);
	
	--stimulus
	process
	begin
		
	end process;
	
	--verification
	process
	begin
		
	end process;
end behav_arch;