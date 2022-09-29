------------------------------------------------------------------------------
--                                                                          --
--                       Copyright (C) 2016, AdaCore                        --
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

------------------------------------------------------------------------------
--   The MIT License (MIT)
--   Copyright (c) 2016 British Broadcasting Corporation.
--   This software is provided by Lancaster University by arrangement with the BBC.
--   Permission is hereby granted, free of charge, to any person obtaining a
--   copy of this software and associated documentation files (the "Software"),
--   to deal in the Software without restriction, including without limitation
--   the rights to use, copy, modify, merge, publish, distribute, sublicense,
--   and/or sell copies of the Software, and to permit persons to whom the
--   Software is furnished to do so, subject to the following conditions:
--   The above copyright notice and this permission notice shall be included in
--   all copies or substantial portions of the Software.
--   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
--   THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
--   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
--   FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
--    DEALINGS IN THE SOFTWARE.
-----------------------------------------------------------------------------
with NRF.Radio;
with Hal; use Hal;
with ada.Unchecked_Deallocation;
with System.Memory; use System.Memory;
package MicroBit.Radio is
   procedure Enable;

   procedure SetHeader (Length:UInt8;
                        Version:UInt8;
                        Group:UInt8;
                        Protocol:UInt8);

   procedure StartReceiving;

   procedure Stop;

   function State return nRF.Radio.Radio_State;

   function IsInitialized return Boolean;

   function DataReady return Boolean;

   function Receive return nRF.Radio.Framebuffer;

   --procedure Send (data : access nRF.Radio.Framebuffer)
    -- with Pre => data /= null and data.Length <= nRF.Radio.MICROBIT_RADIO_MAX_PACKET_SIZE + nRF.Radio.MICROBIT_RADIO_HEADER_SIZE - 1;

   -- missing or unexposed API's
   -- set frequency, set group, set protocol, disable,
   -- set package limit, set speed

   function HeaderOk (Length:UInt8;
                        Version:UInt8;
                        Group:UInt8;
                      Protocol:UInt8) return Boolean;

   procedure Free is new Ada.Unchecked_Deallocation
     (Object => nRF.Radio.Framebuffer, Name => nRF.Radio.fbPtr);


private
   HeaderLength : Uint8:= 0;
   HeaderVersion : Uint8:= 0;
   HeaderGroup : Uint8:= 0;
   HeaderProtocol : Uint8:= 0;

   procedure Radio_IRQHandler;

   --pragma Export (C, Free, "__gnat_free");

end MicroBit.Radio;
