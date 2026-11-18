SELECT
    otp."Season Year",
    otp."Season Number",
    otp."Season",
    otp."Service Day Category",
    otp."Route Short Name",
    otp."Route Name",
    otp."Direction",
    otp."Trip",

    ISNULL(
        fare."Average Daily Boardings",
        0
    ) AS "Average Daily Boardings",

    ISNULL(
        fare."Total Fare Counts",
        0
    ) AS "Total Fare Counts",

    ISNULL(
        fare."Observed Service Days",
        0
    ) AS "Observed Service Days",

    ISNULL(
        fare."Days With Fare Records",
        0
    ) AS "Days With Fare Records",

    ISNULL(
        fare."Zero Boarding Days",
        0
    ) AS "Zero Boarding Days",

    load."Median Passenger Load",

    ------------------------------------------------------------
    -- ARRIVAL ON-TIME PERFORMANCE
    ------------------------------------------------------------

    otp."On Time Arrivals",

    ROUND(
        100.0 * otp."On Time Arrivals"
        /
        NULLIF(
            otp."Total Arrival Events",
            0
        ),
        1
    ) AS "% Arrival On Time",

    otp."Early Arrivals",

    ROUND(
        100.0 * otp."Early Arrivals"
        /
        NULLIF(
            otp."Total Arrival Events",
            0
        ),
        1
    ) AS "% Arrival Early",

    otp."Late Arrivals",

    ROUND(
        100.0 * otp."Late Arrivals"
        /
        NULLIF(
            otp."Total Arrival Events",
            0
        ),
        1
    ) AS "% Arrival Late",

    otp."Total Arrival Events",

    ------------------------------------------------------------
    -- DEPARTURE ON-TIME PERFORMANCE
    ------------------------------------------------------------

    otp."On Time Departures",

    ROUND(
        100.0 * otp."On Time Departures"
        /
        NULLIF(
            otp."Total Departure Events",
            0
        ),
        1
    ) AS "% Departure On Time",

    otp."Early Departures",

    ROUND(
        100.0 * otp."Early Departures"
        /
        NULLIF(
            otp."Total Departure Events",
            0
        ),
        1
    ) AS "% Departure Early",

    otp."Late Departures",

    ROUND(
        100.0 * otp."Late Departures"
        /
        NULLIF(
            otp."Total Departure Events",
            0
        ),
        1
    ) AS "% Departure Late",

    otp."Total Departure Events"


