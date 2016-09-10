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


Diagram and concept
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
 
