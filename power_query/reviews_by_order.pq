// reviews_by_order: staging query (no destination). 547 orders have more than one review,
// so reviews are collapsed to one average score per order before merging into fact_orders.
let
    Source = raw_reviews,
    GroupedByOrder = Table.Group(Source, {"order_id"}, {{"review_score", each List.Average([review_score]), type nullable number}})
in
    GroupedByOrder
