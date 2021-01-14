
module	key_moveCollision	(	
 
					input	logic	clk,
					input	logic	resetN,
					input	logic	startOfFrame,  // short pulse every start of frame 30Hz   
					input logic collisionKeyBoarder,  //collision if key hit borders
					input logic collisionKeySavior,  //collision if key hit savior
					input	logic	[3:0] HitEdgeCode, //one bit per edge
					input logic moveRightSav,
					input logic moveLeftSav,
					input logic moveUpSav,
					input logic magnetMode,			// magnet mode (on == 1/off == 0) 
					input logic [10:0] XspeedSav ,
					input logic [10:0] YspeedSav ,
					input logic [3:0] stopSaviorSignal, // signals form savior to stop key movement
					input logic [10:0] INITIAL_X,
					input logic [10:0] INITIAL_Y,
					input logic startLevel2,		// pulse to indicate start of level 2
					input logic startLevel3,		// pulse to indicate start of level 3
					output logic signed 	[10:0]	topLeftX,// output the top left corner 
					output logic signed	[10:0]	topLeftY,
					output logic [3:0] stopKeySignal
					
);

// local parameters:
//***************************************************
// local parameters:
parameter int IDENTATION = 44;
parameter int FACTOR = 64;
int  topLeftX_FixedPoint;  
int  topLeftY_FixedPoint;
int XspeedKey,YspeedKey;
const int	FIXED_POINT_MULTIPLIER	=	64;
//****************************************************
// stop movement flags, magnet flags
logic LKeyBoarderHit,RKeyBoarderHit,UKeyBoarderHit,DKeyBoarderHit;
logic Lhit,Rhit,Uhit,Dhit;
logic Lflag,Rflag,Uflag,Dflag;
logic LfreeKey,RfreeKey,UfreeKey,DfreeKey;
logic moveDownSav;
logic only;
logic magnetHistory,magnetStop;
logic pullToLeft,pullToRight,pullToTop,pullToButtom;
//*****************************************************

//=------------------------------------------------------------------------------------------------------------------
assign moveDownSav = moveLeftSav || moveUpSav; 
assign only = moveDownSav; // used to indicate one button is pressed

//=-------------------------------------------------------------------------------------------------------------------=

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN)begin
		XspeedKey <= 0;
		YspeedKey <= 0;
		Lhit <= 0;
		Rhit <= 0;
		Uhit <= 0;
		Dhit <= 0;
		magnetHistory <= 0;
		pullToLeft <= 0;
		pullToRight <= 0;
		pullToTop <= 0;
		pullToButtom <= 0;
		magnetStop <= 0;
	end
	
