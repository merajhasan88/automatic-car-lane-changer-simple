module stimulus;

reg [7:0] car_1_distance_x;
reg [7:0] car_2_distance_x;
reg [7:0] car_3_distance_x;
reg [7:0] car_1_distance_y;
reg [7:0] car_2_distance_y;
reg [7:0] car_3_distance_y;
reg [7:0] car_1_velocity;
reg [7:0] car_2_velocity;
reg [7:0] car_3_velocity;
reg clock;
reg reset;
wire [7:0] car_1_new_velocity;
wire [7:0] car_1_new_distancex;
wire [7:0] car_1_new_distancey;
wire enable;


path_planning path_a(car_1_distance_x,car_2_distance_x, car_3_distance_x,car_1_distance_y,car_2_distance_y,car_3_distance_y,car_1_velocity,car_2_velocity,car_3_velocity,clock,reset,car_1_new_velocity,car_1_new_distancex,car_1_new_distancey,enable);


initial begin
    $display("\t\tTime Car 1 Car 2 Car 3 New velocity New y_distance\n");
    $monitor("%d %d %d %d %d %d", $time, car_1_new_distancex, car_2_distance_x, car_3_distance_x, car_1_new_velocity,car_1_new_distancey);
end

initial begin
    
    $dumpfile("stimulus_pathplanning_fsm.vcd");
    $dumpvars(0,stimulus);
    clock<=0;
    reset<=1;
    car_1_distance_x<=0;
    car_2_distance_x<=0; 
    car_3_distance_x<=0;
    car_1_distance_y<=0;
    car_2_distance_y<=0;
    car_3_distance_y<=0;
    car_1_velocity<=0;
    car_2_velocity<=0;
    car_3_velocity<=0;
   
    
    #50 reset = 0;
    @(negedge clock);

    
    #80 car_1_distance_x<=8'd5; //Car is in middle lane
    car_2_distance_x<=8'd2; //Car 2 is in left lane 
    car_3_distance_x<=8'd6; //Car 3 is in middle lane 
    car_1_distance_y<=8'd4; //Car has traveled 4 units
    car_2_distance_y<=8'd12; //Car 2 has traveled 12 units
    car_3_distance_y<=8'd6;  //Car 3 has traveled 6 units
    car_1_velocity<=8'd50; //Car 1 has max velocity
    car_2_velocity<=8'd50; //Car 2 has max velocity
    car_3_velocity<=8'd40; //Car 3 is traveling at 40
    
// Car is in right lane now
    #180 
    car_2_distance_x<=8'd11; //Car 2 is in right lane 
    car_3_distance_x<=8'd7; //Car 3 is in middle lane 
    car_1_distance_y<=8'd34; //Car has traveled 34 units
    car_2_distance_y<=8'd38; //Car 2 has traveled 38 units
    car_3_distance_y<=8'd62;  //Car 3 has traveled 62 units
    car_2_velocity<=8'd50; //Car 2 has max velocity
    car_3_velocity<=8'd50; //Car 3 has max velocity
    
// Car is in middle lane now
    #180 
    car_2_distance_x<=8'd3; //Car 2 is in left lane 
    car_3_distance_x<=8'd12; //Car 3 is in right lane 
    car_1_distance_y<=8'd64; //Car has traveled 64 units
    car_2_distance_y<=8'd78; //Car 2 has traveled 78 units
    car_3_distance_y<=8'd90;  //Car 3 has traveled 90 units
    car_2_velocity<=8'd50; //Car 2 has max velocity
    car_3_velocity<=8'd50; //Car 3 has max velocity
    
// Car is in middle lane now    
    #180 
    car_2_distance_x<=8'd5; //Car 2 is in middle lane 
    car_3_distance_x<=8'd11; //Car 3 is in right lane 
    car_1_distance_y<=8'd104; //Car has traveled 104 units
    car_2_distance_y<=8'd107; //Car 2 has traveled 107 units
    car_3_distance_y<=8'd106;  //Car 3 has traveled 106 units
    car_2_velocity<=8'd20; //Car 2 has 20 speed
    car_3_velocity<=8'd40; //Car 3 has 40 speed
    
// Car is in left lane now    
    #180 
    car_2_distance_x<=8'd1; //Car 2 is in left lane 
    car_3_distance_x<=8'd7; //Car 3 is in middle lane 
    car_1_distance_y<=8'd136; //Car has traveled 136 units
    car_2_distance_y<=8'd240; //Car 2 has traveled 240 units
    car_3_distance_y<=8'd248;  //Car 3 has traveled 248 units
    car_2_velocity<=8'd50; //Car 2 has 50 speed
    car_3_velocity<=8'd50; //Car 3 has 50 speed
        
    #80 $finish;
end

always
begin
    #20 clock = ~clock;
end

endmodule
