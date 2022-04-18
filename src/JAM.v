module JAM (
input CLK,
input RST,
output reg [2:0] W,
output reg [2:0] J,
input [6:0] Cost,
output reg [3:0] MatchCount,
output reg [9:0] MinCost,
output reg Valid );

//parameter
parameter IDLE    = 3'b000;
parameter READ    = 3'b001;
parameter SORT    = 3'b010; 
parameter REVERSE = 3'b011;
parameter CMP     = 3'b100;
parameter FINISH  = 3'b101;

reg [3:0]   cnt_state, nxt_state;
reg         read_valid, read_complete;
reg [3:0]   cnt_j;
reg [2:0]   cnt_w;
reg [2:0]   bf[0:7];
reg [2:0]   //rplace_aim0,
            rplace_aim0_idx,
            rplace_aim1,
            rplace_aim1_idx;
reg         rplace_find1;
reg [2:0]   bf_tmp[0:7];
reg [2:0]   cnt_cmp0, cnt_cmp1, cnt_cmp1_2;
reg         sort_complete;
reg [9:0]   psum;
reg [9:0]   result;
reg [3:0]   cnt_rd;
reg         compare_valid, compare_complete;
reg [4:0]   cnt_result;

//**** state ****//
//state loic
always@(posedge CLK or posedge RST) begin
    if(RST)
        cnt_state <= IDLE; 
    else
        cnt_state <= nxt_state;
end