// colision Calcultaion 		
//hit bit map has one bit per edge:  hit_colors[3:0] =   {Left, Top, Right, Bottom}	
//there is one bit per edge, in the corner two bits are set  
	else 	begin
	
		if(!magnetMode) begin //****************************MAGNET-MODE-IS-OFF***************************************
		

		
		  if(collisionKeySavior && HitEdgeCode [3]) begin //----- hit left border of key && right button is pressed
			
				if(!moveRightSav) begin
				
					XspeedKey <= XspeedSav;
					Rhit <= 1; 
					
				end
				
			end 
			
			else if(Rhit && moveRightSav) begin
				
				XspeedKey <= 0;
				Rhit <= 0;
				Lhit <= 0;
				Uhit <= 0;
				Dhit <= 0;
				
			end	
			
			//-------------------------------------------------------------------------------------
		  else if(collisionKeySavior && HitEdgeCode [1]) begin //----- hit right border of key && left button is pressed
			
				if(!moveLeftSav && only) begin
				
					XspeedKey <= -XspeedSav;
					Lhit <= 1;
					
				end
				
			end 
			
			else if((Lhit && moveLeftSav) || (Lhit && !moveDownSav)) begin
				
				XspeedKey <= 0;
				Lhit <= 0;
				Rhit <= 0;
				Uhit <= 0;
				Dhit <= 0;
				
			end
		//-----------------------------------------------------------------------------------------	
			
		   else if(collisionKeySavior && HitEdgeCode [2]) begin //----- hit top border of key && down button is pressed
			
				if(!moveDownSav) begin
				
					YspeedKey <= YspeedSav;
					Dhit <= 1;
					
				end
				
			end 
			
			else if(Dhit && moveDownSav) begin
			
				YspeedKey <= 0;
				Dhit <= 0;
				Rhit <= 0;
				Lhit <= 0;
				Uhit <= 0;
			
			end
		//------------------------------------------------------------------------------------------
			
		   else if(collisionKeySavior && HitEdgeCode [0]) begin //----- hit buttom border of key && up button is pressed
			
				if(!moveUpSav && only) begin
				
					YspeedKey <= -YspeedSav;
					Uhit <= 1;
					
				end
				
			end
			
			else if((Uhit && moveUpSav) || (Uhit && !moveDownSav)) begin
			
				YspeedKey <= 0;
				Uhit <= 0;
				Rhit <= 0;
				Lhit <= 0;
				Dhit <= 0;
			
			end

		end// !magnet	
	//****************************MAGNET-MODE-IS-ON********************************************
			
	   if(magnetMode) begin 
		
		  if(collisionKeySavior && HitEdgeCode [3]) begin //----- hit left border of key && right button is pressed
			
				if(!moveRightSav) begin
				
					XspeedKey <= XspeedSav;
					Rhit <= 1; 
					pullToLeft <= 1;
					
				end
				
			end 
			
			else if(Rhit && moveRightSav) begin
				
				XspeedKey <= 0;
				Rhit <= 0;
				Lhit <= 0;
				Uhit <= 0;
				Dhit <= 0;
				
			end	
			
			else if(pullToLeft && (!moveLeftSav && only)) begin
				XspeedKey <= -XspeedSav;
				magnetStop <= 1; 
			
			end
			
			else if(pullToLeft && magnetStop && moveLeftSav) begin
				XspeedKey <= 0;
				pullToLeft <= 0;
				magnetStop <= 0;
			
			end
			
			//-------------------------------------------------------------------------------------
		  else if(collisionKeySavior && HitEdgeCode [1]) begin //----- hit right border of key && left button is pressed
			
				if(!moveLeftSav && only) begin
				
					XspeedKey <= -XspeedSav;
					Lhit <= 1;
					pullToRight <= 1;
					
				end
				
			end 
			
			else if((Lhit && moveLeftSav) || (Lhit && !moveDownSav)) begin
				
				XspeedKey <= 0;
				Lhit <= 0;
				Rhit <= 0;
				Uhit <= 0;
				Dhit <= 0;
				
			end
			
			else if(pullToRight && (!moveRightSav)) begin
				XspeedKey <= XspeedSav;
				magnetStop <= 1; 
			
			end
			
			else if(pullToRight && magnetStop && moveRightSav) begin
				XspeedKey <= 0;
				pullToRight <= 0;
				magnetStop <= 0;
			
			end
		//-----------------------------------------------------------------------------------------	
			
		   else if(collisionKeySavior && HitEdgeCode [2]) begin //----- hit top border of key && down button is pressed
			
				if(!moveDownSav) begin
				
					YspeedKey <= YspeedSav;
					Dhit <= 1;
					pullToTop <= 1;
					
				end
				
			end 
			
			else if(Dhit && moveDownSav) begin
			
				YspeedKey <= 0;
				Dhit <= 0;
				Rhit <= 0;
				Lhit <= 0;
				Uhit <= 0;
			
			end
			
			else if(pullToTop && (!moveUpSav && only)) begin
				YspeedKey <= -YspeedSav;
				magnetStop <= 1; 
			
			end
			
			else if(pullToTop && magnetStop && moveUpSav) begin
				YspeedKey <= 0;
				pullToTop <= 0;
				magnetStop <= 0;
			
			end
		//------------------------------------------------------------------------------------------
			
		   else if(collisionKeySavior && HitEdgeCode [0]) begin //----- hit buttom border of key && up button is pressed
			
				if(!moveUpSav && only) begin
				
					YspeedKey <= -YspeedSav;
					Uhit <= 1;
					pullToButtom <= 1;
					
				end
				
			end
			
			else if((Uhit && moveUpSav) || (Uhit && !moveDownSav)) begin
			
				YspeedKey <= 0;
				Uhit <= 0;
				Rhit <= 0;
				Lhit <= 0;
				Dhit <= 0;
			
			end
			
			else if(pullToButtom && (!moveDownSav)) begin
				YspeedKey <= YspeedSav;
				magnetStop <= 1; 
			
			end
			
			else if(pullToButtom && magnetStop && moveDownSav) begin
				YspeedKey <= 0;
				pullToButtom <= 0;
				magnetStop <= 0;
			
			end
				
		end	// magnetMode	

	end// else
	
