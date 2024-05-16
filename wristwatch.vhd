library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity wristwatch is
    Port ( b1 : in STD_LOGIC;
           b2 : in STD_LOGIC;
           b3 : in STD_LOGIC;
           clk: in STD_LOGIC;  --100MHz clock signal
           an : out STD_LOGIC_VECTOR(3 downto 0);
           seg : out STD_LOGIC_VECTOR (0 to 6);
           dp_out : out STD_LOGIC;
           led:out std_logic_vector(15 downto 0));
           
end wristwatch;

architecture Behavioral of wristwatch is

component deBouncer is
    Port ( bin : in STD_LOGIC;
           bout : out STD_LOGIC;
           clk : in STD_LOGIC;
           rst : in STD_LOGIC);
end component;

--sursa semnalalui cu periaoda de 1 sec
component clock_1s is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           clk_T1s : out STD_LOGIC);
end component;

component driver7seg is
    Port ( clk : in STD_LOGIC; --100MHz board clock input
           Din : in STD_LOGIC_VECTOR (15 downto 0); --16 bit binary data for 4 displays
           an : out STD_LOGIC_VECTOR (3 downto 0); --anode outputs selecting individual displays 3 to 0
           seg : out STD_LOGIC_VECTOR (0 to 6); -- cathode outputs for selecting LED-s in each display
           dp_in : in STD_LOGIC_VECTOR (3 downto 0); --decimal point input values
           dp_out : out STD_LOGIC; --selected decimal point sent to cathodes
           rst : in STD_LOGIC); --global reset
end component;

component alarma is
    Port ( rst : in STD_LOGIC;
           clk : in STD_LOGIC;
           led : out STD_LOGIC_VECTOR (15 downto 0));
end component;

-----------------------------------------
--------------Semnale si var-------------

signal rst:std_logic:=b1 and b2 and b3;  --reset
signal blink_left:std_logic:='0';          --blink when setting hr
signal blink_right:std_logic:='0';         --blink when setting min
signal al_on:std_logic:='0';             --alarma este/nu este activata
signal alarm:std_logic:='0';             --porneste circuitul de alarma   
signal f1hz:std_logic;                   --semanlul divizat cu T=1s   
signal inc_hr,inc_min:std_logic;         --incrementare timp
constant max_al_time:integer:=60;        --timpul maxim in secunde pentru care suna alarma (nu este valabil si pentru timer)
signal al_ctr:integer:=0;                --variabila pt numarat secundele


signal d:std_logic_vector(15 downto 0);  --date binare de trimis la driver
signal dp:std_logic_vector(3 downto 0);  -- decimal point, activ pe 0
signal anode:std_logic_vector (3 downto 0); --semnal pt a genera semnalul de blink pe display
signal ore_min:std_logic_vector(15 downto 0);--semnal pt display
signal min_sec:std_logic_vector(15 downto 0);--...

                                          
--butoane debounce-uite-------
signal b1out:std_logic:='0';
signal b2out:std_logic:='0';
signal b3out:std_logic:='0';

------states------------------
type state is (start,                                                                   --starting state
               afis_ora,set_alrm,set_tmr,crono,                                         --main states
               set_hr,set_min,                                                          --time states
               set_al_hr,set_al_min,turn_al_off,                                        --alarm states
               set_hr_tmr,set_min_tmr,start_tmr,pause_tmr,stop_tmr,tmr_ended,           --timer states
               start_cron,pause_cron,stop_cron                                          --stopwatch states
               );
               
signal crt_state,nxt_state:state;

-----time types---------------
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
------------------------------

-----------time var---------------------
signal t:timp:=((0,0),(0,0),(0,0));         --ora ceasului
signal t_al:timp:=((0,0),(0,0),(0,0));      --ora alarmei
signal t_tmr:timp:=((0,0),(0,0),(0,0));     --timp timer
signal t_cron:timp:=((0,0),(0,0),(0,0));    --timp cronometru
signal t_al_tmr:timp:=((0,0),(0,1),(0,0));  --durata alarma
signal t_tmr_def:timp:=((0,0),(1,0),(0,0)); --timer default
signal t_display:timp:=((0,0),(0,0),(0,0)); --variabila care este citita de driver
----------------------------------------
----------------------------------------


begin


