function [q,r] = divmod(x,y)
% divmod divides X and Y and return the quotient and the remainder.
%
% Arguement:
%   x = Numerator
%   y = Denominator
%
% Output:
%   q = quotient
%   r = remainder
%
% Emin Serin - 14.08.2019
%
%% Input check. 
assert(nargin == 2, 'Please enter numerator and denominator!, Check help section!');
%% Find quotient and remainder.
q = floor(x./y); % quotient
r = mod(x,y); % remainder
end

