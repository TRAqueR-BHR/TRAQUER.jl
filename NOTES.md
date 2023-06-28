[ Info: ATB2[K, l, e, b, s, i, e, l, l, a,  , p, n, e, u, m, o, n, i, a, e,  , -,  , E, P, C]
ERROR: LoadError: UndefVarError: requestTime not defined
Stacktrace:
 [1] importAnalyses(df::DataFrame, encryptionStr::AbstractString; stopAfterXLines::Float64)
   @ TRAQUER ~/CODE/BHRE/TRAQUER.jl/src/Controller/ETLCtrl/ETLCtrl-importAnalyses-imp.jl:115
 [2] importAnalyses(df::DataFrame, encryptionStr::AbstractString)
   @ TRAQUER ~/CODE/BHRE/TRAQUER.jl/src/Controller/ETLCtrl/ETLCtrl-importAnalyses-imp.jl:5
 [3] top-level scope
   @ ~/CODE/BHRE/TRAQUER.jl/test/runtests-ETLCtrl.jl:42
in expression starting at /home/vlaugier/CODE/BHRE/TRAQUER.jl/test/runtests-ETLCtrl.jl:42


Date de ref pour le calcul des cas contact:
Suivant le cas,
- Date de début de séjour au cours duquel on a eu une analyse positive (si découverte fortuite)
- Date d'analyse (si transmission)
- Date de la dernière analyse negative (si patient de reanimation depistage systematique une fois par semaine)

2 depistages negatifs à compter de un an après l'année de la découverte

Un test negatif en veut pas dire uen sortie de la liste des porteurs car un an de 40taine

2022-07-20 / Noumea
Toutes les heures : Extraction des mouvements et analyses sur les 3 derniers mois
Stock 2021 pour les analyses

# TODO:
- Remove Outbreak.refTime
(maybe not, see OutbreakCtrl.getOutbreakFromEventRequiringAttention, OutbreakCtrl.getOutbreakUnitAssosFromInfectiousStatus)
- Remove OutbreakUnitAsso.startTime
- Remove OutbreakUnitAsso.endTime
