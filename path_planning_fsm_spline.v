`include "spline.v"
module path_planning(car_1_distance_x,car_2_distance_x, car_3_distance_x,car_1_distance_y,car_2_distance_y,car_3_distance_y,car_1_velocity,car_2_velocity,car_3_velocity,clock,reset,car_1_new_velocity,car_1_new_distancex,car_1_new_distancey,enable);


//Inputs and outputs declared on main
input [7:0] car_1_distance_x;
input [7:0] car_2_distance_x;
input [7:0] car_3_distance_x;
input [7:0] car_1_distance_y;
input [7:0] car_2_distance_y;
input [7:0] car_3_distance_y;
input [7:0] car_1_velocity;
input [7:0] car_2_velocity;
input [7:0] car_3_velocity;
input clock;
input reset;
output reg [7:0] car_1_new_velocity;
output reg [7:0] car_1_new_distancex;
output reg [7:0] car_1_new_distancey;
output reg enable;

//Calling spline module
parameter N = 2;
reg [(N*8)-1:0] car_y_array; // Vectors sent to spline
reg [(N*8)-1:0] car_x_array; //
//reg clock, reset;
wire [(10*(N-1)*8)-1:0] approx_path; //Spline calculates a curved path between the different coordinates
integer i;
integer j = 1;
spline spline_path(.data_y(car_y_array),.data_x(car_x_array),.enable(enable),.approximation(approx_path));

//Arrays that will be converted to vectors sent to spline
reg [7:0] flat_arrayx [N-1:0];
reg [7:0] flat_arrayy [N-1:0];

// internal variables used prior to FSM
reg [7:0] front_dist;
reg [7:0] rel_velocity;
reg [1:0] lane_car2;
reg [1:0] lane_car3;

//internal FSM state declarations
reg [1:0] NEXT_LANE;
reg [1:0] PRES_LANE;


parameter left = 2'b00;
parameter middle = 2'b01;
parameter right = 2'b10;

//Find lane of any car
task automatic find_lane;
input [7:0] position;
output [1:0] lane;

begin
    if (position <= 8'd4 && position > 8'd0)
    begin
    lane = left;
    //$display("Left Lane");
    end
    else if (position <= 8'd8 && position > 8'd4)
    begin
    lane = middle;
    //$display("Middle Lane");
    end
    else if (position <= 8'd12 && position > 8'd8)
    begin
    lane = right;
    //$display("Right lane");
    end
    else
    begin
    lane = 0;
    //$display("No data yet");
    end
end

endtask


//Calculate distance between front of your car and the one ahead
task front_calculation;
input [1:0] lane_car_1;
input [1:0] lane_car_2;
input [1:0] lane_car_3;
input [7:0] car1distance_y;
input [7:0] car2distance_y;
input [7:0] car3distance_y;

output [7:0] distance_y;

begin
    if(lane_car_1 == lane_car_2) // Car 1 and car 2 are in same lane so calculate the distance between them
    begin
    distance_y = car2distance_y - car1distance_y;
    //$display("Front dist car 2 and 1 is %d",distance_y);
    end
    else if(lane_car_1 == lane_car_3) // Car 1 and car 3 are in same lane so calculate the distance between them
    begin
    distance_y = car3distance_y - car1distance_y;
    //$display("Front dist car 3 and 1 is %d",distance_y);
    end
    else if(lane_car_1 == lane_car_3 && lane_car_1 == lane_car_2) // All cars in same lane
    begin
        if(car2distance_y > car3distance_y)
        begin
        distance_y = car3distance_y - car1distance_y;
        //$display("Front dist car 3 and 1 is %d",distance_y);
        end
        else
        begin
        distance_y = car2distance_y - car1distance_y;
        //$display("Front dist car 2 and 1 is %d",distance_y);
        end
    end
    else
    begin 
    distance_y = 8'd255; // Other car either too far away or not in same lane
    //$display("Other car either far away or not in same lane");
    end
    
end

endtask

//Find relative velocity between two cars in same lane
task relative_velocity;
input [1:0] lanecar1;
input [1:0] lanecar2;
input [1:0] lanecar3;
input [7:0] car1_velocity;
input [7:0] car2_velocity;
input [7:0] car3_velocity;

output [7:0] rel_vel;

begin
    if(lanecar1 == lanecar2) // Car 1 and car 2 are in same lane so calculate the relative velocity between them
    begin
    if (car2_velocity > car1_velocity)
    begin
    rel_vel = car2_velocity - car1_velocity;
    //$display("Relative velocity of cars 1 and 2, first 'if'");
    end
    else
    begin
    rel_vel = car1_velocity - car2_velocity;
    //$display("Relative velocity of cars 1 and 2, second 'if'"); 
    end
    end
    else if(lanecar1 == lanecar3) // Car 1 and car 3 are in same lane so calculate the relative velocity between them
    begin
    if (car3_velocity > car1_velocity)
    begin
    rel_vel = car3_velocity - car1_velocity;
    //$display("Relative velocity of cars 1 and 3, third 'if'");
    end
    else
    begin
    rel_vel = car1_velocity - car3_velocity;
    //$display("Relative velocity of cars 1 and 3, fourth 'if'"); 
    end
    end
    else if(lanecar1 == lanecar3 && lanecar1 == lanecar2) // All cars are in same lane so calculate the relative velocity between first two cars
    begin
    if(car2_velocity >= car3_velocity)
    begin
    if (car2_velocity > car1_velocity)
    begin
    rel_vel = car2_velocity - car1_velocity;
    //$display("Relative velocity of cars 1 and 2, fifth 'if'");
    end
    else
    begin
    rel_vel = car1_velocity - car2_velocity;
    //$display("Relative velocity of cars 1 and 2, sixth 'if'"); 
    end
    end
    else
    begin
    if (car3_velocity > car1_velocity)
    begin
    rel_vel = car3_velocity - car1_velocity;
    //$display("Relative velocity of cars 1 and 3, seventh 'if'");
    end
    else
    begin
    rel_vel = car1_velocity - car3_velocity;
    //$display("Relative velocity of cars 1 and 3, eigth 'if'"); 
    end
    end
    end
    else
    begin 
    rel_vel = 8'd0; //zero value if lane is empty. This would ensure no disturbance in calculations
    //$display("lane is empty");
    end
    
end

endtask



//Main FSM function that takes in front distance, relative velocity and lane values of all cars while giving out next lane, velocity and horizontal distance
task fsm;
input [7:0] fsm_frontdist;
input [7:0] fsm_rel_vel;
input [1:0] fsm_car_1_lane;
input [1:0] fsm_car_2_lane;
input [1:0] fsm_car_3_lane;



output [7:0] fsm_velocity;
output [1:0] fsm_NEXT_LANE;
output [7:0] fsm_distance;
//output [(10*(N-1)*8)-1:0] curve_path;

begin
    case (fsm_car_1_lane)
        left:
        begin
            if(fsm_frontdist <= 8'd5 || fsm_rel_vel >= 8'd30) // other car too in left lane and close
            begin
                fsm_distance = 8'd6; //go to middle lane
                fsm_velocity = 8'd30; //reduce speed to 30
                fsm_NEXT_LANE = middle; //go to middle lane
            end
            else //other car either in left lane but far or lane is empty
            begin 
                fsm_distance = 8'd2; //stay in the lane
                fsm_velocity = 8'd50; //maintain speed at 50
                fsm_NEXT_LANE = left; //stay in the lane
            end
        end

        middle:
        begin
            if(fsm_frontdist <= 8'd5 || fsm_rel_vel >= 8'd30) // A car is near in middle lane
            begin
                if(fsm_car_2_lane == left && fsm_car_3_lane == middle) // Left and middle lane occupied
                begin
                    fsm_distance = 8'd10; // Go to right lane
                    fsm_velocity = 8'd30; // reduce speed
                    fsm_NEXT_LANE = right; //swicth case
                end
                else if(fsm_car_3_lane == left && fsm_car_2_lane == middle) // Left and middle lane occupied
                begin
                    fsm_distance = 8'd10; // Go to right lane
                    fsm_velocity = 8'd30; // reduce speed
                    fsm_NEXT_LANE = right; //swicth case
                end
                else if(fsm_car_3_lane == right && fsm_car_2_lane == middle) // Right and middle lane occupied
                begin
                    fsm_distance = 8'd2; // Go to left lane
                    fsm_velocity = 8'd30; // reduce speed
                    fsm_NEXT_LANE = left; //swicth case
                end
                else if(fsm_car_3_lane == middle && fsm_car_2_lane == right) // Right and middle lane occupied
                begin
                    fsm_distance = 8'd2; // Go to left lane
                    fsm_velocity = 8'd30; // reduce speed
                    fsm_NEXT_LANE = left; //swicth case
                end
                else // other cars in middle lane
                begin
                    fsm_distance = 8'd10;
                    fsm_velocity = 8'd30; //reduce speed
                    fsm_NEXT_LANE = right; //take right lane for overtaking
                end
            end
            else // no car anywhere
            begin
                fsm_distance = 8'd6;
                fsm_velocity = 8'd50; //maintain speed
                fsm_NEXT_LANE = middle; //maintain lane
            end
        end
    
        right:
        begin
            if(fsm_frontdist <= 8'd5 || fsm_rel_vel >= 8'd30) // other car too in right lane and close
            begin
                fsm_distance = 8'd6;
                fsm_velocity = 8'd30; //reduce speed to 30
                fsm_NEXT_LANE = middle; //go to middle lane
            end
            else //other car either in right lane but far or lane is empty
            begin 
                fsm_distance = 8'd10;
                fsm_velocity = 8'd50; //maintain speed at 50
                fsm_NEXT_LANE = right; //stay in the lane
            end
        end

        
    endcase
    
end
endtask

initial 
begin
car_1_new_distancex = car_1_distance_x; //Take the initial value from test bench
flat_arrayx[0] = car_1_distance_x;
flat_arrayy[0] = car_1_distance_y;
car_1_new_velocity = car_1_velocity; //Take the initial value from test bench
end

always @(*)
begin
//Calculate lanes for all cars when needed
find_lane(car_1_new_distancex,PRES_LANE);
find_lane(car_2_distance_x,lane_car2);
find_lane(car_3_distance_x,lane_car3);

//Calculate front distance for any scenario
front_calculation(PRES_LANE,lane_car2,lane_car3,car_1_distance_y,car_2_distance_y, car_3_distance_y,front_dist); 

//Calculare relative velocities for any scenario
relative_velocity(PRES_LANE,lane_car2,lane_car3,car_1_new_velocity,car_2_velocity,car_3_velocity,rel_velocity);

// Compute the FSM whenever there are changes then assign the FSM outputs to variables in main program
fsm(front_dist,rel_velocity,PRES_LANE, lane_car2, lane_car3, car_1_new_velocity,NEXT_LANE,car_1_new_distancex);
if(j<N) //Compute curved distance
begin
    for(i=j;i>=0;i-=1) //Push the values up in the array
    begin
        flat_arrayx[j] = flat_arrayx[j-1];
        flat_arrayy[j] = flat_arrayy[j-1];
    end
    enable = 1'b0; //Wait before computing spline
    flat_arrayx[0] = car_1_new_distancex; //Get latest value from FSM
    flat_arrayy[0] = car_1_distance_y; //Get latest value from TB
    //$display("X_array just got %d while Car Distance_x was %d",flat_arrayx[0],car_1_new_distancex);
    //$display("Y_array just got %d while Car Distance_y was %d",flat_arrayy[0],car_1_distance_y);
    if(j==N-1)
    begin
    for(i=0;i<N;i+=1)
    begin
    car_x_array[i*8+:8]=flat_arrayx[i];
    car_y_array[i*8+:8]=flat_arrayy[i];
    end
    enable = 1'b1;// Send the vectors and compute spline
    j = 1; // reset 'j'
    for(i=0;i<=9;i+=1)
    begin
    car_1_new_distancey = approx_path[(i)*8+:8]; // Put curved path values from spline into variable here
    //$display("Approx path at value of i%d and j%d is = %d",i,j,approx_path[(i)*8+:8]);
    $display("Car Distance_y is now = %d",car_1_new_distancey);
    end
    enable = 1'b0;
    end
    else
    begin
        //$display("X_array just got %d while Car Distance_x was %d",car_x_array[j],fsm_carx_distance);
        //$display("Y_array just got %d while Car Distance_y was %d",car_y_array[j],car_1_distance_y);
        enable = 1'b0; //Dont compute spline
        j+=1;
    end
end
else 
j=1; //Reset counter of data points after N data points have been collected
end

//Set the flip-flops
always @(posedge clock)
begin 
if (reset == 1'b1)
begin
car_1_new_distancex <= 8'd6; 
flat_arrayx[0] <= 8'd6;
flat_arrayy[0] <= 8'd0;
car_1_new_velocity <= 8'd50;
PRES_LANE <= middle;
end
else
// car_x_array[0] <= car_1_new_distancex;
// car_y_array[0] <= car_1_distance_y;
PRES_LANE <= NEXT_LANE;
end



endmodule