// dim_product: one row per product, with English category names
let
    Source = raw_products,
    // Look up the English category name (left outer: keep products with no translation)
    MergedTranslation = Table.NestedJoin(Source, {"product_category_name"}, raw_category_translation, {"product_category_name"}, "raw_category_translation", JoinKind.LeftOuter),
    ExpandedTranslation = Table.ExpandTableColumn(MergedTranslation, "raw_category_translation", {"product_category_name_english"}, {"product_category_name_english"}),
    // Fall back to the Portuguese name, then to "unknown" (610 products have no category)
    AddedCategory = Table.AddColumn(ExpandedTranslation, "category", each
        if [product_category_name_english] <> null then [product_category_name_english]
        else if [product_category_name] <> null then [product_category_name]
        else "unknown", type text),
    ReplacedUnderscore = Table.ReplaceValue(AddedCategory, "_", " ", Replacer.ReplaceText, {"category"}),
    KeptColumns = Table.SelectColumns(ReplacedUnderscore, {"category", "product_id", "product_photos_qty", "product_weight_g"}),
    CapitalizedCategory = Table.TransformColumns(KeptColumns, {{"category", Text.Proper, type text}}),
    Typed = Table.TransformColumnTypes(CapitalizedCategory, {{"product_photos_qty", Int64.Type}, {"product_weight_g", Int64.Type}, {"product_id", type text}})
in
    Typed
