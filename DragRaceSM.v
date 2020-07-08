module DragRaceSM (Accelerate, Clutch, GearIn, Limit, Rate, EG, NewGame, CountDownTime, Speed, Gear, Clock);
	input Accelerate, Clutch, GearIn, Limit, Rate, NewGame, Clock;
	input [9:0]EG;
	output reg [5:0]gear;
	output reg [8:0]Speed;
	
	parameter Idle = 0, InGear = 1, Neutral = 2, 
					Crash = 3, Win = 4, SaveBest = 5, Best = 6;

	reg [1:0] state;
	
	initial begin 
		//Clock = 0;
		//Clutch =0;
		//Speed = 0;
		//Speed Display = 1;
		//BestTime Display =0;
	end
	
	always @(negedge Clutch or posedge NewGame or posedge scoreboard) begin
		if (NewGame)
			state <= Idle;
		else
			case (state)
				Idle:
					if (Clutch and gear)
						begin 
							state <= InGear;
						end
					else if (scoreboard)
						begin
							state <= Best;
						end
					else 
						begin
							state <= state;
						end
				InGear: 
					if (Speed >= 200)
						begin 
							state <= Win;
						end
					else if (Speed < 200)
						begin 
							state <= State;
						end
					else if (Clutch)
						begin
							state <= Neutral;
						end
				Neutral: 
					if (Speed >= 200)
						begin 
							state <= Win;
						end
					else if (Speed < 200)
						begin 
							state <= State;
						end
					else if (gear and Clutch)
						begin 
							state <= Ingear;
						end
					else if (gear)
						begin
							state <= Crash;
						end 
					else if (Clutch)
						begin
							state <= state;
						end
				Crash:
					if (NG)
						begin
							state <= Idle;
						end
					if (scoreboard)
						begin 
							state <= Best;
						end
					else 
						begin
						 state <= state;
						end
				Win: 
					if (Scoreboard)
						begin 
							state <= SaveBest;
						end
					else if (NewGame)
						begin
							state <= Idle;
						end
					else 
						begin
							state <= Win;
						end
				SaveBest:
					begin
						state <= Best;
					end
				Best: 
					if (NewGame)
						begin
							state <= Idle;
						end
					else
						begin
							state <= state;
						end
				default: state <= Idle;
			endcase
		end
	always @(*) begin
		case (state)
			Idle:
					begin
						Speed = 0;
						Timer = 0;
						BestTime = 0;
						Limit = 0;
						Rate = 0;
					end
			InGear:
					begin 
						case (gear)
							0: Speed <= Speed;
							1: Speed <= Speed + 6;
							2: Speed <= Speed + 5;
							3: Speed <= Speed + 4;
							4: Speed <= Speed + 3;
							5: Speed <= Speed + 2;
							6: Speed <= Speed + 1;
						endcase
					end 
					begin 
						Speed = 0;
						Timer = 1;
						BestTime = 0;
						Limit = 0;
						Rate = 0;
					end
			Neutral:
					begin 
						Speed = Speed;
						Timer = 0;
						BestTime = 0;
						Limit = 0;
						Rate = 0;
					end
					
					
					
					
					
					
					
					
					
					
					
						
						
	

	


