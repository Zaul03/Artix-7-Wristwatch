library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

    entity alarma is

    Port ( rst : in STD_LOGIC;
           clk : in STD_LOGIC;
           led : out STD_LOGIC_VECTOR (15 downto 0));
    end alarma;



architecture Behavioral of alarma is
-- for the divider
constant fdiv : integer := 25;
constant ndiv : integer := 10**8 / fdiv;

signal en : std_logic := '0'; -- for the counter
constant ncnt : integer := 16;
signal cnt : integer := 0;

begin

divider : process (rst,clk)
     variable div : integer := 0;
begin
    if rst = '1' then
    div := 0;
    en <= '0';
    elsif rising_edge(clk) then
        if div = ndiv - 1 then
            div := 0;
            en <= '1';
        else
            div := div + 1;
            en <= '0';
        end if;
    end if;
end process;

counter : process (rst, clk)
begin
if rst = '1' then
    cnt <= 0;
elsif rising_edge(clk) then
    if en = '1' then
        if cnt = ncnt - 1 then
            if cnt = ncnt - 1 then
                cnt <= 0;
            else
                cnt <= cnt + 1;
            end if;
        end if;
     end if;   
end if;
end process;

with cnt select
    led <= "1000000000000000" when 0,
           "0100000000000000" when 1,
            "0010000000000000" when 2,
            "0001000000000000" when 3,
            "0000100000000000" when 4,
            "0000010000000000" when 5,
            "0000001000000000" when 6,
            "0000000100000000" when 7,
            "0000000010000000" when 8,
            "0000000001000000" when 9,
            "0000000000100000" when 10,
            "0000000000010000" when 11,
            "0000000000001000" when 12,
            "0000000000000100" when 13,
            "0000000000000010" when 14,
            "0000000000000001" when 15,
            "1111111111111111" when others;


end Behavioral;
