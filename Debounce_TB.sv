`timescale 1ns / 1ps

module Debounce_TB();

    // Testbench signals
    reg  r_Clk    = 1'b0;
    reg  r_Switch = 1'b0;
    wire o_LED_1;

    // Clock: 4 ns period
    always #2 r_Clk = ~r_Clk;

    // DUT
    Debounce_Project_Top #(
        .DEBOUNCE_LIMIT(4)
    ) UUT (
        .i_Clk    (r_Clk),
        .i_Switch_1(r_Switch),
        .o_LED_1  (o_LED_1)
    );
    
    initial begin
    $display("===============");
    $display("Starting Debounce Testbench");
    $display("===============");
    
    // Initial condition
        r_Switch = 1'b0;

        repeat(3) @(posedge r_Clk);

        $display("[%0t ns] Initial state: Switch=%b LED=%b",
                 $time, r_Switch, o_LED_1);
                 
         // ------------------------------------------------
        // TEST 1: Press switch with bouncing
        // ------------------------------------------------
        
        $display("\nTest 1: Switch press with bouncing");
        
        //First Transistion
        r_Switch = 1'b0;
        #2
        r_Switch = 1'b1;
        #2
        r_Switch = 1'b0;
        #2
        
        //Finaly stable HIGH
        r_Switch = 1'b1;
        // Wait long enough for debounce
        repeat(6)@(posedge r_Clk)
        
        $display("[%0t ns] After press :Switch=%b LED=%b",$time, r_Switch, o_LED_1);
        
        // ------------------------------------------------
        // TEST 2: Release switch with bouncing
        // ------------------------------------------------

        $display("\nTEST 2: Switch release with bouncing"); 
        
        r_Switch = 1'b0;
        #2
        r_Switch = 1'b1;
        #2
        r_Switch = 1'b0;
        #2
        r_Switch = 1'b1;
        #2
        //Finally Stable Low
        
       repeat(6)@(posedge r_Clk);
       $display("[%0t ns] After press :Switch=%b LED=%b",$time, r_Switch, o_LED_1);
       
       
          // ------------------------------------------------
        // TEST 3: Second press/release
        // ------------------------------------------------

        $display("\nTEST 3: Second press/release");

        // Press
        r_Switch = 1'b1;
        repeat(6) @(posedge r_Clk);

        // Release
        r_Switch = 1'b0;
        repeat(6) @(posedge r_Clk);

        $display("[%0t ns] After second release: Switch=%b LED=%b",
                 $time, r_Switch, o_LED_1);


        // ------------------------------------------------
        // Finish
        // ------------------------------------------------

        $display("\n=================================");
        $display("Test Complete");
        $display("=================================");

        $finish;

    end

endmodule
