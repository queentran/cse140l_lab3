
module didp (
	    output [3:0] di_iMtens,  // current 10's minutes
	    output [3:0] di_iMones,  // current 1's minutes
	    output [3:0] di_iStens,  // current 10's second
	    output [3:0] di_iSones,  // current 1's second
            output       o_oneSecPluse,
            output [4:0] L3_led,     // LED Output

		//loading clock
            input        ldMtens,
            input        ldMones,
            input        ldStens,
            input        ldSones,
	    input [3:0]  ld_num,
		
            input        dicSelectLEDdisp,
	    input 	     dicRun,      // 1: clock should run, 0: clock freeze	
            input        i_oneSecPluse, // 0.5 sec on, 0.5 sec off		
	    input 	     i_oneSecStrb,  // one strobe per sec
	    input 	     rst,
	    input 	     clk 	  
	);

    assign o_oneSecPluse = i_oneSecPluse & dicRun;
    wire clkSecStrb = i_oneSecStrb & dicRun;

    //(dp.1) change this line and add code to set 3 more wires: StensIs5, MonesIs9, MtensIs5
    //   these 4 wires determine if digit reaches 5 or 9.  10% of points assigned to Lab3
    wire SonesIs9 = (~|(di_iSones[3:0] ^ 4'b1001)) ? 1'b1 : 1'b0; // ld_num = 4'd9
    wire StensIs5 = (~|(di_iStens[3:0] ^ 4'b0101)) ? 1'b1 : 1'b0; // ld_num = 4'd5
    wire MonesIs9 = (~|(di_iMones[3:0] ^ 4'b1001)) ? 1'b1 : 1'b0; // ld_num = 4'd9
    wire MtensIs5 = (~|(di_iMtens[3:0] ^ 4'b0101)) ? 1'b1 : 1'b0; // ld_num = 4'd5

    //(dp.2) add code to set 3 more wires: rollStens, rollMones, rollMtens
    //   these 4 wires determine if digit shall be rolled back to 0 : 10% of points assigned to Lab3
    wire rollSones = SonesIs9;
    wire rollStens = StensIs5&SonesIs9;
    wire rollMones = MonesIs9&StensIs5&SonesIs9;
    wire rollMtens = MtensIs5&MonesIs9&StensIs5&SonesIs9;

    //(dp.3) add code to set 3 more wires: countEnStens, countEnMones, countEnMtens
    //   these 4 wires generate a strobe to advance counter: 10% of points assigned to Lab3
    wire countEnSones = clkSecStrb; // enable the counter Sones
    wire countEnStens = clkSecStrb&rollSones;
    wire countEnMones = clkSecStrb&rollStens;
    wire countEnMtens = clkSecStrb&rollMones;
 
    //(dp.4) add code to set sTensDin, mOnesDin, mTensDin
    //   0% of points assigned to Lab3, used in Lab4
    wire [3:0] sOnesDin = ldSones ? ld_num : 4'b0;
    wire [3:0] sTensDin = ldStens ? ld_num : 4'b0;
    wire [3:0] mOnesDin = ldMones ? ld_num : 4'b0;
    wire [3:0] mTensDin = ldMtens ? ld_num : 4'b0;

   		
    //(dp.5) add code to generate digital clock output: di_iStens, di_iMones di_iMtens 
    //   20% of points assigned to Lab3
    countrce didpSones (.q(di_iSones),          .d(sOnesDin), 
                        .ld(rollSones|ldSones), .ce(countEnSones|ldSones), 
                        .rst(rst),              .clk(clk));
    countrce didpStens (.q(di_iStens),          .d(sTensDin), 
                        .ld(rollStens|ldStens), .ce(countEnStens|ldStens), 
                        .rst(rst),              .clk(clk));
    countrce didpMones (.q(di_iMones),          .d(mOnesDin), 
                        .ld(rollMones|ldMones), .ce(countEnMones|ldMones), 
                        .rst(rst),              .clk(clk));
    countrce didpMtens (.q(di_iMtens),          .d(mTensDin), 
                        .ld(rollMtens|ldMtens), .ce(countEnMtens|ldMtens), 
                        .rst(rst),              .clk(clk));


    ledDisplay ledDisp00 (
        .L3_led(L3_led),
        .di_Mtens(di_iMtens),
        .di_Mones(di_iMones),
        .di_Stens(di_iStens),
        .di_Sones(di_iSones),
        .dicSelectLEDdisp(dicSelectLEDdisp),
        .oneSecPluse(o_oneSecPluse),
        .rst(rst),
        .clk(clk)
    );
   
endmodule


//
// LED display
// select what to display on the real LEDs
// 10's minutes, 1's minutes
// 10's seconds, 1's seconds
// dicSelectLEDdisp will move from one to another.
//
module ledDisplay (
        output[4:0] L3_led,
        input [3:0] di_Mtens,
        input [3:0] di_Mones,
        input [3:0] di_Stens,
        input [3:0] di_Sones,
        input  dicSelectLEDdisp, //1: LED is move to display the next digit of clk 
        input  oneSecPluse, 
        input  rst,
        input  clk
    );
	
	//dp.6 add code to select output to LED	
    //     10% of points assigned to lab3
    //wire  [1:0] prev_selLed = {1'b0, dicSelectLEDdisp};
    wire  [1:0] selLed;
    //countrce #(2) cnt1(selLed, prev_selLed, rst, dicSelectLEDdisp, rst, clk); 
    countrce #(2) cnt1 (.q(selLed), .d(1'b0), .ld(1'b0), 
			.ce(dicSelectLEDdisp), .rst(rst), .clk(clk));

    /*always @ (posedge clk) begin
	if (dicSelectLEDdisp)
	    selLed <= selLed ^ dicSelectLEDdisp;
    end*/

    assign L3_led = 
        (~|(selLed ^ 2'b00)) ? {oneSecPluse, di_Sones} :
        (~|(selLed ^ 2'b01)) ? {oneSecPluse, di_Stens} :
        (~|(selLed ^ 2'b10)) ? {oneSecPluse, di_Mones} :
        {oneSecPluse, di_Mtens};
		
endmodule
