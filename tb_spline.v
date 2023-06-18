module tb_spline;
    
parameter N = 6;
reg [(N*8)-1:0] data_y; //Two vectors where first one is for f(x) and second one is for x
reg [(N*8)-1:0] data_x;
reg enable;
wire [(10*(N-1)*8)-1:0] approximation; //Spline vector approximation of one value in f(x) corresponding to 10x more data points

reg signed [63:0] approx_array [N-2:0][9:0];
reg real array_inputx [N-1:0];
reg real array_inputy [N-1:0];
//reg real approx_real [(10*(N-1))-1:0];
spline spline_a(data_y,data_x,enable,approximation);
integer i;
integer j;
integer k;
// initial begin
//     $display("\t\tTime Car 1 Car 2 Car 3 New velocity\n");
//     $monitor("%d %d %d %d %d", $time, car_1_new_distancex, car_2_distance_x, car_3_distance_x, car_1_new_velocity);
// end

initial begin
    
    $dumpfile("stimulus_spline.vcd");
    $dumpvars(0,tb_spline);
    // clock <= 0;
    // reset <= 1;
    enable = 1'b0;
    // data_y <= {8'd20,8'd7,8'd3,8'd1};
    // data_x <= {8'd3,8'd2,8'd1,8'd0};
    // data_y <= {8'd136,8'd104,8'd64,8'd34,8'd4,8'd0};
    // data_x <= {8'd2,8'd2,8'd6,8'd6,8'd10,8'd6};
    
    //N <= 0;
    data_y <= 48'd0;
    data_x <= 48'd0;

    #50 enable = 1'b1;
    // @(negedge clock);

    
    
    //N <= 4;
    // data_y = {8'd1,8'd3,8'd7,8'd20};
    // data_x = {8'd0,8'd1,8'd2,8'd3};
     
    // array_inputy = [20.09,7.39,2.72,1];
    // array_inputx = [3,2,1,0];
    #50 
    // data_y <= {8'd20,8'd7,8'd3,8'd1};
    // data_x <= {8'd3,8'd2,8'd1,8'd0};
    data_y <= {8'd136,8'd104,8'd64,8'd34,8'd4,8'd0};
    data_x <= {8'd2,8'd2,8'd6,8'd6,8'd10,8'd6};
    // data_y <= 32'b00000001000000110000011100010100;
    // data_x <= 32'b00000000000000010000001000000011;
    
    // data_y <= {8'b00000001,8'b00000011,8'b00000111,8'b00010100};
    // data_x <= {8'b00000000,8'b00000001,8'b00000010,8'b00000011};
    // // //Convert approximate output into matrix
    #100
    for (i=0;i<N-1;i=i+1) 
    begin
    for (j=0;j<=9;j=j+1)
    begin
    approx_array[i][j] = approximation[(i*10+j)*8+:8]; //Each value is 8-bit wide
    $display("\t %d \n",approx_array[i][j]);
    end
    end
    //Convert the matrix into an array of real values
    // k=0;
    // for (i=0;i<N-1;i=i+1) 
    // begin
    // for (j=0;j<=9;j=j+1)
    // begin
    // approx_real[k] = $bitstoreal(approx_array[i][j]); //Each value is 64-bit wide
    // $display("Real approximate values are = %g",approx_real[k]);
    // k=k+1;
    // end
    // end
    




    #100 $finish;
end

// always
// begin
//     #20 clock = ~clock;
// end



endmodule 