----------------------------------Componente-------------------------------------------
--mapare debouncer
deBounce1: deBouncer port map (bin=>b1,bout=>b1out,clk=>clk,rst=>rst);
deBounce2: deBouncer port map (bin=>b2,bout=>b2out,clk=>clk,rst=>rst);
deBounce3: deBouncer port map (bin=>b3,bout=>b3out,clk=>clk,rst=>rst);

--mapare div frecv
ceas_sist: clock_1s port map(clk=>clk,rst=>rst,clk_T1s=>f1hz);

--mapare driver
driver_display: driver7seg port map(
                                clk=>clk,
                                Din=>d,
                                an=>anode,
                                seg=>seg,
                                dp_in=>dp,
                                dp_out=>dp_out ,
                                rst=>rst);
                                
alarma_leduri: alarma port map(clk=>clk,rst=>rst,led=>led);
----------------------------------------------------------------------------------------



fsm: process(rst,clk)  
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
                    elsif b2out='1' then
                        nxt_state<=set_hr;
                    else 
                        nxt_state<=afis_ora;
                    end if;
                    t_display<=t;
                    d<=ore_min;
                    
    when set_alrm=>
                    if b1out='1' then
                        nxt_state<=set_tmr;
                    elsif b2out='1' then
                        nxt_state<=set_al_hr;
                    elsif b3out='1' then
                        nxt_state<=turn_al_off;
                    else
                        nxt_state<=set_alrm;
                    end if;
                    t_display<=t_al;
                    if al_on='1'then 
                    d<=ore_min;
                    else 
                    d<="0000000000001111";
                    end if;
    when set_tmr=>
                    if b1out='1' then
                        nxt_state<=crono;
                    elsif b2out='1' then
                        nxt_state<=set_hr_tmr;
                    elsif b3out='1' then   
                        nxt_state<=start_tmr;
                     else
                        nxt_state<=set_tmr; 
                    end if;
                    t_display<=t_tmr;
                    d<=ore_min;
    when crono=>
                    if b1out='1' then
                        nxt_state<=afis_ora;
                    elsif b2out='1' then
                        nxt_state<=start_cron;
                     else
                        nxt_state<=crono;    
                    end if;
                    t_display<=t_cron;
                    d<=min_sec;
    when set_hr=> 
                    if b2out='1' then
                        nxt_state<=set_min;
                     else
                        nxt_state<=set_hr;    
                    end if;
                    t_display<=t;
                    d<=ore_min;
    when set_min=> 
                    if b2out='1' then
                        nxt_state<=afis_ora;
                     else
                        nxt_state<=set_min;    
                    end if;    
                    t_display<=t;
                    d<=ore_min;                            
    when set_al_hr=> 
                    if b2out='1' then
                        nxt_state<=set_al_min;
                     else
                        nxt_state<=set_al_hr;    
                    end if;
                    t_display<=t_al;
                    d<=ore_min;
    when set_al_min=> 
                    if b2out='1' then
                        nxt_state<=set_alrm;
                    else
                       nxt_state<=set_al_min;
                    end if;
                    t_display<=t_al;
                    d<=ore_min;
    when turn_al_off=>
                    nxt_state<=set_alrm;  
                    t_display<=t_al;
                    d<="0000000000001111";
    when set_hr_tmr=> 
                    if b2out='1' then
                        nxt_state<=set_min_tmr;
                     else
                        nxt_state<=set_hr_tmr;    
                    end if;
                    t_display<=t_tmr;
                    d<=ore_min;
    when set_min_tmr=> 
                    if b2out='1' then
                        nxt_state<=set_tmr;
                     else
                        nxt_state<=set_min_tmr;
                    end if;
                    t_display<=t_tmr;
                    d<=ore_min;
    when start_tmr=>
                    if b2out='1' then
                        nxt_state<=stop_tmr;
                    elsif b3out='1' then
                        nxt_state<=pause_tmr;
                    elsif t_tmr=((0,0),(0,0),(0,0)) then
                        nxt_state<=tmr_ended;
                    else
                        nxt_state<=start_tmr;
                    end if;
                    t_display<=t_tmr;
                    d<=ore_min;
    when pause_tmr=>
                    if b3out='1' then
                        nxt_state<=start_tmr;
                    elsif b2out='1' then
                        nxt_state<=stop_tmr;
                     else
                        nxt_state<=pause_tmr;        
                    end if;
                    t_display<=t_tmr;
                    d<=ore_min;
    when stop_tmr=>
                    nxt_state<=set_tmr;
                    t_display<=t_tmr;
                    d<=ore_min;
    when tmr_ended=>
                    if b3out='1' then
                        nxt_state<=stop_tmr;
                    end if;
                    t_display<=t_tmr;
                    d<=ore_min;                
    when start_cron=>
                    if b2out='1' then
                        nxt_state<=stop_cron;
                    elsif b3out='1' then
                        nxt_state<=pause_cron;
                     else
                        nxt_state<=start_cron;        
                    end if;
                    t_display<=t_cron;
                    d<=min_sec;
    when pause_cron=>
                    if b3out='1' then
                        nxt_state<=start_cron;
                     else
                        nxt_state<=pause_cron;    
                    end if;
                    t_display<=t_cron;
                     d<=min_sec;
    when stop_cron=>
                    if b2out='1' then
                        nxt_state<=crono;
                     else
                        nxt_state<=stop_cron;    
                    end if;
                    t_display<=t_cron;
                    d<=min_sec;
    when others=> nxt_state<=start;                                                                                                                                                                                                                                                     
