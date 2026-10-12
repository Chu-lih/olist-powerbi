// dim_customer: one row per customer_id (Olist issues a new customer_id per order;
// customer_unique_id identifies the real person and is used for customer counts)
let
    Source = raw_customers,
    MergedStates = Table.NestedJoin(Source, {"customer_state"}, raw_states, {"StateCode"}, "raw_states", JoinKind.LeftOuter),
    ExpandedStates = Table.ExpandTableColumn(MergedStates, "raw_states", {"StateName", "Region", "MapLocation"}, {"StateName", "Region", "MapLocation"}),
    CapitalizedCity = Table.TransformColumns(ExpandedStates, {{"customer_city", Text.Proper, type text}}),
    // Zip prefixes were loaded as numbers (leading zeros lost) and are not used in the analysis
    RemovedZip = Table.RemoveColumns(CapitalizedCity, {"customer_zip_code_prefix"})
in
    RemovedZip
