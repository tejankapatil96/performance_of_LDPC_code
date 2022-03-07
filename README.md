# performance_of_LDPC_code

In this project it contains simulation for LDPC codes. MATLAB simulations are used to get the 
bit error rate and packet error rate in the input data stream.
The rayleigh fading channel is designed using Jakes model

Files included in this folder are as follows:
RunFile.m - Run this file for simulation. This is main simulation file.

getLDPC_ParityCheckMat.m - This file includes function to generate LDPC parity check matrix H. 
			   Input to this file is message length and code rate.
         
get_channel.m - This file include function to select channel for data transmission. The channel used are AWGN and Rayleigh. 
		Different text files are used to define parameters of this channel.
    
rayleigh_EsN0.m - This file include function to add noise to the input data stream according to Rayleigh fading channel parameters.

Rayleigh.txt -  This is text file conation all the parameters value for Rayleigh fading channel
