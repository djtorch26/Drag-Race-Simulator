module chris_final (BUTTON, SW, CLOCK_50, HEX0, HEX1, HEX2, HEX3, HEX2_DP, LEDG);
	input [2:0] BUTTON;
	input [9:0] SW;
	input CLOCK_50;
	output [6:0] HEX0, HEX1, HEX2, HEX3;
	output HEX2_DP;
	output [9:0] LEDG;
	wire [5:0] gear;
	wire [13:0] speed, timer, display, normal, best;
	wire [3:0] hex3, hex2, hex1, hex0;
	wire win, clk;
	
	assign LEDG[5:0] = gear;
	assign LEDG[7] = win;
	
	gears u0 (SW[5:0], gear, BUTTON[1], SW[9], LEDG[6]);
	speed u1 (BUTTON[2], gear, SW[9], SW[8], speed, LEDG[9], LEDG[8], win);
	clk_divider u8 (CLOCK_50, clk);
	incrementer u2 (clk, speed, timer);
	best_time u9 (timer, win, SW[9], best);
	
	assign normal = (speed == 200) ? timer : speed;
	assign display = ~BUTTON[0] ? best : normal;
	assign HEX2_DP = (speed == 200) | ~BUTTON[0] ? 0 : 1;
	
	bianary_to_bcd u3 (display, hex3, hex2, hex1, hex0);
	bcd_to_seven_seg u4 (hex3, HEX3);
	bcd_to_seven_seg u5 (hex2, HEX2);
	bcd_to_seven_seg u6 (hex1, HEX1);
	bcd_to_seven_seg u7 (hex0, HEX0);
endmodule

module gears (gear_in, gear_out, clutch, rst, change);
	input [5:0] gear_in;
	input clutch, rst;
	output reg [5:0] gear_out = 0;
	output change;
	
	assign change = ((~clutch) & (gear_in[5] + gear_in[4] + gear_in[3] + gear_in[2] + gear_in[1] + gear_in[0] <= 1));
	assign gears = (gear_in[5] + gear_in[4] + gear_in[3] + gear_in[2] + gear_in[1] + gear_in[0] <= 1);
	
		always @(*)
		begin
			if (rst == 1)
					gear_out <= 0;
				else if (gears == 0)
						gear_out <= 0;
				else if (change == 1)
						gear_out <= gear_in;
				
		end
endmodule

module speed (in, gear, rst, ng, out, crash, pre_crash, win);
	input in, rst, ng;
	input [5:0] gear;
	output crash, pre_crash;
	output reg [13:0] out;
	output reg win;
	reg [7:0] crash_step;
	wire ng;
	
	assign crash = (crash_step >= 2) | ng;
		
	assign pre_crash = ((out >= 45) & (gear == 1))
		| ((out >= 80) & (gear == 2))
		| ((out >= 120) & (gear == 4))
		| ((out >= 150) & (gear == 8))
		| ((out >= 180) & (gear == 16));
	
	always @(negedge in or posedge rst)
	begin
	if (rst == 1)
			win <= 0;
		else if (out >= 199)
			win <= 1;
		else win <= 0;
	if (rst == 1)
			crash_step <= 2;
		else if (pre_crash == 1)
			crash_step <= crash_step + 1;
		else crash_step <= 0;
	if (rst == 1)
			out <= out;
		else if (crash == 1)
			out <= 0;
		else if (win == 1)
			out <= 0;
			else
			begin
				case(gear)
					0: out <= out;
					1: out <= out + 6;
					2: out <= out + 5;
					4: out <= out + 4;
					8: out <= out + 3;
					16: out <= out + 2;
					32: out <= out + 1;
				endcase
			end
	end
endmodule

module clk_divider (clk_in, clk_out);
	input clk_in;
	output reg clk_out;
	reg [28:0] count;
	
	always @(posedge clk_in)
	begin
		if (count >= 500000)
			count <= 0;
		else count <= count + 1;
		clk_out <= (count == 0);
	end
endmodule

module incrementer (clk, speed, out);
	input clk;
	input [13:0] speed;
	output reg [13:0] out;
	
	always @(posedge clk)
	begin
		if (speed == 0)
			out <= 0;
		else if (speed == 200)
			out <= out;
		else if (out == 9999)
			out <= out;
		else out <= out + 1;
	end		
endmodule

module best_time (in, win, rst, out,);
	input [13:0] in;
	input win, rst;
	output reg [13:0] out = 9999;
	
	always @(posedge win or posedge rst)
	begin
		if (rst == 1)
			out <= 9999;
			else if (in <= out)
				out <= in;
				else
					out <= out;
	end
endmodule

module bianary_to_bcd (in, out3, out2, out1, out0);
	input [13:0] in;
	output reg [3:0] out3, out2, out1, out0;
	
	reg [29:0] shift;
	integer i;
	
	always @(in)
	begin
		shift[29:14] = 0;
		shift[13:0] = in;
		
		for (i=0; i<14; i=i+1)
		begin
			if (shift[17:14] >= 5)
				shift[17:14] = shift[17:14] + 3;
			if (shift[21:18] >= 5)
				shift[21:18] = shift[21:18] + 3;
			if (shift[25:22] >= 5)
				shift[25:22] = shift[25:22] + 3;
			if (shift[29:26] >= 5)
				shift[29:26] = shift[29:26] + 3;
			shift = shift <<1;
		end
		out3 = shift[29:26];
		out2 = shift[25:22];
		out1 = shift[21:18];
		out0 = shift[17:14];
	end
endmodule

module bcd_to_seven_seg(in, realout);
	input [3:0]in;
	output [6:0] realout;
	reg [6:0]out;
	
	assign realout = ~out;
	
	always @(in) begin
		case (in)
			// WXYZ            GFEDCBA
			4'b0000: out <= 7'b0111111;
			4'b0001: out <= 7'b0000110;
			4'b0010: out <= 7'b1011011;
			4'b0011: out <= 7'b1001111;
			4'b0100: out <= 7'b1100110;
			4'b0101: out <= 7'b1101101;
			4'b0110: out <= 7'b1111101;
			4'b0111: out <= 7'b0000111;
			4'b1000: out <= 7'b1111111;
			4'b1001: out <= 7'b1100111;
			default: out <= 7'bx;
		endcase
	end
endmodule
