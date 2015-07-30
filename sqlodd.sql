Question 1
select * from (
(select St_ID||' ' ||St_FName||' '||St_LName AS "student" 
from student 
left join loan using (St_ID)
left join computer using (Comp_ID)
left join location using (Location_ID)
where Loc_Bldg = 'NSH')
MINUS 
(select St_ID||' ' ||St_FName||' '||St_LName AS "student" 
from student 
left join loan using (St_ID)
left join computer using (Comp_ID)
left join location using (Location_ID)
where Loc_Bldg != 'NSH')
);


student
----------------------
1008 KENNETH JONES


Question 3 
/*Add HbH 001A room and two computers into that room and two loans*/
/* grand total is the total number of distinct students */
select Loc_Room, count(DISTINCT St_ID) AS "Num_Of_Student"
from student 
left join loan using (St_ID)
left join computer using (Comp_ID)
left join location using (Location_ID)
where Loc_Bldg = 'HbH' AND Start_Date<='31-DEC-2014' AND Date_Returned>='01-JAN-2014'
group by grouping sets(Loc_Room,())
;

LOC_ROOM                  Num_Of_Student
------------------------- --------------
001F                                   2
1020A                                  5
                                       6
(what if a room has never been used)


Question 5
select Loan_ID, St_ID, Comp_ID,Start_Date,Date_Returned
from loan
left join computer using (Comp_ID)
left join location using (Location_ID)
where Loc_Bldg='HbH' AND (Date_Returned>ADD_Months(Date_Returned,-18) or date_returned is null)
ORDER BY Date_Returned DESC NULLS FIRST
;


   LOAN_ID      ST_ID    COMP_ID START_DAT DATE_RETU
---------- ---------- ---------- --------- ---------
        33       1012         25 16-OCT-14 14-NOV-14
         9       1007          9 19-AUG-14 08-NOV-14
        34       1007         28 19-AUG-14 08-NOV-14
         2       1001          2 15-AUG-14 05-NOV-14
        35       1004         29 15-AUG-14 03-NOV-14
        25       1014         25 24-SEP-14 14-OCT-14
        17       1013         17 17-SEP-14 08-OCT-14
        38       1015         30 01-DEC-13 26-JAN-14
        39       1015          2 01-NOV-13 26-NOV-13

Question 7
/* need to format column*/
select "st1","st2","computer" 
from (
(SELECT a.St_ID||' '||c.St_FName|| ' '||c.St_LName as "st1", 
b.St_ID||' '||d.St_FName|| ' '||d.St_LName as "st2", a.Comp_ID as "computer"
From 
 loan a,
 loan b,
 student c,
 student d 
where a.COMP_ID = b.COMP_ID and a.St_ID < b.St_ID and a.St_ID = c.St_ID and b.St_ID = d.St_ID
)
);



       st1        st2   computer
---------- ---------- ----------
      1012       1014         25
      1005       1013         26
      1008       1009         10
      1009       1011         11
      1001       1015          3
      1001       1015          2
      1015       1020         30

7 rows selected.

Question 9
select Comp_ID, T1.Comp_Name AS "Computer", "Earliest","Latest",case when Loc_Bldg='HbH' then Loc_Room else NULL end "optional"
from(
(select * from 
(select Comp_Name, RANK() OVER (Partition by Comp_ID ORDER BY Start_Date) rank1,Start_Date AS "Earliest",Comp_ID
from loan 
left join computer
using (Comp_ID)
left join item 
using (Item_ID)
where Item_Manuf='HP' AND Date_Returned<=SYSDATE)
where rank1=1) T1
left join
(select * from 
(select Comp_Name, RANK() OVER (Partition by Comp_ID ORDER BY Start_Date DESC) rank2,Start_Date AS "Latest",Comp_ID
from loan 
left join computer
using (Comp_ID)
left join item 
using (Item_ID)
where Item_Manuf='HP' AND Date_Returned<=SYSDATE)
where rank2=1) T2
using (Comp_ID)
left join (
select Comp_ID, Loc_Bldg,Loc_Room
from computer
left join 
location using (Location_ID))
using (Comp_ID))
;



   COMP_ID Computer                  Earliest  Latest    optional
---------- ------------------------- --------- --------- -------------------------
         2 HP Pavilion               01-NOV-13 15-AUG-14 1020A
         3 HP Pavilion               15-AUG-14 17-OCT-14
        30 HP Pavilion               01-DEC-13 01-DEC-13 001F


Question 11
select Comp_ID, Comp_Name,"AVG Length"
from computer
left outer join
(select a.Comp_ID,AVG("s"-"DR") As "AVG Length" from 
(SELECT a.Comp_ID,a.Start_Date AS "SD",a.Date_Returned AS "DR",
  b.Start_Date as "s",b.Date_Returned as "d", Rank() OVER (Partition by a.Loan_ID ORDER BY b.Start_Date) AS r
 FROM 
 (loan a
 join
 loan b
 on (a.Comp_ID = b.Comp_ID))
 where a.Date_Returned < b.Start_Date)
using (Comp_ID)
 where r=1 
 group by c.Comp_ID,c.Comp_Name
 ) d on (computer.Comp_ID = d.Comp_ID)
 ;



Question 13

SELECT student.St_ID||' '||St_FName||' '||St_LName AS "Student",a.Comp_ID,b.Comp_ID,To_Number(To_Char(a.Date_Returned,'DDD'))-To_Number(To_Char(b.Start_Date,'DDD')) as "overlap"
FROM loan a, loan b,student
where a.Loan_ID !=b. Loan_ID 
      and a.Date_Returned > b.Start_Date
      and b.Date_Returned >a.Date_Returned
      and a.St_ID= b.St_ID
      and a.St_ID = student.St_ID
      and a.Date_Returned - b.Start_Date > 30
order by "overlap";
	  

Student                                                                                         COMP_ID    COMP_ID    overlap
-------------------------------------------------------------------------------------------- ---------- ---------- ----------
1009 JORGE PEREZ                                                                                     12         11         48
1012 WILLIAM MCKENZIE                                                                                25         27         51
1015 STEVE SCHELL                                                                                     3         18         51
1012 WILLIAM MCKENZIE                                                                                14         15         53
1012 WILLIAM MCKENZIE                                                                                15         27         55
1012 WILLIAM MCKENZIE                                                                                14         27         61
1012 WILLIAM MCKENZIE                                                                                25         15         74
1001 BONITA MORALES                                                                                   1          3         82
1001 BONITA MORALES                                                                                   2          3         82

9 rows selected.
