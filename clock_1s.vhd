library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity clock_1s is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           clk_T1s : out STD_LOGIC);
end clock_1s;

architecture Behavioral of clock_1s is
signal inc_sec:std_logic:='0';
constant n:integer:=10**8;   --freq div factor

begin

div: process(rst,clk)
variable counter:integer:=0;
begin
if rst='1' then
    counter:=0;
    inc_sec<='1';
elsif rising_edge(clk) then    
    if (counter=n-1) then
        counter:=0;
        inc_sec<='1';
    else 
        counter:=counter+1;
        inc_sec<='0';    
    end if;
end if;
end process;

clk_T1s<=inc_sec;

end Behavioral;
