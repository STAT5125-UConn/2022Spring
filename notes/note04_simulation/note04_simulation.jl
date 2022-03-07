using Random, Statistics 
using StatsBase, Distributions

## Elevator waiting time
Random.seed!(2022);
n = 1_000_000
elevator = 1 .+ 14rand(n)
elevator = rand(Uniform(1, 15), n)
up = elevator .< 13
sum(up) / n

12 / (12 +2)

n_up = 0
for i in 1:n
 n_up += 1 + 14rand() < 13
end
n_up / n

## Intransitive Dice
Random.seed!(2022);
A = [2, 2, 4, 4, 9, 9]
B = [1, 1, 6, 6, 8, 8]
C = [3, 3, 5, 5, 7, 7]

[A[i] > B[j] for i in 1:6, j in 1:6]

ab = A .> B'
mean(ab)
sum(ab) / 36
bc = B .> C'
mean(ab)
ca = C .> A'
mean(ca)

n = 100000
rollA = rand(A, n)
rollB = rand(B, n)
rollC = rand(C, n)
sum(rollA .> rollB) / n
mean(rollA .> rollB)
mean(rollB .> rollC)
mean(rollC .> rollA)

ab = 0
for i in 1:n
    if rand(A) > rand(B)
        ab += 1
    end
end
ab / n

function v1(n; A=A, B=B)
    rollA = rand(A, n)
    rollB = rand(B, n)
    sum(rollA .> rollB) / n
end
@time v1(1_000_000)

function v2(n; A=A, B=B)
    ab = 0
    for i in 1:n
        if rand(A) > rand(B)
            ab += 1
        end
    end
    ab / n
end
@time v2(1_000_000)

# Banach Match Problem
function BMP(n)
    l = r = n
    for i in 1:(2n + 1)
        (rand() < 0.5) ? (l -= 1) : (r -=1)
        if l == -1 || r == -1
            return max(l, r)
        end
    end
end

function BMP(n)
    l = r = n
    while l > -1 && r > -1
        (rand() < 0.5) ? (l -= 1) : (r -=1)
    end
    return max(l, r)
end

n = 100
m = 3
simu = [BMP(n) for i in 1:100000]
mean(simu .== m)
sum(simu .== m) ./ length(simu)

counts(simu) ./ length(simu)
bar(counts(simu) ./ length(simu))
mean(simu)

## Two Child Problem
Random.seed!(2022);
n = 10000
kids = ["👦", "👧"]
res = rand(kids, 2, n)
n_twog = sum((res[1,:] .== "👧") .&& (res[2,:] .== "👧"))
n_oldg = sum(res[1,:] .== "👧")
n_oneg = sum((res[1,:] .== "👧") .|| (res[2,:] .== "👧"))
n_twog / n_oldg
n_twog / n_oneg

## Fair Division
Random.seed!(2022);
n = 100000
players = ["🐱", "🐭"]
res = rand(players, 5, n)
🐱❓ = res .== "🐱"

vec(sum(🐱❓[1:3,:], dims=1)) .== 2

🐱2  = vec(sum(🐱❓[1:3,:], dims=1)) .== 2

🐱2 = sum(eachrow(🐱❓[1:3,:])) .== 2

# vec(sum(🐱❓[1:3,:], dims=1)) .== 2
🐱win = sum(eachrow(🐱❓)) .>= 3
🐱win = vec(sum(🐱❓, dims=1)) .> 2

sum(🐱2 .& 🐱win) / sum(🐱2)

🐭❓ = res .== "🐭"
🐭1 = sum(eachrow(🐭❓[1:3,:])) .== 1
🐭win = sum(eachrow(🐭❓)) .> 2
sum(🐭1 .& 🐭win) / sum(🐭1)

## Bertrand’s Box
Random.seed!(2022);
boxes = [["🪙", "🪙"], ["🪙", "🥈"], ["🥈", "🥈"]]
n = 100000
boxcoin = Array{Any}(undef, n, 2)

