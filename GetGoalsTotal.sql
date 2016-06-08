DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetGoalsTotal`(
 d1 datetime,  d2 datetime
)
    READS SQL DATA
begin
--  d1 - start date, supposed to be Jan 1st of any year
--  d2 - end date (NO TIME), supposed to be in the same year as  d1
-- Returns a resultset: Mon, V1, V2

	set  d2 = d2 + interval '23:59:59' hour_second; -- last second of the day today
	SET sql_safe_updates=0;

	create temporary table IF NOT EXISTS DAS (
		mon tinyint, utype tinyint, v1 int, v2 decimal
	) engine=memory;
	truncate table DAS;
	insert into DAS
		select g_month, 1, 0, floor(sum(g_1)) 
		from tgoalsnew where g_class = 1 and g_year=Year( d1) group by g_month;

	insert into DAS
		select g_month, 3, 0, sum(g_1) 
		from tgoalsnew where g_class = 3 and g_year=Year( d1) group by g_month;

-- placements monthly
	update DAS,(select month(pl_date) as plmon, count(pl_id) as placcnt
		from tplacements join tctrpipl on pl_id = pipl_id where pipl_cancel = 0 and pl_date between  d1 and  d2
		and pipl_status = 4 -- exclude replacements
		group by month(pl_date)) as plac
	set v1 = placcnt
	where utype = 1 and mon = plmon;

-- marketer retainers
	update DAS,(select month(ctr_retain_date) as rrmon, count(ctr_id) as rrcnt
		from allcontracts where (ctr_type <> 'C ' or ctr_status in (7,8)) and ctr_type <> 'CP' 
		and ctr_retain_date between  d1 and  d2 and ifnull(ctr_nomktg,0)=0
		group by month(ctr_retain_date)) as rr
	set v1 = rrcnt
	where utype = 3 and mon = rrmon;

	select * from DAS order by utype, mon;

	drop table DAS;
end$$
DELIMITER ;
