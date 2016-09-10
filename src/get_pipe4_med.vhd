library ieee;
use ieee.std_logic_arith.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity get_pipe4_med is 
    port 
    (
        clk, rstn               : in    std_logic;
        data00, data10, data20  : in    std_logic_vector(7 downto 0);
        data01, data11, data21  : in    std_logic_vector(7 downto 0);
        data02, data12, data22  : in    std_logic_vector(7 downto 0);
        data_vld                : in    std_logic;
        
        new_data                : in    std_logic_vector(3 downto 0);
        
        med_data                : out   std_logic_vector(7 downto 0);
        med_data_vld            : out   std_logic
        ) ;
end get_pipe4_med ;

architecture RTL of get_pipe4_med is
signal med_data0, med_data1, med_data2, med_data3 : std_logic_vector(7 downto 0) ;
signal med_data_vld0, med_data_vld1, med_data_vld2, med_data_vld3 : std_logic ;
begin
    get_medium_inst0 : 
        entity work.get_medium
            port map
            (
                clk             => clk ,
                rstn            => rstn ,
                data00          => data00 ,
                data01          => data01 ,
                data02          => data02 ,
                data10          => data10 ,
                data11          => data11 ,
                data12          => data12 , 
                data20          => data20 ,
                data21          => data21 ,
                data22          => data22 , 
                data_vld        => data_vld ,
                new_data        => new_data(0) ,
                med_data        => med_data0 ,
                med_data_vld    => med_data_vld0
                ) ;
                
    get_medium_inst1 : 
        entity work.get_medium
            port map
            (
                clk             => clk ,
                rstn            => rstn ,
                data00          => data00 ,
                data01          => data01 ,
                data02          => data02 ,
                data10          => data10 ,
                data11          => data11 ,
                data12          => data12 , 
                data20          => data20 ,
                data21          => data21 ,
                data22          => data22 , 
                data_vld        => data_vld ,
                new_data        => new_data(1) ,
                med_data        => med_data1 ,
                med_data_vld    => med_data_vld1
                ) ;

    get_medium_inst2 : 
        entity work.get_medium
            port map
            (
                clk             => clk ,
                rstn            => rstn ,
                data00          => data00 ,
                data01          => data01 ,
                data02          => data02 ,
                data10          => data10 ,
                data11          => data11 ,
                data12          => data12 , 
                data20          => data20 ,
                data21          => data21 ,
                data22          => data22 , 
                data_vld        => data_vld ,
                new_data        => new_data(2) ,
                med_data        => med_data2 ,
                med_data_vld    => med_data_vld2
                ) ;

    get_medium_inst3 : 
        entity work.get_medium
            port map
            (
                clk             => clk ,
                rstn            => rstn ,
                data00          => data00 ,
                data01          => data01 ,
                data02          => data02 ,
                data10          => data10 ,
                data11          => data11 ,
                data12          => data12 , 
                data20          => data20 ,
                data21          => data21 ,
                data22          => data22 , 
                data_vld        => data_vld ,
                new_data        => new_data(3) ,
                med_data        => med_data3 ,
                med_data_vld    => med_data_vld3
                ) ;  

    med_data_vld <= (med_data_vld0 or med_data_vld1) or 
                    (med_data_vld2 or med_data_vld3) ;

    med_data <= med_data0 when med_data_vld0='1' else
                med_data1 when med_data_vld1='1' else
                med_data2 when med_data_vld2='1' else
                med_data3 when med_data_vld3='1' else
                X"00" ;
end RTL ;