--
-- Port Each on Enable with RAM Dual-Port 
--
library ieee ;
USe ieee.std_logic_arith.all;
USE ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all; 

entity dram is 
    port(
        clk     : in    std_logic ;
        ena     : in    std_logic ;
        enb     : in    std_logic ;
        wea     : in    std_logic ;
        addra   : in    std_logic_vector(9 downto 0) ;
        addrb   : in    std_logic_vector(9 downto 0) ;
        dia     : in    std_logic_vector(7 downto 0) ;
        doa     : out   std_logic_vector(7 downto 0) ;
        dob     : out   std_logic_vector(7 downto 0) 
        ) ;
end dram ;

architecture RTL of dram is
type ram_type is array(511 downto 0) of std_logic_vector(7 downto 0) ;
signal ram : ram_type ;
signal read_addra : std_logic_vector(9 downto 0) ;
signal read_addrb : std_logic_vector(9 downto 0) ;
begin

    process (clk)
    begin
        if rising_edge(clk) then
            if(ena='1') then
                if(wea='1') then
                    ram(conv_integer(addra)) <= dia ;
                end if ;
                
                read_addra <= addra ;
            end if ;

            if(enb='1') then
                read_addrb <= addrb ;
            end if;
        end if;
    end process ;

    doa <= ram(conv_integer(read_addra));
    dob <= ram(conv_integer(read_addrb));
    
end RTL ;