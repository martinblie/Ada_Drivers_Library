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
with System.Storage_Elements; use System.Storage_Elements;
with nRF.Clock;     use nRF.Clock;
with Cortex_M.NVIC; use Cortex_M.NVIC;

package body nRF.Radio is
   ------------------------------------
   -- Setup_For_Bluetooth_Low_Energy --
   ------------------------------------
   procedure Setup_For_Bluetooth_Low_Energy is
   begin
      Set_Mode (BLE_1MBIT);

      Configure_Packet (S0_Field_Size_In_Byte        => TRUE,
                        S1_Field_Size_In_Bit         => 0,
                        Length_Field_Size_In_Bit     => 8,
                        Max_Packet_Length_In_Byte    => 1 + 1 + 37,
                        Static_Packet_Length_In_Byte => 0,
                        On_Air_Endianness            => Little_Endian);

      Configure_CRC (Enable        => True,
                     Length        => 3,
                     Skip_Address  => True,
                     Polynomial    => 16#00_065B#,
                     Initial_Value => 16#55_5555#);

      Configure_Whitening (True);
   end Setup_For_Bluetooth_Low_Energy;

   procedure Setup_For_RF_nrf52 (Frequency: Radio_Frequency_MHz;
                                 Mode : Radio_Mode;
                                 Power: Radio_Power;
                                 Base0Address : Radio_Address;
                                 Group: Radio_Group) is
   begin
      --Setup based on https://github.com/andenore/NordicSnippets/blob/master/examples/radio_rx and https://github.com/aiunderstand/NRF52_Radio_library
      --Full spec on nrf52833 manual: https://infocenter.nordicsemi.com/pdf/nRF52833_PS_v1.5.pdf
      --Current issues:
        -- Memory map or clock issue, missing errata? CRC is enabled while set to disabled and BALEN is set to illegal value of 1. Ideally we set BALEN to 4 with CRC to 2.
        -- Not all API's are exposed with functions, eg. disable, gpio at compare, etc.
        -- Not all ranges are exposed, eg. with frequency we can also choose 40 Mhz lower than 2400, so the full range is acstually between 2360-2500 in 1MHz steps
        -- The setup of parameters is done at startup, not at runtime. See examples in repo's on how to implement.

      --The new keyword is used for dynamically allocated memory
      --It request a memory region of size framebuffer on the heap and the address pointer points to the first element of that region.
      --We use this pointer that it can be used by the radio receiver using EasyDMA, allowing it write the received framebuffer to it.
      --If the request is denied, for example because the heap is full, get a null pointer back, so we always need to check for this
      --It also means that we need to free the allocated memory if we dont use them or the heap will become full.
      --We free the memory when we are fully done with it, so after we removed it from the rxqueue (receive function).
      --In ADA we try to avoid using pointers, so this example could be improved: https://en.wikibooks.org/wiki/Ada_Programming/Types/access
       RxBuf := new Framebuffer;
       if RxBuf = null then --is this ever null in ADA?
          return;
       end if;


      --Enable the High Frequency clock on the processor. This is a pre-requisite for
	   --the RADIO module. Without this clock, no communication is possible.
      Set_High_Freq_Source (HFCLK_XTAL);
      Start_High_Freq;
      while not High_Freq_Running loop
         null;
      end loop;

      Configure_Packet (S0_Field_Size_In_Byte        => False,
                        S1_Field_Size_In_Bit         => 0,
                        Length_Field_Size_In_Bit     => 8,
                        Max_Packet_Length_In_Byte    => MICROBIT_RADIO_MAX_PACKET_SIZE,
                        Static_Packet_Length_In_Byte => 0,
                        On_Air_Endianness            => Little_Endian);

      Configure_CRC (Enable        => False, --normally set to enabled
                     Length        => 2, --this values is ignored when disabled, but ideally set to 2
                     Skip_Address  => False,
                     Polynomial    => 16#AB_CD_EF#,
                     Initial_Value => 16#12_34_56#);

      Set_Logic_Addresses (Base0 => Base0Address,
                           Base1 => 16#00_00_00_00#,
                           Base_Length_In_Byte => 1, --set to illegal value of 1, should ideally be 4
                           AP0   => Group,
                           AP1   => 16#00#,
                           AP2   => 16#00#,
                           AP3   => 16#00#,
                           AP4   => 16#00#,
                           AP5   => 16#00#,
                           AP6   => 16#00#,
                           AP7   => 16#00#);

      Set_Mode (Mode);
      Set_Frequency(Frequency);
      Set_Power(Power);
      Configure_Whitening (True);
      Set_TX_Address(0);
      Set_RX_Addresses((true,false,false,false,false,false,false,false));
      Set_Nrf52FastRampup;
      Set_Packet(RxBuf.all'Address);

      -- Using shorts is much faster than manual state transition from disabled to RX state due to CPU cycles. For a manual example see nrf52 library repo
      -- Check fig. 6 in the manual
      -- The state transition is from Disabled -- trigger RXEN --> RXRU --> (ready event) --> RXIDLE -- trigger START --> RX -- (end event, packet received) --> trigger Disable so
      Enable_Shortcut (Ready_To_Start); --if event radio ready (due to done with rampup) -> auto trigger radio_start
      Enable_Shortcut (End_To_Disable); --if event end (due to packaged received) -> auto trigger radio_disabled. When disabled, EasyDMA is not writing to memory anymore which give us time to process the data and trigger the next RXEN.
      Enable_Shortcut (Address_To_RSSIstart); -- also enable RSSI sampling

      IsInit := true;
   end Setup_For_RF_nrf52;

   -----------
   -- State --
   -----------

   function State return Radio_State is
   begin
      --  return Radio_State'Enum_Val (RADIO_Periph.STATE.STATE'Enum_Rep);
      case RADIO_Periph.STATE.STATE is
         when Disabled => return Disabled;
         when Rxru => return Rx_Ramp_Up;
         when Rxidle => return Rx_Idle;
         when Rx => return Rx_State;
         when Rxdisable => return Rx_Disabled;
         when Txru => return Tx_Ramp_Up;
         when Txidle => return Tx_Idle;
         when Tx => return Tx_State;
         when Txdisable => return Tx_Disabled;
      end case;
   end State;

   ---------------------
   -- Enable_Shortcut --
   ---------------------

   procedure Enable_Shortcut (Short : Shortcut) is
   begin
      case Short is
         when Ready_To_Start =>
            RADIO_Periph.SHORTS.READY_START := Enabled;
         when End_To_Disable =>
            RADIO_Periph.SHORTS.END_DISABLE := Enabled;
         when Disabled_To_TXen =>
            RADIO_Periph.SHORTS.DISABLED_TXEN := Enabled;
         when Disabled_To_RXen =>
            RADIO_Periph.SHORTS.DISABLED_RXEN := Enabled;
         when Address_To_RSSIstart =>
            RADIO_Periph.SHORTS.ADDRESS_RSSISTART := Enabled;
         when End_To_Start =>
            RADIO_Periph.SHORTS.END_START := Enabled;
         when Address_To_BCstart =>
            RADIO_Periph.SHORTS.ADDRESS_BCSTART := Enabled;
      end case;
   end Enable_Shortcut;

   ----------------------
   -- Disable_Shortcut --
   ----------------------

   procedure Disable_Shortcut (Short : Shortcut) is
   begin
      case Short is
         when Ready_To_Start =>
            RADIO_Periph.SHORTS.READY_START := Disabled;
         when End_To_Disable =>
            RADIO_Periph.SHORTS.END_DISABLE := Disabled;
         when Disabled_To_TXen =>
            RADIO_Periph.SHORTS.DISABLED_TXEN := Disabled;
         when Disabled_To_RXen =>
            RADIO_Periph.SHORTS.DISABLED_RXEN := Disabled;
         when Address_To_RSSIstart =>
            RADIO_Periph.SHORTS.ADDRESS_RSSISTART := Disabled;
         when End_To_Start =>
            RADIO_Periph.SHORTS.END_START := Disabled;
         when Address_To_BCstart =>
            RADIO_Periph.SHORTS.ADDRESS_BCSTART := Disabled;
      end case;
   end Disable_Shortcut;



   ----------------------
   -- Get_SafeFramebuffer --
   ----------------------
   function Get_SafeFramebuffer return Framebuffer is
   begin
      return SafeFramebuffer;
   end Get_SafeFramebuffer;

    ----------------------
   -- Get_QueueDepth --
   ----------------------
   function Get_QueueDepth return UInt8 is
   begin
      return QueueDepth;
   end Get_QueueDepth;

 ----------------------
   -- Set_QueueDepth --
   ----------------------
   procedure Set_QueueDepth(newDepth : UInt8) is
   begin
      QueueDepth := newDepth;
end Set_QueueDepth;

   procedure DeepCopyIntoSafeFramebuffer (framebufferPtr : fbPtr) is
      data :Payload_Data;
   begin
      SafeFramebuffer.Length := framebufferPtr.Length;
      SafeFramebuffer.Version := framebufferPtr.Version;
      SafeFramebuffer.Group := framebufferPtr.Group;
      SafeFramebuffer.Protocol := framebufferPtr.Protocol;
      SafeFramebuffer.RSSI := framebufferPtr.RSSI;
      SafeFramebuffer.PtrNext := null;

      for i in data'Range loop
       data(i) := framebufferPtr.Payload(i);
      end loop;

      SafeFramebuffer.Payload := data;
   end DeepCopyIntoSafeFramebuffer;

   ----------------------
   -- Get_RSSIsample --
   ----------------------
   function Get_RSSIsample return UInt7 is
   begin
      return RADIO_Periph.RSSISAMPLE.RSSISAMPLE;
   end Get_RSSIsample;



    ----------------------
   -- DataReady --
   ----------------------
   function DataReady return Boolean is
   begin
	   return QueueDepth >0;
   end DataReady;

    ----------------------
   -- IsInitialized --
   ----------------------
   function IsInitialized return Boolean is
   begin
	   return IsInit;
   end IsInitialized;


   -------------------------
   -- Set_Nrf52FastRampup --
   -------------------------
   --New faster rampup features for nrf52 ONLY, can we use platform defines?
   procedure Set_Nrf52FastRampup is
   begin
      RADIO_Periph.MODECNF0.DTX := B0;
      RADIO_Periph.MODECNF0.RU := Fast;
   end Set_Nrf52FastRampup;

   ----------------
   -- Set_RSSI --
   ----------------

   procedure Set_RSSI
     (rssi_value : UInt7)
   is
   begin
      rssi := rssi_value;
   end Set_RSSI;

   ----------------
   -- Get_RSSI --
   ----------------

   function Get_RSSI return UInt7 is
   begin
      return rssi;
   end Get_RSSI;

   ----------------
   -- QueueRxBuf --
   ----------------

   procedure QueueRxBuf
   is
       p : fbPtr;
       NewRxBuf : fbPtr;
   begin

      NewRxBuf := new FrameBuffer;
      if NewRxBuf = null then --is this never null in ADA?
         return;
      end if;

      -- Store the received RSSI value in the frame
      RxBuf.all.rssi := Get_RSSI;

      -- We add to the tail of the queue to preserve causal ordering.
      RxBuf.all.PtrNext := null;

      if RxQueue = null then
     		RxQueue := RxBuf;
      else
          p := RxQueue;

          while p.all.PtrNext /= null  loop
             p := p.all.PtrNext;
          end loop;

		    p.all.PtrNext := RxBuf;
	   end if;

	-- Increase our received packet count
	QueueDepth := QueueDepth +1;

   -- Allocate a new buffer for the receiver hardware to use. the old on will be passed on to higher layer protocols/apps.
	RxBuf := newRxBuf;

   end QueueRxBuf;


   ----------------
   -- Set_Packet --
   ----------------

   procedure Set_Packet
     (Address : System.Address)
   is
   begin
      RADIO_Periph.PACKETPTR := UInt32 (To_Integer (Address));
   end Set_Packet;

   -------------------
   -- Set_Frequency --
   -------------------

   procedure Set_Frequency (F : Radio_Frequency_MHz) is
   begin
      RADIO_Periph.FREQUENCY.FREQUENCY :=
        UInt7 (F - Radio_Frequency_MHz'First);
   end Set_Frequency;

   ---------------
   -- Set_Power --
   ---------------

   procedure Set_Power (P : Radio_Power) is
   begin
      RADIO_Periph.TXPOWER.TXPOWER :=
        TXPOWER_TXPOWER_Field'Enum_Val (P'Enum_Rep);
   end Set_Power;

   --------------
   -- Set_Mode --
   --------------

   procedure Set_Mode (Mode : Radio_Mode) is
   begin
      RADIO_Periph.MODE.MODE := (case Mode is
                                    when Nordic_1MBIT => Nrf_1Mbit,
                                    when Nordic_2MBIT => Nrf_2Mbit,
                                    when Nordic_250KBIT => Nrf_250Kbit,
                                    when BLE_1MBIT => Ble_1Mbit);
   end Set_Mode;

   -------------------------
   -- Set_Logic_Addresses --
   -------------------------

   procedure Set_Logic_Addresses
     (Base0, Base1 : HAL.UInt32;
      Base_Length_In_Byte : Base_Address_Lenght;
      AP0, AP1, AP2, AP3, AP4, AP5, AP6, AP7 : HAL.UInt8)
   is
   begin
      RADIO_Periph.BASE0 := Base0;
      RADIO_Periph.BASE1 := Base1;
      RADIO_Periph.PCNF1.BALEN := UInt3 (Base_Length_In_Byte);
      RADIO_Periph.PREFIX0.Arr := (AP0, AP1, AP2, AP3);
      RADIO_Periph.PREFIX1.Arr := (AP4, AP5, AP6, AP7);
   end Set_Logic_Addresses;

   -----------------------------
   -- Translate_Logic_Address --
   -----------------------------

   procedure Translate_Logic_Address (Logic_Addr : Radio_Logic_Address;
                                      Base       : out HAL.UInt32;
                                      Prefix     : out HAL.UInt8)
   is
   begin
      case Logic_Addr is
         when 0 =>
            Base := RADIO_Periph.BASE0;
         when 1 .. 7 =>
            Base := RADIO_Periph.BASE1;
      end case;
      case Logic_Addr is
         when 0 .. 3 =>
            Prefix := RADIO_Periph.PREFIX0.Arr (Integer (Logic_Addr));
         when 4 .. 7 =>
            Prefix := RADIO_Periph.PREFIX1.Arr (Integer (Logic_Addr));
      end case;
   end Translate_Logic_Address;

   --------------------
   -- Set_TX_Address --
   --------------------

   procedure Set_TX_Address (Logic_Addr : Radio_Logic_Address) is
   begin
      RADIO_Periph.TXADDRESS.TXADDRESS := UInt3 (Logic_Addr);
   end Set_TX_Address;

   --------------------------
   -- Get_RX_Match_Address --
   --------------------------

   function RX_Match_Address return Radio_Logic_Address is
   begin
      return Radio_Logic_Address (RADIO_Periph.RXMATCH.RXMATCH);
   end RX_Match_Address;

   ----------------------
   -- Set_RX_Addresses --
   ----------------------

   procedure Set_RX_Addresses (Enable_Mask : Logic_Address_Mask) is
   begin
      for Index in Enable_Mask'Range loop
         RADIO_Periph.RXADDRESSES.ADDR.Arr (Integer (Index)) :=
           (if Enable_Mask (Index) then Enabled else Disabled);
      end loop;
   end Set_RX_Addresses;

   -------------------
   -- Configure_CRC --
   -------------------

   procedure Configure_CRC (Enable        : Boolean;
                            Length        : UInt2;
                            Skip_Address  : Boolean;
                            Polynomial    : UInt24;
                            Initial_Value : UInt24)
   is
   begin
      if Enable then
         case Length is
            when 0 =>
               RADIO_Periph.CRCCNF.LEN := Disabled;
            when 1 =>
               RADIO_Periph.CRCCNF.LEN := One;
            when 2 =>
               RADIO_Periph.CRCCNF.LEN := Two;
            when 3 =>
               RADIO_Periph.CRCCNF.LEN := Three;
         end case;
      else
         RADIO_Periph.CRCCNF.LEN := Disabled;
      end if;

      RADIO_Periph.CRCCNF.SKIPADDR := (if Skip_Address then Skip else Include);
      RADIO_Periph.CRCPOLY.CRCPOLY := Polynomial;
      RADIO_Periph.CRCINIT.CRCINIT := Initial_Value;
   end Configure_CRC;

   ---------------
   -- CRC_Error --
   ---------------

   function CRC_Error return Boolean is
   begin
      return RADIO_Periph.CRCSTATUS.CRCSTATUS = Crcerror;
   end CRC_Error;

   -------------------------
   -- Configure_Whitening --
   -------------------------

   procedure Configure_Whitening (Enable        : Boolean;
                                  Initial_Value : UInt6 := 0)
   is
   begin
      RADIO_Periph.PCNF1.WHITEEN := (if Enable then Enabled else Disabled);
      RADIO_Periph.DATAWHITEIV.DATAWHITEIV :=
        16#55# or UInt7 (Initial_Value);
   end Configure_Whitening;

   ----------------------
   -- Configure_Packet --
   ----------------------

   procedure Configure_Packet
     (S0_Field_Size_In_Byte        : Boolean;
      S1_Field_Size_In_Bit         : UInt4;
      Length_Field_Size_In_Bit     : UInt4;
      Max_Packet_Length_In_Byte    : Packet_Len;
      Static_Packet_Length_In_Byte : Packet_Len;
      On_Air_Endianness            : Length_Field_Endianness)
   is
   begin
      RADIO_Periph.PCNF0.LFLEN := Length_Field_Size_In_Bit;
      RADIO_Periph.PCNF0.S0LEN := S0_Field_Size_In_Byte; --removed overwrite =1;
      RADIO_Periph.PCNF0.S1LEN := S1_Field_Size_In_Bit;
      RADIO_Periph.PCNF1.MAXLEN := Max_Packet_Length_In_Byte;
      RADIO_Periph.PCNF1.STATLEN := Static_Packet_Length_In_Byte;
      RADIO_Periph.PCNF1.ENDIAN := (if On_Air_Endianness = Little_Endian then
                                       Little
                                    else
                                       Big);
   end Configure_Packet;
end nRF.Radio;
