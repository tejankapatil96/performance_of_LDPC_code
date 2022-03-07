% function to genarate sparse parity check matrix for specified code rate and the message length.
% Variables defination 
% MessageLength - total number of bits tranmitted(k)
% ParityBitsLength - Number of extra bits added (p)
% CodewordLength - length of codeword formed after adding parity bits (n)
% ColumnHMatrix - information about the message bits in each of the parity quition.
% RowHMatrix - row index of parity check matrix
% 

function [ParityCheckMatrix] = getLDPC_ParityCheckMat(Rate,MessageLength)
CodewordLength = ceil(MessageLength*(1/Rate));

if mod(CodewordLength,2)~=0
    CodewordLength = CodewordLength + 1;      % making codeword length even if not even got modulation
end

ParityBitsLength =CodewordLength-MessageLength;   % calculating length of parity bits
message = [];
MsgBitCount = 1;

% For each code rate diffrent number of message bits are assigned in each parity
% check equation
switch Rate
    case 4/5
        MsgBits = 13;
    case 2/3
        MsgBits = 9;
    case 4/7
        MsgBits = 7;
    case 1/2
        MsgBits = 5;
    case 4/9
        MsgBits = 5;
    case 2/5
        MsgBits = 4;
    case 4/11
        MsgBits = 4;
    case 4/13
        MsgBits = 3;
    case 2/7
        MsgBits = 2;
    case 4/15
        MsgBits = 2;
    case 1/4
        MsgBits = 2;
    otherwise
        MsgBits = 2;        
end
   
message = 1:1:MessageLength;

ColumnHMatrix = [];
RowHMatrix = [];

% Assigning different message bit combination to each parity check equation
while MsgBitCount < ParityBitsLength
    message = 1:1:MessageLength;
    while ~isempty(message) && MsgBitCount < ParityBitsLength

        if size(message,2)< 2*MsgBits
            bitEntries = randsample(message,size(message,2));
            MsgBitsCheck = 1;
        else
            bitEntries = randsample(message,MsgBits);
            MsgBitsCheck = MsgBits;
        end

        ColumnHMatrix = [ColumnHMatrix bitEntries];  
        RowHMatrix = [RowHMatrix MsgBitCount*ones(1,length(bitEntries))];
        MsgBitCount = MsgBitCount + 1;

        if MsgBitsCheck==1
            message = [];
        else
            for aa = 1:1:MsgBitsCheck
               index = find(message == bitEntries(aa));
               message(index) = [];
            end
        end
    end
end

MatrixTemp=[];
Rate=[];

for ColumnData = 1:1:MessageLength    
    ColumnIndex = find(ColumnHMatrix == ColumnData);
    if ~isempty(ColumnIndex)        
        MatrixTemp=[MatrixTemp ColumnData*ones(1,size(ColumnIndex,2))];
        Rate=[Rate RowHMatrix(ColumnIndex)];
    end
end

% Representing parity check matrix in order of (n-k) by (n-k)
for H_ParityBit = 1:1:ParityBitsLength
    if H_ParityBit==ParityBitsLength
        MatrixTemp = [MatrixTemp H_ParityBit+MessageLength];
        Rate = [Rate H_ParityBit];
    else
        MatrixTemp = [MatrixTemp H_ParityBit+MessageLength H_ParityBit+MessageLength];
        Rate = [Rate H_ParityBit H_ParityBit+1];
    end
end

% returning parity check matrix H 
ParityCheckMatrix = logical(sparse(double(Rate'), MatrixTemp', 1));