FROM (

    ------------------------------------------------------------
    -- OTP DATA
    -- IMPORTANT:
    -- Does NOT require TotalCount / APC passenger-load data
    ------------------------------------------------------------

    SELECT
        x."Season Year",
        x."Season Number",
        x."Season",
        x."Service Day Category",
        x."Route Short Name",
        x."Route Name",
        x."Direction",
        x."Trip",

        --------------------------------------------------------
        -- Arrival OTP
        --------------------------------------------------------

        SUM(
            CASE
                WHEN x."Arrive Delta Seconds"
                     BETWEEN -60 AND 300
                THEN 1
                ELSE 0
            END
        ) AS "On Time Arrivals",

        SUM(
            CASE
                WHEN x."Arrive Delta Seconds" < -60
                THEN 1
                ELSE 0
            END
        ) AS "Early Arrivals",

        SUM(
            CASE
                WHEN x."Arrive Delta Seconds" > 300
                THEN 1
                ELSE 0
            END
        ) AS "Late Arrivals",

        COUNT(
            x."Arrive Delta Seconds"
        ) AS "Total Arrival Events",

        --------------------------------------------------------
        -- Departure OTP
        --------------------------------------------------------

        SUM(
            CASE
                WHEN x."Depart Delta Seconds"
                     BETWEEN -60 AND 300
                THEN 1
                ELSE 0
            END
        ) AS "On Time Departures",

        SUM(
            CASE
                WHEN x."Depart Delta Seconds" < -60
                THEN 1
                ELSE 0
            END
        ) AS "Early Departures",

        SUM(
            CASE
                WHEN x."Depart Delta Seconds" > 300
                THEN 1
                ELSE 0
            END
        ) AS "Late Departures",

        COUNT(
            x."Depart Delta Seconds"
        ) AS "Total Departure Events"

    FROM (

        SELECT

            ----------------------------------------------------
            -- Season Year
            ----------------------------------------------------

            CASE
                WHEN dd.Month = 12
                THEN dd.Year + 1
                ELSE dd.Year
            END AS "Season Year",

            ----------------------------------------------------
            -- Season Number
            ----------------------------------------------------

            CASE
                WHEN dd.Month IN (12,1,2)
                THEN 1

                WHEN dd.Month IN (3,4,5)
                THEN 2

                WHEN dd.Month IN (6,7,8)
                THEN 3

                WHEN dd.Month IN (9,10,11)
                THEN 4
            END AS "Season Number",

            ----------------------------------------------------
            -- Season
            ----------------------------------------------------

            CASE
                WHEN dd.Month IN (12,1,2)
                THEN 'Winter'

                WHEN dd.Month IN (3,4,5)
                THEN 'Spring'

                WHEN dd.Month IN (6,7,8)
                THEN 'Summer'

                WHEN dd.Month IN (9,10,11)
                THEN 'Fall'
            END AS "Season",

            ----------------------------------------------------
            -- Service Day
            ----------------------------------------------------

            CASE
                WHEN dd.DayName IN (
                    'Monday',
                    'Tuesday',
                    'Wednesday',
                    'Thursday',
                    'Friday'
                )
                THEN 'Weekday'

                WHEN dd.DayName = 'Saturday'
                THEN 'Saturday'

                WHEN dd.DayName = 'Sunday'
                THEN 'Sunday'
            END AS "Service Day Category",

            r.RouteShortName
                AS "Route Short Name",

            r.RouteName
                AS "Route Name",

            d.DirectionName
                AS "Direction",

            tp.TripName
                AS "Trip",

            ----------------------------------------------------
            -- Arrival Delta
            ----------------------------------------------------

            CASE
                WHEN tp.ActualArriveTime IS NOT NULL
                 AND tp.ScheduleArriveTime IS NOT NULL

                THEN DATEDIFF(
                    SECOND,
                    tp.ScheduleArriveTime,
                    tp.ActualArriveTime
                )
            END AS "Arrive Delta Seconds",

            ----------------------------------------------------
            -- Departure Delta
            ----------------------------------------------------

            CASE
                WHEN tp.ActualDepartTime IS NOT NULL
                 AND tp.ScheduleDepartTime IS NOT NULL

                THEN DATEDIFF(
                    SECOND,
                    tp.ScheduleDepartTime,
                    tp.ActualDepartTime
                )
            END AS "Depart Delta Seconds"

        FROM VehicleLocationTP tp

        INNER JOIN DateDimension dd
            ON tp.ActualArriveDateKey =
               dd.DateDimensionKey

        INNER JOIN sch_Route r
            ON tp.RouteKey =
               r.RouteKey

        INNER JOIN sch_Pattern p
            ON tp.PatternKey =
               p.PatternKey

        INNER JOIN sch_Direction d
            ON p.DirectionKey =
               d.DirectionKey

        WHERE
            dd.FullDate >= CAST(
                '2025-12-01' AS DATETIME
            )

            AND dd.FullDate < CAST(
                '2027-01-01' AS DATETIME
            )

            AND r.RouteShortName IN (
                '1','10','123','123s','170',
                '2','20','225','240','25',
                '26','26s','27','3','40',
                '41','42','47','48','50',
                '60','61',
                '64','65','67','68'
            )

            AND tp.InBetween <> 1

            AND tp.TripName IS NOT NULL

    ) x

    GROUP BY
        x."Season Year",
        x."Season Number",
        x."Season",
        x."Service Day Category",
        x."Route Short Name",
        x."Route Name",
        x."Direction",
        x."Trip"

) otp


------------------------------------------------------------
-- PASSENGER LOAD
------------------------------------------------------------

