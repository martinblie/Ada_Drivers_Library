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
with nRF.Tasks;   use nRF.Tasks;
with nRF.Events;  use nrf.Events;
with Cortex_M.NVIC; use Cortex_M.NVIC;
with nRF.Interrupts;
--with Ada.Unchecked_Deallocation;
  with HAL; use HAL;
with MicroBit.Console; use MicroBit.Console;

package body MicroBit.Radio is

   function Status return Radio_State is
   begin
      return nRF.Radio.State;
   end Status;

   function IsEnabled return Boolean is
   begin
      return nRF.Radio.IsInitialized;
   end IsEnabled;

   function DataReady return Boolean is
   begin
	   return nRF.Radio.queueDepth >0 ;
   end DataReady;

   --procedure Send (data : access Framebuffer) is
   --begin
   -- Firstly, disable the Radio interrupt. We want to wait until the trasmission completes.
   --Disable_Interrupt(1); --interruptID for radio is 1 see nrf.interrupts

	-- Turn off the transceiver.
	--NRF_RADIO->EVENTS_DISABLED = 0;
	--NRF_RADIO->TASKS_DISABLE = 1;
	--while (NRF_RADIO->EVENTS_DISABLED == 0);

	-- Configure the radio to send the buffer provided.
	--NRF_RADIO->PACKETPTR = (uint32_t)buffer;

	-- Turn on the transmitter, and wait for it to signal that it's ready to use.
	--NRF_RADIO->EVENTS_READY = 0;
	--NRF_RADIO->TASKS_TXEN = 1;
	--while (NRF_RADIO->EVENTS_READY == 0);

	-- Start transmission and wait for end of packet.
	--NRF_RADIO->EVENTS_END = 0;
	--NRF_RADIO->TASKS_START = 1;
	--while (NRF_RADIO->EVENTS_END == 0);

	-- Return the radio to using the default receive buffer
	--NRF_RADIO->PACKETPTR = (uint32_t)rxBuf;

	-- Turn off the transmitter.
	--NRF_RADIO->EVENTS_DISABLED = 0;
	--NRF_RADIO->TASKS_DISABLE = 1;
	--while (NRF_RADIO->EVENTS_DISABLED == 0);

	--Start listening for the next packet
	--NRF_RADIO->EVENTS_READY = 0;
	--NRF_RADIO->TASKS_RXEN = 1;
	--while (NRF_RADIO->EVENTS_READY == 0);


	--NRF_RADIO->EVENTS_END = 0;
	--NRF_RADIO->TASKS_START = 1;

	-- Re-enable the Radio interrupt.
	--NVIC_ClearPendingIRQ(RADIO_IRQn);
	--Enable_Interrupt(1);

   --end Send;

   function Receive return access nrF.Radio.Framebuffer is
      p : access nRF.Radio.Framebuffer;
   begin
      p := rxQueue;

      if DataReady then
         -- Protect shared resource from ISR activity
         Disable_Interrupt(1); --interruptID for radio is 1 see nrf.interrupts

         rxQueue := rxQueue.PtrNext;
         nRF.Radio.queueDepth := nRF.Radio.queueDepth -1;

		  -- Allow ISR access to shared resource
         Enable_Interrupt(1); --interruptID for radio is 1 see nrf.interrupts
      end if;

      return p;
   end Receive;

   procedure Enable is
   begin
      nRF.Radio.Setup_For_RF;

      nRF.Interrupts.Register (nRF.Interrupts.RADIO_Interrupt,
                              Radio_IRQHandler'Access);

      nRF.Interrupts.Enable (nRF.Interrupts.RADIO_Interrupt);
   end Enable;

   procedure Radio_IRQHandler is
      sample : UInt7;
   begin
        --Start listening and wait for the END event
      if (RADIO_Periph.EVENTS_READY = 1) then
        Clear(Radio_READY);
        Trigger (Radio_START);
      end if;

      if (RADIO_Periph.EVENTS_END = 1) then
   		   Clear (Radio_END);

         if (RADIO_Periph.CRCSTATUS.CRCSTATUS = Crcok) then
            Put("interrupt");
            sample := RADIO_Periph.RSSISAMPLE.RSSISAMPLE;

            -- Associate this packet's rssi value with the data just
            -- transferred by DMA receive
            nRF.Radio.Set_RSSI(-sample);

            -- Now move on to the next buffer, if possible.
            -- The queued packet will get the rssi value set above.
            nRF.Radio.QueueRxBuf;

            Set_Packet(nRF.Radio.rxBuf'Address);
         else
            nRF.Radio.Set_RSSI(0);
         end if;

         --Start listening and wait for the END event
         Trigger (Radio_START);
      end if;
  end Radio_IRQHandler;

end MicroBit.Radio;
