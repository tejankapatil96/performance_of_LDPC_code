% function to select required text file of channel parameter
% Variables defination:
% selectChannel - channel simulator
% ChannelParameter - different channel parameters required for computaion 
% e.g SNR ratio, bandwidth,packet size,gain
% ChannelName - text file name with extension.txt
% file is open with permission r which means read only 
% fgetl reads single line at time
% eval is used to assign parameter value to repective variable

function [selectChannel,ChannelParameter]=get_channel(ChannelName)
fileopen=fopen([ChannelName '.txt'],'r');            
while 1                                        
    readline = fgetl(fileopen);                     
    if ~ischar(readline) break; end;               
    eval(readline);                                               
end;                                    
fclose(fileopen);