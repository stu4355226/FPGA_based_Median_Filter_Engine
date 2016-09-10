LIBRARY ieee;                                               
USE ieee.std_logic_1164.all ;  
use ieee.std_logic_arith.all ;
use ieee.std_logic_unsigned.all ;                              

ENTITY tb_med_filter IS
END tb_med_filter;
ARCHITECTURE medium_filter_arch OF tb_med_filter IS
-- constants                                                 
-- signals                                                   
SIGNAL clk : STD_LOGIC := '0' ;
SIGNAL datain : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL datain_vld : STD_LOGIC;
SIGNAL dataout : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL dataout_vld : STD_LOGIC;
SIGNAL finish : STD_LOGIC;
SIGNAL ready : STD_LOGIC;
SIGNAL rstn : STD_LOGIC;
SIGNAL start : STD_LOGIC;
signal cnt : std_logic_vector(7 downto 0) ;
COMPONENT medium_filter
	PORT (
	clk : IN STD_LOGIC;
	datain : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
	datain_vld : IN STD_LOGIC;
	dataout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
	dataout_vld : OUT STD_LOGIC;
	finish : OUT STD_LOGIC;
	ready : OUT STD_LOGIC;
	rstn : IN STD_LOGIC;
	start : IN STD_LOGIC
	);
END COMPONENT;
BEGIN
	i1 : medium_filter
	PORT MAP (
-- list connections between master ports and signals
	clk => clk,
	datain => datain,
	datain_vld => datain_vld,
	dataout => dataout,
	dataout_vld => dataout_vld,
	finish => finish,
	ready => ready,
	rstn => rstn,
	start => start
	);
    
gen_clk : process(clk)
begin
    clk <= not clk after 5 ns ;
end process gen_clk ;
    
init : PROCESS                                               
-- variable declarations                                     
BEGIN    
    rstn <= '0' ;
    start <= '0' ;
    wait for 20 ns ;
    rstn <= '1' ;  
    wait for 100 ns ;
    start <= '1' ;
    wait for 10 ns ;
    start <= '0' ;
        -- code that executes only once                      
WAIT;                                                       
END PROCESS init;  

process(clk, rstn)
begin
    if(rstn='0') then
        cnt <= (others => '0') ;
        datain <= X"00" ;
        datain_vld <= '0' ;
    elsif rising_edge(clk) then
        if(ready='1') then
            cnt <= cnt + '1' ;
            case cnt is 
                when X"00" => datain <= X"09" ;
                when X"01" => datain <= X"04" ;
                when X"02" => datain <= X"12" ;
                when X"03" => datain <= X"27" ;
                when X"04" => datain <= X"05" ;
                when X"05" => datain <= X"08" ;
                when X"06" => datain <= X"17" ;
                when X"07" => datain <= X"06" ;
                when X"08" => datain <= X"06" ;
                when X"09" => datain <= X"04" ;
                when X"0A" => datain <= X"10" ;
                when X"0B" => datain <= X"22" ;
                when X"0C" => datain <= X"01" ;
                when X"0D" => datain <= X"18" ;
                when X"0E" => datain <= X"29" ;
                when X"0F" => datain <= X"15" ;
                when X"10" => datain <= X"21" ;
                when X"11" => datain <= X"07" ;
                when X"12" => datain <= X"03" ;
                when X"13" => datain <= X"14" ;
                when X"14" => datain <= X"19" ;
                when X"15" => datain <= X"08" ;
                when X"16" => datain <= X"26" ;
                when X"17" => datain <= X"38" ;
                when X"18" => datain <= X"10" ;
                when X"19" => datain <= X"20" ;
                when X"1A" => datain <= X"16" ;
                when X"1B" => datain <= X"06" ;
                when X"1C" => datain <= X"13" ;
                when X"1D" => datain <= X"28" ;
                when X"1E" => datain <= X"05" ;
                when X"1F" => datain <= X"18" ;
                when X"20" => datain <= X"19" ;
                when X"21" => datain <= X"24" ;
                when X"22" => datain <= X"02" ;
                when X"23" => datain <= X"17" ;
                when X"24" => datain <= X"15" ;
                when X"25" => datain <= X"38" ;
                when X"26" => datain <= X"07" ;
                when X"27" => datain <= X"06" ;
                when X"28" => datain <= X"16" ;
                when X"29" => datain <= X"44" ;
                when X"2A" => datain <= X"10" ;
                when X"2B" => datain <= X"02" ;
                when X"2C" => datain <= X"31" ;
                when X"2D" => datain <= X"08" ;
                when X"2E" => datain <= X"29" ;
                when X"2F" => datain <= X"15" ;
                when X"30" => datain <= X"11" ;
                when X"31" => datain <= X"07" ;
                when X"32" => datain <= X"23" ;
                when X"33" => datain <= X"04" ;
                when X"34" => datain <= X"09" ;
                when X"35" => datain <= X"18" ;
                when X"36" => datain <= X"16" ;
                when X"37" => datain <= X"08" ;
                when X"38" => datain <= X"14" ;
                when X"39" => datain <= X"10" ;
                when X"3A" => datain <= X"16" ;
                when X"3B" => datain <= X"06" ;
                when X"3C" => datain <= X"13" ;
                when X"3D" => datain <= X"08" ;
                when X"3E" => datain <= X"05" ;
                when X"3F" => datain <= X"13" ;
                when others => datain <= X"00" ;
            end case ;
            
            datain_vld <= '1' ;
        else    
            datain_vld <= '0' ;
        end if ;
    end if ;
end process ;                                       
END medium_filter_arch;
