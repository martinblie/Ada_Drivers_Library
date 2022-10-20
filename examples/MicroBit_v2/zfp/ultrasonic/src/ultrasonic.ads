With MicroBit.IOs; use MicroBit.IOs;

package Ultrasonic is

   type Distance_cm is range 0 .. 400; -- if < 2 it is invalid
   
   function Read return Distance_cm;
   
   procedure SendTriggerPulse;
   
   procedure Setup (trigger_pin : Pin_Id; echo_pin : Pin_Id);
   
   function WaitForEcho return Integer;
   
   function ConvertEchoToDistance (echo_time_us : Integer) return Distance_cm;
end Ultrasonic;
