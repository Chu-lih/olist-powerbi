// dim_seller: one row per seller, enriched with state name and region
let
    Source = raw_sellers,
    MergedStates = Table.NestedJoin(Source, {"seller_state"}, raw_states, {"StateCode"}, "raw_states", JoinKind.LeftOuter),
    ExpandedStates = Table.ExpandTableColumn(MergedStates, "raw_states", {"StateName", "Region", "MapLocation"}, {"StateName", "Region", "MapLocation"}),
    CapitalizedCity = Table.TransformColumns(ExpandedStates, {{"seller_city", Text.Proper, type text}}),
    RemovedZip = Table.RemoveColumns(CapitalizedCity, {"seller_zip_code_prefix"})
in
    RemovedZip
