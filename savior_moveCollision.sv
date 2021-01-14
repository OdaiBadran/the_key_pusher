
module	savior_moveCollision	(	
 
					input	logic	clk,
					input	logic	resetN,
					input	logic	startOfFrame,  // short pulse every start of frame 30Hz   
					input logic moveRight,
					input logic moveLeft,
					input logic moveUp,
					input logic collisionSaviorBoarder,  //collisionSaviorBoarder if savior hit borders
					input	logic	[3:0] HitEdgeCode, //one bit per edge
					input logic [3:0] stopKeySignal, // signals send from key to stop savior 
					input logic collisionSaviorKey,  //collisionSaviorKey if savior hit key
					input logic [10:0] INITIAL_X,
					input logic [10:0] INITIAL_Y,
					input logic startLevel2,
					input logic startLevel3,
					output logic signed 	[10:0]	topLeftX,// output the top left corner 
					output logic signed	[10:0]	topLeftY,
					output logic signed 	[10:0]	Xspeed,// output the top left corner 
					output logic signed	[10:0]	Yspeed,
					output logic signed  [3:0] stopSaviorSignal
					
);


parameter int INITIAL_X_SPEED = 120;
parameter int INITIAL_Y_SPEED = 120;
parameter int FACTOR = 160;


const int	FIXED_POINT_MULTIPLIER	=	64;
// FIXED_POINT_MULTIPLIER is used to work with integers in high resolution 
// we do all calulations with topLeftX_FixedPoint  so we get a resulytion inthe calcuatuions of 1/64 pixel 
// we devide at the end by FIXED_POINT_MULTIPLIER which must be 2^n 


// local parameters:
int  topLeftX_FixedPoint;  
int  topLeftY_FixedPoint;
logic Lstop,Rstop,Ustop,Dstop;
logic LKeyStop,RKeyStop,UKeyStop,DKeyStop;
logic moveDown;
logic frameCounter;
///---------------------------------------------------------------------------------------------------------------------=
assign moveDown = moveUp || moveLeft;
//////////--------------------------------------------------------------------------------------------------------------=
//  calculation x Axis speed 
always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN)begin
		Xspeed	<= INITIAL_X_SPEED;
		Rstop=0;
		Lstop=0;
	end
	
	else 	begin
			
			
// colision Calcultaion 		
//hit bit map has one bit per edge:  hit_colors[3:0] =   {Left, Top, Right, Bottom}	
//there is one bit per edge, in the corner two bits are set  


		if (collisionSaviorBoarder && HitEdgeCode [3] == 1 )begin   // savior hit wall from his left side  
			Lstop<=1;

		end
		else if(moveRight == 0 || moveUp ==0 || moveDown == 0)	Lstop <= 0;	
		
		if (collisionSaviorBoarder && HitEdgeCode [1] == 1 )begin    // savior hit wall from his right side
				Rstop<=1;
		end 
		else if(moveLeft == 0 || moveUp ==0 || moveDown == 0)	Rstop <= 0;	

	end
end

//////////--------------------------------------------------------------------------------------------------------------=
//  calculation y Axis speed 
always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN)begin
		Yspeed	<= INITIAL_Y_SPEED;
		Ustop=0;
		Dstop=0;
		//Dstop=0;
	end
	else 	begin
			
			
// colision Calcultaion 		
//hit bit map has one bit per edge:  hit_colors[3:0] =   {Left, Top, Right, Bottom}	
//there is one bit per edge, in the corner two bits are set  


		if (collisionSaviorBoarder && HitEdgeCode [2] == 1 )begin   // savior hit wall from his top side  
			Ustop<=1;
				
		end
		else if(moveLeft == 0 || moveRight ==0 || moveDown == 0)	Ustop <= 0;	
					
		
		if (collisionSaviorBoarder && HitEdgeCode [0] == 1 )begin    // savior hit wall from his buttom side
				Dstop<=1;
		end 
		else if((moveLeft == 0 && moveUp==1) || moveRight ==0 || (moveUp == 0 && moveLeft==1))	Dstop <= 0;	
	end
end
////////-----------------------------------------------------------------------------------------------------------=



//*******************************************************************************************************************
//  calculation x Axis speed 
always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN)begin
		RKeyStop=0;
		LKeyStop=0;
	end
	
	else 	begin
			
			
