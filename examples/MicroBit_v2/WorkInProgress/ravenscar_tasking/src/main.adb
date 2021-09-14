with Ada.Text_IO; use Ada.Text_IO;
with Ada.Real_Time; use Ada.Real_Time;
procedure Main is
begin
   loop
      Put_Line ("Hello");
      delay until Clock + Milliseconds (10);
   end loop;
end Main;