//next state logic
always@(*)begin
    nxt_state = cnt_state;
    case(cnt_state)
        IDLE: begin
            nxt_state = READ;
            Valid = 1'd0;
        end
        READ:
            nxt_state = SORT;
        SORT: begin
            if(rplace_find1==1'd1)
                nxt_state = REVERSE;
            else if(sort_complete==1'd1)
                nxt_state = FINISH;
            else
                nxt_state = SORT;
        end
        REVERSE:
            nxt_state = CMP;
        CMP: begin
            if(cnt_rd==4'd8)
                nxt_state = SORT;
            else
                nxt_state = CMP;
        end
        FINISH: begin
            nxt_state = FINISH;
            Valid = 1'd1;
            MatchCount = cnt_result + 5'd1;
            MinCost = result;
        end
        default: nxt_state = FINISH;
    endcase
end

//**** sort algorithom ****//
//sort buffer
always@(posedge CLK or posedge RST)begin
    if (RST) begin
        bf[0] <= 3'd0;
        bf[1] <= 3'd1;
        bf[2] <= 3'd2;
        bf[3] <= 3'd3;
        bf[4] <= 3'd4;
        bf[5] <= 3'd5;
        bf[6] <= 3'd6;
        bf[7] <= 3'd7;
        bf_tmp[0] <= 3'd0;
        bf_tmp[1] <= 3'd0;
        bf_tmp[2] <= 3'd0;
        bf_tmp[3] <= 3'd0;
        bf_tmp[4] <= 3'd0;
        bf_tmp[5] <= 3'd0;
        bf_tmp[6] <= 3'd0;
        bf_tmp[7] <= 3'd0;
        //rplace_aim0     <= 3'd0;
        rplace_aim0_idx <= 3'd0;
        //rplace_find0    <= l'd0;
        rplace_aim1     <= 3'd0;
        rplace_aim1_idx <= 3'd0;
        rplace_find1    <= 1'd0;
        cnt_cmp0        <= 3'd7;
        cnt_cmp1        <= 3'd7;
        cnt_cmp1_2      <= 3'd1;
        sort_complete   <= 1'd0;
    end
    else if(nxt_state==READ)begin
        bf[0] <= 3'd0;
        bf[1] <= 3'd1;
        bf[2] <= 3'd2;
        bf[3] <= 3'd3;
        bf[4] <= 3'd4;
        bf[5] <= 3'd5;
        bf[6] <= 3'd6;
        bf[7] <= 3'd7;
        bf_tmp[0] <= 3'd0;
        bf_tmp[1] <= 3'd0;
        bf_tmp[2] <= 3'd0;
        bf_tmp[3] <= 3'd0;
        bf_tmp[4] <= 3'd0;
        bf_tmp[5] <= 3'd0;
        bf_tmp[6] <= 3'd0;
        bf_tmp[7] <= 3'd0;
        //rplace_aim0     <= 3'd0;
        rplace_aim0_idx <= 3'd0;
        //rplace_find0    <= l'd0;
        rplace_aim1     <= 3'd0;
        rplace_aim1_idx <= 3'd0;
        rplace_find1    <= 1'd0;
        cnt_cmp0        <= 3'd7;
        cnt_cmp1        <= 3'd7;
        cnt_cmp1_2      <= 3'd1;
        sort_complete   <= 1'd0;
    end
    else if(nxt_state==SORT)begin
        if(bf[cnt_cmp0]>bf[cnt_cmp0-3'd1])begin
            //rplace_aim0     <= bf[cnt_cmp0-3'd1];
            rplace_aim0_idx <= cnt_cmp0-3'd1;
            //rplace_find0    <= 1'd1;
            bf_tmp[0] <= bf[0];
            bf_tmp[1] <= bf[1];
            bf_tmp[2] <= bf[2];
            bf_tmp[3] <= bf[3];
            bf_tmp[4] <= bf[4];
            bf_tmp[5] <= bf[5];
            bf_tmp[6] <= bf[6];
            bf_tmp[7] <= bf[7];
            if(bf[cnt_cmp1]-bf[cnt_cmp0-3'd1])begin
                if((bf[cnt_cmp1]<bf[cnt_cmp1-cnt_cmp1_2])||
                   (bf[cnt_cmp1]>bf[cnt_cmp0-3'd1]>bf[cnt_cmp1-cnt_cmp1_2]))begin
                       if((cnt_cmp1-cnt_cmp1_2)==cnt_cmp0-3'd1)begin
                           rplace_aim1          <= bf[cnt_cmp1];
                           rplace_aim1_idx      <= cnt_cmp1;
                           rplace_find1         <= 1'd1;
                           bf[cnt_cmp0-3'd1]    <= bf[cnt_cmp1];
                           bf[cnt_cmp1]         <= bf[cnt_cmp0-3'd1];
                           bf_tmp[cnt_cmp0-3'd1]<=bf_tmp[cnt_cmp1];
                           bf_tmp[cnt_cmp1]     <=bf_tmp[cnt_cmp0-3'd1];
                       end
                       else
                            cnt_cmp1_2 <= cnt_cmp1_2 + 3'd1;
                end
                else begin
                    if((cnt_cmp1-cnt_cmp1_2)==cnt_cmp0-3'd1)begin
                        rplace_aim1          <= bf[cnt_cmp1];
                        rplace_aim1_idx      <= cnt_cmp1;
                        rplace_find1         <= 1'd1;
                        bf[cnt_cmp0-3'd1]    <= bf[cnt_cmp1];
                        bf[cnt_cmp1]         <= bf[cnt_cmp0-3'd1];
                        bf_tmp[cnt_cmp0-3'd1]<=bf_tmp[cnt_cmp1];
                        bf_tmp[cnt_cmp1]     <=bf_tmp[cnt_cmp0-3'd1];  
                    end
                    else
                        cnt_cmp1 <= cnt_cmp1 + 3'd1;
                end
            end
                else
                    cnt_cmp1 <= cnt_cmp1 - 3'd1;
        end
        else if({bf[0], bf[1], bf[2], bf[3], bf[4], bf[5], bf[6], bf[7]}==
                    {3'd7, 3'd6, 3'd5, 3'd4, 3'd3, 3'd2, 3'd1, 3'd0})begin
                sort_complete <= 1'd1;
        end
        else begin
            //rplace_aim0     <= 3'd0;
            rplace_aim0_idx <= 3'd0;
            //rplace_find0    <= 1'd0;
            cnt_cmp0        <= cnt_cmp0 - 3'd1;
        end
    end

    else if(nxt_state==REVERSE)begin
        case(rplace_aim0_idx)
        3'd0:begin
            bf[7] <= bf_tmp[1];
            bf[6] <= bf_tmp[2];
            bf[5] <= bf_tmp[3];
            //bf[4] <= bf_tmp[4];
            bf[3] <= bf_tmp[5];
            bf[2] <= bf_tmp[6];
            bf[1] <= bf_tmp[7];
        end
        3'd1:begin
            bf[7] <= bf_tmp[2];
            bf[6] <= bf_tmp[3];
            bf[5] <= bf_tmp[4];
            bf[4] <= bf_tmp[5];
            bf[3] <= bf_tmp[6];
            bf[2] <= bf_tmp[7];
        end
        3'd2:begin
            bf[7] <= bf_tmp[3];
            bf[6] <= bf_tmp[4];
            //bf[5] <= bf_tmp[5];
            bf[4] <= bf_tmp[6];
            bf[3] <= bf_tmp[7];
        end
        3'd3:begin
            bf[7] <= bf_tmp[4];
            bf[6] <= bf_tmp[5];
            bf[5] <= bf_tmp[6];
            bf[4] <= bf_tmp[7];
        end
        3'd4:begin
            bf[7] <= bf_tmp[5];
            bf[6] <= bf_tmp[6];
            bf[5] <= bf_tmp[7];
        end
        3'd5:begin
            bf[7] <= bf_tmp[6];
            bf[6] <= bf_tmp[7];
        end
        default:bf_tmp[1]<=bf_tmp[1];
        endcase
    end
    else if(nxt_state==CMP)begin
        bf_tmp[0] <= 3'd0;
        bf_tmp[1] <= 3'd0;
        bf_tmp[2] <= 3'd0;
        bf_tmp[3] <= 3'd0;
        bf_tmp[4] <= 3'd0;
        bf_tmp[5] <= 3'd0;
        bf_tmp[6] <= 3'd0;
        bf_tmp[7] <= 3'd0;
        //rplace_aim0     <= 3'd0;
        //rplace_aim0_idx <= 3'd0;
        //rplace_find0    <= l'd0;
        rplace_aim1     <= 3'd0;
        rplace_aim1_idx <= 3'd0;
        rplace_find1    <= 1'd0;
        cnt_cmp0        <= 3'd7;
        cnt_cmp1        <= 3'd7;
        cnt_cmp1_2      <= 3'd1;
    end
end

//**** read ****//
//read valid
always @(posedge CLK or posedge RST) begin
    if(RST)
        read_valid <= 1'd0;
    else
        read_valid <= 1'd1;
end

//read counter
//cnt
always @(posedge CLK or posedge RST) begin
    if(RST)begin
        cnt_rd <= 4'd0;
    end
    else
        if(nxt_state!=SORT)
            if(cnt_rd==4'd9)
                cnt_rd <= 4'd0;
            else
                cnt_rd <= cnt_rd + 4'd1;
        else
            cnt_rd <= 3'd0;
end

//adder
always @(negedge CLK or posedge RST) begin
    if(RST)begin
        J <= 3'd0;
        W <= 3'd0;
    end
    else begin
        case(cnt_rd)
            4'd0:begin
                J <= bf[0];
                W <= 3'd0;
            end
            4'd1:begin
                J <= bf[1];
                W <= 3'd1;
            end
            4'd2:begin
                J <= bf[2];
                W <= 3'd2;
            end
            4'd3:begin
                J <= bf[3];
                W <= 3'd3;
            end
            4'd4:begin
                J <= bf[4];
                W <= 3'd4;
            end
            4'd5:begin
                J <= bf[5];
                W <= 3'd5;
            end
            4'd6:begin
                J <= bf[6];
                W <= 3'd6;
            end
            4'd7:begin
                J <= bf[7];
                W <= 3'd7;
            end
            4'd8:
                J <= J;
            4'd9:begin
                J <= bf[0];
                W <= 3'd0;
            end
            default: J <= J;
        endcase
    end
end

//psum
always @(posedge CLK or posedge RST) begin
    if(RST)
        psum <= 10'd0;
    else
        if(compare_complete==1'd1)
            psum <= 10'd0;
        else if(cnt_rd<4'd1)
            psum <= psum;
        else
            psum <= psum + Cost;
end

//compare logic
always @(posedge CLK or posedge RST) begin
    if(RST)begin
        result <= 10'd0;
        cnt_result <= 5'd0;
    end
    else
        if(compare_complete==1'd1)begin
            if((psum<result)&&(result!=10'd0))begin
               psum <= 10'd0;
                cnt_result <= 5'd0; 
            end
            else if(psum==result)begin
                cnt_result <= cnt_result + 5'd1;
            end
            else if(result==10'd0)begin
                result <= psum;
            end
            else begin
                result <= result;
            end
        end
        else begin
            result <= result;
            cnt_result <= cnt_result;
        end
end

always @(posedge CLK or posedge RST) begin
    if(RST)
        compare_complete <= 1'd0;
    else
        if(cnt_rd==4'd8)
            compare_complete <= 1'd1;
        else
            compare_complete <= 1'd0;
end

endmodule


