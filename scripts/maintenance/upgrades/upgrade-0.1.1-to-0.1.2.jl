include("../../prerequisite.jl")

using PostgresORM, LibPQ

# Create the enum 'grievance_type' first because we need to create the variables
dbconn = TRAQUERUtil.openDBConn()
try
    @info "
    # ##################################### #
    # Update enum 'sample_material_type' #
    # ##################################### #"
    "ALTER TABLE analysis_result DROP column sample_material_type" |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    "DROP TYPE IF EXISTS public.sample_material_type" |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    "CREATE TYPE sample_material_type AS ENUM (
        'purulent_collection', -- Collection purulente
        'actinomycetes', -- Actinomycètes
        'joint_liquid', -- Liquide articulaire
        'ascites_liquid', -- Liquide d'ascite
        'broncho_tracheal_aspiration', -- Aspiration broncho-trachéale
        'bronchial_aspiration', -- Aspiration Bronchique
        'tracheal_aspiration', -- Aspiration Trachéale
        'biopsy_fragment', -- Fragment biopsique
        'biliary_liquid', -- Liquide biliaire
        'mouth', -- Bouche
        'bronchial_brushing', -- Brossage bronchique
        'fungal_mapping', -- cartographie fongique
        'implantable_chamber_pac', -- Chambre implantable (PAC)
        'conjunctiva', -- Conjonctive
        'cornea', -- Cornée
        'sputum', -- Expectoration
        'cryptococcus', -- Cryptocoque
        'miscellaneous', -- Divers
        'dpc_liquid', -- Liquide de DPCA
        'dpc_microbiology', -- Microbiologie sur DPCA
        'intra_tissular_device', -- Dispositif intra-tissulaire
        'intra_cavitary_device', -- Dispositif intra-cavitaire
        'throat_tonsils', -- Gorge, amygdales
        'gynecological_pelvic', -- Gynécologique/Pelvien
        'blood_culture', -- Hémoculture
        'pediatric_blood_culture', -- Hémoculture Pédiatrique
        'unspecified_nature_sample', -- Prél. nature non précisée
        'intravascular_device', -- Dispositif intra-vasculaire
        'broncho_alveolar_lavage', -- Lavage Broncho-Alvéolaire
        'biological_liquid', -- Liquide biologique
        'csf_chemistry_serology', -- Liq. Céphalo-Rach. Chimie/Séro
        'csf_bacterial', -- Liq.Céphalo-Rachidien (Bact)
        'gastric_liquid', -- Liquide gastrique
        'amniotic_liquid', -- Liquide amniotique
        'lochial', -- Lochies
        'pleural_liquid', -- Liquide pleural
        'pericardial_liquid', -- Liquide péricardique
        'mycobacterium', -- Mycobactérie
        'nose', -- Nez
        'placenta', -- Placenta
        'external_ear', -- Oreille externe
        'middle_ear', -- Oreille moyenne
        'ears', -- Oreilles
        'bone', -- Os
        'puncture', -- Ponction
        'skin_or_appendages', -- Peau ou phanères
        'skin', -- Peau
        'peritoneal_liquid', -- Liquide peritonéal
        'pica_liquid', -- Liquide de PICA
        'wound_or_oozing', -- Plaie ou suintement
        'blood_bag_and_tubings', -- Poche sang et tubulures
        'sinus_puncture', -- Ponction de sinus
        'urethral_sampling', -- Prélèvement Uréthral
        'superficial_pus', -- Pus superficiel
        'rectal_swab', -- Ecouvillon Rectal
        'respiratory', -- Respiratoire
        'indwelling_urinary_catheter', -- Sonde Urinaire à demeure
        'stool', -- Selles
        'bacterial_strain', -- Souche bactérienne
        'semen', -- Sperme
        'scales', -- Squames
        'iud', -- Sterilet
        'tissue', -- Tissu
        'transmitted_sample', -- Echantillon transmis
        'protected_tracheal_aspiration', -- Aspi. trachéale protégée
        'urine', -- Urines
        'urine_b', -- Urines [B)
        'resistant_screening_swabs', -- Ecouvillonages (Recherche BMR)
        'cancelled' -- Annulé
    );
    "  |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

    "ALTER TABLE analysis_result ADD column sample_material_type sample_material_type" |>
    n -> PostgresORM.execute_plain_query(n,missing,dbconn)

catch e
    rethrow(e)
finally
    TRAQUERUtil.closeDBConn(dbconn)
end

@warn "
SUCCESS!
"
