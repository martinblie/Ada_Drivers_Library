with Ada.Real_Time; use Ada.Real_Time;
with Ada.Execution_Time;
with Ada.Text_IO; use Ada.Text_IO;

package body Brain is

   task body Sense is
      --Only for calculating schedule--
      StartTimer : Ada.Execution_Time.CPU_Time;
      EndTimer : Ada.Execution_Time.CPU_Time;
      DoOnce: Boolean := False;
      Time_Now : Ada.Real_Time.Time;
   begin
      --Only for calculating schedule--
      --Should start at 0 when task is created, and increase only when used by CPU
      StartTimer := Ada.Execution_Time.Clock;

      Time_Now := Ada.Real_Time.Clock;
      delay until Time_Now + Ada.Real_Time.Milliseconds(1000); --some time to startup to allow eg. a sensor or servo to stabilize

      loop
         Time_Now := Ada.Real_Time.Clock;

         Put_Line ("Sensing...");
         delay 0.01; -- Set C = 10 ms
         delay until Time_Now + Ada.Real_Time.Milliseconds(200);

         --Only for calculating schedule--
         if DoOnce = False then
            DoOnce := True;
            EndTimer := Ada.Execution_Time.Clock;
            Put_Line("Clock:" & EndTimer'Img);
         end if;
      end loop;
   end Sense;

   task body Think is
      Time_Now : Ada.Real_Time.Time;
   begin

      loop
         Time_Now := Ada.Real_Time.Clock;

         Put_Line ("Thinking...");
         delay 0.01; -- Set C = 10 ms
         delay until Time_Now + Ada.Real_Time.Milliseconds(200);
      end loop;
   end Think;

   task body Act is
      Time_Now : Ada.Real_Time.Time;
   begin

      loop
         Time_Now := Ada.Real_Time.Clock;

         Put_Line ("Acting...");
         delay 0.01; -- Set C = 10 ms
         delay until Time_Now + Ada.Real_Time.Milliseconds(200);
      end loop;
   end Act;

end Brain;
