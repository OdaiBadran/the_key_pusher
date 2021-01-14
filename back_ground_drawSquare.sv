//-- Alex Grinshpun Apr 2017
//-- Dudy Nov 13 2017
// SystemVerilog version Alex Grinshpun May 2018
// coding convention dudy December 2018
// (c) Technion IIT, Department of Electrical Engineering 2019 


module	back_ground_drawSquare (	

					input	logic	clk,
					input	logic	resetN,
					input logic	[10:0]	pixelX,
					input logic	[10:0]	pixelY,
					input logic	[10:0]	maze_sel,
					input logic [1:0] level,
					input logic startLevel2,
					input logic startLevel3,
					output logic [7:0]	BG_RGB,
					output logic		boardersDrawReq,
					output logic [10:0] INITIAL_X_SAV,
					output logic [10:0] INITIAL_Y_SAV,
					output logic [10:0] INITIAL_X_KEY,
					output logic [10:0] INITIAL_Y_KEY,
					output logic [10:0] INITIAL_X_PRIS,
					output logic [10:0] INITIAL_Y_PRIS
					
					
);

const int	xFrameSize	=	639;
const int	yFrameSize	=	479;
const int	bracketOffset =	30;

logic [2:0] redBits;
logic [2:0] greenBits;
logic [1:0] blueBits;

localparam logic [2:0] DARK_COLOR = 3'b111 ;// bitmap of a dark color
localparam logic [2:0] LIGHT_COLOR = 3'b000 ;// bitmap of a light color

assign BG_RGB =  {redBits , greenBits , blueBits} ; //collect color nibbles to an 8 bit word 

logic [1:0] selection ;
logic [1:0] selectionTmp ;
logic [2:0]random ;
logic [2:0]randomTmp ;

