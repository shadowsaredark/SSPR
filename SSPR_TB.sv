`timescale 1ns / 1ps



module SSPR_TB();
localparam WIDTH = 8;

logic clk = 1'b0;
logic rst_n;
logic in_valid;
logic in_ready;
logic out_valid;
logic out_ready;
logic [WIDTH-1:0] out_data;
logic [WIDTH-1:0] in_data;

SSPR #(.WIDTH(WIDTH)) DUT
(
.in_clk(clk),
.in_rst_n(rst_n),
.in_valid(in_valid),
.out_valid(out_valid),
.out_ready(out_ready),
.in_ready(in_ready),
.in_data(in_data),
.out_data(out_data)
);
// generate clock
always #10 clk <= ~clk;
int k = 0;
initial begin

//apply reset
rst_n = 0;
in_valid = 0;
out_ready = 0;
in_data = 8'b0;
#20
if (!(in_ready && !out_valid && (out_data === 8'b0)))
    $error("Reset failed");
else
    $display("Reset successful");
#25
rst_n = 1;
#20

in_data <= 8'hA5;
in_valid <= 1; 

@(posedge clk);
@(negedge clk);
in_valid = 0;

out_ready = 0;

repeat (3) begin
    @(posedge clk);
    @(negedge clk);
    if( !out_valid || (out_data !== 8'hA5))
        $error("Data wasn't held correctly under backpressure");
        end
out_ready = 1;


if (!out_valid)
    $error("Expected A5 to be valid before transfer");

if (out_data !== 8'hA5)
    $error("Incorrect output data before transfer");

if (!out_ready)
    $error("Output was not ready");
// This edge is where the transfer happens
@(posedge clk);
@(negedge clk);

// Now the buffer should be empty
if (out_valid)
    $error("Buffer should be empty after transfer");
else    
    $display("Transaction successful");
    
    
// Simulataneous transfer

in_data = 8'hA5;
in_valid = 1; 
out_ready =0;
@(posedge clk);
@(negedge clk);
in_valid = 0;
@(posedge clk);
@(negedge clk);



in_data = 8'hA6;
in_valid = 1;
out_ready = 1;

#3
$display("Before transfer: in_valid=%b in_ready=%b out_valid=%b out_ready=%b in_data=%h out_data=%h",
         in_valid, in_ready, out_valid, out_ready, in_data, out_data);

if (!(in_valid && in_ready))
    $error("Input transfer was not ready");

if (!(out_valid && out_ready))
    $error("Output transfer was not ready");

    
@(posedge clk);
@(negedge clk);  
 
if (!out_valid)
    $error("Expected out_valid to be 1 after transfer");
if(out_data !== 8'hA6)
    $error("Incorrect data, expected A6");
else
    $display("Simultaneous transfer successful"); 
    
    //empty buffer + simultaneous change, valid input and invalid output   
    
rst_n = 0;
#20
rst_n = 1;
in_data = 8'hA5;
in_valid = 1; 
out_ready =1;
if (!(in_valid && in_ready))
    $error("Expected input transfer");

if (out_valid && out_ready)
    $error("Unexpected output transfer from empty buffer"); 
   
@(posedge clk);
@(negedge clk);  
in_valid = 0;
out_ready = 0;

if(!out_valid)
    $error("No data in buffer");
if(out_data !== 8'hA5)
    $error("Incorrect stored data, expected A5"); 

// store in a full buffer

rst_n = 0;
in_valid = 0;
out_ready = 0;
in_data = 8'b0;
#20
rst_n = 1;
#20
in_data <= 8'hA5;
in_valid <= 1; 

@(posedge clk);
@(negedge clk);
 if(in_ready)
    $error("Buffer should be full and out_ready = 0, so in_ready should be 0");   
in_data <= 8'hA6;
in_valid <= 1; 
@(posedge clk);
@(negedge clk);
if (!out_valid)
    $error("Data was lost under backpressure");

if (out_data !== 8'hA5)
    $error("Buffer contents changed; expected A5");

if (in_ready)
    $error("in_ready should remain 0 while buffer is full and blocked");

//read from an empty buffer
rst_n = 0;
in_valid = 0;
out_ready = 0;
in_data = 8'b0;
#20
rst_n = 1;
#20
out_ready = 1;
if(out_valid)
    $error("Expected out_valid to be 0");
@(posedge clk);
@(negedge clk);
if (out_valid)
    $error("Unexpected output transfer");
else
    $display("No data transfer occurred - test successful");
    
    
//Continuous assignment

rst_n = 0;
in_valid = 0;
out_ready = 0;
in_data = 8'b0;
#20
rst_n = 1;
#20
// Continuous traffic
   
out_ready = 1;
in_valid = 1;


for (int i = 0; i < 4; i++) begin
    in_data = 8'hA5 + i;

    @(posedge clk);
    @(negedge clk);

    if (!(in_valid && in_ready))
        $error("Input transfer was not ready for data %h", in_data);

    if (out_data === in_data )
        k++;
    else
        $error("Incorrect output data: expected %h, got %h", in_data, out_data);
end
in_valid = 0;
if (k !== 4)
    $error("Continuous traffic test failed: %0d/4 transfers correct", k);
else
    $display("Continuous traffic test successful: A5 -> A6 -> A7 -> A8");
    
         
    
    
    
    
end
endmodule
