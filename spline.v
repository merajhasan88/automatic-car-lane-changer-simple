module spline(data_y,data_x,enable,approximation);

parameter N = 2; //Number of data points
input [(N*8)-1:0] data_y; //Two vectors where first one is for f(x) and second one is for x
input [(N*8)-1:0] data_x;
input enable;
//input clock;
output reg [(10*(N-1)*8)-1:0] approximation; //Spline vector approximation of one value in f(x) corresponding to 10x more data points
// output real approximation;

reg signed [7:0] A [N-1:0][N-1:0]; //(N)x(N) 'A' matrix
reg signed [7:0] h [N-2:0]; //'h' vector
reg signed [7:0] B [N-1:0]; //'B' vector
reg signed [7:0] c [N-1:0]; //'c' vector
reg signed [7:0] b [N-2:0]; //'b' vector
reg signed [7:0] d [N-2:0]; //'d' vector
//reg signed [63:0] A_inv [N-1:0][N-1:0]; // Inverse matrix of A
//reg signed [(N*N*8)-1:0] cof; //Cofactor matrices converted to vector; function matrices all defined here
//reg signed [(N*N*8)-1:0] cof1; //
//reg signed [7:0] A_mat [N-1:0][N-1:0];
reg signed [7:0] temp [N-1:0][9:0];
//reg signed [(N*N*8)-1:0] temp2;
//reg signed [7:0] Mat_A [N-1:0][N-1:0];
//reg signed [7:0] A_matrix [N-1:0][N-1:0];
//reg signed [(N*N*8)-1:0] A_flat; 
reg signed [7:0] datax_array [N-1:0];
reg signed [7:0] datay_array [N-1:0];
reg signed [7:0] approx_array [N-2:0][9:0];
//reg [7:0] adj [N-1:0][N-1:0];
//reg [7:0] cofactor_mat [N-1:0][N-1:0];
reg [7:0] num = N-1;
reg signed [7:0] L[N-1:0][N-1:0];
reg signed [7:0] U[N-1:0][N-1:0];
reg signed [7:0] zed[N-1:0];


real f;
real g;
integer i;
integer j;
integer k=1;
integer l;
integer m;
integer n;
integer row_index; 
integer col_index; 
integer row;
integer col;
integer det; 
integer det2;
integer sign = 1;
integer p;
integer q;

always@(enable)
begin 
// if (reset == 1'b1)  
// begin
// $display($time,"data_y = %b \t",data_y);
// $display($time,"data_x = %b \t",data_x);
for (j=0;j<N;j=j+1)
begin
for (l=0;l<N;l=l+1)
A[j][l]=8'd0; //Fill matrices with zeros
//A_inv[j][l]=8'd0;
//A_mat[j][l]=8'd0;
//temp1[j][l]=8'd0;
//Mat_A[j][l]=8'd0;
//A_matrix[j][l]=8'd0;
//adj[j][l]=8'd0;
//cofactor_mat[j][l]=8'd0;
end  

// $display($time,"data_y after reset = %b",data_y);
// $display($time,"data_x after reset = %b",data_x);
//Convert the data vectors into arrays
for (i=0;i<N;i=i+1)
begin
    datax_array[i] = data_x[i*8+:8];
    //$display("Data_x array = %d",datax_array[i]);
    datay_array[i] = data_y[i*8+:8];
    //$display("Data_y array = %d",datay_array[i]);
end


//Calculate 'h' vector
//integer i;
for (i=0; i<=N-2; i=i+1)
begin
    h[i]=datax_array[i+1]-datax_array[i]; //h(j)=x(j+1)-x(j)
    //$display("h = %g",h[i]);
    //$display(\n);
end

//Calculate 'A' matrix
//integer j, l;
// for (j=0;j<N;j=j+1)
// begin
// for (l=0;l<N;l=l+1)
// A[j][l]=0; //Fill matrix with zeros
// end  

A[0][0]=8'd1; //First and last index should be 1
A[N-1][N-1]=8'd1;

//integer k = 1,m; //fill the tridiagonal of 'A'
while (k<=N-2)
begin
for (m=0;m<=N-3;m=m+1)
begin
A[k][m]=h[m];
A[k][m+1]=2*(h[m]+h[m+1]);
A[k][m+2]=h[m+1];
k=k+1;
end
end

// for (i=0;i<N;i=i+1)
// begin
//     for (j=0;j<N;j=j+1)
//     begin
//     $display("\t A = %d \n",A[i][j]);
//     end
//     //$display(\n);
// end

