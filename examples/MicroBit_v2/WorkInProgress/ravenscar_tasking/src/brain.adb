--with Ada.Real_Time; use Ada.Real_Time;
with MicroBit.Console;
package body Brain is

   task body Sense is
      --Time_Now : Ada.Real_Time.Time;
   begin
      --loop
        for Index in 1..4 loop
         MicroBit.Console.Put_Line("Sensing, pass number ");
         MicroBit.Console.Put_Line(Integer'Image(Index));
         MicroBit.Console.New_Line;
         end loop;
      --   delay until Time_Now + Ada.Real_Time.Milliseconds (500);
      --end loop;
   end Sense;

   task body Think is
      --Time_Now : Ada.Real_Time.Time;
   begin
      --loop
        for Index in 1..7 loop
         MicroBit.Console.Put_Line("Thinking, pass number ");
         MicroBit.Console.Put_Line(Integer'Image(Index));
         MicroBit.Console.New_Line;
         end loop;
      --   delay until Time_Now + Ada.Real_Time.Milliseconds (500);
      --end loop;
   end Think;

   task body Act is
      --Time_Now : Ada.Real_Time.Time;
   begin
      --loop
        for Index in 1..5 loop
         MicroBit.Console.Put_Line("Acting, pass number ");
         MicroBit.Console.Put_Line(Integer'Image(Index));
         MicroBit.Console.New_Line;
         end loop;
      --   delay until Time_Now + Ada.Real_Time.Milliseconds (500);
      --end loop;
   end Act;

end Brain;
