
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_arith.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top_med_filter is
    generic 
    (
        ROW_WIDTH   : integer := 512 ;
        COL_WIDTH   : integer := 512 ;
        COL_DEPTH   : integer := 10 ;                         -- 2**COL_DEPTH >= COL_WIDTH
        ROW_DEPTH   : integer := 10                           -- 2**ROW_DEPTH >= ROW_WIDTH
    );
    Port 
    ( 
        clk         : in    STD_LOGIC;
        rstn        : in    STD_LOGIC;
        start       : in    STD_LOGIC;
        finish      : out   STD_LOGIC;
        dataout_vld : out   STD_LOGIC;
        dataout     : out   STD_LOGIC_VECTOR (7 downto 0));
end top_med_filter;

architecture Behavioral of top_med_filter is
signal datain       : std_logic_vector(7 downto 0) ; 
signal datain_vld   : std_logic ;
signal ready        : std_logic ;
signal rd_addr      : std_logic_vector(17 downto 0) ;
signal rd_data      : std_logic_vector(7 downto 0) ;
signal rd_done      : std_logic ;
signal clk50m		  : std_logic ;
begin

	 mypll_inst : entity work.mypll 
		port map
		(
			CLK_IN1 => clk,
			CLK_OUT1 => clk50m,
			LOCKED => open);
			
    medium_filter_inst : entity work.medium_filter
		generic map
		(
            ROW_WIDTH   => ROW_WIDTH ,
            COL_WIDTH   => COL_WIDTH ,
            COL_DEPTH   => COL_DEPTH ,
            ROW_DEPTH   => ROW_DEPTH 
		    ) 
		port map 
	    (
            clk         => clk50m ,        
            rstn        => rstn ,      
        
            start       => start ,      
            datain      => datain ,
            datain_vld  => datain_vld ,
        
            ready       => ready ,     
            finish      => finish ,
        
            dataout     => dataout ,
            dataout_vld => dataout_vld
			) ;
   
    bmp_rom_inst : entity work.bmp_rom
		port map
		(
            clka    => clk50m ,    
            addra   => rd_addr ,
            douta   => rd_data 
			) ;
            
    
    process(clk50m, rstn)
    begin
        if(rstn = '0') then
            rd_addr <= (others => '0') ;
            rd_done <= '0' ;
            datain_vld <= '0' ;
        elsif rising_edge(clk50m) then
            if(ready='1') then
                if(rd_addr=X"3ffff") then
                    rd_done <= '1' ;
                end if ;
                
                if(rd_done='0') then
                    datain_vld <= '1' ;
                else 
                    datain_vld <= '0' ;
                end if ;
                
                rd_addr <= rd_addr + '1' ;
            else
                datain_vld <= '0' ;
                rd_done <= '0' ;
                rd_addr <= (others => '0') ;
            end if ;        
        end if ;        
    end process ;    
		
    datain <= rd_data ;
 
end Behavioral;

