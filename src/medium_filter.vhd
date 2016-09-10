library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_arith.all ;
use ieee.std_logic_unsigned.all ;

entity medium_filter is 
    generic 
    (
        ROW_WIDTH : integer := 4 ;
        COL_WIDTH : integer := 3 ;
        COL_DEPTH : integer := 10 ;                         -- 2**COL_DEPTH >= COL_WIDTH+2
        ROW_DEPTH : integer := 10                            -- 2**ROW_DEPTH >= ROW_WIDTH
    );
    port
    (
        clk         : in    std_logic ;
        rstn        : in    std_logic ;
        
        start       : in    std_logic ;                     -- start calculate
        datain      : in    std_logic_vector(7 downto 0) ;  --
        datain_vld  : in    std_logic ;                     --
        
        ready       : out   std_logic ;                     -- request data
        finish      : out   std_logic ;                     -- end calculate        
        
        dataout     : out   std_logic_vector(7 downto 0) ;
        dataout_vld : out   std_logic 
    ) ;
end medium_filter ;

architecture RTL of medium_filter is    
type state is (IDLE, WRAM0, WRAM1, WRAM2, WRAM3, WAIT_END) ;
signal cur_state, nxt_state                                 : state ;     
signal wr_ram                                               : std_logic_vector(3 downto 0) ;
signal rd_ram                                               : std_logic_vector(3 downto 0) ;
signal wr_ram_addr, rd_ram_addr                             : std_logic_vector(COL_DEPTH-1 downto 0) ;     -- set enough ram width
signal start_r, start_falling                               : std_logic ;
signal wr_col_cnt                                           : std_logic_vector(ROW_DEPTH-1 downto 0) ;
signal write_col_done, write_row_done, cal_done             : std_logic ;
signal ram0_wren, ram1_wren, ram2_wren, ram3_wren           : std_logic ;
signal ram0_rden, ram1_rden, ram2_rden, ram3_rden           : std_logic ;
signal ram_data_vld                                         : std_logic ;
signal new_data                                             : std_logic_vector(3 downto 0) ;
signal rd_last_line                                         : std_logic ;
signal data0, data1, data2                                  : std_logic_vector(7 downto 0) ;
signal ram0_data, ram1_data, ram2_data, ram3_data           : std_logic_vector(7 downto 0) ;
signal med_data                                             : std_logic_vector(7 downto 0) ;
signal med_data_vld                                         : std_logic ;
signal rd_ram_r                                             : std_logic_vector(3 downto 0) ;
signal data1_r1, data1_r2, data1_r3                         : std_logic_vector(7 downto 0) ;
signal data2_r1, data2_r2, data2_r3                         : std_logic_vector(7 downto 0) ;
signal rd_line_start, rd_line_end                           : std_logic ;
signal rd_line_start_r3, rd_line_start_r2, rd_line_start_r1 : std_logic ;
signal rd_line_end_r3, rd_line_end_r2, rd_line_end_r1       : std_logic ;
signal rd_last_line_r1, rd_last_line_r2, rd_last_line_r3    : std_logic ;
signal rd_last_ram                                          : std_logic_vector(3 downto 0) ;
signal ram_data_vld_r1, ram_data_vld_r2, ram_data_vld_r3    : std_logic ;
signal cal_done_r                                           : std_logic ;
begin

    start_falling <= start_r and (not start) ;
    ready <= (wr_ram(0) or wr_ram(1)) or 
             (wr_ram(2) or wr_ram(3)) ;

    process(clk, rstn)
    begin
        if(rstn='0') then
            start_r <= '0' ;
            ram_data_vld <= '0' ;
            rd_ram_r <= X"0" ;
            data1_r3 <= X"00" ;
            data1_r2 <= X"00" ;
            data1_r1 <= X"00" ;
            data2_r3 <= X"00" ;
            data2_r2 <= X"00" ;
            data2_r1 <= X"00" ;
            rd_line_end_r3 <= '0' ;
            rd_line_end_r2 <= '0' ;
            rd_line_end_r1 <= '0' ;
            rd_line_start_r3 <= '0' ;
            rd_line_start_r2 <= '0' ;
            rd_line_start_r1 <= '0' ;
            rd_last_line_r3 <= '0' ;
            rd_last_line_r2 <= '0' ;
            rd_last_line_r1 <= '0' ;
            ram_data_vld_r3 <= '0' ;
            ram_data_vld_r2 <= '0' ;
            ram_data_vld_r1 <= '0' ;
            cal_done_r <= '0' ;
        elsif rising_edge(clk) then
            start_r <= start ;
            rd_ram_r <= rd_ram ;
            data1_r3 <= data1_r2 ;
            data1_r2 <= data1_r1 ;
            data1_r1 <= data1 ;
            data2_r3 <= data2_r2 ;
            data2_r2 <= data2_r1 ;
            data2_r1 <= data2 ;
            rd_line_end_r3 <= rd_line_end_r2 ;
            rd_line_end_r2 <= rd_line_end_r1 ;
            rd_line_end_r1 <= rd_line_end ;
            rd_line_start_r3 <= rd_line_start_r2 ;
            rd_line_start_r2 <= rd_line_start_r1 ;
            rd_line_start_r1 <= rd_line_start ;
            rd_last_line_r3 <= rd_last_line_r2 ;
            rd_last_line_r2 <= rd_last_line_r1 ;
            rd_last_line_r1 <= rd_last_line ;
            ram_data_vld_r3 <= ram_data_vld_r2 ;
            ram_data_vld_r2 <= ram_data_vld_r1 ;
            ram_data_vld_r1 <= ram_data_vld ;
            cal_done_r <= cal_done ;
            ram_data_vld <= (ram0_rden or ram1_rden) or 
                            (ram2_rden or ram3_rden) ;
        end if;
    end process;
    
    process(clk, rstn) 
    begin   
        if(rstn='0') then
            cur_state <= IDLE ;
        elsif rising_edge(clk) then
            cur_state <= nxt_state ;
        end if;
    end process;
    
    process(cur_state, start_falling, write_col_done, 
            write_row_done, cal_done)
    begin
        nxt_state <= cur_state ;
        
        case cur_state is
            when IDLE => 
                if(start_falling='1') then
                    nxt_state <= WRAM0;
                end if;
            when WRAM0 =>
                if(write_col_done='1') then
                    nxt_state <= WAIT_END ;
                elsif(write_row_done='1') then
                    nxt_state <= WRAM1 ;
                end if;
            when WRAM1 =>
                if(write_col_done='1') then
                    nxt_state <= WAIT_END ;
                elsif(write_row_done='1') then
                    nxt_state <= WRAM2 ;
                end if;
            when WRAM2 => 
                if(write_col_done='1') then
                    nxt_state <= WAIT_END ;
                elsif(write_row_done='1') then
                    nxt_state <= WRAM3 ;
                end if;
            when WRAM3 =>
                if(write_col_done='1') then
                    nxt_state <= WAIT_END ;
                elsif(write_row_done='1') then
                    nxt_state <= WRAM0 ;
                end if;
            when WAIT_END =>
                if(cal_done='1') then
                    nxt_state <= IDLE ;
                end if;
        end case;    
    end process;

    process(clk, rstn)
    begin
        if(rstn='0') then
            wr_ram <= X"0" ;
            rd_ram <= X"0" ;
            rd_last_ram <= X"0" ;
        elsif rising_edge(clk) then
            case nxt_state is
                when IDLE =>
                    wr_ram <= X"0" ;
                    rd_ram <= X"0" ; 
                    rd_last_ram <= X"0" ;
                when WRAM0 =>
                    if(wr_col_cnt < 3) then
                        rd_ram <= X"0" ;
                    else
                        rd_ram <= X"E" ;
                    end if;
                    
                    wr_ram <= X"1" ;
                when WRAM1 =>
                    if(wr_col_cnt < 3) then
                        rd_ram <= X"1" ;
                    else
                        rd_ram <= X"D" ;
                    end if;
                    
                    wr_ram <= X"2" ;
                when WRAM2 => 
                    if(wr_col_cnt < 3) then
                        rd_ram <= X"0" ;                -- read first line data
                    else
                        rd_ram <= X"B" ;
                    end if;
                    
                    wr_ram <= X"4" ;
                when WRAM3 => 
                    rd_ram <= X"7" ;
                    wr_ram <= X"8" ;
                when WAIT_END => 
                    case wr_ram is 
                        when X"1" => rd_ram <= X"D" ; rd_last_ram <= X"1" ;
                        when X"2" => rd_ram <= X"B" ; rd_last_ram <= X"2" ;
                        when X"4" => rd_ram <= X"7" ; rd_last_ram <= X"4" ;
                        when X"8" => rd_ram <= X"E" ; rd_last_ram <= X"8" ;
                        when others => NULL ;
                    end case;
                    
                    wr_ram <= X"0" ;
            end case;              
        end if;
    end process;
    
    process(clk, rstn) 
    begin
        if(rstn='0') then
            wr_ram_addr <= (others => '0') ;
            rd_ram_addr <= (others => '0') ;
            wr_col_cnt <= (others => '0') ;
            write_row_done <= '0' ;
            write_col_done <= '0' ;
            new_data <= X"0" ;
            rd_last_line <= '0' ;
            cal_done <= '0' ;
            rd_line_start <= '0' ;
            rd_line_end <= '0' ;
        elsif rising_edge(clk) then
            if(datain_vld='1' and wr_ram/=X"0") then
                if(wr_ram_addr=(COL_WIDTH-1)) then
                    wr_ram_addr <= (others => '0') ;
                    rd_ram_addr <= (others => '0') ;
                    new_data <= X"0" ;
                    
                    if(wr_col_cnt >= 3) then
                        rd_line_end <= '1' ;                -- read line's last data
                    end if ;
                else    
                    wr_ram_addr <= wr_ram_addr + '1' ;
                    rd_ram_addr <= rd_ram_addr + '1' ; 
                    
                    if((rd_ram_addr < (COL_WIDTH-2)) and (wr_col_cnt >=3)) then
                        case rd_ram_addr(1 downto 0) is 
                            when "00" => new_data <= X"1" ;
                            when "01" => new_data <= X"2" ;
                            when "10" => new_data <= X"4" ;
                            when "11" => new_data <= X"8" ;
                            when others => new_data <= X"0" ;   
                        end case ;
                    else 
                        new_data <= X"0" ;
                    end if ;
                    
                    if(rd_ram_addr=0 and (wr_col_cnt >=3)) then
                        rd_line_start <= '1' ;          -- read line's first data
                    else 
                        rd_line_start <= '0' ;
                    end if ;

                    rd_line_end <= '0' ;        
                end if ;
                
                if(wr_ram_addr=(COL_WIDTH-2)) then
                    if (wr_col_cnt=(ROW_WIDTH-1)) then
                        write_col_done <= '1' ;
                    else
                        write_col_done <= '0' ;
                        wr_col_cnt <= wr_col_cnt + '1' ;
                    end if ;
                    
                    write_row_done <= '1' ;
                else 
                    write_row_done <= '0' ;
                end if ;
            elsif(wr_ram=X"0" and rd_ram/=X"0") then
                if(rd_ram_addr=(COL_WIDTH-1)) then
                    rd_ram_addr <= (others => '0') ;
                    new_data <= X"0" ;
                    
                    if(rd_last_line='0') then
                        rd_last_line <= '1' ;
                        rd_line_end <= '1' ;
                    else    
                        cal_done <= '1' ;
                    end if ;
                else 
                    rd_ram_addr <= rd_ram_addr + '1' ;
                    
                    if((rd_ram_addr < (COL_WIDTH-2)) and rd_last_line='0') then
                        case rd_ram_addr(1 downto 0) is 
                            when "00" => new_data <= X"1" ;
                            when "01" => new_data <= X"2" ;
                            when "10" => new_data <= X"4" ;
                            when "11" => new_data <= X"8" ;
                            when others => new_data <= X"0" ;
                        end case ;
                    else 
                        new_data <= X"0" ;
                    end if ;
                    
                    if(rd_ram_addr=0 and rd_last_line='0') then
                        rd_line_start <= '1' ;          -- read line's first data
                    else 
                        rd_line_start <= '0' ;
                    end if ;

                    rd_line_end <= '0' ; 
                end if ;
            else
                write_col_done <= '0' ;
                write_row_done <= '0' ;
                new_data <= X"0" ;
                cal_done <= '0' ;
                rd_last_line <= '0' ;
                rd_line_end <= '0' ;
                rd_line_start <= '0' ;
            end if ;
        end if ;
    end process; 

    ram0_wren <= datain_vld and wr_ram(0) ;    
    ram1_wren <= datain_vld and wr_ram(1) ;    
    ram2_wren <= datain_vld and wr_ram(2) ;    
    ram3_wren <= datain_vld and wr_ram(3) ;
    ram0_rden <= (datain_vld or write_col_done) and rd_ram(0) ;
    ram1_rden <= (datain_vld or write_col_done) and rd_ram(1) ;
    ram2_rden <= (datain_vld or write_col_done) and rd_ram(2) ;
    ram3_rden <= (datain_vld or write_col_done) and rd_ram(3) ;
    
    data0  <= ram0_data when rd_ram_r=X"7" else
              ram1_data when rd_ram_r=X"E" else
              ram2_data when rd_ram_r=X"D" else 
              ram3_data when rd_ram_r=X"B" else 
              X"00" ;
    data1  <= ram1_data when rd_ram_r=X"7" else
              ram2_data when rd_ram_r=X"E" else
              ram3_data when rd_ram_r=X"D" else
              ram0_data when rd_ram_r=X"B" else
              X"00" ;
    data2  <= ram2_data when rd_ram_r=X"7" else
              ram3_data when rd_ram_r=X"E" else
              ram0_data when rd_ram_r=X"D" else
              ram1_data when rd_ram_r=X"B" else
              X"00" ;          

    dram_inst0 : entity  work.dram 
        port map
        (
            clk         => clk ,
            dia         => datain ,
            addrb       => rd_ram_addr ,
            enb         => ram0_rden ,
            addra       => wr_ram_addr ,
            wea         => ram0_wren ,
				ena 			=> '1',
            dob         => ram0_data ,
            doa         => open 
            ) ;
            
            
    
    dram_inst1 : entity  work.dram 
        port map
        (
            clk         => clk ,
            dia         => datain ,
            addrb       => rd_ram_addr ,
            enb         => ram1_rden ,
            addra       => wr_ram_addr ,
            wea         => ram1_wren ,
				ena 			=> '1',
            dob         => ram1_data ,
            doa         => open 
            ) ;
            
    dram_inst2 : entity  work.dram 
        port map
        (
            clk         => clk ,
            dia         => datain ,
            addrb       => rd_ram_addr ,
            enb         => ram2_rden ,
            addra       => wr_ram_addr ,
            wea         => ram2_wren ,
				ena 			=> '1',
            dob         => ram2_data ,
            doa         => open 
            ) ;
            
    dram_inst3 : entity  work.dram 
        port map
        (
            clk         => clk ,
            dia         => datain ,
            addrb       => rd_ram_addr ,
            enb         => ram3_rden ,
            addra       => wr_ram_addr ,
            wea         => ram3_wren ,
				ena 			=> '1',
            dob         => ram3_data ,
            doa         => open 
            ) ; 
    
    get_pipe4_med_inst : entity work.get_pipe4_med
        port map
        (
            clk         => clk ,
            rstn        => rstn ,             
            data00      => data0 , 
            data10      => data1 , 
            data20      => data2 ,
            data01      => data0 , 
            data11      => data1 , 
            data21      => data2 ,
            data02      => data0 , 
            data12      => data1 , 
            data22      => data2 ,
            data_vld    => ram_data_vld ,
            new_data    => new_data ,             
             
            med_data        => med_data ,              
            med_data_vld    => med_data_vld 
            ) ;
            
    -- dataout <= ram0_data when (wr_col_cnt < 3) else
               -- data1_r3 when (rd_line_end_r3='1' or rd_line_start_r3='1') else
               -- data2_r3 when (rd_last_line_r3='1') else
               -- med_data ;
    -- dataout_vld <= ram_data_vld    when (wr_col_cnt < 3) else
                   -- ram_data_vld_r3 when ((rd_line_end_r3='1') or 
                                        -- (rd_line_start_r3='1') or 
                                        -- (rd_last_line_r3='1')) else   
                   -- med_data_vld ;
    process(clk, rstn)
    begin
        if(rstn='0') then
            dataout <= X"00" ;
            dataout_vld <= '0' ;
        elsif rising_edge(clk) then
            if(wr_col_cnt<3) then
                dataout <= ram0_data ;
                dataout_vld <= ram_data_vld ;
            elsif(rd_line_end_r3='1' or rd_line_start_r3='1') then
                dataout <= data1_r3 ;
                dataout_vld <= ram_data_vld_r3 ;
            elsif(rd_last_line_r3='1' and rd_last_line_r2 = '1') then
                dataout <= data2_r3 ;
                dataout_vld <= ram_data_vld_r3 ;
            else
                dataout <= med_data ;
                dataout_vld <= med_data_vld ;
            end if ;
        end if ;
    end process ;
    
    finish <= cal_done and (not cal_done_r) ;
    
end RTL ;


