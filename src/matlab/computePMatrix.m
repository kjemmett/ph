function P = computePMatrix(X)

[N, n] = size(X);

for i = 1:N
    disp(i)
    a = sum(X(i, :));
    for j = i:N
        b = sum(X(j, :));
        c = X(i, :) * X(j, :)';
        C = min(a, b);
        P(i, j) = sum(hygepdf(c:C, n, a, b));
    end
end

P = P + P'
