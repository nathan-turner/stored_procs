DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetPIPLR`(
 ctrid decimal
)
    READS SQL DATA
begin
-- build 1-row resultset with stats:
-- i-compl (#), s-2-pl (d), pre (#), i-2-pl (%), pr-2-i (%), i-canc (#)
	declare icpl,pre,ican,pl int;
	declare s2pl,i2pl,pr2i smallint;
	declare pld, srcd datetime;

	select count(*) into icpl from  tctrpipl 
    where pipl_ctr_id =  ctrid and pipl_status = 3 and pipl_cancel = 0;
	select count(*) into ican from  tctrpipl 
	where pipl_ctr_id =  ctrid and pipl_status = 3 and pipl_cancel = 1;
	select count(*) into pre from  tctrpipl 
	where pipl_ctr_id =  ctrid and pipl_status = 2 and pipl_cancel = 0;
	select count(*) into pl from  tctrpipl 
	where pipl_ctr_id =  ctrid and pipl_status in (4,5) and pipl_cancel = 0;

-- now, i-2-pl = pl/i %
	set i2pl = if(icpl is Null or icpl = 0, 0, (( pl*100.0)/ icpl) ); -- 100.0 to force double aryth.
-- pr-2-i = i/pr %
	set  pr2i = if( pre is Null or  pre = 0, 0, (( icpl*100.0)/ pre) );
-- that was easy. now, to figure out s-2-pl
-- pl-d - maximum (re)placement date
	select max(pipl_date) into pld from  tctrpipl 
	where pipl_ctr_id =  ctrid and pipl_status in (4,5) and pipl_cancel = 0;
-- src-d - profile date
	select ctr_pro_date into srcd from  allcontracts where ctr_id =  ctrid;
	set s2pl = datediff(pld, srcd);
-- results
	select icpl as `icpl`,  s2pl as `s2pl`,  pre as `pre`,
		i2pl as `i2pl`,  pr2i as `pr2i`,  ican as `ican`;

end$$
DELIMITER ;