//a(j) used below are simply the elements in first row of data, so we will use them directly

//Calculate 'B' matrix
//integer n;
for (n=0;n<N;n=n+1)
begin
    B[n]=0; //initialize 'B' with all zeros
end
for (n=1;n<=N-2;n=n+1)
begin
B[n]=(3*(datay_array[n+1]-datay_array[n])/h[n]) - (3*(datay_array[n]-datay_array[n-1])/h[n-1]);
end

// for (i=0;i<N;i=i+1)
// begin
// $display("B = %d",B[i]);
// //$display(\n);
// end
//Calculate 'c' matrix through Crout Factorization to solve Ac=b.

begin:Crout
for (n=0;n<N;n=n+1)
begin
    c[n]=0; //initialize 'c' with all zeros
    //$display("Initializing c");
end

L[0][0]=A[0][0]; 
U[0][0]=8'd1;
U[0][1]=A[0][1]/L[0][0];
zed[0]=B[0]/L[0][0];

for (i=1;i<N-1;i+=1)
begin
L[i][i-1]=A[i][i-1];
L[i][i]=A[i][i]-L[i][i-1]*U[i-1][i];
U[i][i+1]=A[i][i+1]/L[i][i];
zed[i]=(B[i]-L[i][i-1]*zed[i-1])/L[i][i];
end

L[N-1][N-2]=A[N-1][N-2];
L[N-1][N-1]=A[N-1][N-1]-(L[N-1][N-2]*U[N-2][N-1]);
zed[N-1]=(B[N-1]-L[N-1][N-2]*zed[N-2])/L[N-1][N-1];

c[N-1]=zed[N-1];
for(i=N-2;i>=1;i-=1)
begin
c[i]=zed[i]-U[i][i+1]*c[i+1];
end
end
//Convert 'A' matrix into 1D
// for (i=0;i<N;i=i+1)
// begin
//     for(j=0;j<N;j=j+1)
//     A_flat[(i*N+j)*8+:8] = A[i][j];
// end
// $display("Converted A into 1D = %b", A_flat);
// //Calling the functions to calculate inverse
// deter(A_flat,N,det);
// $display("Calculated determinant of 'A' = %d",det);
// adjoint(A_flat,temp2); 
// $display("Called adjoint function and got temp2 = %b", temp2);
// //Convert temp2 to a matrix temp1
// for(i=0;i<N;i=i+1)
// begin
//     for(j=0;j<N;j=j+1)
//     temp1[i][j]=temp2[(i*N+j)*8+:8];
// end
// $display("Converted temp2 to temp1");
// for (i=0; i<N; i+=1)
// begin
//     for (j=0; j<N; j+=1)
//     begin
//         A_inv[i][j] = temp1[i][j]/det;
//     end
// end
// $display("Calculated A inverse");
// // Calculating 'c' via matrix multiplication of inverse of 'A' with 'b'
// for (n=0;n<N;n=n+1)
// begin
// for (m=0;m<N;m=m+1)
// begin
// c[n] = c[n] + (A_inv[n][m]*b[m]); //matrix multiplication
// end
// end
//$display("calculated c");
// for (i=0;i<N;i=i+1)
// begin
// $display("c = %d",c[i]);
// //$display(\n);
// end


//calculate 'b' vector
for (n=0;n<N-1;n=n+1)
begin
b[n]=((datay_array[n+1] - datay_array[n])/h[n]) - (h[n]*(c[n+1]+2*c[n]))/3;
end
//$display("calculated b");
// for (i=0;i<N-1;i=i+1)
// begin
// $display("b = %d",b[i]);
// end


//calculate 'd' vector
for (n=0;n<N-1;n=n+1)
begin
d[n]=(c[n+1]-c[n])/(3*h[n]);
end

// for (i=0;i<N-1;i=i+1)
// begin
// $display("d = %d",d[i]);
// end

//Calculating splines for each interval
for (i=0;i<N-1;i=i+1)
begin
f=datax_array[i];
//g=(datax_array[i+1]-datax_array[i])/8'd10;
g=0.1;
//$display("g = %g when i = %d",g,i);
for(j=0;j<=9;j+=1)
begin
    approx_array[i][j]=datay_array[i] + b[i]*(f-datax_array[i])+ c[i]*((f-datax_array[i])**2) + d[i]*((f-datax_array[i])**3);
    f=f+g;
    //$display("f = %g when i = %d",f,i);
