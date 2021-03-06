include("support/gibbs_helper.jl")

immutable Gibbs <: InferenceAlgorithm
  n_iters ::  Int
  algs    ::  Tuple
  Gibbs(n_iters::Int, algs...) = new(n_iters, algs)
end

type GibbsSampler{Gibbs} <: Sampler{Gibbs}
  gibbs       ::  Gibbs               # the sampling algorithm
  samplers    ::  Array{Sampler}      # samplers
  samples     ::  Array{Sample}       # samples
  predicts    ::  Dict{Symbol, Any}   # outputs

  function GibbsSampler(model::Function, gibbs::Gibbs)
    n_samplers = length(gibbs.algs)
    samplers = Array{Sampler}(n_samplers)
    for i in 1:n_samplers
      alg = gibbs.algs[i]
      if isa(alg, HMC)
        samplers[i] = HMCSampler{HMC}(alg)
      elseif isa(alg, PG)
        samplers[i] = ParticleSampler{PG}(model, alg)
      end
    end

    samples = Array{Sample}(gibbs.n_iters)
    weight = 1 / gibbs.n_iters
    for i = 1:gibbs.n_iters
      samples[i] = Sample(weight, Dict{Symbol, Any}())
    end

    predicts = Dict{Symbol, Any}()
    new(gibbs, samplers, samples, predicts)
  end
end

function Base.run(model, data, spl::Sampler{Gibbs})
  # initialization
  task = current_task()
  n = spl.gibbs.n_iters
  t_start = time()  # record the start time of HMC
  varInfo = VarInfo()
  ref_particle = nothing

  # HMC steps
  for i = 1:n
    dprintln(2, "Gibbs stepping...")

    for local_spl in spl.samplers
      dprintln(2, "$local_spl stepping...")

      if isa(local_spl, Sampler{HMC})
        for _ in local_spl.alg.n_samples
          dprintln(2, "recording old θ...")
          old_vals = deepcopy(varInfo.vals)
          is_accept, varInfo = step(model, data, local_spl, varInfo, i==1)
          if ~is_accept
            varInfo.vals = old_vals
          end
        end
      elseif isa(local_spl, Sampler{PG})
        local samples
        for _ in local_spl.alg.n_iterations
          ref_particle, samples = step(model, data, local_spl, varInfo, ref_particle)
        end
        varInfo = update(varInfo, samples, local_spl.alg.space)
      end

    end
    spl.samples[i].value = varInfo2samples(varInfo)

  end

  println("[Gibbs]: Finshed within $(time() - t_start) seconds")
  return Chain(0, spl.samples)    # wrap the result by Chain
end

function sample(model::Function, data::Dict, gibbs::Gibbs)
  global sampler = GibbsSampler{Gibbs}(model, gibbs);
  run(model, data, sampler)
end

function sample(model::Function, gibbs::Gibbs)
  global sampler = GibbsSampler{Gibbs}(model, gibbs);
  run(model, Dict(), sampler)
end
