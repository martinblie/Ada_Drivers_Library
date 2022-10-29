--Important: use Microbit.IOsForTasking for controlling pins as the timer used there is implemented as an protected object
With MicroBit.IOsForTasking; use MicroBit.IOsForTasking; -- we only depend on this for Analog_Value definition and Pin_Id. This could be abstracted so there is a smaller dependency!

package MyMotorDriver is

   type Directions is (Forward, Stop); --only two are implemented but many configuration are possible with mecanum wheels
   
   type DriveInstruction is record
           LeftFrontSpeed: Analog_Value;
           LeftFrontPin1 : Boolean;
           LeftFrontPin2 : Boolean;
           LeftBackSpeed : Analog_Value;
           LeftBackPin1 : Boolean;
           LeftBackPin2 : Boolean;
      
           RightFrontSpeed : Analog_Value;
           RightFrontPin1 : Boolean;
           RightFrontPin2 : Boolean;
           RightBackSpeed : Analog_Value;
           RightBackPin1 : Boolean;
           RightBackPin2 : Boolean;
   end record;
   
   type MotorControllerPins is record
           LeftFrontSpeedEnA : Pin_Id;
           LeftFrontPin1In1 : Pin_Id;
           LeftFrontPin2In2 : Pin_Id;
           LeftBackSpeedEnB : Pin_Id;
           LeftBackPin1In3 : Pin_Id;
           LeftBackPin2In4 : Pin_Id;
                          
           RightFrontSpeedEnA : Pin_Id;
           RightFrontPin1In1 : Pin_Id;
           RightFrontPin2In2 : Pin_Id;
           RightBackSpeedEnB : Pin_Id;
           RightBackPin1In3 : Pin_Id;
           RightBackPin2In4 : Pin_Id;
   end record;
       
   protected MotorDriver is
      -- see https://learn.adacore.com/courses/Ada_For_The_Embedded_C_Developer/chapters/03_Concurrency.html#protected-objects
      function GetDirection return Directions; -- concurrent read operations are now possible
      function GetMotorPins return MotorControllerPins; -- concurrent read operations are now possible

      procedure SetMotorPins (V : MotorControllerPins); -- but concurrent read/write are not!
      procedure SetDirection (V : Directions); -- but concurrent read/write are not!
   private
      DriveDirection : Directions := Stop;
      Pins : MotorControllerPins;
   end MotorDriver;

end MyMotorDriver;
