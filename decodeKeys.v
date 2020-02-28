
// --------------------------------------------------------------------
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
// --------------------------------------------------------------------
// Copyright (c) 2019 by UCSD CSE 140L
// --------------------------------------------------------------------
//
// Permission:
//
//   This code for use in UCSD CSE 140L.
//   It is synthesisable for Lattice iCEstick 40HX.  
//
// Disclaimer:
//
//   This Verilog source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  
//
// -------------------------------------------------------------------- //           
//                     Lih-Feng Tsaur
//                     Bryan Chin
//                     UCSD CSE Department
//                     9500 Gilman Dr, La Jolla, CA 92093
//                     U.S.A
//
// --------------------------------------------------------------------
//
//
//  decodeKeys
//
// decode the 8 bit ascii input charData when
// charDataValid is asserted.
// specifically, we decode
//   'ESC' 
//   '0-9'
//   '0-5'
//   'CR' - stop (carriage return)
//   '@'
//   'a'
//   'l' 
//   's''S' -- start
//   'n''N' -- select LED 
//
module decodeKeys(
        output wire     det_esc,
        output wire     det_num,
        output wire     det_num0to5, 
        output wire     det_cr,
        output wire     det_atSign,
        output wire     det_A,
        output wire     det_L,
        output wire     det_N,
        output wire     det_S,
        input wire[7:0] charData,
        input wire      charDataValid
    );

   // Key.1 add code to detect input keys
   //   5% of points assigned to Lab3
   wire b0_0 = ~charData[0];
   wire b1_0 = ~charData[1];
   wire b2_0 = ~charData[2];
   wire b3_0 = ~charData[3];
   wire b4_0 = ~charData[4];
   wire b5_0 = ~charData[5];
   wire b6_0 = ~charData[6];
   wire b7_0 = ~charData[7];
   wire b0_1 = charData[0];
   wire b1_1 = charData[1];
   wire b2_1 = charData[2];
   wire b3_1 = charData[3];
   wire b4_1 = charData[4];
   wire b5_1 = charData[5];
   wire b6_1 = charData[6];
   wire b7_1 = charData[7];

   // esc - 1b = 8'd27
   assign det_esc = &{b7_0, b6_1, b4_0, b3_0, b2_0, b1_0, b0_1} & charDataValid;

   // 0-5 0x30 - 0x35
   assign det_num0to5 = &{b7_0, b6_0, b5_1, b4_1, b3_0} & (&{b2_1, b1_0} | b2_0) & charDataValid;
   
   // 0-9 0x30 - 0x39
   assign det_num = &{b7_0, b6_0, b5_1, b4_1} &( b3_0 | &{b3_1, b2_0, b1_0}) &  charDataValid;      

   // 8'd13 0x0d
   assign det_cr = &{b7_0, b6_0, b5_0, b4_0, b3_1, b2_1, b1_0, b0_1} & charDataValid;

   // "A/a" = 41/61
   assign det_A = &{b7_0, b6_1, b4_0, b3_0, b2_0, b1_0, b0_1} & charDataValid;
   
   // "L/l" = 4C/6C
   assign det_L = &{b7_0, b6_1, b4_0, b3_1, b2_1, b1_0, b0_0} & charDataValid;

   // "N/n" = 4E/6E
   assign det_N = &{b7_0, b6_1, b4_0, b3_1, b2_1, b1_1, b0_0} & charDataValid;

   // "S/s" = 53/73
   assign det_S = &{b7_0, b6_1, b4_1, b3_0, b2_0, b1_1, b0_1} & charDataValid;

   // "@" = 40
   assign det_atSign = &{b7_0, b6_1, b5_0, b4_0, b3_0, b2_0, b1_0, b0_0} & charDataValid;
   
endmodule
