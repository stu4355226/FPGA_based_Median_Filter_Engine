library ieee;

use ieee.std_logic_arith.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity test is 
	port(
		a, b : in std_logic ;
		d, c : out std_logic 
   );
end test ;

architecture RTL of test is 

begin
 
  d <= a and b ;
  c <= a xor b ;

end RTL ;
	
