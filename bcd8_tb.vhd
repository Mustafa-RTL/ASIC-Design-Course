--=============================
-- Listing 2.7 even detector testbench
--=============================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bcd8_tb is
end bcd8_tb;

architecture tb_arch of bcd8_tb is
   component bcd8
      port(
    	b: in std_logic_vector(7 downto 0);
      	unitss: out std_logic_vector(3 downto 0);
	  	tens: out std_logic_vector(3 downto 0);
	  	hunds: out std_logic_vector(3 downto 0)
	  	);
   end component;
   
   signal test_in: std_logic_vector(7 downto 0);
   signal test_out_units, test_out_tens, test_out_hunds: std_logic_vector(3 downto 0);

begin
   -- instantiate the circuit under test
   uut: bcd8
      port map(
      	b=>test_in,
      	unitss=>test_out_units,
      	tens=>test_out_tens,
      	hunds=>test_out_hunds
      	);
   -- test vector generator
   process
   variable tmp : unsigned(7 downto 0):=(others => '0');
   begin
	for i in 0 to 255 loop
		test_in <= std_logic_vector(tmp);
		tmp := tmp+1;
		wait for 400 ns;
	end loop;
   end process;
   
   --verifier
   process
      variable test_pass: boolean;
      variable tmp1, tmp2, tmp3 : unsigned(7 downto 0):=(others => '0');
   begin
      wait on test_in;
      wait for 200 ns;
      tmp1 := unsigned(test_out_units)*1;
      tmp2 := unsigned(test_out_tens) * 10;
      tmp3 := unsigned(test_out_hunds) * 100;
      if (
      	tmp1 = unsigned(test_in) mod 10 and
      	tmp2 = (unsigned(test_in) mod 100) - tmp1 and
      	tmp3 = (unsigned(test_in) mod 1000) - (tmp1+tmp2)
      	)
      then
         test_pass := true;
      else
         test_pass := false;
      end if;
      -- error reporting
      assert test_pass
         report "test failed."
         severity note;
   end process;
end tb_arch;