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
with Cortex_M.NVIC; use Cortex_M.NVIC;
with nRF.Interrupts;
with nRF.Tasks; use nRF.Tasks;
with nRF.Events; use nrf.Events;

package body MicroBit.Radio is

   function State return String is
   begin
      return "Status: " & Radio_State'Image(nRF.Radio.State) & " (0=Disabled, 3=RX, 6=TX)";

   end State;

   function IsInitialized return Boolean is
   begin
      return nRF.Radio.IsInitialized;
   end IsInitialized;

   function DataReady return Boolean is
   begin
	   return nRF.Radio.DataReady;
   end DataReady;

   function Receive return RadioData is
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

        --copy content of p into object (eg we move from unsafe dynamically created and destroyed framebuffers due to pointer to a safe reusable at runtime created framebuffer)
         DeepCopyIntoSafeFramebuffer(p);

         --deallocate p from heap memory
         Free(p);
      end if;

      return Get_SafeFramebuffer;
   end Receive;

   procedure Transmit (Data : RadioData) is
   begin
      -- Prepare package
      TxBuf.Length := Data.Length;
      TxBuf.Version := Data.Version;
      TxBuf.Group := Data.Group;
      TxBuf.Protocol := Data.Protocol;
      TxBuf.Payload := Data.Payload;

      -- Protect shared resource from ISR activity
      nRF.Interrupts.Disable (nRF.Interrupts.RADIO_Interrupt);

      -- Turn off the transceiver.
	   StopReceiving;

	   -- Configure the radio to send the buffer provided.
      Set_Packet(TxBuf.all'Address);

      -- Turn on the transmitter, send and wait
      TransmitAndWait;

      -- Return the radio to using the default receive buffer
      Set_Packet(RxBuf.all'Address);

      -- Start receiving AGAIN
      StartReceiving;

   end Transmit;

   procedure Enable is
   begin
      --Setup the radio for both sending, eg. TX and receiving eg. RX
      nRF.Radio.Setup_For_RF_nrf52(Frequency, Nordic_1MBIT, Zero_Dbm,16#12_34_56_78#,HeaderGroup);

      --Set/enable the event to trigger a radio interrupt being END (done with receiving package)
      nRF.Events.Enable_Interrupt (nRF.Events.Radio_END);

      --Assign a function (handler) when an interrupt occurs for radio
      nRF.Interrupts.Register (nRF.Interrupts.RADIO_Interrupt,
                              Radio_IRQHandler'Access);

      --Assing a priority when the radio interrupt occurs
      nRF.Interrupts.Set_Priority(nRF.Interrupts.RADIO_Interrupt, 0); --3 priority bits with 0 being the highest priority?

   end Enable;

   procedure Setup (RadioFrequency : Radio_Frequency_MHz;
                        Length:UInt8;
                        Version:UInt8;
                        Group:UInt8;
                        Protocol:UInt8) is
   begin
   Frequency := RadioFrequency;
   HeaderLength := Length;
   HeaderVersion := Version;
   HeaderGroup := Group;
   HeaderProtocol := Protocol;

   Enable;
   end Setup;

   procedure TransmitAndWait is
   begin
      --Start transmission
      nRF.Tasks.Trigger (nRF.Tasks.Radio_TXEN);

      --Wait until done with transmission
      Clear (Radio_DISABLED);
      while nrF.Events.Triggered(Radio_DISABLED) = false loop
         null;
      end loop;

      end TransmitAndWait;

   procedure StartReceiving is
   begin
      --Clear any pending/set event that trigger a radio interrupt
      Clear_Pending(nRF.Interrupts.RADIO_Interrupt'Enum_Rep);

      --Enable the radio interrupt
      nRF.Interrupts.Enable (nRF.Interrupts.RADIO_Interrupt);

      --Start receiving until stopped
      nRF.Tasks.Trigger (nRF.Tasks.Radio_RXEN);

      --Wait until really started up and in RX state
      Clear(Radio_READY);
      while nrF.Events.Triggered(Radio_READY) = false loop
         null;
      end loop;

      end StartReceiving;

   procedure StopReceiving is
   begin
      --Disable interrupts
      nRF.Interrupts.Disable (nRF.Interrupts.RADIO_Interrupt);

      --Trigger to stop
      Clear (Radio_DISABLED);
      nRF.Tasks.Trigger (nRF.Tasks.Radio_DISABLE);

      --Wait until really disabled
      while nrf.Events.Triggered(Radio_DISABLED) = false loop
         null;
      end loop;

   end StopReceiving;

   function HeaderOk (Length:UInt8;
                      Group:UInt8) return Boolean is
   begin
      return (Length = HeaderLength) and
             (Group = HeaderGroup);
   end HeaderOk;

   procedure Radio_IRQHandler is
     sample : UInt7;
   begin
      --Put("a");
      --  Put(" CRCOK: " & Boolean'Image(nRF.Events.Triggered(Radio_CRCOK)));
      --  Put(" CRCERROR: " & Boolean'Image(nRF.Events.Triggered(Radio_CRCERROR)));
      --  Put(" Group: " & UInt8'Image(nRF.Radio.RxBuf.Group));
      --  Put(" Data0: " & UInt8'Image(nRF.Radio.RxBuf.Payload(1)));
      --  Put_Line(" Data1: " & UInt8'Image(nRF.Radio.RxBuf.Payload(2)));
    --    	if nRF.Events.Triggered(Radio_READY) then
    --    Clear (Radio_READY);
    --  nRF.Tasks.Trigger (nRF.Tasks.Radio_START);
    --    end if;
    --
    --    if nRF.Events.Triggered(Radio_END) then
    --       --Put("b");
    --
    --       Clear (Radio_END);
    --
    --       if nRF.Events.Triggered(Radio_CRCOK) then
    --       -- Put(".");
    --          if HeaderOK(nRF.Radio.RxBuf.Length,
    --                   nRF.Radio.RxBuf.Version,
    --                   nRF.Radio.RxBuf.Group,
    --                   nRF.Radio.RxBuf.Protocol) then
    --           --  Put(" Group: " & UInt8'Image(nRF.Radio.RxBuf.Group));
    --
    --
    --         --Put_Line(" Data1: " & UInt8'Image(nRF.Radio.RxBuf.Payload(2)));
    --
    --          sample := Get_RSSIsample;
    --          Set_RSSI(-sample);
    --          QueueRxBuf;
    --          Set_Packet(RxBuf.all'Address);
    --          end if;
    --       else
    --          Set_RSSI(0);
    --       end if;
    --
    --  nRF.Tasks.Trigger (nRF.Tasks.Radio_START);
    --  end if;

       --  Check if we get triggers, if not check frequency, group, balen.
       --  Put_Line(Boolean'Image(nRF.Events.Triggered(Radio_CRCOK)));
       if nRF.Events.Triggered(Radio_CRCOK) and Get_QueueDepth < MICROBIT_RADIO_MAXIMUM_RX_BUFFERS then
         --  CRCOK does not mean data OK. In ADA, sometimes we recieve junk packages (see errata 245 https://infocenter.nordicsemi.com/index.jsp?topic=%2Ferrata_nRF52833_Rev2%2FERR%2FnRF52833%2FRev2%2Flatest%2Ferr_833.html&cp=4_1_1_0)
         --  Put_Line(" Length: " & UInt8'Image(nRF.Radio.RxBuf.Length));
         --  Put_Line(" Version: " & UInt8'Image(nRF.Radio.RxBuf.Version));
         --  Put_Line(" Group: " & UInt8'Image(nRF.Radio.RxBuf.Group));
         --  Put_Line(" Protocol: " & UInt8'Image(nRF.Radio.RxBuf.Protocol));


         --BUG: We shouldnt need this headerOK function. In the Arduino repo we get no? junk packages.
         --Possibly this has been fixed with an errata?
         --
            if HeaderOK(nRF.Radio.RxBuf.Length,
                        nRF.Radio.RxBuf.Group) then

            sample := Get_RSSIsample;
            Set_RSSI(-sample);
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