//logic [0:6][10:0] randomSavPlacesX = {3*32, 6*32, 12*32, 9*32, 16*32, 13*32, 12*32};
//logic [0:6][10:0] randomSavPlacesY = {11*32, 4*32, 8*32, 7*32, 8*32, 11*32, 5*32};
logic [0:4][10:0] randomSavPlacesX = {11'h60, 11'h220 , 11'h100, 11'h120, 11'h60};
logic [0:4][10:0] randomSavPlacesY = {11'h160, 11'hA0 , 11'hA0, 11'h180, 11'h80};
logic [0:4][10:0] randomKeyPlacesX = {11'h180, 11'hC0 , 11'h1C0, 11'h40, 11'h200};
logic [0:4][10:0] randomKeyPlacesY = {11'h160, 11'h60 , 11'h140, 11'hE0, 11'h80};
logic [0:4][10:0] randomPrisPlacesX = {11'h1A0, 11'hC0 , 11'h80, 11'h1C0, 11'h160};
logic [0:4][10:0] randomPrisPlacesY = {11'h60, 11'h180, 11'h60, 11'h80, 11'h100};

//logic [0:9][10:0] randomKeyPlacesX = {};
//logic [0:9][10:0] randomKeyPlacesY = {};

assign INITIAL_X_SAV = randomSavPlacesX[random];
assign INITIAL_Y_SAV = randomSavPlacesY[random];
assign INITIAL_X_KEY = randomKeyPlacesX[random];
assign INITIAL_Y_KEY = randomKeyPlacesY[random];
assign INITIAL_X_PRIS = randomPrisPlacesX[random];
assign INITIAL_Y_PRIS = randomPrisPlacesY[random];



//screen matrix ,where the 1's are bricks

//easy mazes
//logic [0:14] [0:19] array0 = '{
//'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}, //1
//'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}, //2
//'{0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0}, //3....
//'{0,1,0,1,4,0,3,0,1,0,1,0,0,2,0,0,0,0,1,0}, 
//'{0,1,0,6,0,0,0,0,1,1,1,0,0,0,5,0,6,0,1,0},
//'{0,1,0,1,0,0,0,0,4,0,0,0,0,0,0,0,0,3,1,0},
//'{0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0},
//'{0,1,5,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,1,0},
//'{0,1,0,0,0,0,1,0,0,0,0,6,0,0,0,0,0,1,1,0},
//'{0,1,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,1,1,0},
//'{0,1,0,0,0,0,0,0,0,0,0,0,0,0,4,0,0,1,1,0},
//'{0,1,0,2,0,0,0,0,0,0,0,0,2,0,0,0,0,1,1,0},
//'{0,1,0,0,0,0,3,0,0,5,0,0,0,0,0,1,1,1,1,0},
//'{0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0},
//'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}	
//};


logic [0:14] [0:19] array0 = '{
'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}, //1
'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}, //2
'{0,1,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,1,1,0}, //3....
'{0,1,0,1,0,0,0,0,1,0,1,0,0,0,0,0,0,0,1,0}, 
'{0,1,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,1,0},
'{0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0},
'{0,1,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,1,0},
'{0,1,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,1,0},
'{0,1,0,0,0,0,1,1,1,1,1,0,0,1,1,1,0,0,1,0},
'{0,1,1,1,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0},
'{0,1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,1,1,0},
'{0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0},
'{0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0},
'{0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0},
'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}	
};

logic [0:14] [0:19] array1 = '{
'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}, //1
'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}, //2
'{0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0}, //3....
'{0,1,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,1,0}, 
'{0,1,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,1,0},
'{0,1,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,1,0},
'{0,1,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,0,1,0},
'{0,1,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,1,0},
'{0,1,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,1,0},
'{0,1,0,0,0,1,0,0,0,0,0,0,0,0,1,1,1,1,1,0},
'{0,1,0,0,0,1,1,1,0,0,0,0,0,0,0,0,0,0,1,0},
'{0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0},
'{0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0},
'{0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0},
'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}	
};

logic [0:14] [0:19] array2 = '{
'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}, //1
'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}, //2
'{0,1,1,1,1,1,1,1,1,0,0,1,1,1,1,1,1,1,1,0}, //3....
'{0,1,0,0,0,0,0,0,1,0,0,1,0,0,0,0,0,0,1,0}, 
'{0,1,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,1,0},
'{0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0},
'{0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0},
'{0,1,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,1,0},
'{0,1,0,0,0,0,0,1,0,0,1,0,0,0,0,0,0,0,1,0},
'{0,1,1,1,1,0,0,1,0,0,1,0,0,1,1,1,1,1,1,0},
'{0,1,0,0,1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0},
'{0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0},
'{0,1,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0},
'{0,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0},
'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}	
};
//medium mazes
logic [0:14] [0:19] array3 = '{
'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}, //1
'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}, //2
'{0,0,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,1,1,0}, //3....
'{1,1,1,1,0,0,0,0,1,0,1,0,0,0,0,0,0,0,1,0}, 
'{1,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,1,0},
'{1,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,1,1},
'{1,0,0,0,1,1,1,0,0,0,0,0,0,0,1,0,0,0,0,1},
'{0,1,0,0,0,0,0,0,0,0,1,0,0,0,1,0,0,0,0,1},
'{1,1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,1,1,1},
'{1,0,0,0,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,1},
'{1,0,0,0,1,0,0,0,1,0,0,0,0,0,0,0,0,0,0,1},
'{1,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0},
'{0,1,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0},
'{0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0},
'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}	
};
logic [0:14] [0:19] array4 = '{
'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}, //1
'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}, //2
'{0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0}, //3....
'{1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0}, 
'{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0},
'{1,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,1,1},
'{1,0,0,0,0,1,1,0,0,0,1,0,0,0,1,0,0,0,0,1},
'{0,1,0,0,1,0,0,0,0,0,1,0,0,0,0,0,0,0,0,1},
'{1,1,0,0,1,0,0,0,0,0,1,0,0,0,0,0,0,0,1,1},
'{1,0,0,0,1,1,1,1,0,0,1,1,1,1,1,1,0,0,0,1},
'{1,0,0,0,0,1,0,0,0,0,0,0,0,0,0,1,0,0,0,1},
'{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
'{0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,1},
'{0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0},
'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}	
};
logic [0:14] [0:19] array5 = '{
'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}, //1
'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}, //2
'{0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0}, //3....
'{0,1,0,1,0,0,0,0,1,0,1,0,0,0,0,0,0,0,1,0}, 
'{0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0},
'{0,1,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,1,0},
'{0,1,0,0,0,1,1,0,0,0,0,0,0,0,1,0,0,0,1,0},
'{1,0,0,0,0,1,1,0,0,0,0,0,0,0,1,1,0,0,1,0},
'{1,0,0,0,0,0,1,1,1,1,1,0,0,1,1,0,0,0,1,0},
'{1,0,0,0,0,0,0,1,0,0,1,0,0,0,0,0,0,0,1,0},
'{1,1,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,1,1,0},
'{1,1,1,0,0,0,0,0,0,0,0,0,2,0,0,0,1,1,1,0},
'{1,1,1,1,0,0,0,0,0,0,1,0,0,0,0,1,1,1,1,0},
'{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0},
'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}	
};
//hard mazes
logic [0:14] [0:19] array6 = '{
'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}, //1
'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}, //2
'{0,1,1,1,1,1,1,1,0,0,0,1,1,1,1,1,1,1,1,0}, //3....
'{0,1,0,0,0,0,0,0,1,0,0,1,0,0,0,1,0,0,1,0}, 
'{0,1,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,1,1},
'{0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
'{0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,1},
'{0,1,0,0,0,0,0,1,1,1,1,1,1,0,0,1,1,0,0,1},
'{0,1,0,0,0,0,0,0,1,1,0,0,1,0,0,0,1,0,1,1},
'{0,1,1,1,1,0,0,0,0,1,0,0,1,0,0,0,1,1,1,0},
'{0,1,0,0,1,0,0,1,1,1,0,0,0,0,0,0,0,0,1,0},
'{0,1,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,1,0},
'{0,1,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,1,1,0},
'{0,1,1,0,0,0,0,0,0,0,0,1,0,1,1,1,1,1,0,0},
'{0,0,0,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0}	
};
logic [0:14] [0:19] array7 = '{
'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}, //1
'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}, //2
'{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0}, //3....
'{1,1,0,0,1,0,0,0,1,0,0,1,0,0,0,0,0,0,1,0}, 
'{1,0,0,0,0,0,0,0,1,0,0,1,0,0,0,0,0,0,1,0},
'{1,0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,1,0},
'{1,1,0,0,0,1,0,0,0,0,0,1,1,0,0,0,0,0,1,1},
'{1,1,0,0,1,1,0,0,0,0,0,0,0,0,0,0,1,0,0,1},
'{1,1,0,0,0,1,0,0,1,0,0,0,0,0,0,0,1,0,0,1},
'{1,1,1,0,0,1,0,0,1,0,0,0,0,0,1,1,1,1,1,1},
'{1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,1},
'{1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
'{1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
'{1,1,1,0,0,0,0,1,1,1,1,1,0,0,0,0,1,1,1,1},
'{1,1,1,1,1,1,1,0,0,0,0,0,1,1,1,1,1,1,1,1}	
};
logic [0:14] [0:19] array8 = '{
'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}, //1
'{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}, //2
'{0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0}, //3....
'{0,1,0,1,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,1}, 
'{0,1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,1},
'{0,1,0,0,0,0,1,0,0,0,1,1,0,0,0,0,1,0,0,1},
'{1,1,0,0,0,0,1,0,0,0,0,0,0,0,1,0,1,0,0,1},
'{1,0,0,0,1,1,1,0,0,0,0,0,0,0,1,1,1,0,1,1},
'{1,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0,1,1},
'{1,1,1,0,0,0,1,0,0,0,1,0,0,0,0,0,0,0,1,1},
'{1,0,0,0,0,0,1,0,0,0,1,1,1,0,0,0,0,1,1,1},
'{1,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,1,1,1,1},
'{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1},
'{0,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,1,1,1,1},
'{0,1,0,1,0,1,0,1,0,1,1,1,1,1,1,1,1,1,1,1}	
};



