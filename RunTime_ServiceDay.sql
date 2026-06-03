SELECT
    y."Month Number",
    y."Month Name",
    y."Day of Week",
    y."Route Short Name",
    y."Route Name",
    y."Direction",
    y."Trip Name",
    y."Scheduled Trip Start Time",
    y."Scheduled Trip End Time",
    y."Scheduled Runtime (Min)",

    AVG(y."Actual Runtime (Min)") AS "Average Actual Runtime (Min)",
    MAX(y."Median Actual Runtime (Min)") AS "Median Actual Runtime (Min)",
    MAX(y."Actual Runtime (Min)") AS "Maximum Actual Runtime (Min)",

    AVG(y."Runtime Delta (Min)") AS "Average Runtime Delta (Min)",
    MAX(y."Runtime Delta (Min)") AS "Maximum Runtime Delta (Min)",

    COUNT(*) AS "Observation Count"

FROM (
    SELECT
        x.*,

        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY x."Actual Runtime (Min)")
        OVER (
            PARTITION BY
                x."Month Number",
                x."Month Name",
                x."Day of Week",
                x."Route Short Name",
                x."Route Name",
                x."Direction",
                x."Trip Name",
                x."Scheduled Trip Start Time",
                x."Scheduled Trip End Time",
                x."Scheduled Runtime (Min)"
        ) AS "Median Actual Runtime (Min)"

    FROM (
        SELECT
            dd.Month AS "Month Number",
            dd.MonthName AS "Month Name",
            dd.DayName AS "Day of Week",

            r.RouteShortName AS "Route Short Name",
            r.RouteName AS "Route Name",
            d.DirectionName AS "Direction",

            wi.TripName AS "Trip Name",

            CAST(wi.StartDate AS TIME) AS "Scheduled Trip Start Time",
            CAST(wi.EndDate AS TIME) AS "Scheduled Trip End Time",

            DATEDIFF(mi, wi.StartDate, wi.EndDate) AS "Scheduled Runtime (Min)",
            DATEDIFF(mi, wic.StartDate, wic.EndDate) AS "Actual Runtime (Min)",

            DATEDIFF(mi, wic.StartDate, wic.EndDate)
            - DATEDIFF(mi, wi.StartDate, wi.EndDate) AS "Runtime Delta (Min)"

        FROM DateDimension dd

        INNER JOIN sch_WorkItem wi
            ON wi.ScheduledDateKey = dd.DateDimensionKey

        LEFT JOIN sch_WorkItemCompleted wic
            ON wic.WorkItemKey = wi.WorkItemKey

        LEFT JOIN sch_Route r
            ON r.RouteKey = wi.RouteKey

        LEFT JOIN sch_Block b
            ON b.BlockKey = wi.BlockKey

        LEFT JOIN sch_Pattern pa
            ON pa.PatternKey = wic.PatternKey

        LEFT JOIN sch_Direction d
            ON d.DirectionKey = pa.DirectionKey

        LEFT JOIN BlockItemType blit
            ON blit.BlockItemTypeKey = wi.BlockItemTypeKey

        WHERE
            dd.FullDate >= CAST('2026-01-01' AS DATETIME)
            AND dd.FullDate < CAST('2027-01-01' AS DATETIME)

            AND blit.BlockItemTypeCode = 2

            AND r.RouteShortName IN (
                '1','10','123','123s','170','2','20','225','240',
                '25','26','26s','27','3','40','41','42',
                '47','48','50','64','65','67','68'
            )

            AND d.DirectionName IN ('E','W','N','S')

            AND wic.StartDate IS NOT NULL
            AND wic.EndDate IS NOT NULL
            AND wi.StartDate IS NOT NULL
            AND wi.EndDate IS NOT NULL

            AND DATEDIFF(mi, wic.StartDate, wic.EndDate) > 5

            AND DATEDIFF(mi, wic.StartDate, wic.EndDate)
                > (DATEDIFF(mi, wi.StartDate, wi.EndDate) * .5)

    ) x
) y

GROUP BY
    y."Month Number",
    y."Month Name",
    y."Day of Week",
    y."Route Short Name",
    y."Route Name",
    y."Direction",
    y."Trip Name",
    y."Scheduled Trip Start Time",
    y."Scheduled Trip End Time",
    y."Scheduled Runtime (Min)"
