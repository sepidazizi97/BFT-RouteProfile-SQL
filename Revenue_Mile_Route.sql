SELECT
    dd.Year AS "Year",

    r.RouteShortName AS "Route Short Name",

    r.RouteName AS "Route Name",

    d.DirectionName AS "Direction",

    ROUND(
        SUM(wic.OdometerEnd - wic.OdometerStart),
        2
    ) AS "Annual Revenue Miles",

    COUNT(*) AS "Trip Count"

FROM DateDimension dd

INNER JOIN sch_WorkItem wi
    ON wi.ScheduledDateKey = dd.DateDimensionKey

INNER JOIN sch_WorkItemCompleted wic
    ON wic.WorkItemKey = wi.WorkItemKey

INNER JOIN sch_Route r
    ON r.RouteKey = wi.RouteKey

LEFT JOIN sch_Pattern pa
    ON pa.PatternKey = wi.PatternKey

LEFT JOIN sch_Direction d
    ON d.DirectionKey = pa.DirectionKey

INNER JOIN BlockItemType blit
    ON blit.BlockItemTypeKey = wi.BlockItemTypeKey

WHERE
    dd.Year = 2026

    AND blit.BlockItemTypeCode = 2

    AND r.RouteShortName IN (
        '1','10','123','123s','170',
        '2','20','225','240','25',
        '26','26s','27','3','40',
        '41','42','47','48','50',
        '60','61','64','65','67','68'
    )

    AND wic.OdometerEnd > wic.OdometerStart

GROUP BY
    dd.Year,
    r.RouteShortName,
    r.RouteName,
    d.DirectionName

ORDER BY
    r.RouteShortName,
    d.DirectionName
