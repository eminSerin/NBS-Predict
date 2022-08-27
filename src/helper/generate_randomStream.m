function rndSeeds = generate_randomStream(randSeed, iter)
% generate_randomStream generates random stream for loop.

if randSeed ~= -1 % -1 refers to random shuffle.
    rng(randSeed);
else
    rng('shuffle');
end
rndSeeds = randi(1e+9, iter, 1);
end


