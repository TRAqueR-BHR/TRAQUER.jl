include("../runtests-prerequisite.jl")

@testset "Test TaskWaitingForUserExecutionCtrl.executePendingTasks" begin

    TaskWaitingForUserExecutionCtrl.executePendingTasks(getDefaultEncryptionStr())

end
