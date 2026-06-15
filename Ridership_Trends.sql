SELECT
    apc."Year",
    apc."Month Number",
    apc."Month",
    apc."Year-Month",

    apc."Route Short Name",
    apc."Route Name",

    apc."APC Ridership",
    ISNULL(fare."Fare Count Ridership", 0) AS "Fare Count Ridership",

    apc."APC Ridership" - ISNULL(fare."Fare Count Ridership", 0)
        AS "Difference APC Minus Fare",

    CASE
        WHEN apc."APC Ridership" = 0 THEN NULL
        ELSE ROUND(
            100.0 * ISNULL(fare."Fare Count Ridership", 0) / apc."APC Ridership",
            1
        )
    END AS "Fare Count as % of APC"

FROM (
    SELECT
        CAST(dd.Year AS VARCHAR(4)) AS "Year",
        dd.Month AS "Month Number",
        dd.MonthName AS "Month",
        CAST(dd.Year AS VARCHAR(4)) + '-' + RIGHT('0' + CAST(dd.Month AS VARCHAR(2)), 2) AS "Year-Month",

        r.RouteShortName AS "Route Short Name",
        r.RouteName AS "Route Name",

        SUM(tp.BoardCount) AS "APC Ridership"

    FROM VehicleLocationTP tp

    INNER JOIN DateDimension dd
        ON tp.ActualArriveDateKey = dd.DateDimensionKey

    INNER JOIN sch_Route r
        ON tp.RouteKey = r.RouteKey

    WHERE
        dd.FullDate >= CAST('2023-01-01' AS DATETIME)
        AND dd.FullDate < DATEADD(day, 1, CAST(GETDATE() AS DATE))

        AND tp.BoardCount IS NOT NULL

        AND r.RouteShortName IN (
            '1','10','123','123s','170','2','20','225','240',
            '25','26','26s','27','3','40','41','42',
            '47','48','50','64','65','67','68'
        )

    GROUP BY
        CAST(dd.Year AS VARCHAR(4)),
        dd.Month,
        dd.MonthName,
        CAST(dd.Year AS VARCHAR(4)) + '-' + RIGHT('0' + CAST(dd.Month AS VARCHAR(2)), 2),
        r.RouteShortName,
        r.RouteName
) apc

LEFT JOIN (
    SELECT
        CAST(dd.Year AS VARCHAR(4)) AS "Year",
        dd.Month AS "Month Number",
        dd.MonthName AS "Month",
        CAST(dd.Year AS VARCHAR(4)) + '-' + RIGHT('0' + CAST(dd.Month AS VARCHAR(2)), 2) AS "Year-Month",

        r.RouteShortName AS "Route Short Name",
        r.RouteName AS "Route Name",

        SUM(vf.FareCount) AS "Fare Count Ridership"

    FROM VehicleLocationTPFare vf

    INNER JOIN DateDimension dd
        ON dd.DateDimensionKey = vf.EventDateKey

    INNER JOIN sch_WorkItemCompleted wic
        ON wic.WorkItemCompletedKey = vf.WorkItemCompletedKey

    INNER JOIN sch_Route r
        ON r.RouteKey = wic.RouteKey

    WHERE
        dd.FullDate >= CAST('2023-01-01' AS DATETIME)
        AND dd.FullDate < DATEADD(day, 1, CAST(GETDATE() AS DATE))

        AND vf.FareTypeKey NOT IN (9,11,14,20)

        AND vf.FareCount IS NOT NULL

        AND r.RouteShortName IN (
            '1','10','123','123s','170','2','20','225','240',
            '25','26','26s','27','3','40','41','42',
            '47','48','50','64','65','67','68'
        )

    GROUP BY
        CAST(dd.Year AS VARCHAR(4)),
        dd.Month,
        dd.MonthName,
        CAST(dd.Year AS VARCHAR(4)) + '-' + RIGHT('0' + CAST(dd.Month AS VARCHAR(2)), 2),
        r.RouteShortName,
        r.RouteName
) fare

ON apc."Year-Month" = fare."Year-Month"
AND apc."Route Short Name" = fare."Route Short Name"
