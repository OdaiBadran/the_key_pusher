
// game controller Dudy October 2020
// (c) Technion IIT, Department of Electrical Engineering 2020 


module	game_controller	(	
			input	logic	clk,
			input	logic	resetN,
			input	logic	startOfFrame,  // short pulse every start of frame 30Hz 
			input	logic	savior_drawing_request,
			input	logic	key_drawing_request,
			input	logic	boarder_drawing_request,
			input	logic	prisoner_drawing_request,
			input	logic	police1_drawing_request,
			input	logic	police2_drawing_request,
			input	logic	police3_drawing_request,
			input logic tc,
			input logic oneSec,
			output logic collisionSaviorBoarder, 
			output logic collisionKeyBoarder,
			output logic collisionSaviorKey,
			output logic collisionSaviorPrisoner,
			output logic collisionKeyPrisoner,
			output logic collisionKeyPolice1,
			output logic collisionKeyPolice2,
			output logic collisionKeyPolice3,
			output logic collisionSaviorPolice1,
			output logic collisionSaviorPolice2,
			output logic collisionSaviorPolice3,
			output logic countLoadN,
			output logic countEnable,
			output logic [1:0]level,
			output logic [1:0]result,
			output logic collisionKBoarderPolice1,
			output logic collisionKBoarderPolice2,
			output logic collisionKBoarderPolice3,
			output logic startLevel2,
			output logic startLevel3,
			output logic [1:0] curr_lives
			
			
);
//if(collisionPoliceSavior || (collisionKeyPolice && collisionSaviorKey)) lives--;

assign collisionSaviorBoarder = (savior_drawing_request == 1'b1 && boarder_drawing_request  == 1'b1 ) ; 
assign collisionKeyBoarder = (key_drawing_request == 1'b1 && boarder_drawing_request  == 1'b1 ) ; 
assign collisionSaviorKey = (savior_drawing_request == 1'b1 && key_drawing_request  == 1'b1 ) ;
assign collisionSaviorPrisoner = (savior_drawing_request == 1'b1 && prisoner_drawing_request  == 1'b1 ) ; 
assign collisionKeyPrisoner = (key_drawing_request == 1'b1 && prisoner_drawing_request  == 1'b1 ) ;  
assign collisionKeyPolice1 = (key_drawing_request == 1'b1 && police1_drawing_request == 1'b1);
assign collisionKeyPolice2 = (key_drawing_request == 1'b1 && police2_drawing_request == 1'b1);
assign collisionKeyPolice3 = (key_drawing_request == 1'b1 && police3_drawing_request == 1'b1);
assign collisionSaviorPolice1 = (savior_drawing_request == 1'b1 && police1_drawing_request == 1'b1);
assign collisionSaviorPolice2 = (savior_drawing_request == 1'b1 && police2_drawing_request == 1'b1);
assign collisionSaviorPolice3 = (savior_drawing_request == 1'b1 && police3_drawing_request == 1'b1);
assign collisionKBoarderPolice1 = (boarder_drawing_request  == 1'b1 && police1_drawing_request == 1'b1);
assign collisionKBoarderPolice2 = (boarder_drawing_request  == 1'b1 && police2_drawing_request == 1'b1);
assign collisionKBoarderPolice3 = (boarder_drawing_request  == 1'b1 && police3_drawing_request == 1'b1);
// temporary :

////
logic life_flag = 0;
logic [0:1] init_lives = 2'b11;
logic [0:1] lives;
enum logic [2:0] {start,level1, level2, level3, GAMEOVER, WIN } prState, nxtState;

// IN RESET :
// LEVEL ==> 1
// COUNTLOAD ==> 0 LOAD 60 SECONDS TO THE TIMER
// COUNTENABLE ==> 1 ALWAYS COUNTING
//LIVES ==> 3 THREE LIVE AT BEGINING OF EACH LEVEL

always @(posedge clk or negedge resetN)
begin
	
	if (!resetN )begin  // Asynchronic reset
		
		 prState <= start;
		 level<=2'b01;
		 countLoadN<=1'b1;
		 countEnable<=1'b1;
		 result<=2'b00; 
		 startLevel2 <= 0;
		 startLevel3 <= 0;
		 lives <= 3; 
		 life_flag <= 0;

	end
	else begin 	// Synchronic logic FSM
		if(startOfFrame)
			life_flag = 0;
		
		prState <= nxtState; // default values 
		countEnable=1'b1;
		countLoadN=1'b1;
		if(lives <= 0)
			prState <= GAMEOVER;
		
		case(prState)
			start: 			begin	
								lives = 3;
								countLoadN = 1'b0;
								nxtState = level1;	 

								end
			level1: 			begin	
			
									   if(collisionSaviorPolice1) begin
//											nxtState=GAMEOVER;
											if(!life_flag) begin
												lives -= 1;	            // lose life
												life_flag = 1;
											end
										end
										else if(collisionKeyPrisoner) begin
											level = 2'b10; 
											countLoadN = 1'b0;
											startLevel2 = 1;
											nxtState = level2;
											
										end	
											
										else if(tc && oneSec) 
											nxtState = GAMEOVER;	
											
								end
					
			level2: begin 	
										
										if(startLevel2 == 1) begin
										
											lives = 3;
											life_flag = 0;
											startLevel2 = 0;
										
										end
												
										
									   else if(collisionSaviorPolice1 || collisionSaviorPolice2) begin
//											nxtState=GAMEOVER;
											if(!life_flag) begin
												lives -= 1;					// lose life
												life_flag = 1;
											end
										end
										else if(collisionKeyPrisoner) begin
											level = 2'b11;
											countLoadN = 1'b0;
											startLevel3 = 1;
											nxtState = level3;	
										end
									   
										else if(tc && oneSec)
											nxtState = GAMEOVER;	
						end
								
			level3: begin 
										
										if(startLevel3 == 1) begin
											lives = 3;
											life_flag = 0;
											startLevel3 = 0;
										
										end
											
											
										
									   else if(collisionSaviorPolice1 || collisionSaviorPolice2 || collisionSaviorPolice3) begin
//											nxtState=GAMEOVER;
											if(!life_flag) begin
												lives -= 1;						// lose life
												life_flag = 1;
											end
										end
											
										else if(collisionKeyPrisoner) begin
											nxtState=WIN;	
										end	
										
										else if(tc && oneSec)
											nxtState = GAMEOVER;
						end
								
											
		
		      WIN:					begin
											countEnable=1'b0;
											result=2'b01;
											nxtState=start;
										end
					
			   GAMEOVER:			begin
											countEnable=1'b0;
											result=2'b10;
											nxtState=start;
										end		
		endcase
		
	end

end	

assign curr_lives = lives;
///


endmodule
