library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bcd8 is
   port(
      b: in std_logic_vector(7 downto 0);
      unitss: out std_logic_vector(3 downto 0);
	  tens: out std_logic_vector(3 downto 0);
	  hunds: out std_logic_vector(3 downto 0)
   );
end bcd8;

architecture bcd8_arch of bcd8 is

signal temp1, temp2, temp3, temp4, temp6 : std_logic_vector(3 downto 0);

component add3 port(
      a: in std_logic_vector(3 downto 0);
      s: out std_logic_vector(3 downto 0));
end component;
	  

begin
C1 : add3 port map(
	a(3) => '0',
	a(2 downto 0) => b(7 downto 5),
	s => temp1);

C2 : add3 port map(
	a(3 downto 1) => temp1(2 downto 0),
	a(0) => b(4),
	s => temp2);
	
C3 : add3 port map(
	a(3 downto 1) => temp2(2 downto 0),
	a(0) => b(3),
	s => temp3);
	
C4 : add3 port map(
	a(3 downto 1) => temp3(2 downto 0),
	a(0) => b(2),
	s => temp4);
	
C5 : add3 port map(
	a(3 downto 1) => temp4(2 downto 0),
	a(0) => b(1),
	s(2 downto 0) => unitss(3 downto 1),
	s(3) => tens(0));
	
C6 : add3 port map(
	a(3) => '0',
	a(2) => temp1(3),
	a(1) =>temp2(3),
	a(0) =>temp3(3),
	s => temp6);
	
C7 : add3 port map(
	a(3 downto 1) => temp6(2 downto 0),
	a(0) => temp4(3),
	s(3) => hunds(0),
	s(2 downto 0) => tens(3 downto 1));
	
unitss(0) <= b(0);
hunds(1) <= temp6(3);
hunds(2) <= '0';
hunds(3) <= '0';

end bcd8_arch;