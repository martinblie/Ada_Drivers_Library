------------------------------------------------------------------------------
--                                                                          --
--                       Copyright (C) 2021, AdaCore                        --
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
with Ada.Text_IO; use Ada.Text_IO;
with MicroBit.DisplayRT;
with MicroBit.DisplayRT.Symbols;
with MicroBit.Buttons; use MicroBit.Buttons;
with ada.Real_Time; use ada.Real_Time;
with LSM303AGR; use LSM303AGR;
with MicroBit.Accelerometer;
--with MicroBit.Magnetometer;
use MicroBit;

procedure Main is
AccData: All_Axes_Data;
MagData: All_Axes_Data;
   --this demo shows howto use the 2 buttons and the touch logo. Note that the logo is a little sensitive/erratic, sometimes touching back side for ground seems to be needed.
begin
   loop
      --  Read the accelerometer data
      AccData := Accelerometer.AccelData;
      MagData := Accelerometer.MagData;

      --  Print the data on the serial port
      Put_Line ("ACC" & ";" &
                "X,"  & AccData.X'Img & ";" &
                "Y,"  & AccData.Y'Img & ";" &
                "Z,"  & AccData.Z'Img & ";");

       Put_Line ("MAG" & ";" &
                "X,"  & MagData.X'Img & ";" &
                "Y,"  & MagData.Y'Img & ";" &
                "Z,"  & MagData.Z'Img & ";");

      MicroBit.DisplayRT.Clear;

      if (MicroBit.Buttons.State (Button_A) = Pressed) and (MicroBit.Buttons.State (Button_B) = Pressed) then
         Microbit.DisplayRT.Symbols.Smile;
         Put_Line (MicroBit.DisplayRT.ConvertMatrixToMessage);

         Put_Line ("BTN" & ";" &
                   "A,"  & "pressed" & ";" &
                   "B,"  & "pressed" & ";");

      --we dont include the scenario where logo is pressed and one of the buttons

      elsif MicroBit.Buttons.State (Button_A) = Pressed then
         MicroBit.DisplayRT.Display ('A');
         Put_Line (MicroBit.DisplayRT.ConvertMatrixToMessage);

         Put_Line ("BTN" & ";" &
                   "A,"  & "pressed" & ";");

      elsif MicroBit.Buttons.State (Button_B) = Pressed then
         MicroBit.DisplayRT.Display ('B');
         Put_Line (MicroBit.DisplayRT.ConvertMatrixToMessage);

         Put_Line ("BTN" & ";" &
                   "B,"  & "pressed" & ";");

      elsif MicroBit.Buttons.State (Logo) = Pressed then
         Microbit.DisplayRT.Symbols.Heart;
         Put_Line (MicroBit.DisplayRT.ConvertMatrixToMessage);

         Put_Line ("BTN" & ";" &
                   "L,"  & "pressed" & ";");

      else
         MicroBit.DisplayRT.Clear;
         Put_Line ("BTN" & ";" &
                   "A,"  & "released" & ";" &
                   "B,"  & "released" & ";" &
                   "L,"  & "released" & ";");
      end if;

       delay until Clock + Milliseconds(500); --50ms debounce time / sensitivity
       end loop;
end Main;
