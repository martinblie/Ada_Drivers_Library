package mycontroller_empty is

   type Directions is (Forward, Stop);
   
   task Sense with Priority => 1;
  
   task Think with Priority=> 2;
   
   task Act with Priority=> 3;

   protected MotorDriver is
      function GetDirection return Directions;
      procedure SetDirection (V : Directions);
   private
      DriveDirection : Directions := Stop;
   end MotorDriver;
end mycontroller_empty;
