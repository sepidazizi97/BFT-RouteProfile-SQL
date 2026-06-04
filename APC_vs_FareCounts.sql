SELECT
    apc."Month Number",
    apc."Month",
    apc."Day of Week",
    apc."Route Short Name",
    apc."Route Name",
    apc."Direction",
    apc."Trip",

    apc."APC Boards",
    fare."Total Fare Counts",

    apc."APC Boards" - ISNULL(fare."Total Fare Counts", 0) AS "Difference APC Minus Fare",

    CASE
        WHEN apc."APC Boards" = 0 THEN NULL
        ELSE ROUND(
            100.0 * ISNULL(fare."Total Fare Counts", 0) / apc."APC Boards",
            1
        )
    END AS "Fare Count as % of APC Boards"

FROM (
    SELECT
        dd.Month AS "Month Number",
        dd.MonthName AS "Month",
        dd.DayName AS "Day of Week",
        r.RouteShortName AS "Route Short Name",
        r.RouteName AS "Route Name",
        d.DirectionName AS "Direction",
        tp.TripName AS "Trip",

        SUM(tp.BoardCount) AS "APC Boards"

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

    GROUP BY
        dd.Month,
        dd.MonthName,
        dd.DayName,
        r.RouteShortName,
        r.RouteName,
        d.DirectionName,
        tp.TripName
) apc

LEFT JOIN (
    SELECT
        dd.Month AS "Month Number",
        dd.MonthName AS "Month",
        dd.DayName AS "Day of Week",
        r.RouteShortName AS "Route Short Name",
        r.RouteName AS "Route Name",
        d.DirectionName AS "Direction",
        tp.TripName AS "Trip",

        SUM(vf.FareCount) AS "Total Fare Counts"

    FROM DateDimension dd

    INNER JOIN VehicleLocationTPFare vf
        ON dd.DateDimensionKey = vf.EventDateKey

    INNER JOIN sch_WorkItemCompleted wic
        ON wic.WorkItemCompletedKey = vf.WorkItemCompletedKey

    INNER JOIN VehicleLocationTP tp
        ON tp.VehicleLocationTPKey = vf.VehicleLocationTPKey

    INNER JOIN sch_Route r
        ON r.RouteKey = wic.RouteKey

    INNER JOIN sch_Pattern p
        ON p.PatternKey = tp.PatternKey

    INNER JOIN sch_Direction d
        ON d.DirectionKey = p.DirectionKey

    WHERE
        dd.FullDate >= CAST('2026-01-01' AS DATETIME)
        AND dd.FullDate < CAST('2027-01-01' AS DATETIME)

        AND vf.FareTypeKey NOT IN (9,11,14,20)

        AND r.RouteShortName IN (
            '1','10','123','123s','170','2','20','225','240',
            '25','26','26s','27','3','40','41','42',
            '47','48','50','64','65','67','68'
        )

        AND d.DirectionName IN ('E','W','N','S')
        AND vf.FareCount IS NOT NULL

    GROUP BY
        dd.Month,
        dd.MonthName,
        dd.DayName,
        r.RouteShortName,
        r.RouteName,
        d.DirectionName,
        tp.TripName
) fare

ON apc."Month Number" = fare."Month Number"
AND apc."Day of Week" = fare."Day of Week"
AND apc."Route Short Name" = fare."Route Short Name"
AND apc."Direction" = fare."Direction"
AND apc."Trip" = fare."Trip"