// end of screen array

//localparam logic selected_array [3:0] [14:0] [19:0] = {array1,array2,array3,array4};

//brick bitmap code
localparam  int OBJECT_HEIGHT_Y = 32;
localparam  int OBJECT_WIDTH_X = 32;

logic [0:OBJECT_WIDTH_X-1] [0:OBJECT_HEIGHT_Y-1] [8-1:0] object_colors = {
{8'hB2, 8'h88, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hB2 },
{8'hB1, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hB1 },
{8'hB1, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hB1 },
{8'hB1, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hB1 },
{8'hB2, 8'h88, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hB2 },
{8'hB2, 8'h88, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hB2 },
{8'hB1, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'h00, 8'h00, 8'h00, 8'hFF, 8'h00, 8'hB1 },
{8'hB2, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hDB },
{8'hDB, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hDB },
{8'hDB, 8'h69, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h48, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h69, 8'hDB },
{8'hD6, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hB2 },
{8'hB1, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hB1 },
{8'hB1, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hB1 },
{8'hB1, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hB1 },
{8'hB2, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hB2 },
{8'hB2, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hB1 },
{8'hB1, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hB1 },
{8'hB1, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hB1 },
{8'hB2, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hB2 },
{8'hB2, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hB2 },
{8'hB2, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h00, 8'hB2 },
{8'hB2, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hB2 },
{8'hDB, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hDB },
{8'hFB, 8'h69, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h69, 8'hDB },
{8'hD6, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hB2 },
{8'hB2, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hB2 },
{8'hB1, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hB1 },
{8'hB1, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hB1 },
{8'hB2, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hB2 },
{8'hB2, 8'h88, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hDB },
{8'hB2, 8'h88, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hFF, 8'hB1 },
{8'hB1, 8'h88, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'hB1 }
};
wire [7:0] red_sig, green_sig, blue_sig;
assign red_sig     = {object_colors[pixelY%32][pixelX%32][7:5] , 5'd0};
assign green_sig   = {object_colors[pixelY%32][pixelX%32][4:2] , 5'd0};
assign blue_sig    = {object_colors[pixelY%32][pixelX%32][1:0] , 6'd0};
// end of brick bitmap

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
				redBits <= LIGHT_COLOR ;	
				greenBits <= LIGHT_COLOR  ;	
				blueBits <= LIGHT_COLOR ;	
				selection <= selectionTmp;
				random <= randomTmp;
					
	end
		
	else if(startLevel2 || startLevel3) 
		random <= randomTmp;
	
	else begin
	
	// defaults 
//		greenBits <= 3'b101 ; 
//		redBits <= 3'b100 ;
//		blueBits <= 2'b11;//3'b111
		greenBits <= 3'b101 ; 
		redBits <= 3'b101 ;
		blueBits <= 2'b10;//3'b111
		boardersDrawReq <= 	1'b0 ;
		selectionTmp <= (maze_sel%3);
		randomTmp <= (maze_sel%5);

					
	// draw the yellow borders 
		if (pixelX == 0 || pixelY == 0  || pixelX == xFrameSize || pixelY == yFrameSize)
			begin 
				redBits <= DARK_COLOR ;	
				greenBits <= DARK_COLOR ;	
				blueBits <= LIGHT_COLOR ;	// 3rd bit will be truncked
			end

			
		else begin 
			
			if(level == 2'b01) begin							// level 1
			
				if(selection == 0) begin
					
					if (array0[(pixelY)/32][(pixelX)/32] == 1 ) begin
	
						greenBits <= object_colors[pixelY%32][pixelX%32][4:2]; 
						redBits <= object_colors[pixelY%32][pixelX%32][7:5];
						blueBits <= object_colors[pixelY%32][pixelX%32][1:0];
						boardersDrawReq <= 	1'b1 ;
					end 
					
				end	// selection = 0
					
				else if(selection == 1) begin
					
					if (array1[(pixelY)/32][(pixelX)/32] == 1 ) begin
	
						greenBits <= object_colors[pixelY%32][pixelX%32][4:2]; 
						redBits <= object_colors[pixelY%32][pixelX%32][7:5];
						blueBits <= object_colors[pixelY%32][pixelX%32][1:0];
						boardersDrawReq <= 	1'b1 ;
					end
					
				end	// selection = 1		
					
				 
					
				
				else if(selection == 2) begin
					
					if (array2[(pixelY)/32][(pixelX)/32] == 1 ) begin
	
						greenBits <= object_colors[pixelY%32][pixelX%32][4:2]; 
						redBits <= object_colors[pixelY%32][pixelX%32][7:5];
						blueBits <= object_colors[pixelY%32][pixelX%32][1:0];
						boardersDrawReq <= 	1'b1 ;
					end
					
				end	// selection = 2		
					
				
			end // level 1
			
			else if (level == 2'b10) begin						 // level 2
			
				if ( selection == 0  && array3[(pixelY)/32][(pixelX)/32] == 1 ) begin
	
					greenBits <= object_colors[pixelY%32][pixelX%32][4:2]; 
					redBits <= object_colors[pixelY%32][pixelX%32][7:5];
					blueBits <= object_colors[pixelY%32][pixelX%32][1:0];
					boardersDrawReq <= 	1'b1 ;
				end 
				
				else if ( selection == 1  && array4[(pixelY)/32][(pixelX)/32] == 1 ) begin
	
					greenBits <= object_colors[pixelY%32][pixelX%32][4:2]; 
					redBits <= object_colors[pixelY%32][pixelX%32][7:5];
					blueBits <= object_colors[pixelY%32][pixelX%32][1:0];
					boardersDrawReq <= 	1'b1 ;
				end 
				
				else if ( selection == 2  && array5[(pixelY)/32][(pixelX)/32] == 1 ) begin
	
					greenBits <= object_colors[pixelY%32][pixelX%32][4:2]; 
					redBits <= object_colors[pixelY%32][pixelX%32][7:5];
					blueBits <= object_colors[pixelY%32][pixelX%32][1:0];
					boardersDrawReq <= 	1'b1 ;
				end 
			
			
			end // level 2
			
			else begin													 // level 3
			
				if ( selection == 0  && array6[(pixelY)/32][(pixelX)/32] == 1 ) begin
	
					greenBits <= object_colors[pixelY%32][pixelX%32][4:2]; 
					redBits <= object_colors[pixelY%32][pixelX%32][7:5];
					blueBits <= object_colors[pixelY%32][pixelX%32][1:0];
					boardersDrawReq <= 	1'b1 ;
				end 
				
				else if ( selection == 1  && array7[(pixelY)/32][(pixelX)/32] == 1 ) begin
	
					greenBits <= object_colors[pixelY%32][pixelX%32][4:2]; 
					redBits <= object_colors[pixelY%32][pixelX%32][7:5];
					blueBits <= object_colors[pixelY%32][pixelX%32][1:0];
					boardersDrawReq <= 	1'b1 ;
				end 
				
				else if ( selection == 2  && array8[(pixelY)/32][(pixelX)/32] == 1 ) begin
	
					greenBits <= object_colors[pixelY%32][pixelX%32][4:2]; 
					redBits <= object_colors[pixelY%32][pixelX%32][7:5];
					blueBits <= object_colors[pixelY%32][pixelX%32][1:0];
					boardersDrawReq <= 	1'b1 ;
				end 
			
			
			end // level 3
					

		end // else
		
		

	end 	
	
end 
endmodule

