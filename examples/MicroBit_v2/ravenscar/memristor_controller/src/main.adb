with Ada.Text_IO; use Ada.Text_IO;
with Ada.Real_Time; use Ada.Real_Time;
with MicroBit.DisplayRT; use MicroBit.DisplayRT;
with DigipotModel; use DigipotModel;
with MicroBit.Digipot; use MicroBit.Digipot;
use MicroBit;
procedure Main is
   Data: Integer;   
begin
   --Data := Digipot.Read_Resistance;
   loop
      Put_Line(Data'Image);
      delay until Clock + Milliseconds (1000);
   end loop;
end Main;


