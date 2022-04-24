# Activate project
using Pkg; Pkg.activate(".")
# Pkg.instantiate()
# Pkg.add(Pkg.PackageSpec(;name="Metalhead", version="0.5.0"))


# look at the data
using MLDatasets, Plots
using Images: channelview, colorview

x, y = MLDatasets.MNIST.traindata()

i=2
plot(colorview(Gray, x[:,:,i]'), title=y[i])

n = 9
a = Vector{Any}(undef,n)
for i=1:n
    a[i] = plot(colorview(Gray, x[:,:,i]'), title=y[i])
end
ps = "plot(a[" * join(1:n, "], a[") * "])"
eval(Meta.parse(ps))

# Apply the LeNet5
using Flux
using Flux.Data: DataLoader
using Flux.Optimise: Optimiser, WeightDecay
using Flux: onehotbatch, onecold, flatten
using Flux.Losses: logitcrossentropy
using Statistics, Random
using ProgressMeter: @showprogress
import MLDatasets
import BSON
using CUDA

function LeNet5(; imgsize=(28,28,1), nclasses=10) 
    out_conv_size = (imgsize[1]÷4 - 3, imgsize[2]÷4 - 3, 16)
    return Chain(
            Conv((5, 5), imgsize[end]=>6, relu),
            MaxPool((2, 2)),
            Conv((5, 5), 6=>16, relu),
            MaxPool((2, 2)),
            flatten,
            Dense(prod(out_conv_size), 120, relu), 
            Dense(120, 84, relu), 
            Dense(84, nclasses)
          )
end

function getdata_plt(args)
    xtrain, ytrain = MLDatasets.MNIST.traindata(Float32)
    xtest, ytest = MLDatasets.MNIST.testdata(Float32)
    xtrain = reshape(xtrain, 28, 28, 1, :)
    xtest = reshape(xtest, 28, 28, 1, :)
    ytrain, ytest = onehotbatch(ytrain, 0:9), onehotbatch(ytest, 0:9)
    N = size(ytrain)[end]
    idx = rand(N) .≤ args.n0 / N
    xtrain = xtrain[:,:,:, idx]
    ytrain = ytrain[:, idx]
    train_loader = DataLoader((xtrain, ytrain), batchsize=args.batchsize)
    test_loader = DataLoader((xtest, ytest),  batchsize=args.batchsize)
    return train_loader, test_loader
end

loss(ŷ, y) = logitcrossentropy(ŷ, y)

function eval_loss_accuracy_plt(loader, model, cgpu)
    l = 0f0
    acc = 0
    ntot = 0
    for (x, y) in loader
        x, y = x |> cgpu, y |> cgpu
        ŷ = model(x)
        l += loss(ŷ, y) * size(x)[end]        
        acc += sum(onecold(ŷ |> cpu) .== onecold(y |> cpu))
        ntot += size(x)[end]
    end
    return (loss = l/ntot |> round4, acc = acc/ntot*100 |> round4)
end

round4(x) = round(x, digits=4)

# arguments for the `train` function 
Base.@kwdef mutable struct Args_plt
    η = 3e-4             # learning rate
    λ = 0                # L2 regularizer param, implemented as weight decay
    batchsize = 128      # batch size
    epochs = 10          # number of epochs
    seed = 1             # set seed > 0 for reproducibility
    use_cuda = false      # if true use cuda (if available)
    infotime = 1 	     # report every `infotime` epochs
    n0 = 2000
end

function train_plt(; kws...)
    args = Args_plt(; kws...)
    args.seed > 0 && Random.seed!(args.seed)
    use_cuda = args.use_cuda && CUDA.functional()
    use_cuda ? (cgpu = gpu) : (cgpu = cpu)
    train_loader, test_loader = getdata_plt(args)
    model = LeNet5() |> cgpu
    ps = Flux.params(model)  
    opt = ADAM(args.η) 
    if args.λ > 0 # add weight decay, equivalent to L2 regularization
        opt = Optimiser(WeightDecay(args.λ), opt)
    end
    function report(epoch)
        train = eval_loss_accuracy_plt(train_loader, model, cgpu)
        test = eval_loss_accuracy_plt(test_loader, model, cgpu)        
        println("Ep: $epoch Train: $(train) Test: $(test)")
    end
    ## TRAINING
    @info "Start Training"
    report(0)
    for epoch in 1:args.epochs
        @showprogress for (x, y) in train_loader
            x, y = x |> cgpu, y |> cgpu
            gs = Flux.gradient(ps) do
                    ŷ = model(x)
                    loss(ŷ, y)
                end
            Flux.Optimise.update!(opt, ps, gs)
        end
        ## Printing and logging
        epoch % args.infotime == 0 && report(epoch)
    end
    cpu(model)
end

Random.seed!(1)
@time mplt = train_plt(n0=2000, epochs=5)

savepath = "output"
!ispath(savepath) && mkpath(savepath)
BSON.@save joinpath(savepath, "pilot.bson") mplt
