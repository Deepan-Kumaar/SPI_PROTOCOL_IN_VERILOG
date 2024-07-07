module SPI_master_tb;
 // Parameters

  //Ports
  reg [7:0] in_DATA;
  reg  m_MISO;
  wire  m_MOSI;
  wire  sl_se;
  reg  [1:0]mode;
  wire  sck;
  reg [4:0] clk_RATE;
  reg ss_trig; 
  //wire test;
  reg  s_MOSI;
wire  s_MISO;

//reg r_MOSI;

SPI_master  SPI_master_inst(
    .in_DATA(in_DATA),
    .m_MISO(s_MISO),
    .m_MOSI(m_MOSI),
    .ss_trig(ss_trig),
    .sl_se(sl_se),
    .mode(mode),
    .sck(sck),
    .clk_RATE(clk_RATE)
  );


SPI_slave  SPI_slave_inst (
  .s_MOSI(s_MOSI),
  .s_MISO(s_MISO),
  .sck(sck),
  .sl_se(sl_se),
  .mode(mode)
);
initial assign s_MOSI=m_MOSI;
initial assign m_MISO=s_MISO;

initial 
begin
    clk_RATE=10;
    in_DATA=8'b10001001;
    
    mode=2;
    #10 ss_trig=1;
    #10 ss_trig=0;
  end
  

 
  
  always #300 $finish();

endmodule
