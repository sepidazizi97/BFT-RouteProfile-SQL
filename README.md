# Streets Custom SQL Reports

A collection of custom SQL reports developed for transit planning, operations analysis, service monitoring, and performance reporting within Streets.

These reports support route-level, trip-level, stop-level, and seasonal analyses using APC, fare collection, schedule adherence, runtime, revenue service, and accessibility data.

---

## Report Categories

### Route Profiles

#### RouteProfile_Monthly.sql

Monthly route profile summarizing ridership, median passenger loads, fare counts, and on-time performance by trip.

#### RouteProfile_Seasonal.sql

Seasonal route profile using:

- Winter (Dec–Feb)
- Spring (Mar–May)
- Summer (Jun–Aug)
- Fall (Sep–Nov)

Includes:

- Total Fare Counts
- Median Passenger Load
- On-Time Performance
- Early Arrivals
- Late Arrivals

---

### APC Reports

#### Route Level

**Route_Level_APC.sql**

Route-level APC summary including:

- Boardings
- Alightings
- Median Passenger Load
- Maximum Passenger Load

#### Trip Level

**Trip_Level_APC.sql**

Trip-level APC performance metrics by route and direction.

#### Stop Level

**Stop_Level_APC.sql**

Stop-level APC activity including boardings, alightings, and passenger loads.

---

### APC vs Fare Validation

These reports compare APC boarding counts against fare collection records.

#### Trip Level

**Trip_Level_APC_vs_FareCounts.sql**

Includes:

- APC Boards
- Total Fare Counts
- APC − Fare Difference
- Fare Count as Percentage of APC Boards

#### Stop Level

**Stop_Level_APC_vs_FareCounts.sql**

Same comparison performed at the individual stop level.

---

### Fare Type Reports

#### Trip Level

**Trip_Level_FareType.sql**

Fare counts by fare category including:

- Regular Fare
- Transfer
- Reduced Fare
- Senior Free
- Youth Free
- Veteran
- CBC
- WSU
- Day Pass
- Freedom Pass
- Special Event Free

#### Stop Level

**Stop_Level_FareType.sql**

Fare type usage summarized at the stop level.

---

### On-Time Performance (OTP)

#### Trip Level

**Trip_Level_OTP.sql**

Trip-level schedule adherence and arrival performance.

#### Stop Level

**Stop_Level_OTP.sql**

Stop-level arrival adherence analysis.

#### Service Day

**ServiceDay_OTP.sql**

OTP summarized by:

- Weekday
- Saturday
- Sunday

---

### Runtime Analysis

#### RunTime_ServiceDay.sql

Runtime performance by:

- Route
- Direction
- Service Day Type

Includes:

- Average Runtime
- Median Runtime
- Runtime Delta
- Schedule Comparison

---

### Revenue Service Reports

#### Revenue_Hour_Route.sql

Revenue hours by route and service period.

#### Revenue_Mile_Route.sql

Revenue miles by route using validated mileage records.

---

### Accessibility Reports

#### Bike_Wheelchair_Counts.sql

Stop-level and trip-level accessibility activity including:

- Bicycle boardings
- Wheelchair lift usage
- Route summaries
- Stop summaries

---

## Data Sources

Reports use data from Streets operational tables including:

- VehicleLocationTP
- VehicleLocationTPFare
- DateDimension
- sch_Route
- sch_Pattern
- sch_Direction
- sch_WorkItem
- sch_WorkItemCompleted
- FareType

---

## Purpose

These reports were developed to support:

- Transit planning
- Service evaluation
- Route performance monitoring
- Fare validation
- Accessibility analysis
- Schedule adherence monitoring
- Revenue service reporting
- Seasonal service planning

---

**Author:** Sepideh Azizi  
**Organization:** Ben Franklin Transit (BFT)  
**Platform:** Streets Reporting System
