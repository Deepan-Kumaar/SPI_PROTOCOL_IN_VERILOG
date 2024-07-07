module SPI_master (
    //input  clk,
    input  [7:0]in_DATA,
    input  m_MISO,                                    
    output reg m_MOSI,
    input ss_trig,
    output reg sl_se, 
    input [1:0]mode,
    output reg sck,
    input [4:0]clk_RATE
    //output reg test
);
integer i=0;
//clk
reg clk;
always #clk_RATE clk=~clk;

//fsm states
reg [2:0] state;
parameter [2:0] IDLE =3'd0 ;
parameter [2:0] SEND_NEG =3'd3 ;
parameter [2:0] SEND_POS =3'd2 ;
parameter [2:0] SEL =3'd1 ;
////start ur internal clk and state
initial
begin
clk=0;
state=IDLE;
end




///shift register register 
reg [7:0]mem;///used to make a shift register

////Modes 
wire CPHA;////set as wires for now if want to change change
wire CPOL;

//////////This is used to give different modes for the SPI (0,0),(0,1),(1,0),(1,1) (cpol,cpha)
wire mm;
assign CPOL=(mode==0)|(mode==1)?0:1;
assign CPHA=(mode==0)|(mode==2)?0:1;
xor(mm,CPHA,CPOL);//will be used to get the negedge triggered modes 1 and 2


always @(posedge ss_trig) @(negedge ss_trig) sl_se=0;//this will change the value of sl_se only will the trig is touched like a button

initial #1 mem=in_DATA[7:0];//save data to reg

/* NOTE:WHEN THE CPOL IS "0" THEN IS MEANS THAT THE SCK STARTS WITH A ZERO AND 
WHEN IT IS "1" THEN IT THE SCK STARTS WITH A ONE */
always@(*)
begin
if(sl_se==0)
begin

    sck=(CPOL==0)?clk:~(clk);////will give the sck only when the slave is selected
end
end
//FSM
always@(sck)
begin
    case (state)
    IDLE:
    begin        
       if(sl_se==0)state <= SEL;//this will be true any ways
        else state <= IDLE;
    end
    SEL: //to select neg or pos
    begin 
        i=0;  
        state=(mm==0)?SEND_POS:SEND_NEG;      
    end
        
    SEND_NEG://mode 1 and 2
    begin
        for(i=0;i<=8;i=i+1)begin
        @(negedge sck)begin m_MOSI=mem[0];
        mem={m_MISO,mem[7:1]}; 
        end       
        end
        sl_se=1;
        state=IDLE;
    end
    SEND_POS://mode 0 and 3
    begin
        for(i=0;i<=8;i=i+1)
        begin
        @(posedge sck)begin m_MOSI=mem[0];
        mem={m_MISO,mem[7:1]};
        end
        end
        sl_se=1;
        state = IDLE;
    end
    endcase
    
end    
endmodule