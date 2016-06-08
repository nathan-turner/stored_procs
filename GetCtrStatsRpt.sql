DELIMITER $$
CREATE  PROCEDURE `GetCtrStatsRpt`(
 empid int,
 startd datetime,
 endd datetime
)
    READS SQL DATA
begin

-- first, group by, then join
SELECT  allcontracts.ctr_id,  allcontracts.ctr_no, 
 allcontracts.ctr_spec,  
 allcontracts.ctr_location_c, 
 allcontracts.ctr_location_s,
 ifnull(pipl.ivcnt, 0) as ctr_iv, ifnull(pipl.prcnt,0) as ctr_pr,
 allcontracts.ctr_nurse, at_abbr
FROM allcontracts LEFT OUTER JOIN
 (select  tctrpipl.pipl_ctr_id,
	sum(case when  tctrpipl.pipl_status = 3 then 1 else 0 end) as ivcnt,
	sum(case when  tctrpipl.pipl_status = 2 then 1 else 0 end) as prcnt
	from  tctrpipl
	where  tctrpipl.pipl_cancel = 0 and  tctrpipl.pipl_status in (2,3)
	and  tctrpipl.pipl_date between  startd and  endd
	group by  tctrpipl.pipl_ctr_id
  ) pipl ON  allcontracts.ctr_id = pipl.pipl_ctr_id LEFT OUTER JOIN
 dctalliedtypes on ctr_nu_type = at_code
WHERE     allcontracts.ctr_status in (1,16)
and  allcontracts.ctr_type <> 'CP'
and ( allcontracts.ctr_recruiter =  empid or  allcontracts.ctr_manager =  empid)
order by  allcontracts.ctr_no;

end$$
DELIMITER ;
