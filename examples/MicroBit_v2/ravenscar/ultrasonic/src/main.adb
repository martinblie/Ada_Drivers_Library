with Ultrasonic; use Ultrasonic;
with MicroBit.Console; use MicroBit.Console;
use MicroBit;

procedure Main is
   Distance : Distance_cm := 0;
begin
    Ultrasonic.Setup(14,15); -- trigger is MB pin 14, echo is MB pin 15
                            -- implementation quirk: due to sensitive timing (microseconds), the implementation is really low level. Even an if statement takes too long.
                            -- you can't use pins 6,16,20 for they are on another port address.
                            -- if you want to use these pins change line 35 and 43 (trigger pin) from ultrasonic.adb and/or line 50 and line 55 (echo pin).
                            -- The only change is GPIO_Periph to GPIO_Periph1 to change the correct port address for these 3 pins.
   loop
      Distance := Read;
      Put_Line ("Read" & Distance_cm'Image(Distance)); -- a console line delay the loop significantly
      delay(1.0);
   end loop;

end Main;



