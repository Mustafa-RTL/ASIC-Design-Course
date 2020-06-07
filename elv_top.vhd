library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity elv_top is 
	generic(noffloors: integer:= 4;
		transition_time_sec: integer:= 2			--ONLY UP TO 10 SECS
	);
	port(
		clk, reset: in std_logic;		
		up_btns, dn_btns, elv_btns: in std_logic_vector(noffloors-1 downto 0);
		OD: out std_logic;
		ssout: out std_logic_vector(6 downto 0)
	);
end elv_top;

architecture elv_top_arch of elv_top is
--constant noffloors: integer:= 10;
--constant transition_time_sec: integer:= 2;
signal req: std_logic_vector(3 downto 0);	--adjust to generic
signal floor: std_logic_vector(3 downto 0);
signal elv_btnsl: std_logic_vector(noffloors-1 downto 0);

component ctrl_unit 
	generic(
		noffloors: integer;
		transition_time_sec: integer);
	port(
		clk, reset: in std_logic;
		req: in std_logic_vector(3 downto 0);	--adjust to generic
		floor: out std_logic_vector(3 downto 0);
		OD: out std_logic);
end component;

component elv_resolver 
	generic(noffloors: integer);
	port(
		clk, reset: in std_logic;
		floor: in std_logic_vector(3 downto 0);		
		up_btns, dn_btns, elv_btns: in std_logic_vector(noffloors-1 downto 0);
		req: out std_logic_vector(3 downto 0));	--adjust to generic
end component;

component ssd
   port(
      bcdin: in std_logic_vector(3 downto 0);
      ssout: out std_logic_vector(6 downto 0));
end component;

begin
	CU: ctrl_unit 
		generic map(
			noffloors => noffloors,
			transition_time_sec => transition_time_sec)
		port map(
			clk => clk,
			reset => reset,
			req => req,
			floor => floor,
			OD => OD);
	
	R: elv_resolver
		generic map(noffloors => noffloors)
		port map(
			clk => clk,
			reset => reset,
			floor => floor,
			req => req,
			up_btns => up_btns,
			dn_btns => dn_btns,
			elv_btns => elv_btnsl);
	
	SevenSegment: ssd
		port map(bcdin => floor, ssout => ssout);
	elv_btnsl <= not elv_btns;
	
end elv_top_arch;