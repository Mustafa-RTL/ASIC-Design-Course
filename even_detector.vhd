--=============================
-- Listing 2.1 Even detector
--=============================
library ieee;
use ieee.std_logic_1164.all;

-- entity declaration
entity even_detector is
   port(
      a: in std_logic_vector(2 downto 0);
      even: out std_logic
   );
end even_detector;




--=============================
-- Listing 2.2
--=============================
architecture xor_arch of even_detector is
   signal odd: std_logic;
begin
   even <= not odd;
   odd <= a(2) xor a(1) xor a(0);
end xor_arch;


--=============================
-- Listing 2.3
--=============================
architecture str_arch of even_detector is
   -- declaration for xor gate
   component xor2
      port(
         i1, i2: in std_logic;
         o1: out std_logic
      );
   end component;
   -- declaration for inverter
   component not1
      port(
         i1: in std_logic;
         o1: out std_logic
      );
   end component;
   signal sig1,sig2: std_logic;

begin
   -- instantiation of the 1st xor instance
   unit1: xor2
      port map (i1 => a(0), i2 => a(1), o1 => sig1);
   -- instantiation of the 2nd xor instance
   unit2: xor2
      port map (i1 => a(2), i2 => sig1, o1 => sig2);
   -- instantiation of inverter
   unit3: not1
      port map (i1 => sig2, o1 => even);
end str_arch;


--=============================
-- Listing 2.5
--=============================
architecture beh1_arch of even_detector is
signal odd: std_logic;
begin
   -- invertor
   even <= not odd;
   -- xor network for odd parity
   process(a)
      variable tmp: std_logic;
   begin
      tmp := '0';
      for i in 2 downto 0 loop
         tmp := tmp xor a(i);
      end loop;
      odd <= tmp;
   end process;
end beh1_arch;


--=============================
-- Listing 2.6
--=============================
architecture beh2_arch of even_detector is
begin
   process(a)
      variable sum, r: integer;
   begin
      sum := 0;
      for i in 2 downto 0 loop
         if a(i)='1' then
            sum := sum +1;
         end if;
      end loop ;
      r := sum mod 2;
      if (r=0) then
         even <= '1';
      else
         even <='0';
      end if;
   end process;
end beh2_arch;   

-- architecture body
architecture sop_arch of even_detector is
   signal p1, p2, p3, p4 : std_logic;
begin
   even <= (p1 or p2) or (p3 or p4) after 20 ns;
   p1 <= (not a(2)) and (not a(1)) and (not a(0)) after 15 ns;
   p2 <= (not a(2)) and a(1) and a(0) after 12 ns;
   p3 <= a(2) and (not a(1)) and a(0) after 12 ns;
   p4 <= a(2) and a(1) and ( a(0)) after 12 ns;
end sop_arch ;

