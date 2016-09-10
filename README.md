# FPGA-based-Median-Filter-Engine
A Hardware Median Filter Engine in  VHDL

Author    
-------------
CHIA-CHE, LEE   
Computer Engineering, Florida institute of technology.   
Email: stu4355226@gmail.com    
    
Target   
-------------
Platform: Xilinx Planahead 14.7   
Board: Xilinx Zynq-7000 SoC (Zedboard)    
Language: VHDL   

Goal   
-------------
The median filter is an effective device for the removal of impulse-based noise on video signals.    
This is due to the partial averaging effect of the median filter and its biasing of the input stream,    
rather than straight mathematical averaging.   


Diagram and Concept
-------------
    
![Diagram](/images/diagram.jpg)   
    
THis project is using ping-pong and pipeline on the data processing.    
ping-pong is used for buffering received image data. In the project it has four Dual Rams,    
In the execution, every clock cycle will has oen ram writing new data, and other 3 rams reading data then compute.   
For example: When RAM0 is receving new data, RAM1,2,3 will poop out the buttered data.
wr_ram signal controls RAM writing funtion.    
If wr_ram is "0001", rd_ram is "1110", that means RAM0 is reciving data, RAM3,2,1 are pooping out data.
When the operation is done, wr_row_done will set to 1.   
   
Pipeline is used to quickly compute data in thie project. get_medium.vhd computes 3x3 array data and find the meduim value.   
However, it takes 4 cycles to finish this operation, here I use 4 get_medium to process the data.
 
![pipelining](/images/pipelining.jpg)     
![window](/images/window.jpg)     

FSM
-------------
![FSM](/images/fsm.jpg) 

Result
-------------
Case1:4x3

![1](/images/1.jpg)     

 we get the result is shown:     
![2](/images/2.jpg)    
The first line is the datain, and the second line is dataoout. The result is the same as we expect.     

Case2: 8x8
![3](/images/3.jpg)     

We get the result and check it that it’s right one：    
![4](/images/4.jpg)     
![5](/images/5.jpg)     
The output data is “test1.coe” which in the folder. We can check the result there.    

We do another test-bench to check the mid- filter is working properly on big images    
1. What if we keep sanding same data?    
    We put this 512*512 and data depth = 8 matrix as X”08”. Then simulate the program.     
The input data are the X”08”, so the output data should be the same as X”08”.     
It’s the result:    

![6](/images/6.jpg)     

Rd_addr is reading ROM address, and rd_data is reading ROM data. The datain and dataout are the same. So we can say it’s right.        
2. What if we keep sanding different data?   
The input data I used three 8*8 matrix in 1.2 in the test-bench.   
It’s the result, then we can cleanly see we the first two matrix is output properly:    

![7](/images/7.jpg)     