for i in 1:n
    boxcoin[i,1] = box = rand(boxes)
    boxcoin[i,2] = rand(box)
end

gold❓ = boxcoin[:,2] .== "🪙"
sum(gold❓ .&& (boxcoin[:,1] .== [["🪙", "🪙"]])) / sum(gold❓)

boxcoin[:,1] .== [["🪙", "🪙"]]

mean(boxcoin[:,1][gold❓] .== [["🪙", "🪙"]])

gold = twogolds = 0
for i in 1:n
    box = rand(boxes)
    if rand(box) == "🪙"
        gold += 1
        if box == ["🪙", "🪙"]
            twogolds += 1
        end
    end
end
twogolds / gold

## Birthday Problem
n = 10
n_people = 23
N = 365
function bd(n_people=23, N=365, n=10)
    same = Array{Bool}(undef, n)
    for i in 1:n
        tmp = rand(1:N, n_people)
        same[i] = length(unique(tmp)) < n_people
    end
    return mean(same)
end

bd(23, 365, 10000)

bd(500, 2_400_000, 10000)

rpt = 10000
samebd = 0
for i in 1:rpt
    samebd += length(unique(rand(1:365, 23))) < 23
end
samebd / rpt

using Dates

Random.seed!(2022);
function birthday(n=23, yours="05-01")
    # n is the number of people
    # yours is your birthday with format "mm-dd"
    N = 365 # number of days each year
    room = rand(1:N, n) # randomly choose n people
    doy = dayofyear(Date(yours, "mm-day"))
    # convert the birthday to day of year
    share = length(unique(room)) < n
    ## if there are people sharing a common birthday
    same = doy ∈ room # if someone's birthday the same as yours
    return [share, same]
end

doy = dayofyear(Date("04-01", "mm-day"))

res = [birthday(23) for i in 1:10000];
mean(res)
res = [birthday(253) for i in 1:10000];
mean(res)

## ## Birth problem direct calculation
function p_share(n)
    p = 1
    for i in 1:n
        p *= (365 - i + 1) / 365
    end
    return 1-p
end
p_share.([4, 16, 23, 32, 40, 56])

1 - prod(BigInt.((365-22):365)) / BigInt(365)^23

n = [4, 16, 23, 32, 40, 56, 252, 253, 254]
P2 = 1 .- (364/365).^n

# 500/(2.4*10^6)
# 1 - BigFloat((2.4*10^6-1)/(2.4*10^6))^500


## Henry’s Choice
Random.seed!(2022);
n = 10000 # number of simulations

### spin and shot
spin_shot = rand(1:6, 2, n)
## Assume that the bullets are in chambers 1 and 2_
first_blank = spin_shot[1,:] .> 2
prob1 = sum(spin_shot[2,first_blank] .<= 2) / sum(first_blank)

nf = nb = 0
for i in 1:n
    spin_shot = rand(1:6, 2)
    if spin_shot[1] > 2 # first_blank
        nf += 1
    end
    if sum(spin_shot .> 2) == 2 # both_blank
        nb += 1
    end
end
nb / nf

### keep shoting
function twoshots() 
    first_shot = rand(1:6)
    second_shot = first_shot % 6 + 1
    [first_shot, second_shot]
end
twoshots()

shot_again = [twoshots() for i in 1:n]
first_blank = first.(shot_again) .> 2
# first.(shot_again)
mean(last.(shot_again[first_blank]) .<= 2)

shot_again = [rand(1:6) .|> [x->x, x->x%6+1] for i in 1:n];
tmp = [x->x, x->x%6+1]

first_blank = first.(shot_again) .> 2
mean(last.(shot_again[first_blank]) .<= 2)

## Monty Hall problem
# using Base.Iterators
Random.seed!(2022);

choice = 1
nds = 3
prize = rand(1:nds)
if prize == choice
    host = rand(setdiff(1:nds, choice))
