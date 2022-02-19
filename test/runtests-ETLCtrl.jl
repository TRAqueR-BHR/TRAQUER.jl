include("runtests-prerequisite.jl")

# ############### #
# Anonymized data #
# ############### #
# Stays
df = DataFrame(XLSX.readtable("csv/mouvements DXCARE 202009-202010 avril 2021 V2.xlsx",
                              1)...)

ETLCtrl.importStays(df,getDefaultEncryptionStr())


# Analyses
df = DataFrame(XLSX.readtable("csv/mouvements INLOG 202009-202010 avril 2021 V2.xlsx",
                              1)...)

filter(x -> x.BILAN in ["GXEPCC","PREPC","GXERVC","ATB2"],df) |>
n -> filter(x -> x.BILAN != x.ANA_CODE, n) |>
n -> n[:,[:BILAN,:ANA_CODE]] |> n -> unique(n)

filter(x -> (x.BILAN in ["GXEPCC"]),df)
filter(x -> (x.BILAN in ["PREPC"]),df)
filter!(x -> (x.BILAN in ["GXEPCC","PREPC","GXERVC"]
            || (x.BILAN == "ATB2" && !ismissing(x.BMR) && x.BMR in ["EPC","ERV"])),
        df)
ETLCtrl.importAnalyses(df,getDefaultEncryptionStr())

# ######### #
# Real data #
# ######### #

# Stays
dfStays = DataFrame(XLSX.readtable("csv/prod/dxcare.xlsx",
                              1)...)
minimum(dfStays.DATE_ENTREE_MVT) # "01/07/2021"
maximum(dfStays.DATE_ENTREE_MVT) # "31/10/2021"

# ETLCtrl.importStays(dfStays[20300:end,:],getDefaultEncryptionStr())


# Analyses
dfAnalyses = DataFrame(XLSX.readtable("csv/prod/inlog.xlsx",
                              1)...)
minimum(dfAnalyses.DATE_DEMANDE) # "01/01/2020"
maximum(dfAnalyses.DATE_DEMANDE) # "31/12/2020"

ETLCtrl.importAnalyses(dfAnalyses,
    getDefaultEncryptionStr()
    # ;stopAfterXLines = 10
    )

@warn "qqq"

let
    a::Int64 = Inf64
    a < Inf64
end

df = DataFrame(a = [10,20])
df.rowNumber = 1:nrow(df)
