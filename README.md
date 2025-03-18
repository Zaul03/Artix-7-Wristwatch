# Disclaimer!
  The project is not working properly as I dont have the board to debug.
  The board counts the time properly but you cant change the time or use other function (or see if it changed) because the display becomes glitched upon pressing a button.
  Reseting works but not much else (reset is B1 and B2 and B3).

# Uni project.
  A wristwatch with 4 digits, 3 buttons written in VHDL and implemented on an ARTIX-7 FPGA board.

# Functions
  - Digital watch
      It displays the time with the possibility to change it.
  - Alarm clock
      The alarm rings when the alarm time equals the clock time. There is the "al_on" flag that enables/disables the alarm clock. The "alarm" flag rings the alarm and it also used by the timer and stopwatch (this could be why the system doesnt work)
  - Timer
  - Stopwatch

# How?
  The watch is a state machine and with each button press it jumps into the next corresponding state. For each state there are corresponding processes and flags. For example: There is the al_on flag, it checks if the alarm is enabled. If the alarm is enabled then it checks if the alarm time matches the clock's time.
  The state machine diagram is the following:
[automat.pdf](https://github.com/user-attachments/files/15770419/automat.pdf)
  


  