end case;
end process;


-------------------------------------flag pentru incrementare ore si minute--------------------------------------

--am lasat doua semnale si le refolosesc pt setare ora la ceas, alarma si timer.
--cred ca este mai bine sa am 2 semnale in loc de 6
--am pus in ceas si o sa pun si in alarma si timer conditie can inc_hr sau min este HIGH sa fie si in starea corespunzatoare
--si sa nu incrementeze la toate
--am pus si mai jos starile ca sa nu comute semanalul in high cand apar butonul b3 in cazul in care este folosit
--si in alte parti

inc_min<='1' when (crt_state=set_min or crt_state=set_al_min or crt_state=set_min_tmr ) and b3out='1' else '0';
inc_hr<='1' when (crt_state=set_hr or crt_state=set_al_hr or crt_state=set_hr_tmr ) and b3out='1' else '0';

----------------------------------------------------------------------------------------------------------------

ceas_digital:process(rst,clk)  --ceasul digital in format de 24Hr
begin
if rst='1' then
      t<=((0,0),(0,0),(0,0));
elsif rising_edge (clk) then
    if f1hz = '1' then                        --incre secunde si pt cazurile in care sec sunt la 09, 19, 29 ... 59
        if t.sec.dig1 = 9 then                              
            t.sec.dig1 <= 0;
            if t.sec.dig2 = 5 then
                t.sec.dig2 <= 0;
                if t.min.dig1 = 9 then
                    t.min.dig1 <= 0;
                    if t.min.dig2 = 5 then
                        t.min.dig2 <= 0;
                        if t.hr.dig1 = 3 and t.hr.dig2 = 2 then
                            t.hr.dig1 <= 0;
                            t.hr.dig2 <= 0;
                        elsif t.hr.dig1 = 9 then
                            t.hr.dig1 <= 0;
                            t.hr.dig2 <= t.hr.dig2 + 1;
                        else t.hr.dig1 <= t.hr.dig1 + 1;
                        end if;
                    else
                        t.min.dig2 <= t.min.dig2 + 1;
                    end if;
                else
                    t.min.dig1 <= t.min.dig1 + 1;
                end if;
            else
                t.sec.dig2 <= t.sec.dig2 + 1;
            end if;
        else
            t.sec.dig1 <= t.sec.dig1 + 1;
        end if;
   
   
   
    elsif inc_min = '1' and crt_state=set_min then                --inc_min este 1 in starea de setat minutele
        if t.min.dig1 = 9 then
            t.min.dig1 <= 0;
                if t.min.dig2 = 5 then
                    t.min.dig2 <= 0;
                else
                    t.min.dig2 <= t.min.dig2 + 1;
                end if;
        else
                t.min.dig1 <= t.min.dig1 + 1;
        end if;
    elsif inc_hr = '1' and crt_state=set_hr then                                 --si pt ore, 09, 19, 23
        if t.hr.dig1 = 3 and t.hr.dig2 = 2 then
            t.hr.dig1 <= 0;
            t.hr.dig2 <= 0;
        elsif t.hr.dig1 = 9 then
            t.hr.dig1 <= 0;
            t.hr.dig2 <= t.hr.dig2 + 1; 
        else
            t.hr.dig1 <= t.hr.dig1 + 1;
        end if;
    end if;
    
end if;

end process;

---------------------------setare alarma-------------------------
------------se face la fel ca la setarea orei--------------------
setare_alarma: process (rst,clk)
begin
if rst='1' then
    t_al<=((0,0),(0,0),(0,0)); 
