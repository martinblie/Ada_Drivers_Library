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
--with Ada.Text_IO; use Ada.Text_IO;
with MicroBit.IOsForTasking;
with MicroBit.IOsForTaskingTimer1;
With NRF_SVD.PWM; use NRF_SVD.PWM;
with nRF.Tasks;   use nRF.Tasks;
WITH HAL; USE HAL;
with System.Storage_Elements;

--with Ada.Real_Time; use Ada.Real_Time;
--with MicroBit.TimeWithRTC1; use MicroBit.TimeWithRTC1;
procedure Main is
   type My_Int_Array is array (1 .. 4) of UInt16;
   pwm_seq :  My_Int_Array := (50, 50, 50, 50);
begin
   --   	 MicroBit.IOsForTasking.Set_Analog_Period_Us(10);
   PWM0_Periph.PSEL.OUT_k(0).PIN := 2;
   PWM0_Periph.PSEL.OUT_k(0).CONNECT := Connected;
   PWM0_Periph.PSEL.OUT_k(1).PIN := 3;
   PWM0_Periph.PSEL.OUT_k(1).CONNECT := Connected;
   PWM0_Periph.ENABLE.ENABLE := Enabled;
  
   PWM0_Periph.MODE.UPDOWN := Up;
   PWM0_Periph.PRESCALER.PRESCALER := Div_1;
   PWM0_Periph.COUNTERTOP.COUNTERTOP := 100; --1MSEC
   PWM0_Periph.LOOP_k.CNT := Disabled;
   
   --NRF_PWM0->SEQ[0].PTR = ((uint32_t)(pwm_seq) << PWM_SEQ_PTR_PTR_Pos);
   PWM0_Periph.SEQ (0).PTR := UInt32(System.Storage_Elements.To_Integer (pwm_seq'Address));
   
   --NRF_PWM0->SEQ[0].CNT = ((sizeof(pwm_seq) / sizeof(uint16_t)) << PWM_SEQ_CNT_CNT_Pos);
   PWM0_Periph.SEQ (0).CNT.CNT := Disabled; -- actually 4
   PWM0_Periph.SEQ (0).REFRESH.CNT:= Continuous;
   PWM0_Periph.SEQ (0).ENDDELAY.CNT := 0;
   Trigger(PWM_SEQSTART_0);
      -- MicroBit.IOsForTaskingTimer1.Set_Analog_Period_Us(10);
  loop
   null;
	  --  This generates a PWM signal without the servo library
     --  Loop for value between 30 and 100. Note that this range is not checking boundaries, 1023 is the max.
	  --  When using with a servo, this first sets the interval period (20ms=50Hz), and the dutycycle to 30/1023 = 2.9% to 9.75%
	  --  The spec says duty cycle is 0.5 ms/20ms = 2.5%  (-90 degree) 
	  --                              1.5 ms/20ms = 7.5% ( 0 degree) 
	  --                              2.5 ms/20ms = 12.5% ( +90 degree) 
	  -- https://components101.com/motors/mg995-servo-motor
	  
       -- for Value in MicroBit.IOsForTaskingTimer1.Analog_Value range 1 .. 1000 loop
    --  Put("Value: ");
    --      Put_Line(Integer'Image(Integer(Value)));
    --  
    --       --  Write the analog value to pin 0
    --       Write (1, Value);
    --  
    --       --  Wait 20 milliseconds
    --       delay until Clock + Milliseconds(20);
      -- MicroBit.IOsForTasking.set(0, true);
       --delay 0.00001;
      --MicroBit.IOsForTasking.set(0, false);
       --delay 0.00001;
      
         --MicroBit.IOsForTaskingTimer1.Write (0, 512);
         --end loop;
      --  MicroBit.IOsForTasking.Write (1, 100);
      --  MicroBit.IOsForTasking.Write (2, 100);
      --  MicroBit.IOsForTaskingTimer1.Write (3, 100);
      --  delay 0.25;
--  delay 0.25;
--  
--  MicroBit.IOsForTasking.Write (2, 100);
--  delay 0.25;
--  
--  MicroBit.IOsForTasking.Write (0, 30);
--  MicroBit.IOsForTasking.Write (1, 30);
--  delay 0.25;
--  
--  MicroBit.IOsForTasking.Write (2, 30);
--  delay 0.25;
--  
--  MicroBit.IOsForTaskingTimer1.Write (3, 100);
--  --      Write (4, 100);
--  delay 0.25;
--  
--  --  Write (10, 100);
--  --  Delay_Ms(250);
--  
--  MicroBit.IOsForTaskingTimer1.Write (3, 30);
 --     Write (4, 30);
--delay 0.25;

--  Write (10, 30);
--  Delay_Ms(250);

   
   end loop;
end Main;