LEFT JOIN (

    SELECT
        y."Season Year",
        y."Season Number",
        y."Season",
        y."Service Day Category",
        y."Route Short Name",
        y."Route Name",
        y."Direction",
        y."Trip",

        MAX(
            y."Median Passenger Load"
        ) AS "Median Passenger Load"

    FROM (

        SELECT
            x.*,

            PERCENTILE_CONT(0.5)
            WITHIN GROUP (
                ORDER BY x."Passenger Load"
            )
            OVER (
                PARTITION BY
                    x."Season Year",
                    x."Season Number",
                    x."Season",
                    x."Service Day Category",
                    x."Route Short Name",
                    x."Route Name",
                    x."Direction",
                    x."Trip"
            ) AS "Median Passenger Load"

        FROM (

            SELECT

                CASE
                    WHEN dd.Month = 12
                    THEN dd.Year + 1
                    ELSE dd.Year
                END AS "Season Year",

                CASE
                    WHEN dd.Month IN (12,1,2)
                    THEN 1

                    WHEN dd.Month IN (3,4,5)
                    THEN 2

                    WHEN dd.Month IN (6,7,8)
                    THEN 3

                    WHEN dd.Month IN (9,10,11)
                    THEN 4
                END AS "Season Number",

                CASE
                    WHEN dd.Month IN (12,1,2)
                    THEN 'Winter'

                    WHEN dd.Month IN (3,4,5)
                    THEN 'Spring'

                    WHEN dd.Month IN (6,7,8)
                    THEN 'Summer'

                    WHEN dd.Month IN (9,10,11)
                    THEN 'Fall'
                END AS "Season",

                CASE
                    WHEN dd.DayName IN (
                        'Monday',
                        'Tuesday',
                        'Wednesday',
                        'Thursday',
                        'Friday'
                    )
                    THEN 'Weekday'

                    WHEN dd.DayName = 'Saturday'
                    THEN 'Saturday'

                    WHEN dd.DayName = 'Sunday'
                    THEN 'Sunday'
                END AS "Service Day Category",

                r.RouteShortName
                    AS "Route Short Name",

                r.RouteName
                    AS "Route Name",

                d.DirectionName
                    AS "Direction",

                tp.TripName
                    AS "Trip",

                tp.TotalCount
                    AS "Passenger Load"

            FROM VehicleLocationTP tp

            INNER JOIN DateDimension dd
                ON tp.ActualArriveDateKey =
                   dd.DateDimensionKey

            INNER JOIN sch_Route r
                ON tp.RouteKey =
                   r.RouteKey

            INNER JOIN sch_Pattern p
                ON tp.PatternKey =
                   p.PatternKey

            INNER JOIN sch_Direction d
                ON p.DirectionKey =
                   d.DirectionKey

            WHERE
                dd.FullDate >= CAST(
                    '2025-12-01' AS DATETIME
                )

                AND dd.FullDate < CAST(
                    '2027-01-01' AS DATETIME
                )

                AND r.RouteShortName IN (
                    '1','10','123','123s','170',
                    '2','20','225','240','25',
                    '26','26s','27','3','40',
                    '41','42','47','48','50',
                    '60','61',
                    '64','65','67','68'
                )

                ------------------------------------------------
                -- APC restriction applies ONLY here
                ------------------------------------------------

                AND tp.TotalCount IS NOT NULL

                AND tp.TripName IS NOT NULL

                AND tp.InBetween <> 1

        ) x

    ) y

    GROUP BY
        y."Season Year",
        y."Season Number",
        y."Season",
        y."Service Day Category",
        y."Route Short Name",
        y."Route Name",
        y."Direction",
        y."Trip"

) load

    ON otp."Season Year" =
       load."Season Year"

    AND otp."Season Number" =
        load."Season Number"

    AND otp."Season" =
        load."Season"

    AND otp."Service Day Category" =
        load."Service Day Category"

    AND otp."Route Short Name" =
        load."Route Short Name"

    AND otp."Direction" =
        load."Direction"

    AND otp."Trip" =
        load."Trip"


------------------------------------------------------------
-- FARE DATA
------------------------------------------------------------

