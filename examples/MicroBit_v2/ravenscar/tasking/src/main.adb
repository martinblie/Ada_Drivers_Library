pragma Task_Dispatching_Policy(FIFO_Within_Priorities);

with Ada.Text_IO; use Ada.Text_IO;
with Ada.Real_Time; use Ada.Real_Time;

with Brain;

procedure Main with Priority => 0 is --Set Interrupt Priorty P to 0, the lowest priority 
begin
   loop
      Put_Line ("Main"); -- These lines contribute to execute time C. Use a clock or
      delay 0.01;        -- count assembly instruction * time it takes for that instruction
                         -- to compute C. We simulate that using delay, eg delay 0.1 means 
                         -- C = 10ms + a little time for the Put_Line statement
      delay until Clock + Milliseconds(250); -- Set Period T to 250 ms
   end loop;
end Main;
