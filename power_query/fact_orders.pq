// fact_orders: one row per order, with delivery metrics and review score
let
    Source = raw_orders,
    AddedPurchaseDate = Table.AddColumn(Source, "purchase_date", each Date.From([order_purchase_timestamp]), type date),
    // Days from purchase to delivery (null when not delivered)
    AddedDeliveryDays = Table.AddColumn(AddedPurchaseDate, "delivery_days", each
        if [order_delivered_customer_date] = null then null
        else Number.Round(Duration.TotalDays([order_delivered_customer_date] - [order_purchase_timestamp]), 1), type nullable number),
    // 1 = delivered after the estimated date, 0 = on time, null = not delivered.
    // AVERAGE(is_late) in DAX then gives the late-delivery rate directly.
    AddedIsLate = Table.AddColumn(AddedDeliveryDays, "is_late", each
        if [order_delivered_customer_date] = null then null
        else if Date.From([order_delivered_customer_date]) > Date.From([order_estimated_delivery_date]) then 1
        else 0, Int64.Type),
    AddedDeliveryStatus = Table.AddColumn(AddedIsLate, "delivery_status", each
        if [is_late] = null then "Not Delivered" else if [is_late] = 1 then "Late" else "On Time", type text),
    MergedCustomers = Table.NestedJoin(AddedDeliveryStatus, {"customer_id"}, raw_customers, {"customer_id"}, "raw_customers", JoinKind.LeftOuter),
    ExpandedCustomers = Table.ExpandTableColumn(MergedCustomers, "raw_customers", {"customer_unique_id"}, {"customer_unique_id"}),
    MergedReviews = Table.NestedJoin(ExpandedCustomers, {"order_id"}, reviews_by_order, {"order_id"}, "reviews_by_order", JoinKind.LeftOuter),
    ExpandedReviews = Table.ExpandTableColumn(MergedReviews, "reviews_by_order", {"review_score"}, {"review_score"}),
    TypedReview = Table.TransformColumnTypes(ExpandedReviews, {{"review_score", type number}}),
    RemovedColumns = Table.RemoveColumns(TypedReview, {"order_approved_at", "order_delivered_carrier_date"})
in
    RemovedColumns
