using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using TMPro;

namespace USN
{
    public class GameController : MonoBehaviour
    {
        public float sensitivityAccX = 1; //0.36
        public float sensitivityAccY = 1; //0.36
        public float sensitivityAccZ = 1; //0.36
        public float sensitivityMagX = 1; //0.36
        public float sensitivityMagY = 1; //0.36
        public float sensitivityMagZ = 1; //0.36
        public Led[] Leds;
        public CustomButton[] Btns;
        public bool useAccelerometer = false;
        public bool useMagnetometer = false;
        public bool useLeds = true;
        public bool useButtons = true;
        public bool useWorldBackground = false;

        //stats
        public int btnAcount = 0;
        public int btnBcount = 0;
        public int btnLcount = 0;

        //ui
        public TMP_Text btnAcountLabel;
        public TMP_Text btnBcountLabel;
        public TMP_Text btnLcountLabel;

        public TMP_Text accelXLabel;
        public TMP_Text accelYLabel;
        public TMP_Text accelZLabel;

        public TMP_Text magnetoXLabel;
        public TMP_Text magnetoYLabel;
        public TMP_Text magnetoZLabel;

        void Start()
        {
            SerialController.Init();
        }

        private void Update()
        {
            Receive();

            if (useWorldBackground)
                Camera.main.clearFlags = CameraClearFlags.Skybox;
            else
                Camera.main.clearFlags = CameraClearFlags.SolidColor;
        }

        void Receive()
        {
            var messageCount = SerialController.RX.Count;
            for (int i = 0; i < messageCount; i++)
            {
                string message;
                SerialController.RX.TryDequeue(out message);


                //Syntax:  "instruction;param1,value;param2,value;---;paramN,value"
                //Example: "leds;led1_1, off;led5_5,on"
                //This instruction is related to leds, stating to switch off led 1_1 (top left corner) and switch on led5_5 (bottom right corner).

                //Syntax Benefit: it is readable over the serial port and can deal with all messages from 1 bit IO's to accelerometers floats and debug strings
                //Syntax Drawback: Cumbersome to implement at the ADA side and very communication heavy.
                //Improved Syntax: Only send a package of 20 bytes +1 byte end of line, meaning that every byte is a MB_pin being high or low
                //Then the syntax is not as readible over the serial port but still somewhat readable AND the message can then be parsed at C# side where there
                //is a lot of compute power. It is easily expendable if you want to send all 47 pins.
                //It is easily implementable at the ADA side using a With Microbit.Simulation package in your main.adb file using a task with highest priority.
                //At at signal rate of 115.000 Baud, with binary signals one Baud is one bit per second, so in our case the bit rate is 115.000 bps
                //in Bytes per second this is 115.000 / 8 = 14.375 Bytes per second.
                //Since we have 21 bytes, we can update at the ADA side with a max rate (frequency) of: 684 times per second.
                //This results in a "delay until" in the Microbit.Simulation of about 1.46 miliseconds. This is fast enough for most real-time applications.  

                //Note that this compressed format does not address multibit packages. For example an accelerometer will need to send a float
                //We could signal that the 21 byte package is actually larger as it also includes a few floats from which we know the size.
                //If the MBpin of the accelerometer is 1, then we expect an X number of extra bits immediately following that 1. Note that this is careful package engineering!
                //We could do the same for a debug message as a string by a convention that the last bit (in this case we would need 22 bits + 1 bit for end of line)
                //is always reserved for debug message. If this is 1 then a --variable amount!-- of bits follow with the second last bit being the end of the string
                //and the last bit being the end of line. 

                var Instruction = new Instruction(message);

                switch (Instruction.Name)
                {
                    case Instruction.InstructionSet.BTN:
                        {
                            if (useButtons)
                            {
                                foreach (var btn in Instruction.Params)
                                {
                                    switch (btn.Name)
                                    {
                                        case "A":
                                            {
                                                if ((btn.Value.Equals("pressed")) && (Btns[0].isPressed == false))
                                                {
                                                    btnAcount++;
                                                    btnAcountLabel.text = btnAcount.ToString();
                                                    Btns[0].Press(true);
                                                }

                                                if (btn.Value.Equals("released"))
                                                    Btns[0].Press(false);
                                            }
                                        break;
                                        case "B":
                                            {
                                                if ((btn.Value.Equals("pressed")) && (Btns[1].isPressed == false))
                                                {
                                                    btnBcount++;
                                                    btnBcountLabel.text = btnBcount.ToString();
                                                    Btns[1].Press(true);
                                                }

                                                if (btn.Value.Equals("released"))
                                                    Btns[1].Press(false);
                                            }
                                            break;
                                        case "L":
                                            {
                                                //not fully implemented, incorrect logo release detected while pressing logo!
                                                if ((btn.Value.Equals("pressed")) && (Btns[2].isPressed == false))
                                                {
                                                    btnLcount++;
                                                    btnLcountLabel.text = btnLcount.ToString();
                                                    //Btns[2].GetComponent<Btn>().Press(true);
                                                }

                                                if (btn.Value.Equals("released"))
                                                    Btns[2].Press(false);
                                                //else
                                                //Btns[2].GetComponent<Btn>().Press(false);
                                            }
                                            break;
                                    }
                                    
                                }
                            }
                        }
                        break;
                    case Instruction.InstructionSet.LED:
                        {
                            if (useLeds)
                            {
                                foreach (var led in Instruction.Params)
                                {
                                    //use id of led and index of ledArray. So led 1 is R1_C1, led 2 is R2_C2, etc)
                                    int ledId = int.Parse(led.Name);

                                    bool ledStatus = bool.Parse(led.Value);
                                    Leds[ledId].Switch(ledStatus);
                                }
                            }
                        }
                        break;
                    case Instruction.InstructionSet.ACC:
                        {
                            if (useAccelerometer)
                            {
                                float x =  float.Parse(Instruction.Params[0].Value) * sensitivityAccX;
                                float y = -float.Parse(Instruction.Params[1].Value) * sensitivityAccY;
                                float z =  float.Parse(Instruction.Params[2].Value) * sensitivityAccZ;
                                
                                accelXLabel.text = x.ToString();
                                accelYLabel.text = y.ToString(); 
                                accelZLabel.text = z.ToString(); //we dont use z coordinate (which is y coordinate in Unity). use Compass.
                                RotateObject(x, this.transform.rotation.eulerAngles.y, y);
                            }
                            else
                                RotateObject(0, this.transform.rotation.eulerAngles.y, 90);
                        }
                        break;
                    case Instruction.InstructionSet.MAG:
                        {
                            if (useMagnetometer)
                            {
                                float x = float.Parse(Instruction.Params[0].Value) * sensitivityMagX;
                                float y = -float.Parse(Instruction.Params[1].Value) * sensitivityMagY;
                                float z = float.Parse(Instruction.Params[2].Value) * sensitivityMagZ;

                                magnetoXLabel.text = x.ToString(); //we dont use x coordinate. use Accel.
                                magnetoYLabel.text = y.ToString(); //we dont use y coordinate. Use Accel. 
                                magnetoZLabel.text = z.ToString(); 
                                RotateObject(this.transform.rotation.eulerAngles.x, z, this.transform.rotation.eulerAngles.z);
                            }
                            else
                                RotateObject(this.transform.rotation.eulerAngles.x, 0, this.transform.rotation.eulerAngles.z);
                        }
                        break;
                    default:
                        break;
                }

              
            }
        }