elsif rising_edge (clk) then
        if inc_min = '1' and crt_state=set_al_min then                --inc_min este 1 in starea de setat minutele
            if t_al.min.dig1 = 9 then
             t_al.min.dig1 <= 0;
                  if t_al.min.dig2 = 5 then
                      t_al.min.dig2 <= 0;
                  else
                      t_al.min.dig2 <= t_al.min.dig2 + 1;
                  end if;
            else
                t_al.min.dig1 <= t_al.min.dig1 + 1;
            end if;
        elsif inc_hr = '1' and crt_state=set_al_hr then         --si pt ore, 09, 19, 23
            if t_al.hr.dig1 = 3 and t_al.hr.dig2 = 2 then
                t_al.hr.dig1 <= 0;
                t_al.hr.dig2 <= 0;
            elsif t_al.hr.dig1 = 9 then
                t_al.hr.dig1 <= 0;
                t_al.hr.dig2 <= t_al.hr.dig2 + 1; 
            else
                t_al.hr.dig1 <= t_al.hr.dig1 + 1;
            end if;
        end if;
end if;               
end process;
---------------------------------------------------------------------
validare_alaram: process(rst,clk)   --alarma desteptatoare sau oricare cateodata nu vrei sa sune in fiecare zi.
begin                               --semnalul al_on valideaza alarma, sa suna sau nu la timpul setat

if rst='1' then
    al_on<='0';
elsif rising_edge (clk) then
    if crt_state=set_al_hr then
        al_on<='1';
    elsif crt_state=turn_al_off then
        al_on<='0';     
    end if;
end if;

end process;



---------------------------------------------------------------------
-----------------verifica daca ora este egala cu ora alarmei--------- 
---nu am mai considera sensibilitatea la reset deoarece oricum al_on
--depinde de reset din procesul trecut
---------------------------------------------------------------------

comparator_alarma:process(rst,clk,al_on)
begin
if rst='1' then
    al_ctr<=0;  --al_on depinde de reset deja in procesul de mai sus
elsif rising_edge (clk) then
    if al_on='1' and t=t_al then                        --daca ora alarmei coencide cu ora ceasului o sa sune in timp ce este setata alarma
            alarm<='1';
    elsif alarm='1' then
        if al_ctr=max_al_time or b3out='1' then     --oprire alarma dupa max_al_time secunde sau manual cu b3
            alarm<='0';
            al_ctr<=0;
        else 
        al_ctr<=al_ctr+1;    
        end if;                       
    else
        alarm<='0';
    end if;   
    
    if crt_state=tmr_ended then   --alarma de la timer
        alarm<='1';
    end if;
end if;

end process;
---------------------------------------------------------------------


timer:process(rst,clk)
begin
if rst='1' then
    t_tmr<=((0,0),(1,0),(0,0)); 
elsif rising_edge (clk) then
    if f1hz = '1' and crt_state=start_tmr then 
        if t_tmr.sec.dig1=0 then
            if t_tmr.sec.dig2=0 then
                if t_tmr.min.dig1=0 then
                    if t_tmr.min.dig2=0 then
                        if t_tmr.hr.dig1=0 then
                            if t_tmr.hr.dig2=0 then
                                t_tmr.hr.dig2<=0;
                            else 
                                t_tmr.hr.dig2<=t_tmr.hr.dig2-1;
                                t_tmr.hr.dig1<=9;
                            end if;
                        else
                            t_tmr.hr.dig1<=t_tmr.hr.dig1-1;
                            t_tmr.min.dig2<=5;
                        end if;
                    else
                        t_tmr.min.dig2<=t_tmr.min.dig2-1;
                        t_tmr.min.dig1<=9;
                    end if;
                else
                    t_tmr.min.dig1<=t_tmr.min.dig1-1;
                    t_tmr.sec.dig2<=5;
                end if;
            else
                t_tmr.sec.dig2<=t_tmr.sec.dig2-1;
                t_tmr.sec.dig1<=9;
            end if;
        else
            t_tmr.sec.dig1<=t_tmr.sec.dig1-1;
        end if;
    elsif crt_state=pause_tmr then
        t_tmr<=t_tmr;
    elsif crt_state=stop_tmr then                                     --resetarea la valoarea default a timerului
        t_tmr<=t_tmr_def;    
    elsif inc_min = '1' and crt_state=set_min_tmr then                --inc_min este 1 in starea de setat minutele
            if t_tmr.min.dig1 = 9 then
             t_tmr.min.dig1 <= 0;
                  if t_tmr.min.dig2 = 5 then
                      t_tmr.min.dig2 <= 0;
                  else
                      t_tmr.min.dig2 <= t_tmr.min.dig2 + 1;
                  end if;
            else
                t_tmr.min.dig1 <= t_tmr.min.dig1 + 1;
            end if;
        elsif inc_hr = '1' and crt_state=set_hr_tmr then         --si pt ore, 09, 19, 23
            if t_tmr.hr.dig1 = 3 and t_tmr.hr.dig2 = 2 then
                t_tmr.hr.dig1 <= 0;
                t_tmr.hr.dig2 <= 0;
            elsif t_tmr.hr.dig1 = 9 then
                t_tmr.hr.dig1 <= 0;
                t_tmr.hr.dig2 <= t_tmr.hr.dig2 + 1; 
            else
                t_tmr.hr.dig1 <= t_tmr.hr.dig1 + 1;
            end if;
     end if;
