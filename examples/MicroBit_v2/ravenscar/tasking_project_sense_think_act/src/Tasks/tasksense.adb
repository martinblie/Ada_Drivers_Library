With Ada.Real_Time; use Ada.Real_Time;

package body TaskSense is

    task body sense is
      myClock : Time;
   begin
      loop
         myClock := Clock; --important to get current time such that the period is exactly 200ms.
                           --you need to make sure that the instruction NEVER takes more than this period. 
                           --make sure to measure how long the task needs, see Tasking_Calculate_Execution_Time example in the repository.
                           --What if for some known or unknown reason the execution time becomes larger?
                           --When Worst Case Execution Time (WCET) is overrun so higher than your set period, see : https://www.sigada.org/ada_letters/dec2003/07_Puente_final.pdf
                           --In this template we put the responsiblity on the designer/developer.
         delay (0.024); --simulate a sensor eg the ultrasonic sensors needs at least 24ms for 400cm range.
         Brain.SetMeasurementSensor1 (10); -- random value, hook up a sensor here!
         Brain.SetMeasurementSensor2 (1);
            
         delay until myClock + Milliseconds(200); --random period
      end loop;
   end sense;

end TaskSense;
