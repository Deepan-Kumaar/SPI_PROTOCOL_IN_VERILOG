module SPI_slave (
    input   s_MOSI,
    output reg s_MISO,
    input sck,
    input  sl_se,
    input [1:0]mode
);
//reg clk=0;
//always #3 clk=~clk;
integer i=0;
//slave mem
reg [7:0]s_mem=8'b10101010;

//fsm states
reg [2:0] state;
parameter [2:0] IDLE =3'd0 ;
parameter [2:0] SEND_NEG =3'd3 ;
parameter [2:0] SEND_POS =3'd2 ;
parameter [2:0] SEL =3'd1 ;
initial state=IDLE;

////Modes 
wire CPHA;////set as wires for now if want to change change
wire CPOL;

//////////This is used to give different modes for the SPI (0,0),(0,1),(1,0),(1,1) (cpol,cpha)
wire mm;
assign CPOL=(mode==0)|(mode==1)?0:1;
assign CPHA=(mode==0)|(mode==2)?0:1;
xor(mm,CPHA,CPOL);//will be used to get the negedge triggered modes 1 and 2

always@(sck)
begin
    case (state)
    IDLE:
    begin        
       if(sl_se==0)state= SEL;//this will be true any ways
        else state = IDLE;
    end
    SEL: //to select neg or pos
    begin 
        i=0;  
        state=(mm==0)?SEND_POS:SEND_NEG;      
    end
        
    SEND_NEG://mode 1 and 2
    begin
        for(i=0;i<=8;i=i+1)
        @(negedge sck)begin 
        s_MISO=s_mem[0];
        s_mem={s_MOSI,s_mem[7:1]};
        end
        state=IDLE;
    end
    SEND_POS://mode 0 and 3
    begin
        for(i=0;i<=8;i=i+1)
        @(posedge sck)begin 
        s_MISO=s_mem[0];
        s_mem={s_MOSI,s_mem[7:1]};
        end
        state = IDLE;
    end
    endcase
    
end   





endmodule //SPI_slave