else
    host = rand(setdiff(1:nds, [choice, prize]))
end
switch = rand(setdiff(1:nds, [choice, host]))
return [prize, switch]


function whichDoor(choice; nds=3)
    prize = rand(1:nds)
    if prize == choice
        host = rand(setdiff(1:nds, choice))
    else
        host = rand(setdiff(1:nds, [choice, prize]))
    end
    switch = rand(setdiff(1:nds, [choice, host]))
    return [prize, switch]
end

n = 100000
n_win_original = n_win_switch = 0
for i in 1:n
    tmp = whichDoor(1, nds=3) 
    if tmp[1] == 1
        n_win_original += 1
    end
    if tmp[1] == tmp[2]
        n_win_switch += 1
    end
end
(n_win_original / n, n_win_switch / n)

function whichDoor(choice; nds=3)
    prize = rand(1:nds)
    if prize == choice
        host = rand(setdiff(1:nds, choice))
    else
        host = rand(setdiff(1:nds, [choice, prize]))
    end
    switch = rand(setdiff(1:nds, [choice, host]))
    return Dict{String,Int32}("host"=>host,
                              "prize"=>prize,
                              "switch"=>switch)
end

nds = 3
whichDoor(1)

doors = fill("🚪", nds) # ["🚪", "🚪", "🚪"]
choice = 1
doors[choice] *= "👈"
# doors[choice] =  doors[choice] * "👈"
# "hello" * "Hi"
doors
onegame = whichDoor(choice)
onegame["host"]
doors[onegame["host"]] *= "🐐"
doors
doors[onegame["prize"]] *= "🚗"

nds = 3
n = 100
results = Vector{Vector{String}}(undef, n)
for i in eachindex(results)
    doors = fill("🚪", nds)
    choice = 1
    doors[choice] *= "👈"
    onegame = whichDoor(choice, nds=nds)
    doors[onegame["host"]] *= "🐐"
    doors[onegame["switch"]] *= "👌"
    doors[onegame["prize"]] *= "🚗"
    results[i] = doors
end

mean([any(results[i] .== "🚪👈🚗") for i in eachindex(results)])
mean([any(results[i] .== "🚪👌🚗") for i in 1:n])

## 100 prisoners problem
Random.seed!(2022);
n = 1000 # number of prisoners
prisoners = 1:n # prisoners' numbers
# simulate the procedure of randomly open 50 (n/2) drawers
function open_random(prisoners, n=length(prisoners)) 
    drawers = shuffle(1:n)
    # randomly put prisoners’ numbers in the drawers
    pardon = true # initialize pardon to be true
    for i in prisoners
        opens = sample(drawers, n÷2, replace=false)
        # rand(drawers, n÷2)
        # randomly open n/2 drawers
        if i ∉ opens
        # if !(i in opens)
            # if any prisoner does not find his number, all prisoners die
            pardon = false
            break
        end
    end
    return pardon
end
open_random(prisoners)

function open_smart(prisoners, n=length(prisoners)) 
    drawers = shuffle(1:n)
    pardon = true
    for i in prisoners
        opens = fill(n+1, n÷2) # Vector{Int32}(undef, n÷2)
        # opens = zeros(Int64, n+1, n÷2) # Vector{Int32}(undef, n÷2)
        opens[1] = drawers[i]
        for j in 2:n÷2
            if opens[j-1] == i
                break
            else
               opens[j] = drawers[opens[j-1]]
            end
        end
        if i ∉ opens
        # if !(i in opens)
            pardon = false
            break
        end
    end
    return pardon
end
open_smart(prisoners)

# survival probability of randomly open
mean([open_random(prisoners) for i in 1:100000])
# survival probability of using the better strategy
@time mean([open_smart(prisoners) for i in 1:100000])

@time begin
    c = 0
    for i in 1:100000
        c += open_smart(prisoners)
    end
    c / 100000
end
