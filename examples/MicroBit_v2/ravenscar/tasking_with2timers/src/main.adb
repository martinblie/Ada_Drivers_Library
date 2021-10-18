with Ada.Text_IO; use Ada.Text_IO;
with MicroBit.TimeWithRTC1; use MicroBit.TimeWithRTC1;
with Ada.Real_Time; use Ada.Real_Time;

procedure Main with Priority => 0 is --Set Interrupt Priorty P to 0, the lowest priority   
begin
   Put_Line ("Start");
   delay 3.0;
   Put_Line ("Delay RTC 0: " & Integer'Image (Integer(Timer.Get_Clock)));
   Delay_Ms(1000);
   Put_Line ("Delay RTC 1: " & Integer'Image (Integer(Timer.Get_Clock)));
   loop
      Put_Line ("Delay RTC 1: " & Integer'Image (Integer(Timer.Get_Clock)));
      delay until Clock + Milliseconds(500);
   end loop;
end Main;
