SELECT
    apc."Month Number",
    apc."Month",
    apc."Service Day Category",
    apc."Route Short Name",
    apc."Route Name",
    apc."Direction",
    apc."Trip",

    ISNULL(fare."Total Fare Counts", 0) AS "Total Fare Counts",
    apc."Median Passenger Load",

    apc."On Time Arrivals",
    ROUND(100.0 * apc."On Time Arrivals" / apc."Total Arrival Events", 1) AS "% On Time",

    apc."Early Arrivals",
    ROUND(100.0 * apc."Early Arrivals" / apc."Total Arrival Events", 1) AS "% Early",

    apc."Late Arrivals",
    ROUND(100.0 * apc."Late Arrivals" / apc."Total Arrival Events", 1) AS "% Late"

FROM (
    SELECT
        y."Month Number",
        y."Month",
        y."Service Day Category",
        y."Route Short Name",
        y."Route Name",
        y."Direction",
        y."Trip",

        MAX(y."Median Passenger Load") AS "Median Passenger Load",

        SUM(CASE WHEN y."Arrive Delta Seconds" BETWEEN -60 AND 300 THEN 1 ELSE 0 END) AS "On Time Arrivals",
        SUM(CASE WHEN y."Arrive Delta Seconds" < -60 THEN 1 ELSE 0 END) AS "Early Arrivals",
        SUM(CASE WHEN y."Arrive Delta Seconds" > 300 THEN 1 ELSE 0 END) AS "Late Arrivals",

        COUNT(*) AS "Total Arrival Events"

    FROM (
        SELECT
            x.*,

            PERCENTILE_CONT(0.5)
            WITHIN GROUP (ORDER BY x."Passenger Load")
            OVER (
                PARTITION BY
                    x."Month Number",
                    x."Month",
                    x."Service Day Category",
                    x."Route Short Name",
                    x."Route Name",
                    x."Direction",
                    x."Trip"
            ) AS "Median Passenger Load"

        FROM (
            SELECT
                dd.Month AS "Month Number",
                dd.MonthName AS "Month",

                CASE
                    WHEN dd.DayName IN ('Monday','Tuesday','Wednesday','Thursday','Friday') THEN 'Weekday'
                    WHEN dd.DayName = 'Saturday' THEN 'Saturday'
                    WHEN dd.DayName = 'Sunday' THEN 'Sunday'
                END AS "Service Day Category",

                r.RouteShortName AS "Route Short Name",
                r.RouteName AS "Route Name",
                d.DirectionName AS "Direction",
                tp.TripName AS "Trip",

                tp.TotalCount AS "Passenger Load",

                DATEDIFF(second, tp.ScheduleArriveTime, tp.ActualArriveTime) AS "Arrive Delta Seconds"

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

                AND tp.TotalCount IS NOT NULL
                AND tp.ActualArriveTime IS NOT NULL
                AND tp.ScheduleArriveTime IS NOT NULL
                AND tp.InBetween <> 1
        ) x
    ) y

    GROUP BY
        y."Month Number",
        y."Month",
        y."Service Day Category",
        y."Route Short Name",
        y."Route Name",
        y."Direction",
        y."Trip"
) apc

LEFT JOIN (
    SELECT
        dd.Month AS "Month Number",
        dd.MonthName AS "Month",

        CASE
            WHEN dd.DayName IN ('Monday','Tuesday','Wednesday','Thursday','Friday') THEN 'Weekday'
            WHEN dd.DayName = 'Saturday' THEN 'Saturday'
            WHEN dd.DayName = 'Sunday' THEN 'Sunday'
        END AS "Service Day Category",

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
        CASE
            WHEN dd.DayName IN ('Monday','Tuesday','Wednesday','Thursday','Friday') THEN 'Weekday'
            WHEN dd.DayName = 'Saturday' THEN 'Saturday'
            WHEN dd.DayName = 'Sunday' THEN 'Sunday'
        END,
        r.RouteShortName,
        r.RouteName,
        d.DirectionName,
        tp.TripName
) fare

ON apc."Month Number" = fare."Month Number"
AND apc."Service Day Category" = fare."Service Day Category"
AND apc."Route Short Name" = fare."Route Short Name"
AND apc."Direction" = fare."Direction"
AND apc."Trip" = fare."Trip"
