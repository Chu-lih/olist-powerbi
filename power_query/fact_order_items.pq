// fact_order_items: one row per order line. Order attributes are copied in so that
// dim_date and dim_customer can filter this table directly (no fact-to-fact relationship).
let
    Source = raw_order_items,
    Typed = Table.TransformColumnTypes(Source, {{"price", type number}, {"freight_value", type number}, {"order_item_id", Int64.Type}}),
    MergedOrders = Table.NestedJoin(Typed, {"order_id"}, fact_orders, {"order_id"}, "fact_orders", JoinKind.LeftOuter),
    ExpandedOrders = Table.ExpandTableColumn(MergedOrders, "fact_orders",
        {"customer_id", "customer_unique_id", "order_status", "purchase_date"},
        {"customer_id", "customer_unique_id", "order_status", "purchase_date"}),
    RemovedShippingLimit = Table.RemoveColumns(ExpandedOrders, {"shipping_limit_date"})
in
    RemovedShippingLimit
