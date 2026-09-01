`timescale 1ns / 1ps

module SSPR #(parameter WIDTH = 8 )(
input in_clk,
input in_rst_n,
input in_valid,
input out_ready,
input [WIDTH-1:0] in_data,
output [WIDTH-1:0]  out_data,
output in_ready,
output out_valid 
);
logic [WIDTH-1:0] data_reg;
logic valid_reg;


always_ff @(posedge in_clk or negedge in_rst_n) begin

if ( !in_rst_n) begin
data_reg <= 0;
valid_reg <= 0;
end

else begin

// accept new data when data_reg is empty and input is valid
// Accept and push data simultaneously
if(in_valid && (!valid_reg || out_ready)) begin
data_reg <= in_data;
valid_reg <= 1;
end
// Push old data when data_reg is full and output interface is ready
else if(out_ready && valid_reg) begin
valid_reg <= 0;
end
end
end
assign out_valid = valid_reg;
assign in_ready = ~valid_reg || out_ready;
assign out_data = data_reg;

endmodule
