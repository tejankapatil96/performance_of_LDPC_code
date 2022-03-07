% Rayleigh channel using Jakes model
% Variables defination:
% ChanelInputBits - input data bits recived after modulation
% ChannelParameter -  different channel parameters required for computaion 
% e.g SNR ratio, bandwidth,packet size
% ChannelOutputBits - Data after passing through channle with added noise
% InputSignalPower - power in watts for input signal
% received_symbol - received symbols by passing through the channel

function [ChannelOutputBits,ChannelParameter]=rayleigh_EsN0(ChanelInputBits,ChannelParameter,RayleighTimeOffset,SymbolDuration,fm)
InputSignalPower=1; 
if isstruct(ChannelParameter)
    SNR=10*log10(2)+ChannelParameter.EsN0+ChannelParameter.gain;
else
    SNR=10*log10(2)+ChannelParameter;
end

NoisePower=InputSignalPower*10^(-SNR/10);
Noise=sqrt(NoisePower)*(randn(1,length(ChanelInputBits))+1i*randn(1,length(ChanelInputBits)));

% parameters are taken from the paper 'Combined Forward Error Control and 
% Packetized Zerotree Wavelet Encoding for Transmission of Images Over Varying Channels'

% Variables for Jakes Model:
% fm - maximum Doppler frequency
% fc - the carrier frequency of 900MHz
% c - velocity of light 3x10^8m/s 
% vm - speed of object moving. different speed are considered to demonstrate 
% real world scenarios e.g 5 Km/hr or 1.4 m/s and 6.4 Km/hr or 1.8 m/s  
% for slow moving object, 50 Km/hr or 14 m/s and 100 Km/hr or 28 m/s for fast moving object.
% maximum Doppler frequency is calculated using formula
% fm = (vm*fc)/c; % maximum Doppler frequency in Hz, we are taking  vm=28m/s here so fm=84. 
% fs = 2.048*10^6; % transmission rate, symbol per second, 1.4Mbits/s

BitLength = length(ChanelInputBits);
channel=jakes(fm, SymbolDuration, BitLength,RayleighTimeOffset);
received_symbol = ChanelInputBits.*channel' + Noise';
r_rayleigh = received_symbol.*channel.'./abs(channel');   % equalization
ChannelOutputBits = (r_rayleigh);
