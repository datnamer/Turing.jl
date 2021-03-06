using Turing

# Benchmarking function runs an inference algorithm, measures execution time and evaluates the results.
# An optional warmup run is performed to exclude compilation time from measurements.
function benchmark(modelname :: AbstractString, alg :: InferenceAlgorithm, do_eval = true, do_warmup = true)
  # model definition
  include(string(modelname, ".jl"))

  # extract model and evaluation function
  model = eval(symbol(modelname))
  evaluate = eval(symbol(string(modelname,"_evaluate")))

  # warmup
  if do_warmup
    sample(model, alg)
  end

  # proper run with time measurement
  tic()
  chain = sample(model,alg)
  t = toq()

  # compute results
  if do_eval
    results = evaluate(chain)
  else
    results = Dict{Symbol,Any}()
  end
  results[:model] = modelname
  results[:time] = t

  return results
end

function benchmark(modelname :: AbstractString, algs, do_eval=true, do_warmup=true)
  return map(a -> benchmark(modelname, a, do_eval, do_warmup), algs)
end

function mean_sd(k, results)
  values = map(r -> r[k], results)
  μ = mean(values)
  σ = std(values)
  return (μ, σ)
end

function multibenchmark(n_repeat :: Int, modelname :: AbstractString, alg, do_eval=true, do_warmup=true)
   # model definition
  include(string(modelname, ".jl"))

  # extract model and evaluation function
  model = eval(symbol(modelname))
  evaluate = eval(symbol(string(modelname,"_evaluate")))

  if do_warmup
    #warmup run
    sample(model, alg)
  end

  results = map(x -> benchmark(modelname, alg, do_eval, false), zeros(n_repeat))

  summary = Dict()
  summary[:time] = mean_sd(:time, results)
  summary[:KL]   = mean_sd(:KL,   results)

  return summary
end
