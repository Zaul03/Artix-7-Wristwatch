library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity deBouncer is
    Port ( bin : in STD_LOGIC;
           bout : out STD_LOGIC;
           clk : in STD_LOGIC;
           rst : in STD_LOGIC);
end deBouncer;

architecture Behavioral of deBouncer is

constant max_count :integer:=10000000; ---- 0.1s
constant btn_actv :std_logic:='1'; --buton activ pe 1
type state_type is(idle,waiting);
signal count:integer:=0;
signal state:state_type:=idle;

begin

process(rst,clk)
begin

if(rst='1') then
state<=idle;
bout<=not btn_actv;
    elsif rising_edge(clk) then
        case(state) is
            when idle =>
                if(bin=btn_actv) then
                    state<=waiting;
                else
                    state<=idle;
                end if;
            when waiting=>
                if(count=max_count) then
                    count<=0;
                    if(bin=btn_actv)then
                        bout<=btn_actv;
                    end if;
                    state<=idle;
                else
                    count<=count+1;
                end if;
            
        end case;
    
end if;


end process;




end Behavioral;
