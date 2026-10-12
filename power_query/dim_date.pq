// dim_date: continuous calendar (Direct Lake models cannot use DAX calculated tables
// over lakehouse tables, so the date table is built in Power Query instead)
let
    StartDate  = #date(2016, 9, 1),
    EndDate    = #date(2018, 10, 31),
    Dates      = List.Dates(StartDate, Duration.Days(EndDate - StartDate) + 1, #duration(1, 0, 0, 0)),
    ToTable    = Table.FromList(Dates, Splitter.SplitByNothing(), {"Date"}),
    Typed      = Table.TransformColumnTypes(ToTable, {{"Date", type date}}),
    Year       = Table.AddColumn(Typed, "Year", each Date.Year([Date]), Int64.Type),
    Quarter    = Table.AddColumn(Year, "Quarter", each "Q" & Text.From(Date.QuarterOfYear([Date])), type text),
    MonthNo    = Table.AddColumn(Quarter, "MonthNumber", each Date.Month([Date]), Int64.Type),
    Month      = Table.AddColumn(MonthNo, "Month", each Date.ToText([Date], [Format = "MMM", Culture = "en-US"]), type text),
    YearMonth  = Table.AddColumn(Month, "YearMonth", each Date.ToText([Date], [Format = "yyyy-MM"]), type text),
    MonthStart = Table.AddColumn(YearMonth, "MonthStart", each Date.StartOfMonth([Date]), type date),
    Weekday    = Table.AddColumn(MonthStart, "Weekday", each Date.ToText([Date], [Format = "ddd", Culture = "en-US"]), type text),
    WeekdayNo  = Table.AddColumn(Weekday, "WeekdayNumber", each Date.DayOfWeek([Date], Day.Monday) + 1, Int64.Type)
in
    WeekdayNo
