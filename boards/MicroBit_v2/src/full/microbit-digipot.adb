with MicroBit.I2C;
with DigipotModel;

package body MicroBit.Digipot is

   Dp  : DigipotModel.Digipot_Device (MicroBit.I2C.Controller);

   procedure Initialize;

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize is
   begin
      if not MicroBit.I2C.Initialized then
         MicroBit.I2C.Initialize;
      end if;

      --Dp.Configure (LSM303AGR.Freq_400);
   end Initialize;

   ----------
   -- Data --
   ----------

   function Read_Resistance return Integer
   is (Dp.Read_Resistance);

   --function MagData return LSM303AGR.All_Axes_Data
   --is (Acc.Read_Magnetometer);

begin
   Initialize;
end MicroBit.Digipot;
