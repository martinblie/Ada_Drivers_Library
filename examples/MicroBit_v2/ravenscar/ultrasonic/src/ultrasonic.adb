with MicroBit.TimeHighspeed; use MicroBit.TimeHighspeed;
with MicroBit.IOsForTasking; use MicroBit.IOsForTasking;
with NRF_SVD.GPIO; use NRF_SVD.GPIO;
use MicroBit;
with HAL; use HAL;
package body Ultrasonic is

   trigger_pin_device : Integer;
   echo_pin_device : Integer;
   result : Distance_cm := 0;

   procedure Setup (trigger_pin : Pin_Id; echo_pin : Pin_Id) is
      dummy : Boolean; -- we dont use this variable for anything, but need it to setup the input (bad API)
   begin
      Set(trigger_pin, False); --set to output
      dummy := Set(echo_pin); --set to input

      trigger_pin_device := Points(trigger_pin).Pin;
      echo_pin_device := Points(echo_pin).Pin;
   end Setup;

   function Read return Distance_cm is
      echo_time_us : Integer;
   begin
      SendTriggerPulse; --blocking!
      echo_time_us := WaitForEcho; --blocking!
      result := ConvertEchoToDistance(echo_time_us);

      --Delay needs to be at least 23ms for max range of 400cm. If only interested in shorter ranges, shorter delay can be set
      return result;
   end Read;

   procedure SendTriggerPulse is
   begin
      GPIO_Periph.OUT_k.Arr (trigger_pin_device) := high;
      Delay_Us(10); -- Not 10 us, more about 11.4us (10 us+ required by ultrasonic spec)
                       --Higher delays become more accurate
                      -- If you use direct pin assignment setting a pin once before the loop (to be output, see init)
                      -- and using GPIO_Periph.OUT_k.Arr (1) := high or low (use With NRF_SVD.GPIO; use NRF_SVD.GPIO;)
                      -- 2 us pulses can be reached if Delay is set to 1. These are blocking calls and implemented using assembly NOP instructions so not precise
                      -- A 64MHz clock (systick) signal would be more accurate to use and count 64 pulses for 1 us.
                      -- There will always be a slight delay when toggling a pin. Toggling in hardware using use PPI and TE (eg. automatically reacting to rising/falling edge has the least delay.
      GPIO_Periph.OUT_k.Arr (trigger_pin_device) := low;
      end SendTriggerPulse;

   function WaitForEcho return Integer is
      delayCounter :Integer := 0;
   begin
      --wait for echo to start
      while GPIO_Periph.IN_k.Arr(echo_pin_device) = low loop
         null;
      end loop;

      --wait for echo to end
      while GPIO_Periph.IN_k.Arr(echo_pin_device) = high loop
         Delay_Us(58);  --wait for 58 us or 1 cm distance and check again
         delayCounter := delayCounter + 1;
      end loop;

      return delayCounter * 58; --high time in us
   end WaitForEcho;

   function ConvertEchoToDistance (echo_time_us : Integer) return Distance_cm is
    temp_result : Integer;
   begin
      -- Distance formula see: https://cdn.sparkfun.com/datasheets/Sensors/Proximity/HCSR04.pdf
      temp_result := echo_time_us/ 58;

      if temp_result > 400 then
         temp_result := 400;
      end if;

      if temp_result < 2 then
         temp_result := 0;
      end if;

      return Distance_cm(temp_result);
   end ConvertEchoToDistance;
end Ultrasonic;