end if;            
end process;


cronometru:process(rst,clk)
begin

if rst='1' then
    t_cron<=((0,0),(0,0),(0,0));
elsif rising_edge (clk)then
    if crt_state=start_cron then
      if f1hz = '1' then                        --incre secunde si pt cazurile in care sec sunt la 09, 19, 29 ... 59
        if t_cron.sec.dig1 = 9 then                              
            t_cron.sec.dig1 <= 0;
            if t_cron.sec.dig2 = 5 then
                t_cron.sec.dig2 <= 0;
                if t_cron.min.dig1 = 9 then
                    t_cron.min.dig1 <= 0;
                    if t_cron.min.dig2 = 5 then
                        t_cron.min.dig2 <= 0;
                        if t_cron.hr.dig1 = 3 and t_cron.hr.dig2 = 2 then
                            t_cron.hr.dig1 <= 0;
                            t_cron.hr.dig2 <= 0;
                        elsif t_cron.hr.dig1 = 9 then
                            t_cron.hr.dig1 <= 0;
                            t_cron.hr.dig2 <= t_cron.hr.dig2 + 1;
                        else t_cron.hr.dig1 <= t_cron.hr.dig1 + 1;
                        end if;
                    else
                        t_cron.min.dig2 <= t_cron.min.dig2 + 1;
                    end if;
                else
                    t_cron.min.dig1 <= t_cron.min.dig1 + 1;
                end if;
            else
                t_cron.sec.dig2 <= t_cron.sec.dig2 + 1;
            end if;
        else
            t_cron.sec.dig1 <= t_cron.sec.dig1 + 1;
        end if;
      end if;
    elsif crt_state=pause_cron or crt_state=stop_cron then
        t_cron<=t_cron;
    else 
    t_cron<=((0,0),(0,0),(0,0));        
    end if;
end if;
end process;



----------------------------------------------------------Semnalizare--------------------------------------------------------------------------
blink_left<='1' when (crt_state=set_hr or crt_state=set_al_hr or crt_state=set_hr_tmr or crt_state=tmr_ended or crt_state=pause_cron) else '0';
blink_right<='1' when (crt_state=set_min or crt_state=set_al_min or crt_state=set_min_tmr or crt_state=tmr_ended or crt_state=pause_cron) else '0';
----------------------------------------------------------Semnalizare--------------------------------------------------------------------------

--------------------generare blink-------------------------
an(3)<=(anode(3) or f1hz) when blink_left='1' else anode(3);
an(2)<=(anode(2) or f1hz) when blink_left='1' else anode(2);
an(1)<=(anode(1) or f1hz) when blink_right='1' else anode(1);
an(0)<=(anode(0) or f1hz) when blink_right='1' else anode(0);
------------------------------------------------------------

ore_min <= std_logic_vector(to_unsigned(t_display.hr.dig2,4)) &
                                 std_logic_vector(to_unsigned(t_display.hr.dig1,4)) &
                                 std_logic_vector(to_unsigned(t_display.min.dig2,4)) &
                                 std_logic_vector(to_unsigned(t_display.min.dig1,4));

min_sec <= std_logic_vector(to_unsigned(t_display.min.dig2,4)) &
                                 std_logic_vector(to_unsigned(t_display.min.dig2,4)) &
                                 std_logic_vector(to_unsigned(t_display.sec.dig2,4)) &
                                 std_logic_vector(to_unsigned(t_display.sec.dig1,4));                                 
                                 
 







end Behavioral;
