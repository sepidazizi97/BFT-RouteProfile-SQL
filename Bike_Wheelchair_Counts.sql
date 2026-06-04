SELECT
    dd.Month AS "Month Number",
    dd.MonthName AS "Month",
    dd.DayName AS "Day of Week",

    r.RouteShortName AS "Route Short Name",
    r.RouteName AS "Route Name",
    d.DirectionName AS "Direction",
    tp.TripName AS "Trip",

    tp.StopCode AS "Stop Code",
    tp.StopName AS "Stop Name",

    SUM(CASE WHEN vf.FareTypeKey = 11 THEN vf.FareCount ELSE 0 END) AS "Bike Count",
    SUM(ISNULL(tp.WheelchairCycleCount, 0)) AS "Wheelchair Count",

    SUM(CASE WHEN vf.FareTypeKey = 11 THEN vf.FareCount ELSE 0 END)
    + SUM(ISNULL(tp.WheelchairCycleCount, 0)) AS "Total Bike and Wheelchair Count"

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

    AND r.RouteShortName IN (
        '1','10','123','123s','170','2','20','225','240',
        '25','26','26s','27','3','40','41','42',
        '47','48','50','64','65','67','68'
    )

    AND d.DirectionName IN ('E','W','N','S')

GROUP BY
    dd.Month,
    dd.MonthName,
    dd.DayName,
    r.RouteShortName,
    r.RouteName,
    d.DirectionName,
    tp.TripName,
    tp.StopCode,
    tp.StopName

HAVING
    SUM(CASE WHEN vf.FareTypeKey = 11 THEN vf.FareCount ELSE 0 END)
    + SUM(ISNULL(tp.WheelchairCycleCount, 0)) > 0
