% MAIN This script tests the functions for coding and decoding a
% convolutional code

%% Run configuration
% Source
SOFT_FLAG = true;  % False for use hard decoding; true for soft decoding.
SOURCE_PROVIDED = false;
SOURCE = [0 1 1 0 0 0 1 0 1 1 0 0 0];
SOURCE_LENGTH = 5000;

% Noise
SIGMA = 0:0.025:0.9;    % Noise variance
MU = 0;                 % Noise mean value
ETA = 2;                % Spectral eficiency
BER_soft_convolution = zeros(1,size(SIGMA,2));
BER_hard_convolution = zeros(1,size(SIGMA,2));
BER_no_convolution = zeros(1,size(SIGMA,2));

%% Source of information
% If it was defined, use it; if not, create a random one
power_acc = 0;
if SOURCE_PROVIDED == false

    SOURCE = zeros(1, SOURCE_LENGTH);
    for i = 1:SOURCE_LENGTH
        j = randn();
        if j > 0
            SOURCE(1, i) = 1;
        end
    end
end
power_acc = 0;
for i = 1:SOURCE_LENGTH
    power_acc = power_acc + (SOURCE(1, i))^2 * 0.5;
end
power = power_acc/SOURCE_LENGTH;

fprintf('The size of SOURCE is %.2f \n', size(SOURCE, 2));

%% Soft coding
for i_sigma = 1:size(SIGMA,2)
    %% Coding
    coderIn = SOURCE;
    coderOut = codificadorConvolucional_Sebastian_Lombranna_Alberto(coderIn);

    %% Channeling
    decoderIn = gaussianChannel(coderOut, MU, SIGMA(i_sigma));
    noisy_coderIn = gaussianChannel(coderIn, MU, SIGMA(i_sigma));

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

    BER_soft_convolution(i_sigma) = errors_convolution/(errors_convolution + equals_convolution);
    BER_no_convolution(i_sigma) = errors_no_convolution/(errors_no_convolution + equals_no_convolution);
    fprintf('The BER with convolutional coding is %.2f \n', BER_soft_convolution(i_sigma));
    fprintf('The BER with no convolutional coding is %.2f \n', BER_no_convolution(i_sigma));
end

%% Hard coding
SOFT_FLAG = false;
for i_sigma = 1:size(SIGMA,2)
    %% Coding
    coderIn = SOURCE;
    coderOut = codificadorConvolucional_Sebastian_Lombranna_Alberto(coderIn);

    %% Channeling
    decoderIn = gaussianChannel(coderOut, MU, SIGMA(i_sigma));
    noisy_coderIn = gaussianChannel(coderIn, MU, SIGMA(i_sigma));

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

    BER_hard_convolution(i_sigma) = errors_convolution/(errors_convolution + equals_convolution);
    fprintf('The BER with convolutional coding is %.2f \n', BER_hard_convolution(i_sigma));
    fprintf('The BER with no convolutional coding is %.2f \n', BER_no_convolution(i_sigma));
end

%% Plot
snr = zeros(1,size(SIGMA,2));
% Signal power is SUM_a((1/2)*(input_a)) = 0.5 
for i_sigma = 1:size(SIGMA,2)
    snr(i_sigma) = (size(coderIn, 2)/size(coderOut, 2))*(0.5/SIGMA(i_sigma))*(1/ETA);
end

plot(10*log10(snr), 10*log10(BER_soft_convolution));
hold on;
plot(10*log10(snr), 10*log10(BER_hard_convolution));
hold on;
plot(10*log10(snr), 10*log10(BER_no_convolution));
legend('BER soft convolution', 'BER hard convolution', 'BER no convolution');
title('Curvas de BER');
xlabel('SNR (dB)');
ylabel('BER (dB)');

