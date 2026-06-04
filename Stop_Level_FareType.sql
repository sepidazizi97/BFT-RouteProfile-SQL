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

    SUM(CASE WHEN ft.FareTypeKey = 7 THEN vf.FareCount ELSE 0 END) AS "CBC",
    SUM(CASE WHEN ft.FareTypeKey IN (1,13,23,24,25) THEN vf.FareCount ELSE 0 END) AS "REG",
    SUM(CASE WHEN ft.FareTypeKey IN (2,19) THEN vf.FareCount ELSE 0 END) AS "TRL",
    SUM(CASE WHEN ft.FareTypeKey IN (3,16,15) THEN vf.FareCount ELSE 0 END) AS "RED",
    SUM(CASE WHEN ft.FareTypeKey = 4 THEN vf.FareCount ELSE 0 END) AS "SNR",
    SUM(CASE WHEN ft.FareTypeKey = 17 THEN vf.FareCount ELSE 0 END) AS "SPE",
    SUM(CASE WHEN ft.FareTypeKey IN (6,8,18) THEN vf.FareCount ELSE 0 END) AS "PSL",
    SUM(CASE WHEN ft.FareTypeKey IN (10,12) THEN vf.FareCount ELSE 0 END) AS "YTF",
    SUM(CASE WHEN ft.FareTypeKey = 5 THEN vf.FareCount ELSE 0 END) AS "TRN",
    SUM(CASE WHEN ft.FareTypeKey = 21 THEN vf.FareCount ELSE 0 END) AS "WSU",
    SUM(CASE WHEN ft.FareTypeKey = 22 THEN vf.FareCount ELSE 0 END) AS "VET",

    SUM(vf.FareCount) AS "Total"

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

INNER JOIN FareType ft
    ON ft.FareTypeKey = vf.FareTypeKey

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
    tp.TripName,
    tp.StopCode,
    tp.StopName