LEFT JOIN (

    SELECT
        fare_daily."Season Year",
        fare_daily."Season Number",
        fare_daily."Season",
        fare_daily."Service Day Category",
        fare_daily."Route Short Name",
        fare_daily."Route Name",
        fare_daily."Direction",
        fare_daily."Trip",

        --------------------------------------------------------
        -- Average daily boardings
        --------------------------------------------------------

        ROUND(
            CAST(
                SUM(
                    fare_daily."Daily Fare Counts"
                )
                AS DECIMAL(18,2)
            )
            /
            NULLIF(
                MAX(
                    service_days."Observed Service Days"
                ),
                0
            ),
            1
        ) AS "Average Daily Boardings",

        --------------------------------------------------------
        -- Total fare
        --------------------------------------------------------

        SUM(
            fare_daily."Daily Fare Counts"
        ) AS "Total Fare Counts",

        MAX(
            service_days."Observed Service Days"
        ) AS "Observed Service Days",

        COUNT(*)
            AS "Days With Fare Records",

        CASE
            WHEN
                MAX(
                    service_days."Observed Service Days"
                ) - COUNT(*) < 0
            THEN 0

            ELSE
                MAX(
                    service_days."Observed Service Days"
                ) - COUNT(*)
        END AS "Zero Boarding Days"

    FROM (

        --------------------------------------------------------
        -- DAILY FARE COUNTS
        --------------------------------------------------------

        SELECT

            CASE
                WHEN dd.Month = 12
                THEN dd.Year + 1
                ELSE dd.Year
            END AS "Season Year",

            CASE
                WHEN dd.Month IN (12,1,2)
                THEN 1

                WHEN dd.Month IN (3,4,5)
                THEN 2

                WHEN dd.Month IN (6,7,8)
                THEN 3

                WHEN dd.Month IN (9,10,11)
                THEN 4
            END AS "Season Number",

            CASE
                WHEN dd.Month IN (12,1,2)
                THEN 'Winter'

                WHEN dd.Month IN (3,4,5)
                THEN 'Spring'

                WHEN dd.Month IN (6,7,8)
                THEN 'Summer'

                WHEN dd.Month IN (9,10,11)
                THEN 'Fall'
            END AS "Season",

            CAST(
                dd.FullDate AS DATE
            ) AS "Service Date",

            CASE
                WHEN dd.DayName IN (
                    'Monday',
                    'Tuesday',
                    'Wednesday',
                    'Thursday',
                    'Friday'
                )
                THEN 'Weekday'

                WHEN dd.DayName = 'Saturday'
                THEN 'Saturday'

                WHEN dd.DayName = 'Sunday'
                THEN 'Sunday'
            END AS "Service Day Category",

            r.RouteShortName
                AS "Route Short Name",

            r.RouteName
                AS "Route Name",

            d.DirectionName
                AS "Direction",

            tp.TripName
                AS "Trip",

            SUM(
                vf.FareCount
            ) AS "Daily Fare Counts"

        FROM DateDimension dd

        INNER JOIN VehicleLocationTPFare vf
            ON dd.DateDimensionKey =
               vf.EventDateKey

        INNER JOIN sch_WorkItemCompleted wic
            ON wic.WorkItemCompletedKey =
               vf.WorkItemCompletedKey

        INNER JOIN VehicleLocationTP tp
            ON tp.VehicleLocationTPKey =
               vf.VehicleLocationTPKey

        INNER JOIN sch_Route r
            ON r.RouteKey =
               wic.RouteKey

        INNER JOIN sch_Pattern p
            ON p.PatternKey =
               tp.PatternKey

        INNER JOIN sch_Direction d
            ON d.DirectionKey =
               p.DirectionKey

        WHERE
            dd.FullDate >= CAST(
                '2025-12-01' AS DATETIME
            )

            AND dd.FullDate < CAST(
                '2027-01-01' AS DATETIME
            )

            AND vf.FareTypeKey NOT IN (
                9,11,14,20
            )

            AND r.RouteShortName IN (
                '1','10','123','123s','170',
                '2','20','225','240','25',
                '26','26s','27','3','40',
                '41','42','47','48','50',
                '60','61',
                '64','65','67','68'
            )

            AND vf.FareCount IS NOT NULL

            AND tp.TripName IS NOT NULL

        GROUP BY

            CASE
                WHEN dd.Month = 12
                THEN dd.Year + 1
                ELSE dd.Year
            END,

            CASE
                WHEN dd.Month IN (12,1,2)
                THEN 1

                WHEN dd.Month IN (3,4,5)
                THEN 2

                WHEN dd.Month IN (6,7,8)
                THEN 3

                WHEN dd.Month IN (9,10,11)
                THEN 4
            END,

            CASE
                WHEN dd.Month IN (12,1,2)
                THEN 'Winter'

                WHEN dd.Month IN (3,4,5)
                THEN 'Spring'

                WHEN dd.Month IN (6,7,8)
                THEN 'Summer'

                WHEN dd.Month IN (9,10,11)
                THEN 'Fall'
            END,

            CAST(
                dd.FullDate AS DATE
            ),

            CASE
                WHEN dd.DayName IN (
                    'Monday',
                    'Tuesday',
                    'Wednesday',
                    'Thursday',
                    'Friday'
                )
                THEN 'Weekday'

                WHEN dd.DayName = 'Saturday'
                THEN 'Saturday'

                WHEN dd.DayName = 'Sunday'
                THEN 'Sunday'
            END,

            r.RouteShortName,
            r.RouteName,
            d.DirectionName,
            tp.TripName

    ) fare_daily


    ------------------------------------------------------------
    -- SERVICE DAYS
    ------------------------------------------------------------

    LEFT JOIN (

        SELECT

            CASE
                WHEN dd_service.Month = 12
                THEN dd_service.Year + 1
                ELSE dd_service.Year
            END AS "Season Year",

            CASE
                WHEN dd_service.Month IN (12,1,2)
                THEN 1

                WHEN dd_service.Month IN (3,4,5)
                THEN 2

                WHEN dd_service.Month IN (6,7,8)
                THEN 3

                WHEN dd_service.Month IN (9,10,11)
                THEN 4
            END AS "Season Number",

            CASE
                WHEN dd_service.Month IN (12,1,2)
                THEN 'Winter'

                WHEN dd_service.Month IN (3,4,5)
                THEN 'Spring'

                WHEN dd_service.Month IN (6,7,8)
                THEN 'Summer'

                WHEN dd_service.Month IN (9,10,11)
                THEN 'Fall'
            END AS "Season",

            CASE
                WHEN dd_service.DayName IN (
                    'Monday',
                    'Tuesday',
                    'Wednesday',
                    'Thursday',
                    'Friday'
                )
                THEN 'Weekday'

                WHEN dd_service.DayName = 'Saturday'
                THEN 'Saturday'

                WHEN dd_service.DayName = 'Sunday'
                THEN 'Sunday'
            END AS "Service Day Category",

            r_service.RouteShortName
                AS "Route Short Name",

            r_service.RouteName
                AS "Route Name",

            d_service.DirectionName
                AS "Direction",

            tp_service.TripName
                AS "Trip",

            COUNT(
                DISTINCT CAST(
                    dd_service.FullDate AS DATE
                )
            ) AS "Observed Service Days"

        FROM VehicleLocationTP tp_service

        INNER JOIN DateDimension dd_service
            ON tp_service.ActualArriveDateKey =
               dd_service.DateDimensionKey

        INNER JOIN sch_Route r_service
            ON tp_service.RouteKey =
               r_service.RouteKey

        INNER JOIN sch_Pattern p_service
            ON tp_service.PatternKey =
               p_service.PatternKey

        INNER JOIN sch_Direction d_service
            ON p_service.DirectionKey =
               d_service.DirectionKey

        WHERE
            dd_service.FullDate >= CAST(
                '2025-12-01' AS DATETIME
            )

            AND dd_service.FullDate < CAST(
                '2027-01-01' AS DATETIME
            )

            AND r_service.RouteShortName IN (
                '1','10','123','123s','170',
                '2','20','225','240','25',
                '26','26s','27','3','40',
                '41','42','47','48','50',
                '60','61',
                '64','65','67','68'
            )

            AND tp_service.TripName IS NOT NULL

            AND tp_service.ActualArriveTime
                IS NOT NULL

            AND tp_service.InBetween <> 1

        GROUP BY

            CASE
                WHEN dd_service.Month = 12
                THEN dd_service.Year + 1
                ELSE dd_service.Year
            END,

            CASE
                WHEN dd_service.Month IN (12,1,2)
                THEN 1

                WHEN dd_service.Month IN (3,4,5)
                THEN 2

                WHEN dd_service.Month IN (6,7,8)
                THEN 3

                WHEN dd_service.Month IN (9,10,11)
                THEN 4
            END,

            CASE
                WHEN dd_service.Month IN (12,1,2)
                THEN 'Winter'

                WHEN dd_service.Month IN (3,4,5)
                THEN 'Spring'

                WHEN dd_service.Month IN (6,7,8)
                THEN 'Summer'

                WHEN dd_service.Month IN (9,10,11)
                THEN 'Fall'
            END,

            CASE
                WHEN dd_service.DayName IN (
                    'Monday',
                    'Tuesday',
                    'Wednesday',
                    'Thursday',
                    'Friday'
                )
                THEN 'Weekday'

                WHEN dd_service.DayName = 'Saturday'
                THEN 'Saturday'

                WHEN dd_service.DayName = 'Sunday'
                THEN 'Sunday'
            END,

            r_service.RouteShortName,
            r_service.RouteName,
            d_service.DirectionName,
            tp_service.TripName

    ) service_days

        ON fare_daily."Season Year" =
           service_days."Season Year"

        AND fare_daily."Season Number" =
            service_days."Season Number"

        AND fare_daily."Season" =
            service_days."Season"

        AND fare_daily."Service Day Category" =
            service_days."Service Day Category"

        AND fare_daily."Route Short Name" =
            service_days."Route Short Name"

        AND fare_daily."Direction" =
            service_days."Direction"

        AND fare_daily."Trip" =
            service_days."Trip"

    GROUP BY
        fare_daily."Season Year",
        fare_daily."Season Number",
        fare_daily."Season",
        fare_daily."Service Day Category",
        fare_daily."Route Short Name",
        fare_daily."Route Name",
        fare_daily."Direction",
        fare_daily."Trip"

) fare

    ON otp."Season Year" =
       fare."Season Year"

    AND otp."Season Number" =
        fare."Season Number"

    AND otp."Season" =
        fare."Season"

    AND otp."Service Day Category" =
        fare."Service Day Category"

    AND otp."Route Short Name" =
        fare."Route Short Name"

    AND otp."Direction" =
        fare."Direction"

    AND otp."Trip" =
        fare."Trip"
