Creating additional intervals by adding events from a second table

github
https://tinyurl.com/y9jl3j8k
https://github.com/rogerjdeangelis/utl_creating_additional_intervals_by_adding_events_from_a_second_table

  Same results in SAS and WPS

SAS Forum
https://tinyurl.com/yclhvj7o
https://communities.sas.com/t5/SAS-Procedures/Loop-through-one-table-use-data-to-manipulate-another-table/m-p/455930


INPUT
=====

Dates are actually SAS dates bit I prefer to shoe number of days since 1/1/60

WORK.FILE1 total obs=5

  NAME      BEGINDATE    ENDDATE

  Bob         17289       20653
  Carol       17690       18483
  Evan        16132       20812
  Trevor      18074       18439
  Tyler       17364       18898


WORK.HAVTWO total obs=3

  NAME      DATE

  Evan     17355
  Evan     18295
  Tyler    18028


  Use the dates in havTwo to create additional intervals in havOne

                                   |       RULES
           HAVONE TABLE            |   EXAMPLE OF WANT
                                   |
  NAME      BEGINDATE    ENDDATE   |  dteBeg    dteEnd
                                   |
  Bob         17289       20653    |   17289    20653      * Bob is not in havTwo
  Carol       17690       18483    |   17690    18483      * Carol is not in havTwo
                                   |
  Evan        16132       20812    |   16132    17355      * insert using Evan 17255 from havTwo
                                   |   17355    18295      * the end date above and 18295 from havTwo
                                   |   18295    20812      * the end date above and 20812 from **havOne**
                                   |
  Trevor      18074       18439    |   18074    18439      * Trevor is not in havTwo
                                   |
  Tyler       17364       18898    |   17364    18028      * use the between date from havTwo


PROCESS
=======

data catDat;
  set havOne(rename=begindate=date) havTwo;
  by name date;
  output;
  if endDate ne . then do; date=endDate; output; end;
  drop endDate;
run;quit;

/*  SQL should have an elegant solution using this data - too lazy
WORK.HAVONE total obs=13

Obs    NAME       DATE

  1    Bob       17289
  2    Bob       20653
  3    Carol     17690
  4    Carol     18483
  5    Evan      16132
  6    Evan      20812
  7    Evan      17355
  8    Evan      18295
  9    Trevor    18074
 10    Trevor    18439
 11    Tyler     17364
 12    Tyler     18898
 13    Tyler     18028
*/

* you may be able to simplifiy with SQL code using catDat;
proc sort data=catDat out=catDatSrt;
  by name date;
run;quit;

data want(rename=(dteLag=dteBeg date=dteEnd));
  retain name  dteLag date;
  set catDatSrt;
  dteLag=lag(date);
  if name=lag(name) then output;
run;quit;


OUTPUT
======

WORK.WANT total obs=8

Obs    NAME      DTEBEG    DTEEND

 1     Bob        17289    20653
 2     Carol      17690    18483
 3     Evan       16132    17355
 4     Evan       17355    18295
 5     Evan       18295    20812
 6     Trevor     18074    18439
 7     Tyler      17364    18028
 8     Tyler      18028    18898

*                _               _       _
 _ __ ___   __ _| | _____     __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \   / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/  | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|   \__,_|\__,_|\__\__,_|

;
data havOne;
infile datalines dsd truncover;
input Name:$13. BeginDate:mmddyy10. EndDate:mmddyy10.;
datalines4;
Bob,05/03/2007,07/18/2016
Carol,06/07/2008,08/09/2010
Evan, 03/02/2004,12/24/2016
Trevor, 06/26/2009,06/26/2010
Tyler, 07/17/2007, 09/28/2011
;;;;
run;quit;

data havTwo;
infile datalines dsd truncover;
input Name:$13. Date:mmddyy10. ;
datalines4;
Evan, 07/08/2007
Evan, 02/02/2010
Tyler, 05/11/2009
;;;;
run;quit;

*          _       _   _
 ___  ___ | |_   _| |_(_) ___  _ __
/ __|/ _ \| | | | | __| |/ _ \| '_ \
\__ \ (_) | | |_| | |_| | (_) | | | |
|___/\___/|_|\__,_|\__|_|\___/|_| |_|

;

*SAS;
data catDat;
  set havOne(rename=begindate=date) havTwo;
  by name date;
  output;
  if endDate ne . then do; date=endDate; output; end;
  drop endDate;
run;quit;

* you may be able to simplifiy with SQL code using catDat;
proc sort data=catDat out=catDatSrt;
  by name date;
run;quit;

data want(rename=(dteLag=dteBeg date=dteEnd));
  retain name  dteLag date;
  set catDatSrt;
  dteLag=lag(date);
  if name=lag(name) then output;
run;quit;


*WPS;
%utl_submit_wps64('
libname wrk sas7bdat "%sysfunc(pathname(work))";
data catDat;
  set wrk.havOne(rename=begindate=date) wrk.havTwo;
  by name date;
  output;
  if endDate ne . then do; date=endDate; output; end;
  drop endDate;
run;quit;

proc sort data=catDat out=catDatSrt;
  by name date;
run;quit;

data wrk.wantwps(rename=(dteLag=dteBeg date=dteEnd));
  retain name  dteLag date;
  set catDatSrt;
  dteLag=lag(date);
  if name=lag(name) then output;
run;quit;
');


