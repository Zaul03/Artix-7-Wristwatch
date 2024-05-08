library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity wristwatch is
    Port ( b1 : in STD_LOGIC;
           b2 : in STD_LOGIC;
           b3 : in STD_LOGIC;
           clk: in STD_LOGIC);
           
end wristwatch;

architecture Behavioral of wristwatch is

component deBouncer is
    Port ( bin : in STD_LOGIC;
           bout : out STD_LOGIC;
           clk : in STD_LOGIC;
           rst : in STD_LOGIC);
end component;

-----------------------------------------
--------------Semnale si var-------------

signal rst:std_logic:=b1 and b2 and b3;  --reset
signal blink_hr:std_logic:='0';          --blink when setting hr
signal blink_min:std_logic:='0';         --blink when setting min

                                          
--butoane debounce-uite
signal b1out:std_logic;
signal b2out:std_logic;
signal b3out:std_logic;

------states
type state is (start,afis_ora,set_alrm,set_tmr,stp_wtch);
signal crt_state,nxt_state:state;

-----time types

type sec is record
 dig1:integer range 0 to 9;
 dig2:integer range 0 to 5;
end record;

type min is record
    dig1:integer range 0 to 9;
    dig2:integer range 0 to 5;
end record;

type hr is record
    dig1:integer range 0 to 3;
    dig2:integer range 0 to 2;
end record;

type timp is record
    sec:sec;
    min:min;
    hr:hr;
end record;

-----------time var-------------
signal t:timp:=((0,0),(0,0),(0,0));

----------------------------------------
----------------------------------------


begin

--mapare debouncer
deBounce1: deBouncer port map (bin=>b1,bout=>b1out,clk=>clk,rst=>rst);
deBounce2: deBouncer port map (bin=>b2,bout=>b2out,clk=>clk,rst=>rst);
deBounce3: deBouncer port map (bin=>b3,bout=>b3out,clk=>clk,rst=>rst);

rst_clk_sens: process(rst,clk)  
begin
if (rst='1') then
    crt_state<=start;
elsif rising_edge (clk) then
    crt_state<=nxt_state; 
end if;
end process;

states: process(crt_state,b1out)
begin
case crt_state is
    when start=>nxt_state<=afis_ora;
    when afis_ora=>
                    if b1out='1' then
                        nxt_state<=set_alrm;
  --                  elsif b2out='1' then
   --                     nxt_state<=set_hr;
                    end if;
    when set_alrm=>
                    if b1out='1' then
                        nxt_state<=set_tmr;
--                    elsif b2out='1' then
--                        nxt_state<=set_hr;
                    end if;
    when set_tmr=>
                    if b1out='1' then
                        nxt_state<=stp_wtch;
--                    elsif b2out='1' then
--                        nxt_state<=set_hr;
                    end if;
    when stp_wtch=>
                    if b1out='1' then
                        nxt_state<=afis_ora;
                    end if;  
--    when set_hr=>
--                    if b2out='1' then
--                        nxt_state<=set_min;
--                    end if;
--    when set_min=>
--                    if b2out='1' then
--                        nxt_state<=top_state;
--                    end if; 
                                                                      
end case;
end process;


end Behavioral;
