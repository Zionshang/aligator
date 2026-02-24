```
SolverProxDDP::run [ZoneScoped]
└── while (AL outer loop)
    └── innerLoop [ZoneNamed: InnerLoop]
        ├── 进入 innerLoop 的初始化阶段
        │   ├── TrajOptProblem::evaluate [ZoneScopedN: "TrajOptProblem::evaluate"]
        │   │   └── StageModel::evaluate [ZoneScopedN: "StageModel::evaluate"] (每个 stage)
        │   ├── computeMultipliers [ZoneScoped]
        │   └── ALFunction::evaluate [ZoneScoped]
        └── for iter in max_iters
            └── inner_iteration [ZoneNamedN: "inner_iteration"]
                ├── TrajOptProblem::computeDerivatives [ZoneScopedN: "TrajOptProblem::computeDerivatives"]
                │   ├── StageModel::computeFirstOrderDerivatives [ZoneScopedN]
                │   └── StageModel::computeSecondOrderDerivatives [ZoneScopedN]
                ├── LagrangianDerivatives::compute [ZoneScopedN: "LagrangianDerivatives::compute"]
                ├── computeCriterion [ZoneScoped]
                ├── computeProjectedJacobians [ZoneScoped]
                ├── updateLQSubproblem [ZoneScoped]
                ├── 线性子问题求解（按 solver 选择）
                │   ├── ProximalRiccatiSolver::backward [ZoneNamed: Zone1]
                │   │   ├── factor_initial [ZoneNamedN: "factor_initial"]
                │   │   └── ProximalRiccatiKernel::backwardImpl [ZoneScoped]
                │   │       ├── terminalSolve [ZoneScoped]
                │   │       └── stageKernelSolve [ZoneScoped]
                │   │           └── stage_solve_parameter [ZoneScopedN]
                │   ├── ProximalRiccatiSolver::forward [ZoneScoped]
                │   │   ├── computeInitial [ZoneScoped]
                │   │   └── forwardImpl [ZoneScoped]
                │   ├── ParallelRiccatiSolver::backward [ZoneScopedN: "parallel_backward"] (并行分支)
                │   │   ├── assembleCondensedSystem [ZoneScoped]
                │   │   └── symmetricBlockTridiagSolve [ZoneScoped]
                │   ├── ParallelRiccatiSolver::forward [ZoneScopedN: "parallel_forward"] (并行分支)
                │   └── RiccatiSolverDense::backward [ZoneScoped] (dense 分支)
                ├── 回写反馈增益 block [ZoneScoped]
                ├── ALFunction::directionalDerivative [ZoneScoped]
                │   └── LagrangianDerivatives::compute [ZoneScopedN]
                └── line search / filter
                    ├── Armijo / Nonmonotone: repeated merit_eval_fun(alpha)
                    │   └── forwardPass [ZoneScoped]
                    │       ├── tryLinearStep [ZoneScoped]
                    │       │   └── TrajOptProblem::evaluate [ZoneScopedN]
                    │       ├── tryNonlinearRollout [ZoneScoped]
                    │       │   └── StageModel::evaluate [ZoneScopedN] (每个 stage)
                    │       ├── computeMultipliers [ZoneScoped]
                    │       └── ALFunction::evaluate [ZoneScoped]
                    └── Filter: pair_eval_fun [ZoneNamedN: "pair_eval_fun"]
                        └── forwardPass [ZoneScoped] (同上)
```