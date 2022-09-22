--pragma Task_Dispatching_Policy(FIFO_Within_Priorities);

with Delay_Aux_Pkg;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Real_Time; use Ada.Real_Time;

--if you want to do something when WCET is overrun, see : https://www.sigada.org/ada_letters/dec2003/07_Puente_final.pdf
procedure Main with Priority => 0 is --Set Interrupt Priorty P to 0, the lowest priority   
   package Aux renames Delay_Aux_Pkg;
    Cycle : constant Time_Span := Milliseconds (1000);
    Next  : Time := Aux.Get_Start_Time + Cycle;
    Cnt   : Integer := 1;
begin
   loop
      delay until Next;

      Aux.Show_Elapsed_Time;
      Aux.Computational_Intensive_App;

      Put_Line ("Cycle # " & Integer'Image (Cnt));
      Cnt  := Cnt + 1;
      Next := Next+ Cycle;
   end loop;
end Main;
