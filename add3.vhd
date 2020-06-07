library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity add3 is
   port(
      a: in std_logic_vector(3 downto 0);
      s: out std_logic_vector(3 downto 0)
   );
end add3;

architecture add3_arch of add3 is
begin
   s <= a when (unsigned(a) < 5) else
   "1000" when a = "0101" else
   "1001" when a = "0110" else
   "1010" when a = "0111" else
   "1011" when a = "1000" else
   "1100";
end add3_arch;