end// always	
			
			
		
//=--------------------------------------------------------------------------------------------------------------------
// **************************************************** WALL - KEY - COLLISION ***************************************
always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN)begin
		LKeyBoarderHit<=0;
		RKeyBoarderHit<=0;
		UKeyBoarderHit<=0;
		DKeyBoarderHit<=0;
	end

	else 	begin	
	
			if (collisionKeyBoarder && HitEdgeCode [3] == 1 && (!moveLeftSav && only))begin   // hit left border of key  
				
				LKeyBoarderHit <= 1;
				
			end
			
			else if(LfreeKey && ((!moveRightSav) || (!moveUpSav && only) || !moveDownSav))
			
				LKeyBoarderHit <= 0;
			
			if (collisionKeyBoarder && HitEdgeCode [1] == 1 && (!moveRightSav))begin   // hit right border of key 
				
				RKeyBoarderHit <= 1;
				
			end
			
			else if(RfreeKey && ((!moveLeftSav && only) || (!moveUpSav && only) || !moveDownSav))
			
				RKeyBoarderHit <= 0;
			
			if (collisionKeyBoarder && HitEdgeCode [0] == 1 && (!moveDownSav))begin   // hit buttom border of key  
				
				DKeyBoarderHit <= 1;
				
			end
			
			else if(DfreeKey && ((!moveLeftSav && only) || (!moveUpSav && only) || (!moveRightSav)))
			
				DKeyBoarderHit <= 0;
			
			if (collisionKeyBoarder && HitEdgeCode [2] == 1 && (!moveUpSav && only))begin   // hit top border of key
				
				UKeyBoarderHit <= 1;
				
			end
			else if(UfreeKey && ((!moveLeftSav && only) || (!moveDownSav) || (!moveRightSav)))
			
				UKeyBoarderHit <= 0;
			
			

		
			
	end
	
