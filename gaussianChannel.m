function out = gaussianChannel(in, mu, sigma)

    % GAUSSIANCHANNEL  Adds some real gaussian noise to an array of samples. % OUT = GAUSSIANCHANNEL(IN, MU, SIGMA) Adds a N(MU, SIGMA) gaussian real noise to the array IN.

%% Execution
eta = (randn(1, size(in, 2)) + mu)*sigma;
out = in + eta;
end