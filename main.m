% MAIN This script tests the functions for coding and decoding a
% convolutional code

%% Run configuration
% Source
SOFT_FLAG = false;  % False for use hard decoding; true for soft decoding.
SOURCE_PROVIDED = true;
SOURCE = [0 1 1 0 0 0 1 0 1 1 0 0 0];
SOURCE_LENGTH = 1000;

% Noise
SIGMA = 0.0001;
MU = 0;


%% Source of information
% If it was defined, use it; if not, create a random one
if SOURCE_PROVIDED == false
    
    SOURCE = zeros(1, SOURCE_LENGTH);
    for i = 1:SOURCE_LENGTH
        j = randn();
        if j > 0
            SOURCE(1, i) = 1;
        end
    end
end
fprintf('The size of SOURCE is %.2f \n', size(SOURCE, 2));

%% Coding
% polGeneradorDen = [1 0 1]
% polGenNum = [1 1 1]
% mod(filter(polGeneradorDen, polGenNum, in), 2)
coderIn = SOURCE;
coderOut = codificadorConvolucional_Sebastian_Lombranna_Alberto(coderIn);

%% Chenneling
decoderIn = canal(coderOut, SIGMA, MU);
noisy_coderIn = canal(coderIn, SIGMA, MU);

%% Decoding
if SOFT_FLAG
    decoderOut = decodificadorConvolucionalBlando_Sebastian_Lombranna_Alberto(decoderIn);
else
    decoderOut = decodificadorConvolucionalDuro_Sebastian_Lombranna_Alberto(decoderIn);
end
    
%% Evaluation

fprintf('The size of coderIn is %.2f \n', size(coderIn, 2));
fprintf('The size of coderOut is %.2f \n', size(coderOut, 2));
fprintf('The size of decoderIn is %.2f \n', size(decoderIn, 2));
fprintf('The size of decoderOut is %.2f \n', size(decoderOut, 2));
fprintf('The size of noisyCoderIn is %.2f \n', size(noisy_coderIn, 2));

errors_no_convolution = 0;
errors_convolution = 0;
equals_no_convolution = 0;
equals_convolution = 0;

decidedNoisyCoderIn = zeros(1, size(noisy_coderIn, 2));
for i = 1:size(noisy_coderIn, 2)
    if noisy_coderIn(i) >= 0.5
        decidedNoisyCoderIn(i) = 1;
    else
        decidedNoisyCoderIn(i) = 0;
    end
end

fprintf('The size of decidedNoisyCoderIn is %.2f \n', size(decidedNoisyCoderIn, 2));

for i = 1:size(coderIn, 2)
    
    % No convolution
    if coderIn(1, i) == decidedNoisyCoderIn(1, i)
        equals_no_convolution = equals_no_convolution + 1;
    else
        errors_no_convolution = errors_no_convolution + 1;
    end
    
    % Convolution
    if coderIn(1, i) == decoderOut(1, i)
        equals_convolution = equals_convolution + 1;
    else
        errors_convolution = errors_convolution + 1;
    end
end
BER_convolution = errors_convolution/(errors_convolution + equals_convolution);
BER_no_convolution = errors_no_convolution/(errors_no_convolution + equals_no_convolution);
fprintf('The BER with convolutional coding is %.2f \n', BER_convolution);
fprintf('The BER with no convolutional coding is %.2f \n', BER_no_convolution);