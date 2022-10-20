with Ultrasonic; use Ultrasonic;
with MicroBit.Console; use MicroBit.Console;
with MicroBit.Time; use MicroBit.Time;
use MicroBit;

procedure Main is
   Distance : Distance_cm := 0;
begin
   Ultrasonic.Setup(14,15); --trigger is MB pin 14, echo is MB pin 15
   loop
      Distance := Read;
      Put_Line ("Read" & Distance_cm'Image(Distance)); -- a console line delay the loop significantly
      Delay_Ms(1000);
   end loop;

end Main;



