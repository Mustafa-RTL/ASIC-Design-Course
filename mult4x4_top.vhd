library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mult4x4_top is
   port(
      NumA: in std_logic_vector(3 downto 0);
      NumB: out std_logic_vector(3 downto 0);
	  SS1: out std_logic_vector(6 downto 0);
	  SS2: out std_logic_vector(6 downto 0);
	  SS3: out std_logic_vector(6 downto 0)
   );
end mult4x4_top;

architecture mult4x4_top_arch of mult4x4_top is

signal temp1, temp2, temp3 : std_logic_vector(3 downto 0);
signal temp4 : std_logic_vector(7 downto 0);

component mult4x4 port(
      N1,N2: in std_logic_vector(3 downto 0);
	  y: out std_logic_vector(7 downto 0));
end component;

component bcd8 port(
      b: in std_logic_vector(7 downto 0);
      unitss: out std_logic_vector(3 downto 0);
	  tens: out std_logic_vector(3 downto 0);
	  hunds: out std_logic_vector(1 downto 0));
end component;

component ssd port(
      bcdin: in std_logic_vector(3 downto 0);
      ssout: out std_logic_vector(6 downto 0));
end component;

begin
U1 : mult4x4 port map(
	N1 => NumA,
	N2 => NumB,
	y => temp4);
	
U2 : bcd8 port map(
	b => temp4,
	unitss => temp1,
	tens => temp2,
	hunds => temp3);

U3 : ssd port map(
	bcdin => temp1,
	ssout => SS1);

U4 : ssd port map(
	bcdin => temp2,
	ssout => SS2);

U5 : ssd port map(
	bcdin => temp3,
	ssout => SS3);

end mult4x4_top_arch;