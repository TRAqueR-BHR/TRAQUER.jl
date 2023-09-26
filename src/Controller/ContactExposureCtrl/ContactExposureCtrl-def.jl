"""
    getExactOverlap(
        contactInTime::ZonedDateTime,
        contactOutTime::Union{Missing, ZonedDateTime},
        carrierInTime::ZonedDateTime,
        carrierOutTime::Union{Missing, ZonedDateTime}
    )::Tuple{ZonedDateTime,ZonedDateTime}

CASE1: Carrier stay and contact stay have an out time

  carrier: [=================]
  contact:     [===================]
  overlap:     [-------------]

  carrier:          [=================]
  contact:     [===================]
  overlap:          [--------------]

  carrier:          [===========]
  contact:     [===================]
  overlap:          [-----------]

  carrier: [==========================]
  contact:     [============]
  overlap:     [------------]

  carrier: [=============]
  contact:                     [============]
  overlap:  ∅

  carrier:                     [=============]
  contact:  [============]
  overlap:  ∅

CASE2 : Carrier stay has an out time but contact stay has not

    carrier: [=================]
    contact:     [=====================
    overlap:     [-------------]

    carrier:       [===============]
    contact: [=========================
    overlap:       [---------------]

    carrier: [=========]
    contact:               [=========================
    overlap: ∅

CASE3 : Carrier stay doesn't have an out time but contact stay has

    carrier: [============================
    contact:     [=====================]
    overlap:     [---------------------]

    carrier:       [======================
    contact: [=========================]
    overlap:       [-------------------]

    carrier:             [======================
    contact: [========]
    overlap: ∅

CASE4 : Neither carrier stay nor contact stay have an out time

    carrier: [============================
    contact:     [========================
    overlap:     [------------------------

    carrier:       [======================
    contact: [============================
    overlap:       [----------------------

"""
function getExactOverlap end

function generateContactExposures end


"""
    canGenerateContactExposures(
        stay::Stay,
        carrierStatusRefTime::ZonedDateTime,
        notAtRiskStatusRefTime::Union{ZonedDateTime,Missing}
    )

Tells whether a stay

[What stays generate contact exposures:]

The stays of the carrier that are used to generate the contact exposures are the following:

# Cases where there is no 'not_at_risk' status after the 'carrier' status:
```
Infectious status:                              🍎
Stay:                           [======][==========][=====][=========================
Generate contact exposures? :       0         1        1           1

Infectious status:                              🍎
Stay:                           [======][============================================
Generate contact exposures? :       0                     1
```

# Cases where there is a 'not_at_risk' status after the 'carrier' status
```
Infectious status:                              🍎             🍏
Stay:                           [======][==========][=====][==========][========]
Generate contact exposures? :       0         1        1         1          0

Infectious status:                              🍎                         🍏
Stay:                           [======][==========][=====][=========================
Generate contact exposures? :       0         1        1              1

Infectious status:                              🍎     🍏
Stay:                           [======][==========][=====][=========================
Generate contact exposures? :       0         1        1              0
````

"""
function canGenerateContactExposures end

function upsert! end

function generateContactExposuresAndInfectiousStatuses end

"""

Get the instances of ContactExposure where the given patient is a contact
"""
function getPatientExposuresForListing end
