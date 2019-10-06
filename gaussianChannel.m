function out = gaussianChannel(in, mu, sigma)

    % GAUSSIANCHANNEL  Adds some real gaussian noise to an array of samples. % OUT = GAUSSIANCHANNEL(IN, MU, SIGMA) Adds a N(MU, SIGMA) gaussian real noise to the array IN.

%% Execution
out= zeros(1, size(in, 2));

for i = 1:size(in, 2)
    eta = normrnd(mu,sigma);
    out(i) = in(i) + eta;
end