with HAL;     use HAL;
with HAL.I2C; use HAL.I2C;

private with Ada.Unchecked_Conversion;

package DigipotModel is

   type Register_Address is new UInt8;
   type Device_Identifier is new UInt8;

   type Digipot_Device (Port : not null Any_I2C_Port) is
     tagged limited private;

   procedure Set_Resistance (This : Digipot_Device; Resistance : Integer);

   function Read_Resistance (This : Digipot_Device) return Integer;

private
   type Digipot_Device (Port : not null Any_I2C_Port)
   is tagged limited null record;

   Digipot_Address   : constant I2C_Address := 16#20#;
   CTRL_Address : constant Register_Address := 16#00#; -- 30 request Channel 1

   type CTRL_Register is record
      c3  : Bit   := 0; --control-bits
      c2  : Bit   := 0;
      c1  : Bit   := 0;
      c0  : Bit   := 0;
      a3  : Bit   := 0; --address-bits
      a2  : Bit   := 0;
      a1  : Bit   := 0;
      a0  : Bit   := 0;
   end record;

   type DATA_Register is record
      d7  : Bit   := 0; --data-bits
      d6  : Bit   := 0;
      d5  : Bit   := 0;
      d4  : Bit   := 0;
      d3  : Bit   := 0;
      d2  : Bit   := 0;
      d1  : Bit   := 0;
      d0  : Bit   := 0;
   end record;

   function To_UInt8 is new Ada.Unchecked_Conversion
     (DATA_Register, UInt8);
   function To_Reg is new Ada.Unchecked_Conversion
     (UInt8, DATA_Register);

end DigipotModel;
