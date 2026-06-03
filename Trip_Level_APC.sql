SELECT
    dd.Month AS "Month Number",
    dd.MonthName AS "Month",
    dd.DayName AS "Day of Week",

    r.RouteShortName AS "Route Short Name",
    r.RouteName AS "Route Name",
    d.DirectionName AS "Direction",
    tp.TripName AS "Trip",

    SUM(tp.BoardCount) AS "Total Boards",
    AVG(tp.BoardCount) AS "Average Boards per Stop Event",
    MAX(tp.BoardCount) AS "Maximum Boards at a Stop",

    SUM(tp.AlightCount) AS "Total Alights",
    AVG(tp.AlightCount) AS "Average Alights per Stop Event",
    MAX(tp.AlightCount) AS "Maximum Alights at a Stop",

    AVG(tp.TotalCount) AS "Average Passenger Load",
    MAX(tp.TotalCount) AS "Maximum Passenger Load",

    COUNT(*) AS "Observation Count"

FROM VehicleLocationTP tp

INNER JOIN DateDimension dd
    ON tp.ActualArriveDateKey = dd.DateDimensionKey

INNER JOIN sch_Route r
    ON tp.RouteKey = r.RouteKey

INNER JOIN sch_Pattern p
    ON tp.PatternKey = p.PatternKey

INNER JOIN sch_Direction d
    ON p.DirectionKey = d.DirectionKey

WHERE
    dd.FullDate >= CAST('2026-01-01' AS DATETIME)
    AND dd.FullDate < CAST('2027-01-01' AS DATETIME)

    AND r.RouteShortName IN (
        '1','10','123','123s','170','2','20','225','240',
        '25','26','26s','27','3','40','41','42',
        '47','48','50','64','65','67','68'
    )

    AND d.DirectionName IN ('E','W','N','S')

    AND tp.BoardCount IS NOT NULL
    AND tp.AlightCount IS NOT NULL
    AND tp.TotalCount IS NOT NULL

GROUP BY
    dd.Month,
    dd.MonthName,
    dd.DayName,
    r.RouteShortName,
    r.RouteName,
    d.DirectionName,
    tp.TripName
