library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- entity declaration
entity mult4x4 is
   port(
      N1,N2: in std_logic_vector(3 downto 0);
	  y: out std_logic_vector(7 downto 0)
   );
end mult4x4;


--architecture
architecture directmult of mult4x4 is
begin
   y <= std_logic_vector(unsigned(N1) * unsigned(N2));
end directmult;