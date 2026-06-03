SELECT
    y."Month Number",
    y."Month",
    y."Day of Week",

    y."Route Short Name",
    y."Route Name",

    y."Direction",

    SUM(y."BoardCount") AS "Total Boards",
    MAX(y."BoardCount") AS "Maximum Boards at a Stop",

    SUM(y."AlightCount") AS "Total Alights",
    MAX(y."AlightCount") AS "Maximum Alights at a Stop",

    AVG(y."TotalCount") AS "Average Passenger Load",
    MAX(y."Median Passenger Load") AS "Median Passenger Load",
    MAX(y."TotalCount") AS "Maximum Passenger Load",

    COUNT(*) AS "Observation Count"

FROM (
    SELECT
        x.*,

        PERCENTILE_CONT(0.5)
        WITHIN GROUP (ORDER BY x."TotalCount")
        OVER (
            PARTITION BY
                x."Month Number",
                x."Month",
                x."Day of Week",
                x."Route Short Name",
                x."Route Name",
                x."Direction"
        ) AS "Median Passenger Load"

    FROM (
        SELECT
            dd.Month AS "Month Number",
            dd.MonthName AS "Month",
            dd.DayName AS "Day of Week",

            r.RouteShortName AS "Route Short Name",
            r.RouteName AS "Route Name",

            d.DirectionName AS "Direction",

            tp.BoardCount AS "BoardCount",
            tp.AlightCount AS "AlightCount",
            tp.TotalCount AS "TotalCount"

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

    ) x
) y

GROUP BY
    y."Month Number",
    y."Month",
    y."Day of Week",
    y."Route Short Name",
    y."Route Name",
    y."Direction"
