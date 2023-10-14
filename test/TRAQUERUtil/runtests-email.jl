include("../runtests-prerequisite.jl")

@testset "Test 'TRAQUERUtil.sendemail'" begin

    TRAQUERUtil.sendemail(
        ["vincent.laugier@tekliko.com"],
        "Email de Test ",
        "Lorem ipsum"
        ;bcc = false,
        attachmentFilesPaths = missing
    )


end
