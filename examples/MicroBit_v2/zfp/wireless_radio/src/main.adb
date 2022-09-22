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
with MicroBit.Radio;
--with nRF.Radio; --we need to refactor a bit more so we dont need this reference
--with MicroBit.Console; use MicroBit.Console;
--with MicroBit.Time; use MicroBit.Time;
use MicroBit;
--with HAL; use HAL;

procedure Main is

--   data : nRF.Radio.Framebuffer;
begin

   Radio.Enable;
   Radio.SetHeader(6,12,1,14);
   Radio.StartReceiving;

   loop
     --Delay_Ms(5000);
      -- check if the buffer is not empty, print the received data to the serial monitor
      if Radio.DataReady then
         --data :=Radio.Receive;
        null;
         --  Put_Line("L : " & UInt8'Image(data.Length));
         --  Put_Line("V : " & UInt8'Image(data.Version));
         --  Put_Line("G : " & UInt8'Image(data.Group));
         --  Put_Line("P : " & UInt8'Image(data.Protocol));
         --  Put_Line("D0: " & UInt8'Image(data.Payload(1)));
         --  Put_Line("D1: " & UInt8'Image(data.Payload(2)));
      end if;
   end loop;
end Main;
