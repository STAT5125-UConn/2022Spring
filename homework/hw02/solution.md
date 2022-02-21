Problem 1

```julia
using Random; Random.seed!(2022);
n = 100
x = randexp(n)
y = x .+ randn(n)
vx = sum(x.^2) / (n-1) - sum(x)^2 / n / (n-1)
vy = sum(y.^2) / (n-1) - sum(y)^2 / n / (n-1)
cv = sum(x .* y) / (n-1) - sum(x) .* sum(y) / n / (n-1)
cr = cv / sqrt(vx * vy)
```

```
0.5577138448039966
```




Problem 2

```julia
using DelimitedFiles
dat = readdlm("triangle.csv", ',');
s = 0
for i in eachrow(dat)
    global s
    tmp = sort!(i)
    if sum(tmp[1:2]) > tmp[3]
        s += 1
    end
end
@show s;
```

```
s = 25084
```



