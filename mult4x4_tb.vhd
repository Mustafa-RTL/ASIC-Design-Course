--=============================
-- mult4x4 test-bench
--=============================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mult4x4_tb is
end mult4x4_tb;

architecture tb_arch of mult4x4_tb is
   component mult4x4
      port(
         n1,n2: in std_logic_vector(3 downto 0);
         y: out std_logic_vector(7 downto 0)
      );
   end component;
   
   signal test_in1, test_in2: std_logic_vector(3 downto 0);
   signal test_out: std_logic_vector(7 downto 0);

begin
   -- instantiate the circuit under test
   uut: mult4x4
      port map( n1=> test_in1, n2=> test_in2, y=> test_out);
   -- test vector generator
   process
   variable tmp1,tmp2 : unsigned(3 downto 0):=(others => '0');
   begin
      for i in 0 to 15 loop
      	test_in1 <= std_logic_vector(tmp1);
      	for j in 0 to 15 loop
			test_in2 <= std_logic_vector(tmp2);
			tmp2 := tmp2+1;
			wait for 300 ns;
	  	end loop;
	  	tmp1 := tmp1+1;
	  end loop;
	  wait;
    end process;
   
   --verifier
   process
    variable test_pass: boolean;
    variable tmp : unsigned(7 downto 0):=(others => '0');
   begin
      wait on test_in1,test_in2;
	  tmp := unsigned(test_in1) * unsigned(test_in2);
      wait for 150 ns;
      if (test_out = std_logic_vector(tmp))
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