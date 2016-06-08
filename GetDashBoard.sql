DELIMITER $$
CREATE DEFINER=`phgadmin`@`%` PROCEDURE `GetDashBoard`(
 d1 datetime,  d2 datetime
)
    READS SQL DATA
begin
--  d1 - start date, supposed to be Jan 1st of any year
--  d2 - end date (NO TIME), supposed to be in the same year as  d1
--  Recruitiers: 24,2,107,147,105
--  Marketers: 3, 152, 216, 184, 226 (and 31, adds to 3)
-- Returns a resultset: Uname, Uid, Utype, V1, V2, V3
-- utype=0: ratios with npres, no2, no6 (one row only)
-- utype=1: recruter presents, IVs, placements
-- utype=2: marketer's retainers in V1
declare  npres,  nret,  no2,  no6, v31 smallint;
declare  d3 datetime;

set  d3 = d2 - interval 30 day;
set  d2 = d2 + interval '23:59:59' hour_second; -- last second of the day today

-- gauges
select count(*) into nret from allcontracts where ctr_status = 1 and ctr_type not in ('A','C','S','CP'); -- excl zombies
select count(*) into no2 from vcliaccwatch where datediff(curdate(), lastup) > 60;
select count(*) into no6 from vcliaccwatch where datediff(current_date, lastup) > 180;
select count(*) into npres from tctrpipl join allcontracts on pipl_ctr_id = ctr_id
  where pipl_cancel = 0 and pipl_date between  d3 and  d2
  and pipl_status in (2,8) and ctr_type not in ('A','C','S','CP'); -- any contract status, incl. cancelled and zombies

	SET sql_safe_updates=0;

	create temporary table DASH (
		uname char(2) not null,
		uid int, utype tinyint, v1 int, 
		v2 int, v3 int
	) engine=memory;

	insert into DASH values ('XX', 0, 0,
		(IFNULL( npres,0)*100)/ nret,(IFNULL( no2,0)*100)/ nret,(IFNULL( no6,0)*100)/ nret);

	-- all recruiters with accounts
	insert into DASH
		select upper(left(emp_uname,2)), emp_id, 1, 0, 0, 0
		from lstemployees where emp_id in  (24,2,107,147,105);

	-- presents, interviews
	update DASH,(select pipl_emp_id, 
		  sum(CASE WHEN pipl_status = 3 THEN 1 ELSE 0 END) as iv,
		  sum(CASE WHEN pipl_status in (2,8) THEN 1 ELSE 0 END) as pres
		 from tctrpipl  where pipl_cancel = 0 and pipl_date between  d3 and  d2
		 and pipl_emp_id in  (24,2,107,147,105)
		 group by pipl_emp_id) as plac
	set v1 = pres, v2 = iv where uid = pipl_emp_id;

	-- placements ytd
	update DASH,(select pl_emp_id, 
		  sum(CASE WHEN pl_split_emp is null THEN 2 ELSE 1 END) as placcnt
		 from tplacements join tctrpipl on pl_id = pipl_id 
		 where pipl_cancel = 0 and pl_date between  d1 and  d2
		  and pipl_status = 4 -- exclude replacements
		  and pipl_emp_id in  (24,2,107,147,105)
		 group by pl_emp_id) as plac
	set v3 = placcnt where uid = pl_emp_id;

	-- marketers with accounts
	insert into DASH
		select upper(left(emp_uname,2)), ctr_marketer, 2, rrcnt, 0, 0
		from
		(select ctr_marketer, count(ctr_id) as rrcnt
		 from allcontracts where  (ctr_type <> 'C ' or ctr_status in (7,8)) and ctr_type <> 'CP' 
		  and ctr_retain_date between  d3 and  d2 and ifnull(ctr_nomktg,0)=0
		  and ctr_marketer in (3, 152, 184, 226, 31)
		 group by ctr_marketer) as rr join lstemployees on ctr_marketer = emp_id;
	-- house goes to MPB
	select v1 into v31 from DASH where uid=31;
	update DASH set v1=v1+v31 where uid=3 and v31 is not null;
	select * from DASH where uid <> 31 order by utype, uid;
	drop table DASH;

end$$
DELIMITER ;