// colision Calcultaion 		
//hit bit map has one bit per edge:  hit_colors[3:0] =   {Left, Top, Right, Bottom}	
//there is one bit per edge, in the corner two bits are set  

		
		if (collisionSaviorKey && HitEdgeCode [3] && stopKeySignal[1] )begin   // hit key from its right side 
			LKeyStop<=1;

		end
		else if(moveRight == 0 || moveUp ==0 || moveDown == 0)	LKeyStop <= 0;	
		
		if (collisionSaviorKey && HitEdgeCode [1] && stopKeySignal[3] )begin    // hit key from its left side 
				RKeyStop<=1;
		end 
		else if(moveLeft == 0 || moveUp ==0 || moveDown == 0)	RKeyStop <= 0;	

	end
end

//////////--------------------------------------------------------------------------------------------------------------=
//  calculation y Axis speed 
always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN)begin
		UKeyStop=0;
		DKeyStop=0;
		//Dstop=0;
	end
	else 	begin
			
			
// colision Calcultaion 		
//hit bit map has one bit per edge:  hit_colors[3:0] =   {Left, Top, Right, Bottom}	
//there is one bit per edge, in the corner two bits are set  


		if (collisionSaviorKey && HitEdgeCode [2] && stopKeySignal[0])begin   // hit key from its buttom side 
			UKeyStop<=1;
				
		end
		else if(moveLeft == 0 || moveRight ==0 || moveDown == 0)	UKeyStop <= 0;	
					
		
		if (collisionSaviorKey && HitEdgeCode [0] && stopKeySignal[2])begin    // hit key from its top side 
				DKeyStop<=1;
		end 
		else if((moveLeft == 0 && moveUp==1) || moveRight ==0 || (moveUp == 0 && moveLeft==1))	DKeyStop <= 0;	
	end
end
////////-----------------------------------------------------------------------------------------------------------=



















//*******************************************************************************************************************
// position calculate 

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN)
	begin
		topLeftX_FixedPoint	<= INITIAL_X * FIXED_POINT_MULTIPLIER;
		topLeftY_FixedPoint	<= INITIAL_Y * FIXED_POINT_MULTIPLIER;
		stopSaviorSignal <= 0;
	end
	
	else if(startLevel2 || startLevel3)	begin
		topLeftX_FixedPoint	<= INITIAL_X * FIXED_POINT_MULTIPLIER;
		topLeftY_FixedPoint	<= INITIAL_Y * FIXED_POINT_MULTIPLIER;
		stopSaviorSignal <= 0;
	end
	
	else begin
		if (startOfFrame == 1) begin // perform  position integral only 30 times per second 
			if (moveRight==0)begin 
					if(Rstop == 0 && RKeyStop == 0)begin
						topLeftX_FixedPoint  <= topLeftX_FixedPoint + Xspeed;
						stopSaviorSignal <= 0;
					end
					else if(stopSaviorSignal[1]==0) begin
							topLeftX_FixedPoint  <= topLeftX_FixedPoint - (FACTOR);  
							stopSaviorSignal[1] <= 1;
					end
			end//right
			
			
			else if (moveLeft==0 && moveDown==1)begin
						if(Lstop == 0 && LKeyStop == 0)begin
							topLeftX_FixedPoint  <= topLeftX_FixedPoint - Xspeed;		
							stopSaviorSignal <= 0;
						end
						else if(stopSaviorSignal[3]==0)	begin
							topLeftX_FixedPoint  <= topLeftX_FixedPoint + (FACTOR);
							stopSaviorSignal[3]<=1;
						end
			end//left	
			
			else if (moveUp==0 && moveDown==1)begin
						if(Ustop == 0 && UKeyStop == 0)begin
							topLeftY_FixedPoint  <= topLeftY_FixedPoint - Yspeed;
							stopSaviorSignal <= 0;
						end
						else if(stopSaviorSignal[2]==0)begin
							topLeftY_FixedPoint  <= topLeftY_FixedPoint + (FACTOR);
							stopSaviorSignal[2] <= 1;
						end
			end//up	
			
			else if (moveDown==0 )begin
						if(Dstop == 0 && DKeyStop == 0)begin
							topLeftY_FixedPoint  <= topLeftY_FixedPoint + Yspeed; 
							stopSaviorSignal <= 0;
						end
						else if(stopSaviorSignal[0]==0)begin
							topLeftY_FixedPoint  <= topLeftY_FixedPoint - (FACTOR);
							stopSaviorSignal[0] <= 1;
						end	
			end		
			else begin
				topLeftX_FixedPoint  <= topLeftX_FixedPoint;
				topLeftY_FixedPoint  <= topLeftY_FixedPoint;
			end
		end//sof
	end//else
end//always

//get a better (64 times) resolution using integer   
assign 	topLeftX = topLeftX_FixedPoint / FIXED_POINT_MULTIPLIER ;   // note it must be 2^n 
assign 	topLeftY = topLeftY_FixedPoint / FIXED_POINT_MULTIPLIER ;    

endmodule
