--pragma Task_Dispatching_Policy(FIFO_Within_Priorities);
--pragma Locking_Policy (Ceiling_Locking);
--pragma Profile(JORVIK); --these pragma's are already active


--based on: https://learn.adacore.com/courses/intro-to-ada/chapters/tasking.html#simple-task
with Ada.Text_IO; use Ada.Text_IO;
with Brain;

procedure Main with Priority => 0 is --Set Interrupt Priorty P to 0, the lowest priority   
begin
   loop
     null;
   end loop;
end Main;
