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
with MicroBit.Radio;
with nRF.Radio; use nRF.Radio;
with MicroBit.Console; use MicroBit.Console;
use MicroBit;
with HAL; use HAL;
with Ada.Real_Time; use Ada.Real_Time;

procedure Main is

   data : access nRF.Radio.Framebuffer;
   queue: Boolean;

begin
   -- enable the micro:bit radio using default settings like channel, speed, power, protocol, etc.
   Put(Boolean'Image(Radio.IsEnabled));
   Radio.Enable;
   Put(Radio_State'Image(Radio.Status));

   loop
      queue := Radio.DataReady;
      Put("-");
      delay(0.5);

      -- check if the buffer is not empty, print the received data to the serial monitor
      if Radio.DataReady then
          Put("got data");
         --copy the receive buffer of the radio
          data := Radio.Receive;

         --the header information.
          Put(UInt8'Image(data.Length));
          Put("  ");
          Put(UInt8'Image(data.Version));
          Put("  ");
          Put(UInt8'Image(data.Group));
          Put("  ");
          Put(UInt8'Image(data.Protocol));
          Put("  ");

         --The actual data. note we only print the 1st byte of data, there could be more.
         Put_Line(UInt8'Image(data.Payload(1)));

         --is this needed?
         --deallocate (free) the data as it will be dangling after the  next assignment.
         --Destroy (data);
       end if;
   end loop;
end Main;

