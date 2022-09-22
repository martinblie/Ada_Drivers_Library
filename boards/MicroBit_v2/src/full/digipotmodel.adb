package body DigipotModel is
     function Read_Register
     (This : Digipot_Device'Class; Device_Address : I2C_Address;
      Register_Addr : Register_Address) return UInt8;

   procedure Write_Register
     (This : Digipot_Device'Class; Device_Address : I2C_Address;
      Register_Addr : Register_Address; Val : UInt8);


   procedure Assert_Status (Status : I2C_Status);

   procedure Set_Resistance (This : Digipot_Device; Resistance : Integer)
   is
      Data : DATA_Register;
   begin
      Data.d0 := 0 ;
      Data.d1 := 0 ;
      Data.d2 := 0 ;
      Data.d3 := 0 ;
      Data.d4 := 0 ;
      Data.d5 := 0 ;
      Data.d6 := 0 ;
      Data.d7 := 0 ;

      This.Write_Register
        (Digipot_Address, CTRL_Address, To_UInt8 (Data));

   end Set_Resistance;

  function Read_Resistance
     (This : Digipot_Device)
      return Integer
   is
      d : UInt8;
   begin
      d := Read_Register (This, Digipot_Address, CTRL_Address);
      return
        0;
   end Read_Resistance;



   -------------------
   -- Read_Register --
   -------------------

   function Read_Register
     (This : Digipot_Device'Class; Device_Address : I2C_Address;
      Register_Addr : Register_Address) return UInt8
   is
      Data   : I2C_Data (1 .. 1);
      Status : I2C_Status;
   begin
      This.Port.Mem_Read
        (Addr          => Device_Address, Mem_Addr => UInt16 (Register_Addr),
         Mem_Addr_Size => Memory_Size_8b, Data => Data, Status => Status);
      Assert_Status (Status);

      return Data (Data'First);
   end Read_Register;

   --------------------
   -- Write_Register --
   --------------------

   procedure Write_Register
     (This : Digipot_Device'Class; Device_Address : I2C_Address;
      Register_Addr : Register_Address; Val : UInt8)
   is
      Status : I2C_Status;
   begin
      This.Port.Mem_Write
        (Addr          => Device_Address, Mem_Addr => UInt16 (Register_Addr),
         Mem_Addr_Size => Memory_Size_8b, Data => (1 => Val), Status => Status);
      Assert_Status (Status);

   end Write_Register;

   procedure Assert_Status (Status : I2C_Status) is
   begin
      if Status /= Ok then
         --  No error handling...
         raise Program_Error;
      end if;
   end Assert_Status;

end DigipotModel;
