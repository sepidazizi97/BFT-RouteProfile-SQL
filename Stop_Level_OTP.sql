SELECT
    x."Month",
    x."Month Name",
    x."Day of Week",
    x."Route Short Name",
    x."Direction",
    x."Trip",
    x."Stop Code",
    x."Stop Name",
    x."Is Time Point",
    x."Scheduled Arrive Time",
    x."Scheduled Depart Time",

    AVG(x."Arrive Delta Seconds") AS "Average Arrive Delta Seconds",
    MAX(x."Arrive Delta Seconds") AS "Maximum Arrive Delta Seconds",
    AVG(x."Depart Delta Seconds") AS "Average Depart Delta Seconds",
    MAX(x."Depart Delta Seconds") AS "Maximum Depart Delta Seconds",
    COUNT(*) AS "Observation Count"

FROM (
    SELECT
        dd.Month AS "Month",
        dd.MonthName AS "Month Name",
        dd.DayName AS "Day of Week",

        tp.RouteShortName AS "Route Short Name",
        d.DirectionName AS "Direction",
        tp.TripName AS "Trip",

        tp.StopCode AS "Stop Code",
        tp.StopName AS "Stop Name",

        pp.IsTimePoint AS "Is Time Point",

        CAST(tp.ScheduleArriveTime AS TIME) AS "Scheduled Arrive Time",
        CAST(tp.ScheduleDepartTime AS TIME) AS "Scheduled Depart Time",

        DATEDIFF(second, tp.ScheduleArriveTime, tp.ActualArriveTime) AS "Arrive Delta Seconds",
        DATEDIFF(second, tp.ScheduleDepartTime, tp.ActualDepartTime) AS "Depart Delta Seconds"

    FROM VehicleLocationTP tp

    INNER JOIN DateDimension dd
        ON tp.ActualArriveDateKey = dd.DateDimensionKey

    INNER JOIN sch_Direction d
        ON tp.DirectionKey = d.DirectionKey

    INNER JOIN sch_PatternPoint pp
        ON tp.PatternPointKey = pp.PatternPointKey

    WHERE
        dd.FullDate >= CAST('2026-01-01' AS DATETIME)
        AND dd.FullDate < CAST('2027-01-01' AS DATETIME)

        AND tp.RouteShortName IN (
            '1','10','123','123s','170','2','20','225','240','25','26','26s','27',
            '3','40','41','42','47','48','50','64','65','67','68'
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
    x."Day of Week",
    x."Route Short Name",
    x."Direction",
    x."Trip",
    x."Stop Code",
    x."Stop Name",
    x."Is Time Point",
    x."Scheduled Arrive Time",
    x."Scheduled Depart Time"
