SELECT
    x."Month",
    x."Month Name",
    x."Service Day Category",
    x."Route Short Name",
    x."Direction",
    x."Trip",

    SUM(CASE WHEN x."Arrive Delta Seconds" < -60 THEN 1 ELSE 0 END) AS "Early Arrivals",
    ROUND(100.0 * SUM(CASE WHEN x."Arrive Delta Seconds" < -60 THEN 1 ELSE 0 END) / COUNT(*), 1) AS "% Early Arrival",

    SUM(CASE WHEN x."Arrive Delta Seconds" BETWEEN -60 AND 300 THEN 1 ELSE 0 END) AS "On Time Arrivals",
    ROUND(100.0 * SUM(CASE WHEN x."Arrive Delta Seconds" BETWEEN -60 AND 300 THEN 1 ELSE 0 END) / COUNT(*), 1) AS "% On Time Arrival",

    SUM(CASE WHEN x."Arrive Delta Seconds" > 300 THEN 1 ELSE 0 END) AS "Late Arrivals",
    ROUND(100.0 * SUM(CASE WHEN x."Arrive Delta Seconds" > 300 THEN 1 ELSE 0 END) / COUNT(*), 1) AS "% Late Arrival",

    SUM(CASE WHEN x."Depart Delta Seconds" < -60 THEN 1 ELSE 0 END) AS "Early Departures",
    ROUND(100.0 * SUM(CASE WHEN x."Depart Delta Seconds" < -60 THEN 1 ELSE 0 END) / COUNT(*), 1) AS "% Early Departure",

    SUM(CASE WHEN x."Depart Delta Seconds" BETWEEN -60 AND 300 THEN 1 ELSE 0 END) AS "On Time Departures",
    ROUND(100.0 * SUM(CASE WHEN x."Depart Delta Seconds" BETWEEN -60 AND 300 THEN 1 ELSE 0 END) / COUNT(*), 1) AS "% On Time Departure",

    SUM(CASE WHEN x."Depart Delta Seconds" > 300 THEN 1 ELSE 0 END) AS "Late Departures",
    ROUND(100.0 * SUM(CASE WHEN x."Depart Delta Seconds" > 300 THEN 1 ELSE 0 END) / COUNT(*), 1) AS "% Late Departure",

    COUNT(*) AS "Total Stop Events"

FROM (
    SELECT
        dd.Month AS "Month",
        dd.MonthName AS "Month Name",

        CASE
            WHEN dd.DayName IN ('Monday','Tuesday','Wednesday','Thursday','Friday') THEN 'Weekday'
            WHEN dd.DayName = 'Saturday' THEN 'Saturday'
            WHEN dd.DayName = 'Sunday' THEN 'Sunday'
        END AS "Service Day Category",

        tp.RouteShortName AS "Route Short Name",
        d.DirectionName AS "Direction",
        tp.TripName AS "Trip",

        DATEDIFF(second, tp.ScheduleArriveTime, tp.ActualArriveTime) AS "Arrive Delta Seconds",
        DATEDIFF(second, tp.ScheduleDepartTime, tp.ActualDepartTime) AS "Depart Delta Seconds"

    FROM VehicleLocationTP tp

    INNER JOIN DateDimension dd
        ON tp.ActualArriveDateKey = dd.DateDimensionKey

    INNER JOIN sch_Direction d
        ON tp.DirectionKey = d.DirectionKey

    WHERE
        dd.FullDate >= CAST('2026-01-01' AS DATETIME)
        AND dd.FullDate < CAST('2027-01-01' AS DATETIME)

        AND tp.RouteShortName IN (
            '1','10','123','123s','170','2','20','225','240',
            '25','26','26s','27','3','40','41','42',
            '47','48','50','64','65','67','68'
        )

        AND tp.ActualArriveTime IS NOT NULL
        AND tp.ScheduleArriveTime IS NOT NULL
        AND tp.ActualDepartTime IS NOT NULL
        AND tp.ScheduleDepartTime IS NOT NULL
        AND tp.InBetween <> 1

) x

GROUP BY
    x."Month",
    x."Month Name",
    x."Service Day Category",
    x."Route Short Name",
    x."Direction",
    x."Trip"