end
end
//Display approx_array
// for (i=0;i<N-1;i=i+1)
// begin
//     for (j=0;j<=9;j=j+1)
//     begin
//     //$display("approx_array = %d",approx_array[i][j]);
//     //temp[i][j]=$realtobits(approx_array[i][j]);
//     end
//     //$display(\n);
// end


//Convert the matrix 'approx_array' into 'approximation' vector
for (i=0;i<N-1;i=i+1)
begin
for (j=0;j<=9;j=j+1)
approximation[(i*10+j)*8+:8] = approx_array[i][j];
end


$display("approximation = %b",approximation);
end



//Finding cofactor
// task automatic cofactor;
// input [(N*N*8)-1:0] A_mat_flat;
// input [7:0] rows;
// input [7:0] cols;
// input [7:0] number;
// output [(N*N*8)-1:0] cofactor_mat_flat;


// // integer row_index, col_index = 0; 
// // integer row, col;
// begin

// // Convert 1D matrix into 2D
// for (i=0;i<=N-1;i=i+1) 
// begin
// for (j=0;j<=N-1;j=j+1)
// begin
//     A_mat[i][j] = A_mat_flat[(i*N+j)*8+:8]; //Each value is is 8-bit wide
// end
// end
// $display("Inside cofactor step 1");
// row_index = 0;
// col_index = 0;
// for (row=0;row<N;row=row+1)
// begin
//     for(col=0;col<N;col=col+1)
//     begin
//         if(row != rows && col != cols)
//         begin
//             cofactor_mat[row_index][col_index]= A_mat[row][col];
//             col_index = col_index + 1;
//             $display("Inside cofactor step 2");
//             if(col_index == number - 1)
//             begin
//                 col_index = 0;
//                 row_index = row_index + 1;
//                 $display("Inside cofactor step 3");
//             end
//         end
//     end
// end

// //Convert cofactor matrix into 1D vector
// for (i=0;i<N;i=i+1)
// begin
// for (j=0;j<N;j=j+1)
// cofactor_mat_flat[(i*N+j)*8+:8] = cofactor_mat[i][j];
// end
// end
// endtask

//Finding determinant
// task automatic determinant;

// input [(N*N*8)-1:0] A_matrix_flat;
// input [7:0] size;
// output [7:0] det1;
// begin 

// sign = 1;

// //real temp [N-1:0][N-1:0] = 0;



// // Convert 1D matrix into 2D
// for (i=0;i<=N-1;i=i+1) 
// begin
// for (j=0;j<=N-1;j=j+1)
// begin
//     A_matrix[i][j] = A_matrix_flat[(i*N+j)*8+:8]; 
// end
// end

// $display("Inside determinant step 1");
// // integer det = 0, sign = 1;
// if(size == 1)
// begin
// det1=A_matrix[0][0];
// $display("Base case of determinant where size = %d", size);
// end
// else
// begin
// det1=0;
// for (f = 0; f<N; f=f+1)
// begin
//     cofactor(A_matrix_flat,0,f,N, cof);
//     $display("Inside determinant step 2 where size = %d",size);
//     determinant(cof,size-1,det1);
//     $display("Inside determinant step 3 and determinant is = %d", det1);
//     det1 = det1 + sign*A_matrix[0][f]*det1;
//     $display("Inside determinant step 4 and determinant is now = %d", det1);
//     sign = -1*sign;
//     $display("Sign = %d", sign);
// end
// end
// end
// endtask

//Finding adjoint
// task automatic adjoint;

// input [(N*N*8)-1:0] Mat_A_flat;
// output [(N*N*8)-1:0] adj_flat;
// begin


// //Convert 1D matrix into 2D
// det2 = 0;
// for (i=0;i<=N-1;i=i+1) 
// begin
// for (j=0;j<=N-1;j=j+1)
// begin
//     Mat_A[i][j] = Mat_A_flat[(i*N+j)*8+:8]; 
// end
// end

// for (i=0;i<N; i=i+1)
// begin
//     for(j=0;j<N;j=j+1)
//     begin
//     cofactor(Mat_A_flat,i,j,N,cof1);
//     sign = ((i+j)%2==0)? 1: -1;
//     determinant(cof1,N-1,det2);
//     adj[j][i] = sign*det2;
//     end
// end

