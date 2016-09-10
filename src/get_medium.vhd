library ieee;
use ieee.std_logic_arith.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity get_medium is 
    port
    (
        clk, rstn               : in    std_logic;
        data00, data10, data20  : in    std_logic_vector(7 downto 0);
        data01, data11, data21  : in    std_logic_vector(7 downto 0);
        data02, data12, data22  : in    std_logic_vector(7 downto 0);
        data_vld                : in    std_logic;
        
        new_data                : in    std_logic;
        
        med_data                : out   std_logic_vector(7 downto 0);
        med_data_vld            : out   std_logic
        );
end get_medium;

architecture RTL of get_medium is
type state is (s0, s1, s2) ;
signal cur_state, nxt_state         : state;
signal med_max, med_min, med_med    : std_logic_vector(7 downto 0);
signal max_min, min_max             : std_logic_vector(7 downto 0);
signal new_data_r, data_vld_r       : std_logic ;
begin
    process(clk,rstn)
    begin
        if(rstn='0') then
            cur_state <= s0 ;
            data_vld_r <= '0' ;
            new_data_r <= '0' ;
        elsif rising_edge(clk) then
            cur_state <= nxt_state ;
            data_vld_r <= data_vld ;
            new_data_r <= new_data ;
        end if;
    end process;
    
    process(cur_state, data_vld, new_data, data_vld_r, new_data_r)
    begin
        nxt_state <= cur_state ;
        case cur_state is 
            when s0 =>
                if(data_vld_r='1' and new_data_r='1' and new_data='0') then
                    nxt_state <= s1 ;
                end if;
            when s1 =>
                if(data_vld='1') then
                    nxt_state <= s2 ;
                end if;
            when s2 =>
                if(data_vld='1') then
                    nxt_state <= s0 ;
                end if;
        end case;
    end process;
    
    process(clk, rstn)
    begin
        if(rstn='0') then
            max_min <= X"00" ;
            med_med <= X"00" ;
            med_max <= X"00" ;
            med_min <= X"00" ;
            min_max <= X"00" ;
        elsif rising_edge(clk) then
            case nxt_state is
                when s0 =>
                    if(data_vld='1' and new_data='1') then
                        if((data00 >= data10) and (data00 >= data20)) then
                            max_min <= data00 ;
                            
                            if(data10 >= data20) then
                                med_max <= data10 ;
                                med_min <= data10 ;
                                min_max <= data20 ;
                            else 
                                med_max <= data20 ;
                                med_min <= data20 ;
                                min_max <= data10 ;
                            end if ;
                        elsif((data10 >= data00) and (data10 >= data20)) then
                            max_min <= data10 ;
                            
                            if(data00 >= data20) then
                                med_max <= data00 ;
                                med_min <= data00 ;
                                min_max <= data20 ;
                            else 
                                med_max <= data20 ;
                                med_min <= data20 ;
                                min_max <= data00 ;
                            end if ;
                        else
                            if(data00 >= data10) then
                                med_max <= data00 ;
                                med_min <= data00 ;
                                min_max <= data10 ;
                            else 
                                med_max <= data10 ;
                                med_min <= data10 ;
                                min_max <= data00 ;
                            end if ;
                            
                            max_min <= data20 ;
                        end if ;
                    else 
                        med_max <= X"00" ;
                        med_min <= X"00" ;
                        min_max <= X"00" ;
                        max_min <= X"00" ; 
                    end if ;        
                when s1 =>
                    if(data_vld='1') then
                        if((data01 >= data11) and (data01 >= data21)) then
                            if(data01 < max_min) then
                                max_min <= data01 ;
                            end if ;
                            
                            if(data11 >= data21) then
                                if(med_max < data11) then
                                    med_max <= data11 ;
                                end if ;
                                
                                if(med_min > data11) then
                                    med_min <= data11 ;
                                end if ;
                                
                                if(min_max < data21) then
                                    min_max <= data21 ;
                                end if ;
                            else 
                                if(med_max < data21) then
                                    med_max <= data21 ;
                                end if ;
                                
                                if(med_min > data21) then
                                    med_min <= data21 ;
                                end if ;
                                
                                if(min_max < data11) then
                                    min_max <= data11 ;
                                end if ;
                            end if ;
                        elsif((data11 >= data01) and (data11 >= data21)) then
                            if(data11 < max_min) then
                                max_min <= data11 ;
                            end if ;
                            
                            if(data01 >= data21) then
                                if(med_max < data01) then
                                    med_max <= data01 ;
                                end if ;
                                
                                if(med_min > data01) then
                                    med_min <= data01 ;
                                end if ;
                                
                                if(min_max < data21) then
                                    min_max <= data21 ;
                                end if ;
                            else 
                                if(med_max < data21) then
                                    med_max <= data21 ;
                                end if ;
                                
                                if(med_min > data21) then
                                    med_min <= data21 ;
                                end if ;
                                
                                if(min_max < data01) then
                                    min_max <= data01 ;
                                end if ;
                            end if ;
                        else
                            if(data01 >= data11) then
                                if(med_max < data01) then
                                    med_max <= data01 ;
                                end if ;
                                
                                if(med_min > data01) then
                                    med_min <= data01 ;
                                end if ;
                                
                                if(min_max < data11) then
                                    min_max <= data11 ;
                                end if ;
                            else 
                                if(med_max < data11) then
                                    med_max <= data11 ;
                                end if ;
                                
                                if(med_min > data11) then
                                    med_min <= data11 ;
                                end if ;
                                
                                if(min_max < data01) then
                                    min_max <= data01 ;
                                end if ;
                            end if ;
                            
                            if(data21 < max_min) then
                                max_min <= data21 ;
                            end if ;
                        end if ;    
                    end if ;
                when s2 => 
                    if(data_vld='1') then
                        if((data02 >= data12) and (data02 >= data22)) then
                            if(data02 < max_min) then
                                max_min <= data02 ;
                            end if ;
                            
                            if(data12 >= data22) then
                                if(data12 > med_max) then
                                    med_med <= med_max ;
                                elsif(data12 < med_min) then
                                    med_med <= med_min ;
                                else 
                                    med_med <= data12 ;
                                end if ;
                                
                                if(min_max < data22) then
                                    min_max <= data22 ;
                                end if ;
                            else 
                                if(data22 > med_max) then
                                    med_med <= med_max ;
                                elsif(data22 < med_min) then
                                    med_med <= med_min ;
                                else 
                                    med_med <= data22 ;
                                end if ;
                                
                                if(min_max < data12) then
                                    min_max <= data12 ;
                                end if ;
                            end if ;
                        elsif((data12 >= data02) and (data12 >= data22)) then
                            if(data12 < max_min) then
                                max_min <= data12 ;
                            end if ;
                            
                            if(data02 >= data22) then
                                if(data02 > med_max) then
                                    med_med <= med_max ;
                                elsif(data02 < med_min) then
                                    med_med <= med_min ;
                                else 
                                    med_med <= data02 ;
                                end if ;
                                
                                if(min_max < data22) then
                                    min_max <= data22 ;
                                end if ;
                            else 
                                if(data22 > med_max) then
                                    med_med <= med_max ;
                                elsif(data22 < med_min) then
                                    med_med <= med_min ;
                                else 
                                    med_med <= data22 ;
                                end if ;
                                
                                if(min_max < data02) then
                                    min_max <= data02 ;
                                end if ;
                            end if ;
                        else 
                            if(data22 < max_min) then
                                max_min <= data22 ;
                            end if ;
                            
                            if(data02 >= data12) then
                                if(data02 > med_max) then
                                    med_med <= med_max ;
                                elsif(data02 < med_min) then
                                    med_med <= med_min ;
                                else 
                                    med_med <= data02 ;
                                end if ;
                                
                                if(min_max < data12) then
                                    min_max <= data12 ;
                                end if ;
                            else 
                                if(data12 > med_max) then
                                    med_med <= med_max ;
                                elsif(data12 < med_min) then
                                    med_med <= med_min ;
                                else 
                                    med_med <= data12 ;
                                end if ;
                                
                                if(min_max < data02) then
                                    min_max <= data02 ;
                                end if ;
                            end if ;    
                        end if ;
                    end if ;
            end case ;
        end if ;
    end process;
    
    process(clk, rstn) 
    begin
        if(rstn='0') then
            med_data <= X"00" ;
            med_data_vld <= '0' ;
        elsif rising_edge(clk) then
            if(cur_state=s2) then
                if(((max_min >= med_med) and (max_min <= min_max)) or
                   ((max_min <= med_med) and (max_min >= min_max))) then
                    med_data <= max_min ;
                elsif(((min_max >= med_med) and (min_max <= max_min)) or
                      ((min_max <= med_med) and (min_max >= max_min))) then
                    med_data <= min_max ;
                else 
                    med_data <= med_med ;
                end if ;
                
                med_data_vld <= '1' ;
            else 
                med_data_vld <= '0' ;
            end if ;
        end if ;
    end process ;    
        
                                

end RTL;
