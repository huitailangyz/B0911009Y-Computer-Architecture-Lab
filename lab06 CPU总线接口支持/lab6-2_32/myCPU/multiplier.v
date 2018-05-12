module multiplier(
  input wire    mul_clk,
  input wire    resetn,
  input wire    mul_signed,
  input wire [31:0]   x,
  input wire [31:0]   y,
  input wire valid_in_x,
  input wire valid_in_y,
  output reg valid_out,
  output wire [63:0]    result
);


//step1 booth 编码

wire [64:0] xx;
wire [64:0] yy;
wire [64:0] xb;
wire [64:0] neg_xb;
wire [64:0] xb_2;
wire [64:0] neg_xb_2;

assign xx = (mul_signed) ? {{33{x[31]}},x} : {{33{0}},x};
assign yy = (mul_signed) ? {{33{y[31]}},y} : {{33{0}},y};

assign xb = xx;
assign neg_xb = ~xb[64:0]+1;
assign xb_2 = xb <<1;
assign neg_xb_2 =  ~xb_2[64:0]+1;

wire [64:0] oper [0:16];
reg [64:0] partmul[0:16];
wire [64:0] partsum[0:29];
reg [1:0]  state;
always @(posedge mul_clk)
begin
    if (!resetn)
    begin
        state <= 1'b0;
        valid_out <=1'b0;
    end
    else if (valid_in_x&&valid_in_y)
    begin
        state <= 1'b1;
        valid_out <= 1'b0;
    end
    else if (state == 1'b1)
    begin
        valid_out <= 1'b1;
        state <=1'b0;
    end
    else
    begin
        valid_out <= 1'b0;
        state <= 1'b0;
    end    
end
//...................

assign oper[0] = (yy[1]==yy[0] && yy[0]==0) ? 0:
                 (!yy[1] && yy[0]==1) ? xb :
                 (yy[1] && !yy[0]) ?neg_xb_2 :
                 (yy[1] && yy[0]) ? neg_xb :0;
assign oper[1] = (yy[3]==yy[2] && yy[2]==yy[1]) ? 0:
                 (!yy[3] && yy[2]^yy[1]) ? xb :
                 (!yy[3] && yy[2]&yy[1]) ? xb_2 :
                 (yy[3] && (yy[2]|yy[1])==0) ?neg_xb_2 :
                 (yy[3] && yy[2]^yy[1]) ? neg_xb :0;
assign oper[2] = (yy[5]==yy[4] && yy[4]==yy[3]) ? 0:
                 (!yy[5] && yy[4]^yy[3]) ? xb :
                 (!yy[5] && yy[4]&yy[3]) ? xb_2 :
                 (yy[5] && (yy[4]|yy[3])==0) ?neg_xb_2 :
                 (yy[5] && yy[4]^yy[3]) ? neg_xb :0;
assign oper[3] = (yy[7]==yy[6] && yy[6]==yy[5]) ? 0:
                 (!yy[7] && yy[6]^yy[5]) ? xb :
                 (!yy[7] && yy[6]&yy[5]) ? xb_2 :
                 (yy[7] && (yy[6]|yy[5])==0) ?neg_xb_2 :
                 (yy[7] && yy[6]^yy[5]) ? neg_xb :0 ;
assign oper[4] = (yy[9]==yy[8] && yy[8]==yy[7]) ? 0:
                 (!yy[9] && yy[8]^yy[7]) ? xb :
                 (!yy[9] && yy[8]&yy[7]) ? xb_2 :
                 (yy[9] && (yy[8]|yy[7])==0) ?neg_xb_2 :
                 (yy[9] && yy[8]^yy[7]) ? neg_xb :0;
assign oper[5] = (yy[11]==yy[10] && yy[10]==yy[9]) ? 0:
                 (!yy[11] && yy[10]^yy[9]) ? xb :
                 (!yy[11] && yy[10]&yy[9]) ? xb_2 :
                 (yy[11] && (yy[10]|yy[9])==0) ?neg_xb_2 :
                 (yy[11] && yy[10]^yy[9]) ? neg_xb :0;
assign oper[6] = (yy[13]==yy[12] && yy[12]==yy[11]) ? 0:
                 (!yy[13] && yy[12]^yy[11]) ? xb :
                 (!yy[13] && yy[12]&yy[11]) ? xb_2 :
                 (yy[13] && (yy[12]|yy[11])==0) ? neg_xb_2 :
                 (yy[13] && yy[12]^yy[11]) ? neg_xb :0;
assign oper[7] = (yy[15]==yy[14] && yy[14]==yy[13]) ? 0:
                 (!yy[15] && yy[14]^yy[13]) ? xb :
                 (!yy[15] && yy[14]&yy[13]) ? xb_2 :
                 (yy[15] && (yy[14]|yy[13])==0) ?neg_xb_2 :
                 (yy[15] && yy[14]^yy[13]) ? neg_xb :0 ;
assign oper[8] = (yy[17]==yy[16] && yy[16]==yy[15]) ? 0:
                 (!yy[17] && yy[16]^yy[15]) ? xb :
                 (!yy[17] && yy[16]&yy[15]) ? xb_2 :
                 (yy[17] && (yy[16]|yy[15])==0) ?neg_xb_2 :
                 (yy[17] && yy[16]^yy[15]) ? neg_xb :0;
assign oper[9] = (yy[19]==yy[18] && yy[18]==yy[17]) ? 0:
                 (!yy[19] && yy[18]^yy[17]) ? xb :
                 (!yy[19] && yy[18]&yy[17]) ? xb_2 :
                 (yy[19] && (yy[18]|yy[17])==0) ?neg_xb_2 :
                 (yy[19] && yy[18]^yy[17]) ? neg_xb :0;
assign oper[10] = (yy[21]==yy[20] && yy[20]==yy[19]) ? 0:
                 (!yy[21] && yy[20]^yy[19]) ? xb :
                 (!yy[21] && yy[20]&yy[19]) ? xb_2 :
                 (yy[21] && (yy[20]|yy[19])==0) ?neg_xb_2 :
                 (yy[21] && yy[20]^yy[19]) ? neg_xb :0;
assign oper[11] = (yy[23]==yy[22] && yy[22]==yy[21]) ? 0:
                 (!yy[23] && yy[22]^yy[21]) ? xb :
                 (!yy[23] && yy[22]&yy[21]) ? xb_2 :
                 (yy[23] && (yy[22]|yy[21])==0) ?neg_xb_2 :
                 (yy[23] && yy[22]^yy[21]) ? neg_xb :0;
assign oper[12] = (yy[25]==yy[24] && yy[24]==yy[23]) ? 0:
                 (!yy[25] && yy[24]^yy[23]) ? xb :
                 (!yy[25] && yy[24]&yy[23]) ? xb_2 :
                 (yy[25] && (yy[24]|yy[23])==0) ?neg_xb_2 :
                 (yy[25] && yy[24]^yy[23]) ? neg_xb :0;
assign oper[13] = (yy[27]==yy[26] && yy[26]==yy[25]) ? 0:
                 (!yy[27] && yy[26]^yy[25]) ? xb :
                 (!yy[27] && yy[26]&yy[25]) ? xb_2 :
                 (yy[27] && (yy[26]|yy[25])==0) ?neg_xb_2 :
                 (yy[27] && yy[26]^yy[25]) ? neg_xb :0;
assign oper[14] = (yy[29]==yy[28] && yy[28]==yy[27]) ? 0:
                 (!yy[29] && yy[28]^yy[27]) ? xb :
                 (!yy[29] && yy[28]&yy[27]) ? xb_2 :
                 (yy[29] && (yy[28]|yy[27])==0) ?neg_xb_2 :
                 (yy[29] && yy[28]^yy[27]) ? neg_xb :0;
assign oper[15] = (yy[31]==yy[30] && yy[30]==yy[29]) ? 0:
                 (!yy[31] && yy[30]^yy[29]) ? xb :
                 (!yy[31] && yy[30]&yy[29]) ? xb_2 :
                 (yy[31] && (yy[30]|yy[29])==0) ?neg_xb_2 :
                 (yy[31] && yy[30]^yy[29]) ? neg_xb :0;
assign oper[16] = (yy[33]==yy[32] && yy[32]==yy[31]) ? 0:
                  (!yy[33] && yy[32]^yy[31]) ? xb :
                  (!yy[33] && yy[32]&yy[31]) ? xb_2 :
                  (yy[33] && (yy[32]|yy[31])==0) ?neg_xb_2 :
                  (yy[33] && yy[32]^yy[31]) ? neg_xb :0;
always @ (posedge mul_clk)
begin
    if(!resetn)
    begin
        partmul[0] <= 0;
        partmul[1] <= 0;
        partmul[2] <= 0;
        partmul[3] <= 0;
        partmul[4] <= 0;
        partmul[5] <= 0;
        partmul[6] <= 0;
        partmul[7] <= 0;
        partmul[8] <= 0;
        partmul[9] <= 0;
        partmul[10] <= 0;
        partmul[11] <= 0;
        partmul[12] <= 0;
        partmul[13] <= 0;
        partmul[14] <= 0;
        partmul[15] <= 0;
        partmul[16] <= 0;  //
    end
    else
    begin
        partmul[0] <= oper[0];
        partmul[1] <= oper[1]<<2;
        partmul[2] <= oper[2]<<4;
        partmul[3] <= oper[3]<<6;
        partmul[4] <= oper[4]<<8;
        partmul[5] <= oper[5]<<10;
        partmul[6] <= oper[6]<<12;
        partmul[7] <= oper[7]<<14;
        partmul[8] <= oper[8]<<16;
        partmul[9] <= oper[9]<<18;
        partmul[10] <= oper[10]<<20;
        partmul[11] <= oper[11]<<22;
        partmul[12] <= oper[12]<<24;
        partmul[13] <= oper[13]<<26;
        partmul[14] <= oper[14]<<28;
        partmul[15] <= oper[15]<<30;
        partmul[16] <= oper[16]<<32;  //
    end
end


//step2 华莱士树   //符号位扩��??????
assign partsum[0] =  (partmul[16] ^~ partmul[15] ^~ partmul[14]);
assign partsum[1] =  (partmul[16]&partmul[15] | partmul[15]&partmul[14] | partmul[14]&partmul[16])<<1;
assign partsum[2] =  (partmul[13] ^~ partmul[12] ^~ partmul[11]);
assign partsum[3] =  (partmul[13]&partmul[12] | partmul[12]&partmul[11] | partmul[11]&partmul[13])<<1;
assign partsum[4] =  (partmul[10] ^~ partmul[9] ^~ partmul[8]);
assign partsum[5] =  (partmul[10]&partmul[9] | partmul[9]&partmul[8] | partmul[8]&partmul[10])<<1;
assign partsum[6] =  (partmul[7] ^~ partmul[6] ^~ partmul[5]);
assign partsum[7] =  (partmul[7]&partmul[6] | partmul[6]&partmul[5] | partmul[5]&partmul[7])<<1;
assign partsum[8] =  (partmul[4] ^~ partmul[3] ^~ partmul[2]);
assign partsum[9] =  (partmul[4]&partmul[3] | partmul[3]&partmul[2] | partmul[2]&partmul[4])<<1;
assign partsum[10] =  (partsum[0] ^~ partsum[2] ^~ partsum[4]);
assign partsum[11] =  (partsum[0]&partsum[2] | partsum[2]&partsum[4] | partsum[4]&partsum[0])<<1;
assign partsum[12] =  (partsum[6] ^~ partsum[8] ^~ partmul[1]);
assign partsum[13] =  (partsum[6]&partsum[8] | partsum[8]&partmul[1] | partmul[1]&partsum[6])<<1;
assign partsum[14] =  (partmul[0] ^~ partsum[1] ^~ partsum[3]);
assign partsum[15] =  (partmul[0]&partsum[1] | partsum[1]&partsum[3] | partsum[3]&partmul[0])<<1;
assign partsum[16] =  (partsum[5] ^~ partsum[7] ^~ partsum[9]);
assign partsum[17] =  (partsum[5]&partsum[7] | partsum[7]&partsum[9] | partsum[9]&partsum[5])<<1;
assign partsum[18] = (partsum[10] ^~ partsum[12] ^~ partsum[14]);
assign partsum[19] = (partsum[10]&partsum[12] | partsum[12]&partsum[14] | partsum[14]&partsum[10])<<1;
assign partsum[20] = (partsum[16] ^~ partsum[11] ^~ partsum[13]);
assign partsum[21] = (partsum[16]&partsum[11] | partsum[11]&partsum[13] | partsum[13]&partsum[16])<<1;
assign partsum[22] = (partsum[18] ^~ partsum[20] ^~ partsum[15]);
assign partsum[23] = (partsum[18]&partsum[20] | partsum[20]&partsum[15] | partsum[15]&partsum[18])<<1;
assign partsum[24] = (partsum[17] ^~ partsum[19] ^~ partsum[21]);
assign partsum[25] = (partsum[17]&partsum[19] | partsum[19]&partsum[21] | partsum[21]&partsum[17])<<1;
assign partsum[26] = (partsum[22] ^~ partsum[24] ^~ partsum[23]);
assign partsum[27] = (partsum[22]&partsum[24] | partsum[24]&partsum[23] | partsum[23]&partsum[22])<<1;
assign partsum[28] = (partsum[26] ^~ partsum[27] ^~ partsum[25]);
assign partsum[29] = (partsum[26]&partsum[27] | partsum[27]&partsum[25] | partsum[25]&partsum[26])<<1;

wire [64:0] tempresult;
assign tempresult = partsum[29]+partsum[28];
assign result = {tempresult[63:0]};

endmodule 
