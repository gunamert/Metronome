# Metronome

This code is basic metronome. It works like this:

	After we run the program our program takes base address of general port which we put buzzer on it. 
  Program makes enable bit of port to zero so make buzzer silence. We define a value for stable specific value for every frequency. 	
  This is the basic idea of metronome actually. Buzzer keeps silence for a specific time. 
  Program does it with subtract 1 from that certain value again and again until that value become zero. 
  After that value become is zero program’s main loop is start. Main loop looks which key button is pressed. 
  According to which key is pressed frequency value is changes and program displays the coefficient value of a frequency to 7 Segment Displayer. 
  Program chance global port’s enable bit to one to make buzzer to sound. According to value of frequency program keeps subtract 1 from frequency value until it is zero. 
  If it is zero program going back to starting point and makes enable bit of port to zero.

