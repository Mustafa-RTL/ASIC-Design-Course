--=============================
-- Listing 4.0
--=============================
library ieee;
use ieee.std_logic_1164.all;


entity mux2 is
   port(
      a,b: in std_logic_vector(3 downto 0);
      s: in std_logic;
      x: out std_logic_vector(3 downto 0)
   );
end mux2;

architecture cond_arch of mux2 is
begin
   x <= a when (s = '0') else b;
end cond_arch;

--=============================
-- Listing 4.0a
--=============================
--architecture sel_arch of mux2 is
--begin
--   with s select
--     x <= a when '0',
--          b when others;
--end sel_arch;
