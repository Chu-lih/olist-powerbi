// fact_payments: one row per payment (an order can be paid with several methods)
let
    Source = raw_payments,
    ReplacedUnderscore = Table.ReplaceValue(Source, "_", " ", Replacer.ReplaceText, {"payment_type"}),
    CapitalizedType = Table.TransformColumns(ReplacedUnderscore, {{"payment_type", Text.Proper, type text}}),
    Typed = Table.TransformColumnTypes(CapitalizedType, {{"payment_value", type number}, {"payment_installments", Int64.Type}, {"payment_sequential", Int64.Type}})
in
    Typed