// //Convert adj into flat vector
// for (i=0;i<N;i=i+1)
// begin
// for (j=0;j<N;j=j+1)
// adj_flat[(i*N+j)*8+:8] = adj[i][j];
// end
// end
// endtask

// task automatic minor; //Given two indexes this finds the minor matrix for them from original 'A' matrix
// input [(number*number*8)-1:0] A_mat_flat;
// input [7:0] rows;
// input [7:0] cols;
// input [7:0] number;
// output [((number-1)*(number-1)*8)-1:0] minor_mat_flat;

// begin:B1
// reg signed [7:0] temp3 [number-2:0][number-2:0];
// reg signed [7:0] A_mat [number-1:0][number-1:0];
// // Convert 1D matrix into 2D
// for (i=0;i<=number-1;i=i+1) 
// begin
// for (j=0;j<=number-1;j=j+1)
// begin
//     A_mat[i][j] = A_mat_flat[(i*number+j)*8+:8]; //Each value is is 8-bit wide
// end
// end
// p=0;
// q=0;
// for (i=0;i<number;i=i+1)
// begin
// for (j=0;j<number;j=j+1)
// begin
//     if(i!=rows && j!=cols)
//     begin
//         temp3[p][q]=A_mat[i][j];
//         q+=1;
//         if(q==number-2)
//         begin
//             q=0;
//             p+=1;
//         end
//     end
// end
// end

// //Convert minor matrix into 1D vector
// for (i=0;i<number;i=i+1)
// begin
// for (j=0;j<number;j=j+1)
// minor_mat_flat[(i*number+j)*8+:8] = temp3[i][j]; //Minor for subscripts p and q
// end

// end
// endtask

// // task automatic reduce_minor;
// // input [(size*size*8)-1:0] minor_matrix_f;
// // input [7:0] size;
// // output [((size-1)*(size-1)*8)-1:0] minor_matrix_reduced;

// // begin

// // end
// // endtask

// task automatic deter;
// input [(size*size*8)-1:0] matrix_flat; //this is the matrix whose determinant we have to find
// input [7:0] size; //its current size
// output [7:0] det1; //its determinant

// begin:B2
// reg signed [7:0] matrix_unpacked [size-2:0][size-2:0];
// reg [((size-1)*(size-1)*8)-1:0] temp4; 
// //reg [7:0] det3;
// det1 = 0;
// // Convert 1D matrix into 2D
// for (i=0;i<=size-1;i=i+1) 
// begin
// for (j=0;j<=size-1;j=j+1)
// begin
//     matrix_unpacked[i][j] = matrix_flat[(i*size+j)*8+:8]; 
// end
// end

// if(size==8'd3)
// begin
//     det1 += (matrix_unpacked[0][0]*matrix_unpacked[1][1]) - (matrix_unpacked[0][1] - matrix_unpacked[1][0]);
// end
// else
// // Call the task 'minor' to brng the minor matrix for given indexes and then finding its determinant recursively
// begin
// for (f=0;f<size;f+=1)
// minor(matrix_flat,0,f,size-1,temp4);
// det1 += matrix_unpacked[0][f]*deter(temp4,size-1,det1);
// end
    
// end
// endtask

// task automatic adjoint; //Using minors and determinants find cofactors then put them in one matrix
// input [(N*N*8)-1:0] Mat_A_flat;
// output [(N*N*8)-1:0] adj_flat;

// begin:B3
// reg signed [7:0] MatA_unpacked [N-1:0][N-1:0];
// reg signed temp5 [num-1:0][num-1:0];
// num-=1;
// det2 = 0;
// //Convert 1D matrix into 2D
// for (i=0;i<=N-1;i=i+1) 
// begin
// for (j=0;j<=N-1;j=j+1)
// begin
//     MatA_unpacked[i][j] = Mat_A_flat[(i*N+j)*8+:8]; 
// end
// end
// for(i=0;i<N;i+=1)
// begin
// for(j=0;j<N;j+=1)
// begin
// minor(Mat_A_flat,i,j,N-1,temp5);
// deter(temp5,N-1,det2);
// sign = ((i+j)%2==0)? 1: -1;
// adj[j][i]=sign*det2;    
// end
// end
// //Convert adj into flat vector
// for (i=0;i<N;i=i+1)
// begin
// for (j=0;j<N;j=j+1)
// adj_flat[(i*N+j)*8+:8] = adj[i][j];
// end

// end
// endtask
endmodule