        private void RotateObject(float x, float y, float z)
        {
            transform.rotation = Quaternion.Euler(x, y, z);
        }

        private void OnApplicationQuit()
        {
            SerialController.Close();
        }
    }

    public class Instruction
    {
        public enum InstructionSet
        {
            LED,
            ACC,
            MAG,
            BTN, 
            ERR //ERROR
        }

        public InstructionSet Name;
        public InstructionParams[] Params;
        public Instruction(string message)
        {
            bool hasError = false; ;
            var parts = message.Split(';');

            var parseSuccessful = Enum.TryParse(parts[0], out Name);
            if (parseSuccessful)
            {
                Params = new InstructionParams[parts.Length - 2];

                for (int i = 1; i < parts.Length-1; i++)
                {
                    var paramParts = parts[i].Split(',');
                    //sanity check
                    if (paramParts.Length == 2)
                        Params[i-1] = new InstructionParams(paramParts[0], paramParts[1]);
                    else
                    {
                        hasError = true;
                        break;
                    }
                }
            }
            else
            {
                hasError = true;
            }

            //sanity check
            if ((Name.Equals(InstructionSet.ACC) && Params.Length != 3) ||
                (Name.Equals(InstructionSet.MAG) && Params.Length != 3) ||
                (Name.Equals(InstructionSet.LED) && Params.Length < 1) ||
                (Name.Equals(InstructionSet.BTN) && Params.Length < 1))
            {
                hasError = true;
            }

            if (hasError)
            {
                Name = InstructionSet.ERR;
                Debug.Log("Warning: instruction: " + parts[0] + " had incorrect syntax and will fail silently. Message was:" + message);
            }
        }
    }
    
    public struct InstructionParams
    {
        public string Name;
        public string Value;

        public InstructionParams(string name, string value)
        {
            Name = name;
            Value = value;
        }
    }
}
