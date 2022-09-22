------------------------------------------------------------------------------
--                                                                          --
--                    Copyright (C) 2016-2020, AdaCore                      --
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
with NRF_SVD.RADIO; use NRF_SVD.RADIO;
with nRF.Radio; use nRF.Radio;
with Cortex_M.NVIC; use Cortex_M.NVIC;
with nRF.Interrupts;
with nRF.Tasks; use nRF.Tasks;
with nRF.Events; use nrf.Events;
--with Microbit.Console; use MicroBit.Console;
--with ada.Unchecked_Deallocation;
--with System.Storage_Elements; use System.Storage_Elements;

package body MicroBit.Radio is

 --type Pointer is access Character;

--procedure Gnat_Free (Ptr : Pointer);
--pragma Export (C, Gnat_Free, "__gnat_free");


   --procedure Free is new Ada.Unchecked_Deallocation
  --    (Object => nRF.Radio.Framebuffer, Name => nRF.Radio.fbPtr);


   function State return Radio_State is
   begin
      return nRF.Radio.State;
   end State;

   function IsInitialized return Boolean is
   begin
      return nRF.Radio.IsInitialized;
   end IsInitialized;

   function DataReady return Boolean is
   begin
	   return nRF.Radio.DataReady;
   end DataReady;



   function Receive return nrF.Radio.Framebuffer is
      p : fbPtr;
   begin
      if DataReady then
         p := RxQueue;

         -- Protect shared resource from ISR activity
         nRF.Interrupts.Disable (nRF.Interrupts.RADIO_Interrupt);

         RxQueue := p.all.PtrNext;
         Set_QueueDepth(Get_QueueDepth -1);

		  -- Allow ISR access to shared resource
         nRF.Interrupts.Enable (nRF.Interrupts.RADIO_Interrupt);

        --copy content of p into object
         DeepCopyIntoSafeFramebuffer(p);

         --deallocate p from heap memory
         --Gnat_Free(p);
      end if;

      return Get_SafeFramebuffer;
   end Receive;

   procedure Enable is
   begin
      --Set/enable the event to trigger a radio interrupt being END (done with receiving package)
      RADIO_Periph.INTENSET.END_k := Set;

      --Assign a function (handler) when an interrupt occurs for radio
      nRF.Interrupts.Register (nRF.Interrupts.RADIO_Interrupt,
                              Radio_IRQHandler'Access);

      --Assing a priority when the radio interrupt occurs
      nRF.Interrupts.Set_Priority(nRF.Interrupts.RADIO_Interrupt, 0); --3 priority bits with 0 being the highest priority

      --Setup the radio for both sending, eg. TX and receiving eg. RX
      nRF.Radio.Setup_For_RF_nrf52(2400, Nordic_1MBIT, Zero_Dbm,16#75_62_69_74#,16#1#);
   end Enable;

   procedure SetHeader (Length:UInt8;
                        Version:UInt8;
                        Group:UInt8;
                        Protocol:UInt8) is
   begin
   HeaderLength := Length;
   HeaderVersion := Version;
   HeaderGroup := Group;
   HeaderProtocol := Protocol;
   end SetHeader;

   procedure StartReceiving is
   begin
      --Clear any pending/set event that trigger a radio interrupt
      Clear_Pending(nRF.Interrupts.RADIO_Interrupt'Enum_Rep);

      --Enable the radio interrupt
      nRF.Interrupts.Enable (nRF.Interrupts.RADIO_Interrupt);

      --Start receiving until stopped
      nRF.Tasks.Trigger (nRF.Tasks.Radio_RXEN);
   end StartReceiving;

   procedure Stop is
   begin
      --Disable interrupts
      nRF.Interrupts.Disable (nRF.Interrupts.RADIO_Interrupt);

      --Trigger to stop
      nRF.Tasks.Trigger (nRF.Tasks.Radio_DISABLE);
   end Stop;


   function HeaderOk (Length:UInt8;
                        Version:UInt8;
                        Group:UInt8;
                      Protocol:UInt8) return Boolean is
   begin
      return (Length = HeaderLength) and
             (Version = HeaderVersion) and
             (Group = HeaderGroup) and
             (Protocol = HeaderProtocol);
   end HeaderOk;

   procedure Radio_IRQHandler is
     sample : UInt7;
     begin
      if (RADIO_Periph.CRCSTATUS.CRCSTATUS = Crcok) then

         if HeaderOK(nRF.Radio.RxBuf.Length,
                     nRF.Radio.RxBuf.Version,
                     nRF.Radio.RxBuf.Group,
                     nRF.Radio.RxBuf.Protocol) then
            --  Put_Line("L : " & UInt8'Image(nRF.Radio.RxBuf.all.Length));
            --  Put_Line("V : " & UInt8'Image(nRF.Radio.RxBuf.all.Version));
            --  Put_Line("G : " & UInt8'Image(nRF.Radio.RxBuf.all.Group));
            --  Put_Line("P : " & UInt8'Image(nRF.Radio.RxBuf.all.Protocol));
            --  Put_Line("D0: " & UInt8'Image(nRF.Radio.RxBuf.all.Payload(1)));
            --  Put_Line("D1: " & UInt8'Image(nRF.Radio.RxBuf.all.Payload(2)));

            sample := Get_RSSIsample;
            --  Put_Line("R: " & UInt7'Image(sample));

         -- Associate this packet's rssi value with the data just
         -- transferred by DMA receive
            Set_RSSI(-sample);
         -- Now move on to the next buffer, if possible.
         -- The queued packet will get the rssi value set above.
         QueueRxBuf;
         Set_Packet(RxBuf.all'Address);
         else
            Set_RSSI(0);
         end if;
      else
         Set_RSSI(0);
      end if;

      --important otherwise this ISR gets called repeatedly. We can do this anywhere we like in this routine, but at least before trigger RXEN.
      --note that since radio state is no longer in RX so no new interrupts can happen until we trigger RXEN
      Clear (Radio_END);
      nRF.Tasks.Trigger (nRF.Tasks.Radio_RXEN); --due to short setup it will go from RXEN to RXRU to START to RX
   end Radio_IRQHandler;

end MicroBit.Radio;
