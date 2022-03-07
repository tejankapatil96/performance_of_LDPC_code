clc;
close all;
clear all;
%% Parameters Used
% num_bits - size of packet in byts
% PacketCount - Number of packet need to send or interate for LDPC coding
% ChannelName - selected channel for trasmssion 
% CodeRate - different code rate betwwen 0 to 1
% N - number of subcarriers used for modulation
% cp_len - cycalic prefix length used for modualtion
% SymbolDuration - Symbol Duration in seconds
% M - Modulation order

%% Variable Declaration

num_bits = 1024;             
N = 128;                    
cp_len = 64;                 
PacketCount = 50;               
M = 4;                       
OffsetTime = 0;           
SymbolDuration = 1e-4;                   
RayleighTimeOffset=0;
SNR_values = 10:1:25;
CodeRate=[4/5 2/3 4/7 1/2 4/9 2/5 4/11 4/13 2/7 4/15 1/4];
%ChannelName = 'Rayleigh';
ChannelName = 'AWGN';
[selectChannel,ChannelParameter]=get_channel(ChannelName);

%% Parity Check Matrix Genaration and Modulation
for rate_count = 1:length(CodeRate)
    Rate = CodeRate(rate_count); 
    fprintf('\nCode Rate R is: %ddB\n',Rate);
    
    % Gerating sparse parity check matrix for total number of bits
    ParityCheckMatrix = getLDPC_ParityCheckMat(Rate,num_bits);  
    EncoderParityCheckMatrix = comm.LDPCEncoder(ParityCheckMatrix);
    DecoderParityCheckMatrix = comm.LDPCDecoder(ParityCheckMatrix);
    
    loopCnt = 1;

    for SNR = SNR_values
        ChannelParameter.EsN0=SNR;
        for CntPkt = 1:PacketCount
            bits = randi([0,1], num_bits,1);
            DataEncoded = step( EncoderParityCheckMatrix, (bits) );          
            
            % Modulation of Data
            % specify gray coding for consistency during demodulation
            modulated_symbols = qammod((DataEncoded), M, "gray", "InputType", "bit","UnitAveragePower", false);
            modulated_sym_parallel = reshape(modulated_symbols, N, []);     %serial to parallel
            time_domain_symbols = ifft(modulated_sym_parallel, N, 1);
            transmit_signal_parallel = [time_domain_symbols(end - (cp_len -1):end, :); time_domain_symbols];    % addition of cyalic prefix
            transmit_signal = reshape(transmit_signal_parallel, [],1);
            
            % Noise addition according to Channel Selection
            if(strcmp(ChannelName,'Rayleigh'))             
                [ChannelOutputBits,ChannelParameter]=feval(selectChannel,transmit_signal,ChannelParameter,RayleighTimeOffset,SymbolDuration,ChannelParameter.fm);
                RayleighTimeOffset=RayleighTimeOffset+SymbolDuration*num_bits;             
            else
                [ChannelOutputBits,ChannelParameter]=feval(selectChannel,transmit_signal,ChannelParameter);                 
            end
            
            % Demodulation od Data
            received_signal = ChannelOutputBits;
            % Offset is introduced by prepending OffsetTime number of zeros to the signal and ignoring the last OffsetTime number
            offset_signal = zeros(OffsetTime, 1);
            received_signal = [offset_signal; received_signal(1:end-OffsetTime)];
            % removal of Cycalic prefix and serial to parallel conversion
            received_parallel = reshape(received_signal, N + cp_len, []);
            received_parallel = received_parallel(cp_len + 1: end, :);
            received_freq_domain = fft(received_parallel, N);
            
            % Correction for timing offset
            indexArray = 1:N;
            indexArray = indexArray' - 1;
            correctionVector = exp(2*pi*1i*indexArray*OffsetTime/N);
            
            received_freq_domain = received_freq_domain.*correctionVector;
            received_freq_serial = reshape(received_freq_domain, [], 1);
            received_bits = qamdemod(received_freq_serial, M, "gray","OutputType", "approxllr");  
            
            recivedData = DecoderParityCheckMatrix(received_bits);
            [ErrorCount(CntPkt), berror] = biterr( bits, recivedData);
        end
        
        % comaparing origanl bits and packets to compute bit error rate and
        % packet error rate
        TotalBitErrors=sum(ErrorCount);                            
        BER(rate_count,loopCnt)=TotalBitErrors/(PacketCount*num_bits);  
        TotalPckettErrors=sum(ErrorCount>0);                      
        PER(rate_count,loopCnt)=TotalPckettErrors/PacketCount;          

        loopCnt=loopCnt+1;
    end
end
    
%BER vs SNR Plot
figure;
semilogy(SNR_values,BER,'-o','linewidth',1.2);
grid on; title('BER vs SNR'); xlabel('SNR (dB)'); ylabel('Bit Error Rate');
legend("Code Rate = 4/5", "Code Rate = 2/3","Code Rate = 4/7","Code Rate = 1/2",...
       "Code Rate = 4/9","Code Rate = 2/5" ,"Code Rate = 4/11", "Code Rate = 4/13",...
       "Code Rate = 2/7","Code Rate = 4/15","Code Rate = 1/4", "NumColumns", 2)
  
%PER vs BER Plot   
figure;
semilogy(SNR_values,PER,'-o','linewidth',1.2);
grid on; title('PER vs SNR'); xlabel('SNR (dB)'); ylabel('Packet Error Rate');
legend("Code Rate = 4/5", "Code Rate = 2/3","Code Rate = 4/7","Code Rate = 1/2",...
       "Code Rate = 4/9","Code Rate = 2/5" ,"Code Rate = 4/11", "Code Rate = 4/13",...
       "Code Rate = 2/7","Code Rate = 4/15","Code Rate = 1/4", "NumColumns", 2)




