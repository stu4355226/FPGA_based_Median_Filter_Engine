
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY tb_top IS
END tb_top;
 
ARCHITECTURE behavior OF tb_top IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT top_med_filter
    PORT(
         clk : IN  std_logic;
         rstn : IN  std_logic;
         start : IN  std_logic;
         finish : OUT  std_logic;
         dataout_vld : OUT  std_logic;
         dataout : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rstn : std_logic := '0';
   signal start : std_logic := '0';

 	--Outputs
   signal finish : std_logic;
   signal dataout_vld : std_logic;
   signal dataout : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: top_med_filter PORT MAP (
          clk => clk,
          rstn => rstn,
          start => start,
          finish => finish,
          dataout_vld => dataout_vld,
          dataout => dataout
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	
		rstn <= '1' ;
      wait for clk_period*2;
		
		start <= '1' ;
		
		wait for 12 ns ;
		
		start <= '0' ;

      -- insert stimulus here 

      wait;
   end process;

END;
