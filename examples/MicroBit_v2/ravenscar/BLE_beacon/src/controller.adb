
with Ada.Real_Time; use Ada.Real_Time;
--with Ada.Execution_Time;
with Ada.Text_IO; use Ada.Text_IO;

package body Controller is


   task body Sense is
      --Only for calculating schedule--
      --StartTimer : Ada.Execution_Time.CPU_Time;
      --EndTimer : Ada.Execution_Time.CPU_Time;
      --ExeTime : Ada.Execution_Time.CPU_Time;

      Time_Now : Ada.Real_Time.Time;
   begin
      --Only for calculating schedule--
      --Should start at 0 when task is created, and increase only when used by CPU
      --StartTimer := Ada.Execution_Time.Clock;

      Time_Now := Ada.Real_Time.Clock;
      delay until Time_Now + Ada.Real_Time.Milliseconds(1000);
      loop
         Time_Now := Ada.Real_Time.Clock;

         Put_Line ("Sensing...");

         delay until Time_Now + Ada.Real_Time.Milliseconds(500);

         --Only for calculating schedule--
         --EndTimer := Ada.Execution_Time.Clock;
      end loop;
   end Sense;

   task body Act is
      Time_Now : Ada.Real_Time.Time;
   begin

      loop
         Time_Now := Ada.Real_Time.Clock;

           Put_Line ("Acting...");

         delay until Time_Now + Ada.Real_Time.Milliseconds(200);
      end loop;
   end Act;

end Controller;
