SELECT DISTINCT TOP 20 
   "New View"."Month" AS C2,
   "New View"."Route Short Name" AS C4,
   "New View"."Direction" AS C6,
   "New View"."Revenue Hours" AS C8
FROM (
   SELECT
    dd.Month AS "Month Number",
    dd.MonthName AS "Month",

    r.RouteShortName AS "Route Short Name",
    r.RouteName AS "Route Name",

    d.DirectionName AS "Direction",

    SUM(
        DATEDIFF(mi, wic.StartDate, wic.EndDate)
    ) / 60.0 AS "Revenue Hours",

    COUNT(*) AS "Trip Count"

FROM DateDimension dd

INNER JOIN sch_WorkItem wi
    ON wi.ScheduledDateKey = dd.DateDimensionKey

INNER JOIN sch_WorkItemCompleted wic
    ON wic.WorkItemKey = wi.WorkItemKey

INNER JOIN sch_Route r
    ON r.RouteKey = wi.RouteKey

LEFT JOIN sch_Pattern pa
    ON pa.PatternKey = wic.PatternKey

LEFT JOIN sch_Direction d
    ON d.DirectionKey = pa.DirectionKey

INNER JOIN BlockItemType blit
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


    AND wic.StartDate IS NOT NULL
    AND wic.EndDate IS NOT NULL

GROUP BY
    dd.Month,
    dd.MonthName,
    r.RouteShortName,
    r.RouteName,
    d.DirectionName

) AS "New View"
