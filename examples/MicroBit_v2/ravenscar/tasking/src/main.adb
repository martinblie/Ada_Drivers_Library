with Ada.Text_IO; use Ada.Text_IO;
with Ada.Real_Time; use Ada.Real_Time;

with Brain;

procedure Main with Priority => 0 is
begin
   loop
      Put_Line ("Main before");
      delay until Clock + Milliseconds(250);
      Put_Line ("Main after");
      delay until Clock + Milliseconds(250);
   end loop;
end Main;
