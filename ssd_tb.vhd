library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ssd_tb is
end ssd_tb;

architecture tb_arch of ssd_tb is
	component ssd
		port(
    		bcdin: in std_logic_vector(3 downto 0);
    		ssout: out std_logic_vector(6 downto 0)
			);
	end component;

	signal test_in: std_logic_vector(3 downto 0);
	signal test_out: std_logic_vector(6 downto 0);

begin
	uut: ssd
	port map(
		bcdin=> test_in,
		ssout=> test_out
	);
	process
	begin
		test_in <= "0000"; wait for 300 ns;
		test_in <= "0001"; wait for 300 ns;
      	test_in <= "0010"; wait for 300 ns;
      	test_in <= "0011"; wait for 300 ns;
      	test_in <= "0100"; wait for 300 ns;
      	test_in <= "0101"; wait for 300 ns;
      	test_in <= "0110"; wait for 300 ns;
      	test_in <= "0111"; wait for 300 ns;
      	test_in <= "1000"; wait for 300 ns;
      	test_in <= "1001"; wait for 300 ns;
      	wait;
	end process;
	   --verifier
	process
	variable test_pass: boolean;
	begin
		wait on test_in;
		wait for 150 ns;
			if ((test_in="0000" and test_out = "1000000") or
				(test_in="0001" and test_out = "1111001") or
				(test_in="0010" and test_out = "0100100") or
				(test_in="0011" and test_out = "0110000") or
				(test_in="0100" and test_out = "0011001") or
				(test_in="0101" and test_out = "0010010") or
				(test_in="0110" and test_out = "0000010") or
				(test_in="0111" and test_out = "1111000") or
				(test_in="1000" and test_out = "0000000") or
				(test_in="1001" and test_out = "0010000"))
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