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
with MicroBit.Console; use MicroBit.Console;
with MicroBit.IOs;
with MicroBit.Time;

procedure Main is
begin
	  MicroBit.IOs.Set_Analog_Period_Us(20_000);
    loop

	  --  This generates a PWM signal without the servo library
      --  Loop for value between 30 and 100. Note that this range is not checking boundaries, 1023 is the max.
	  --  When using with a servo, this first sets the interval period (20ms=50Hz), and the dutycycle to 30/1023 = 2.9% to 9.75%
	  --  The spec says duty cycle is 0.5 ms/20ms = 2.5%  (-90 degree) 
	  --                              1.5 ms/20ms = 7.5% ( 0 degree) 
	  --                              2.5 ms/20ms = 12.5% ( +90 degree) 
	  -- https://components101.com/motors/mg995-servo-motor
	  
      for Value in MicroBit.IOs.Analog_Value range 30 .. 100 loop
		 MicroBit.Console.Put("Value: ");
         MicroBit.Console.Put_Line(Integer'Image(Integer(Value)));

         --  Write the analog value to pin 0
         MicroBit.IOs.Write (0, Value);

         --  Wait 20 milliseconds
         MicroBit.Time.Delay_Ms (50);
      end loop;
   end loop;
end Main;
