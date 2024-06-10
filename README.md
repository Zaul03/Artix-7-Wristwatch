# Disclaimer!
  The project is not working properly as I dont have the board to debug (The university owns it :().
  The board count time propoerly but you cant change (or see if it changed) because the display becomes glitched.

# Uni project.
  A wristwatch with 3 buttons written in VHDL and implemented on an ARTIX-7 FPGA board.

# Functions
  - Digital watch
  - Alarm clock
  - Timer
  - Stopwatch

# How?
  The watch is a state machine and with each button press it jumps into the next corresponding state. For each state there are corresponding processes and flags. For example: There is the al_on flag, it checks if the alarm is enabled. If the alarm is enabled then it checks if the alarm time matches the clock's time.
  The state machine diagram:
[automat.pdf](https://github.com/user-attachments/files/15770419/automat.pdf)

  I 


  

