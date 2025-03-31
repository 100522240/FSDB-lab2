select d.fullname,
/* Obtain the age of the driver by substracting the driver's birhtdate to the actual date and dividing by 365. 
For obtaining an integer value smaller or equal than the obtained result, we will use floor()
*/
floor((sysdate - d.birthdate) / 365) as age, 
/*--For obtaining the seniority contracted we have to substract the contract start date
to the contract end date (or the actual date in case that it is null)
*/
floor((nvl(d.cont_end, sysdate) - d.cont_start) / 365) as seniority_contracted,
/*To obtain the active years, we have taken into account the differnece between taskdates (columnn from assign_drv table).
If a driver has null taskdates, then we replace them with the actual date. If they have more, we will obtain the earliest and latest taskdates
and we then substract them to obtain the number of days and finally divide by 365*/ 
case 
    when floor((max(nvl(a.taskdate, sysdate)) - nvl(min(a.taskdate), sysdate)) / 365) != 0 then
    end floor((max(nvl(a.taskdate, sysdate)) - nvl(min(a.taskdate), sysdate)) / 365)
    else 1
    as active_years,
/*To obtain the number of stops per active year we have to count the number of not null taskdates assigned to the driver
and then divide it by the number of active years. In case that the active years is 0, we would get an error. Thus we have made a case statement where will divide the 
taskdates by the number of active years if it is different than zero, otherwise, we will divide by one*/
count(distinct a.taskdate) /
    case
        when floor((max(nvl(a.taskdate, sysdate)) - min(nvl(a.taskdate, sysdate))) / 365) != 0 then
        floor((max(nvl(a.taskdate, sysdate)) - min(nvl(a.taskdate, sysdate))) / 365)
        else 1
    end as num_stops_per_year,
/*For calculating the number of loans per year we have to do the same thing as with the number of stops, but
instead of counting the taskdates, we will count the signatures*/
count(distinct l.signature) /
    case
        when floor((max(nvl(a.taskdate, sysdate)) - min(nvl(a.taskdate, sysdate))) / 365) != 0 then
        floor((max(nvl(a.taskdate, sysdate)) - min(a.taskdate)) / 365)
        else 1
    end as num_loans_per_active_year,
/*To obtain the percentage of unreturned loans we have to count those that have null in the return column and then divide by the number of loans, and then multiply by 100*/
round(
    case 
        when count(distinct l.signature) = 0 then 0  -- Avoid division by zero
        else (count(distinct case when l.return is null then l.signature end) * 100.0) 
             / count(distinct l.signature) 
    END, 
    2
) AS percentage_unreturned_loans
from drivers d
left outer join assign_drv a on d.passport = a.passport
left outer join services s on a.passport = s.passport
left outer join loans l on l.stopdate = s.taskdate and l.town = s.town and l.province = s.province
group by d.fullname, d.birthdate, d.cont_start, d.cont_end;