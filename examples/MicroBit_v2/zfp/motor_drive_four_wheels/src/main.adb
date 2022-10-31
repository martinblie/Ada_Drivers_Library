------------------------------------------------------------------------------
--                                                                          --
--                       Copyright (C) 2018, AdaCore                        --
--                                                                          --
--  Redistribution and use in source and binary forms, with or without      --
--  modification, are permitted provided that the following conditions are  --
--  met:                                                                    --
--     1. Redistributions of source code must retain the above copyright    --
--        notice, this list of conditions and the following disclaimer.     --
--     2. Redistributions in binary form must reproduce the above copyright --
--        notice, this list of conditions and the following disclaimer in   --
--        the documentation and/or other materials provided with the        --
--        distribution.                                                     --
--     3. Neither the name of the copyright holder nor the names of its     --
--        contributors may be used to endorse or promote products derived   --
--        from this software without specific prior written permission.     --
--                                                                          --
--   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS    --
--   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT      --
--   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR  --
--   A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT   --
--   HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, --
--   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT       --
--   LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,  --
--   DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY  --
--   THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT    --
--   (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE  --
--   OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.   --
--                                                                          --
------------------------------------------------------------------------------
with MicroBit.IOs; use Microbit.IOs;
with MicroBit;

procedure Main is
   Speed : constant MicroBit.IOs.Analog_Value := 512; --between 0 and 1023
   Forward : constant Boolean := True; -- forward is true, backward is false
   
begin
   --  This example requires you to wire 2 motor controllers such as the LN298 to 4 DC motors.
   --  The motorcontrollers can be powered by a 6V battery while the IO signals from the MB are 3.3V
   --  Wire the Microbit v2 pins to the pin assignments below, eg motorcontroller1 IN1 is pin 6, motorcontroller2 IN1 is 12
  
   --  We set the frequency by setting the period (remember f=1/t).
   --  By setting up the period, we can now use analog Write to set the dutycycle of the Enable pins of the motorcontroller
   --  This allows to control the speed with 0% being off and 100% dutycycle (value 1023) being the fastest speed. 
   
   Set_Analog_Period_Us(20000); -- 50 Hz = 1/50 = 0.02s = 20 ms = 20000us 
   
   --LEFT
   --front   
   MicroBit.IOs.Set(6, Forward); --IN1
   MicroBit.IOs.Set(7, not Forward); --IN2
   
   --back
   MicroBit.IOs.Set(2, Forward); --IN3
   MicroBit.IOs.Set(3, not Forward); --IN4
   
   --RIGHT
   --front
   MicroBit.IOs.Set(12, Forward); --IN1
   MicroBit.IOs.Set(13, not Forward); --IN2

   --back
   MicroBit.IOs.Set(14, Forward); --IN3
   MicroBit.IOs.Set(15, not Forward); --IN4
   
   MicroBit.IOs.Write (0, Speed); --left speed control ENA ENB
   MicroBit.IOs.Write (1, Speed); --right speed control ENA ENB
   
   loop
     null;
   end loop;
end Main;