end	
//=-----------------------------------------------------------------------------------------------------------------
// ************************************************* POSITION - CALCULATE *****************************************

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN)
	begin
		topLeftX_FixedPoint	<= INITIAL_X * FIXED_POINT_MULTIPLIER;
		topLeftY_FixedPoint	<= INITIAL_Y * FIXED_POINT_MULTIPLIER;
		stopKeySignal <= 0;
		Lflag <= 0;
		Rflag <= 0;
		Uflag <= 0;
		Dflag <= 0;
		LfreeKey <= 0;
		RfreeKey <= 0;
		UfreeKey <= 0;
		DfreeKey <= 0;
	end
	
	else if(startLevel2 || startLevel3)	begin
		topLeftX_FixedPoint	<= INITIAL_X * FIXED_POINT_MULTIPLIER;
		topLeftY_FixedPoint	<= INITIAL_Y * FIXED_POINT_MULTIPLIER;
		stopKeySignal <= 0;
		Lflag <= 0;
		Rflag <= 0;
		Uflag <= 0;
		Dflag <= 0;
		LfreeKey <= 0;
		RfreeKey <= 0;
		UfreeKey <= 0;
		DfreeKey <= 0;
	end
	
	else begin
		if (startOfFrame == 1) begin // perform  position integral only 30 times per second 
			
			if(LKeyBoarderHit) begin
				if(!Lflag) begin
					LfreeKey <= 0;
					stopKeySignal[1] <= 1;    // send signal to savior to stop him
					topLeftX_FixedPoint <= topLeftX_FixedPoint + FACTOR; //+ move key from boarders invisibly
					Lflag <= 1;
				end
				else begin
					topLeftX_FixedPoint <= topLeftX_FixedPoint; 
					topLeftY_FixedPoint <= topLeftY_FixedPoint + YspeedKey;
					if ((!moveRightSav && only) || (!moveUpSav && only) || !moveDownSav) begin
						stopKeySignal[1] <= 0;
						Lflag <= 0;
						LfreeKey <= 1;
					end
				end	
			end

			else if(RKeyBoarderHit) begin
				if(!Rflag) begin
					RfreeKey <= 0;
					stopKeySignal[3] <= 1;     // send signal to savior to stop him
					topLeftX_FixedPoint <= topLeftX_FixedPoint - FACTOR ; // move key from boarders invisibly
					Rflag <= 1;
				end
				else begin
					topLeftX_FixedPoint <= topLeftX_FixedPoint; 
					topLeftY_FixedPoint <= topLeftY_FixedPoint + YspeedKey;
					if ((!moveLeftSav && only) || (!moveUpSav && only) || !moveDownSav) begin
						stopKeySignal[3] <= 0;
						Rflag <= 0;
						RfreeKey <= 1;
					end
				end	
			
			end
			else if(UKeyBoarderHit) begin
				if(!Uflag) begin
					UfreeKey <= 0;
					stopKeySignal[0] <= 1;        // send signal to savior to stop him
					topLeftY_FixedPoint <= topLeftY_FixedPoint + FACTOR ; // move key from boarders invisibly
					Uflag <= 1;
				end
				else begin
					topLeftY_FixedPoint <= topLeftY_FixedPoint; 
					topLeftX_FixedPoint <= topLeftX_FixedPoint + XspeedKey;
					if ((!moveRightSav) || (!moveDownSav) || (!moveLeftSav && only)) begin
						stopKeySignal[0] <= 0;
						Uflag <= 0;
						UfreeKey <= 1;
					end
				end	
			end
			else if(DKeyBoarderHit) begin
				if(!Dflag) begin
					DfreeKey <= 0;
					stopKeySignal[2] <= 1;       // send signal to savior to stop him
					topLeftY_FixedPoint <= topLeftY_FixedPoint - FACTOR ; // move key from boarders invisibly
					Dflag <= 1;
				end
				else begin
					topLeftY_FixedPoint <= topLeftY_FixedPoint; 
					topLeftX_FixedPoint <= topLeftX_FixedPoint + XspeedKey;
					if ((!moveRightSav) || (!moveUpSav && only) || (!moveLeftSav && only)) begin
						stopKeySignal[2] <= 0;
						Dflag <= 0;
						DfreeKey <= 1;
					end
				end	
			
			end
			else begin // this means no KEY - WALL collision at this moment
			
				if((!moveLeftSav && only) && stopSaviorSignal[3]) // savior send signal to stop key left movement
					topLeftX_FixedPoint <= topLeftX_FixedPoint;
					
				else if (!moveRightSav && stopSaviorSignal[1]) // savior send signal to stop key right movement 
					topLeftX_FixedPoint <= topLeftX_FixedPoint;
					
				else if ((!moveUpSav && only) && stopSaviorSignal[2]) // savior send signal to stop key upper movement
					topLeftY_FixedPoint	<= topLeftY_FixedPoint;
					
				else if (!moveDownSav && stopSaviorSignal[0]) 	// savior send signal to stop key droping movement
					topLeftY_FixedPoint	<= topLeftY_FixedPoint;
					
				else begin 
					topLeftX_FixedPoint	<= topLeftX_FixedPoint + XspeedKey;
					topLeftY_FixedPoint	<= topLeftY_FixedPoint + YspeedKey;
				end	
				
			end
			
		end//sof
	end//esle
end//always	





//=-----------------------------------------------------------------------------------------------------------------
//get a better (64 times) resolution using integer   
assign 	topLeftX = topLeftX_FixedPoint / FIXED_POINT_MULTIPLIER ;   // note it must be 2^n 
assign 	topLeftY = topLeftY_FixedPoint / FIXED_POINT_MULTIPLIER ;   		



endmodule
