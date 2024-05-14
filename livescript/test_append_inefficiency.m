n = 1000000;
m = 120;

tic;
for i=1:n
    a = [];
    for j=1:m
        a = [a, j];
    end
end
toc;

tic;
for i=1:n
    a = zeros(1, 120);
end
toc;