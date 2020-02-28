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
//Finite State Machine of Control Path
// using 3 always 
module dicClockFsm (
		output reg dicRun,     // clock is running //1: clicking, 0: disable
		output reg dicDspMtens,
		output reg dicDspMones,
		output reg dicDspStens,
		output reg dicDspSones, //presentable
        input      det_cr,
        input      det_S,      // S/s detected
		input      rst,//reset key
		input      clk
    );

    reg  cState;
    reg  nState;

    // only 2 states:
    //  RUN: dicRun = 1;  dicDspMtens = 1; dicDspMones = 1; dicDspStens = 1; dicDspSones= 1;
    //  STOP: dicRun = 0; dicDspMtens = 1; dicDspMones = 1; dicDspStens = 1; dicDspSones= 1;
    localparam
    STOP    =1'b0, 
    RUN     =1'b1;
   
   
    //
    // state machine next state
    //
    //FSM.1 add code to set nState to STOP or RUN
    //      if det_S -- nState = RUN
    //      if det_cr -- nState = STOP
    //      5% of points assigned to lab3
    always @(*) begin
        if (rst)
	        nState = STOP;
        else begin
	    nState = 1'bx;
            case (cState)
        	RUN:
        	begin
		    nState = (det_cr) ? STOP : RUN;
                end 
	        STOP:
	        begin
		    nState = //(det_cr|rst) ? STOP :
			     (det_S) ? RUN : STOP;
	        end
	        default :
	            nState = STOP;
	    endcase
	end
    end

    //
    // state machine outputs
    //
    //FSM.2 add code to set the output signals of 
    //      STOP and RUN states
	//      5% of points assigned to Lab3
    always @(*) begin
        dicRun = 0;
        dicDspMtens = 0;
        dicDspMones = 0;
        dicDspStens = 0;
        dicDspSones = 0;
        case (cState)
	        STOP : begin
		    dicRun = 0; 
		    dicDspMtens = 1; 
		    dicDspMones = 1; 
		    dicDspStens = 1;
	            dicDspSones = 1;	    
	        end
	        RUN : begin
	            dicRun = 1;
		    dicDspMtens = 1; 
		    dicDspMones = 1; 
		    dicDspStens = 1; 
	            dicDspSones = 1;
	        end
        endcase
   end

   always @(posedge clk) begin
      cState <= nState;
   end
   
endmodule
