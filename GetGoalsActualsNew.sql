DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetGoalsActualsNew`(
 d1 datetime,  d2 datetime
)
    READS SQL DATA
begin
--  d1 - start date, supposed to be Jan 1st of any year
--  d2 - end date (NO TIME), supposed to be in the same year as  d1
-- if there are no goals for  d2, nothing will show
-- class: 1 req, 3 mark, 4 MA
-- see hack notes below
	declare  d3, d4, ctrd, minda, maxda datetime;
	declare  ctrid decimal;
	declare  cliid, req, mark,plac int;
	declare typ char(2);
	declare goon tinyint default true;
	declare ctrs cursor for select ctr_id, ctr_cli_id, ctr_type,
		ctr_recruiter, ctr_marketer, ctr_retain_date
		from allcontracts where /*ctr_status <> 4 and ctr_status <> 9 and*/
		(ctr_type <> 'C ' or ctr_status in (7,8)) and ctr_type <> 'CP' and
		ctr_retain_date between d1 and d2 and (ctr_nomktg is null or ctr_nomktg=0);
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET goon = FALSE;

	set  d4 = d2 - interval (day(d2)-1) day; -- 1st day of the month
	set  d3 = d4 + interval 1 month - interval 1 second; -- last second of the month

	SET sql_safe_updates=0;

	create temporary table IF NOT EXISTS ACTU (
		g_emp_id int not null primary key, g_class tinyint, 
		g_1ytd decimal, g_2ytd decimal, g_3ytd decimal, g_4ytd decimal,
		a_1 decimal, a_2 int, a_3 int, a_4 int,
		g_1 decimal, g_2 decimal, g_3 decimal, g_4 decimal,
		ma_1 decimal, ma_2 int, ma_3 int, ma_4 int,
		y_1 decimal, y_2 int, y_3 int, y_4 int
	) engine=memory;
	truncate table ACTU;
	insert into ACTU
		select g_emp_id, g_class, g_1ytd, g_2ytd, g_3ytd, g_4ytd,
		0.0, 0, 0, 0,  g_1, g_2, g_3, g_4,
		0.0, 0, 0, 0, 0.0, 0, 0, 0
		from tgoalsnew
		where g_class > 0 and g_year = YEAR( d2) and g_month = MONTH( d2);

	update ACTU,tgoalsnew t set y_1 = t.g_1ytd,  y_2 = t.g_2ytd,  y_3 = t.g_3ytd,  y_4 = t.g_4ytd
	where t.g_emp_id = ACTU.g_emp_id and t.g_class = ACTU.g_class
		and t.g_year = YEAR( d2) and t.g_month = 12;

-- placements, interviews, presents
	update ACTU,(select pipl_emp_id, 
		  sum(CASE WHEN pipl_status = 3 THEN 1 ELSE 0 END) as intrcnt,
		  sum(CASE WHEN pipl_status in (2,8) THEN 1 ELSE 0 END) as prescnt,
		  sum(CASE WHEN pipl_status = 3 and pipl_date >=  d4 THEN 1 ELSE 0 END) as intrm,
		  sum(CASE WHEN pipl_status in (2,8) and pipl_date >=  d4 THEN 1 ELSE 0 END) as presm 
		 from tctrpipl   where pipl_cancel = 0 and pipl_date between  d1 and  d3
		 group by pipl_emp_id) as placc
	set a_2 = intrcnt, a_3 = prescnt, ma_2 = intrm, ma_3 = presm
	where g_class = 1 and placc.pipl_emp_id = g_emp_id;

-- placements - new style, 1/2
	update ACTU,(select pl_emp_id, 
	  sum(CASE WHEN pl_split_emp is null THEN 1.0 ELSE 0.5 END) as placcnt,
	  sum(CASE WHEN pl_date >=  d4 THEN 
		CASE WHEN pl_split_emp is null THEN 1.0 ELSE 0.5 END ELSE 0.0 END) as placm
	 from tplacements join tctrpipl on pl_id = pipl_id where pipl_cancel = 0 and pl_date between  d1 and  d3
	  and pipl_status = 4 -- exclude replacements
	 group by pl_emp_id) as placc
	set a_1 = placcnt, ma_1 = placm
	where g_class = 1 and placc.pl_emp_id = g_emp_id;
-- placements - new style, seconf half
	update ACTU,(select pl_split_emp, 
	  sum(0.5) as placcnt,
	  sum(CASE WHEN pl_date >=  d4 THEN 0.5 ELSE 0.0 END) as placm
	 from tplacements join tctrpipl on pl_id = pipl_id where pipl_cancel = 0 and pl_date between  d1 and  d3
	  and pipl_status = 4 -- exclude replacements
	  and pl_split_emp is not null
	 group by pl_split_emp) as placc
	set a_1 = a_1 + placcnt, ma_1 = ma_1 + placm
	where g_class = 1 and placc.pl_split_emp = g_emp_id;

-- retainers new - checks for nomktg
	set  d2 = d2 + interval '23:59:59' hour_second; -- last second of the day today
	update ACTU,(select ctr_marketer, count(ctr_id) as cnt, sum(CASE WHEN ctr_retain_date >=  d4 THEN 1 ELSE 0 END) as mcnt
		from allcontracts where  /*ctr_status <> 4 and ctr_status <> 9 and*/ (ctr_type <> 'C ' or ctr_status in (7,8)) and ctr_type <> 'CP' and
		ctr_retain_date between  d1 and  d2 and (ctr_nomktg is null or ctr_nomktg=0)
		group by ctr_marketer) as rr
	set a_1 = rr.cnt, ma_1 = rr.mcnt
	where g_class = 3 and rr.ctr_marketer = g_emp_id;
-- meetings
-- we won't count next month's meetings
-- d3 is already set
	update ACTU,(select cm_emp_id, count(cm_id) as cnt, sum(CASE WHEN cm_date >=  d4 THEN 1 ELSE 0 END) as mcnt
		from tclimeetings  where cm_cancel = 0 and cm_nomeet = 0 and cm_date between  d1 and  d3
		group by cm_emp_id) as met
	set a_2 = met.cnt, ma_2 = met.mcnt
	where g_class = 3 and met.cm_emp_id = g_emp_id;
-- MA meetings
/* we don't have any MA now
	update ACTU,(select emp_id, count(cm_id) as cnt, sum(CASE WHEN cm_date_mod >  d4 THEN 1 ELSE 0 END) as mcnt
		from tclimeetings join lstEmployees on emp_uname = cm_user_mod
		where cm_cancel = 0 and cm_nomeet = 0 and cm_date_mod between  d1 and  d2
		group by emp_id) as mat
	set a_2 = mat.cnt, ma_2 = mat.mcnt
	where g_class = 4 and mat.emp_id = g_emp_id;
*/
-- retainers
	open ctrs;
	fetch ctrs into  ctrid,  cliid,  typ,  req,  mark,  ctrd;
	while goon do
		set minda = NULL;
		select  max(IFNULL(ctr_pro_date,ctr_date)),
				min(IFNULL(ctr_pro_date,ctr_date)),
				max(CASE WHEN ctr_status in (7,8) THEN 1 ELSE 0 END)
		into maxda,minda,plac
		from allcontracts
		where ctr_id <>  ctrid and ctr_cli_id =  cliid and ctr_date <  ctrd
		-- may be needs adj below (incl nomktg) but leave as is for now
           and ctr_status <> 4 and ctr_status <> 9 and (ctr_type <> 'C ' or ctr_status in (7,8)) and ctr_type <> 'CP';

		if  minda is NULL then -- the first contract - new
			update ACTU set a_3 = a_3+1, ma_3 = ma_3+(CASE WHEN  ctrd >=  d4 THEN 1 ELSE 0 END)
            where g_class = 3 and g_emp_id =  mark;
         /* *MA* 
			update ACTU, (select emp_id, min(cm_id) as cnt from tclimeetings
				join lstEmployees on emp_uname = cm_user_mod
				where cm_cancel = 0 and cm_date_mod between  d1 and  ctrd
				and cm_cli_id =  cliid group by emp_id) as ma
			set a_1 = a_1+1, ma_1 = ma_1+(CASE WHEN  ctrd >  d4 THEN 1 ELSE 0 END)
			where g_class = 4 and ma.emp_id = g_emp_id;
		*/
		elseif plac = 0 then -- no placements
			if DATEDIFF(ctrd, minda) <= 90 then -- oldest contract less than 90 days ago - new
				update ACTU set a_3 = a_3+1, ma_3 = ma_3+(CASE WHEN  ctrd >=  d4 THEN 1 ELSE 0 END)
				where g_class = 3 and g_emp_id =  mark;
			/* *MA*
				update ACTU, (select emp_id, min(cm_id) as cnt from tclimeetings
					join lstEmployees on emp_uname = cm_user_mod
					where cm_cancel = 0 and cm_date_mod between  d1 and  ctrd
					and cm_cli_id =  cliid group by emp_id) as ma
				set a_1 = a_1+1, ma_1 = ma_1+(CASE WHEN  ctrd >  d4 THEN 1 ELSE 0 END)
				where g_class = 4 and ma.emp_id = g_emp_id;
			*/
			else -- oldest contract more than 90 days ago - repeat
				update ACTU set a_4 = a_4+1, ma_4 = ma_4+(CASE WHEN  ctrd >=  d4 THEN 1 ELSE 0 END)
				where (g_emp_id =  req and g_class=1) or (g_emp_id =  mark and g_class = 3);
			end if;
		elseif DATEDIFF(ctrd, maxda) > 180 then -- were placements, latest contract was more than 6 months ago - new
			update ACTU set a_3 = a_3+1, ma_3 = ma_3+(CASE WHEN  ctrd >=  d4 THEN 1 ELSE 0 END)
            where g_class = 3 and g_emp_id =  mark;
		/* *MA*
			update ACTU, (select emp_id, min(cm_id) as cnt from tclimeetings
				join lstEmployees on emp_uname = cm_user_mod
				where cm_cancel = 0 and cm_date_mod between  d1 and  ctrd
				and cm_cli_id =  cliid group by emp_id) as ma
			set a_1 = a_1+1, ma_1 = ma_1+(CASE WHEN  ctrd >  d4 THEN 1 ELSE 0 END)
			where g_class = 4 and ma.emp_id = g_emp_id;
		*/
		else -- placements, but less than 6 months ago - repeat
			update ACTU set a_4 = a_4+1, ma_4 = ma_4+(CASE WHEN  ctrd >=  d4 THEN 1 ELSE 0 END)
			where (g_emp_id =  req and g_class=1) or (g_emp_id =  mark and g_class = 3);
		end if;

		fetch ctrs into  ctrid,  cliid,  typ,  req,  mark,  ctrd;
	end while;
	close ctrs;

-- hack: add House's data to Mike, and delete it afterwards
if exists (select * from ACTU where g_emp_id = 31 and g_class = 3) then
  if exists (select * from ACTU where g_emp_id = 3 and g_class = 3) then
	create temporary table if not exists ACT31 like ACTU;
	insert into ACT31 select * from ACTU where g_emp_id = 31 and g_class = 3;
	update ACTU, ACT31 as u set
     ACTU.g_1ytd = ACTU.g_1ytd + u.g_1ytd,
     ACTU.g_2ytd = ACTU.g_2ytd + u.g_2ytd,
     ACTU.g_3ytd = ACTU.g_3ytd + u.g_3ytd,
     ACTU.g_4ytd = ACTU.g_4ytd + u.g_4ytd,
     ACTU.a_1 = ACTU.a_1 + u.a_1,
     ACTU.a_2 = ACTU.a_2 + u.a_2,
     ACTU.a_3 = ACTU.a_3 + u.a_3,
     ACTU.a_4 = ACTU.a_4 + u.a_4,
     ACTU.g_1 = ACTU.g_1 + u.g_1,
     ACTU.g_2 = ACTU.g_2 + u.g_2,
     ACTU.g_3 = ACTU.g_3 + u.g_3,
     ACTU.g_4 = ACTU.g_4 + u.g_4,
     ACTU.ma_1 = ACTU.ma_1 + u.ma_1,
     ACTU.ma_2 = ACTU.ma_2 + u.ma_2,
     ACTU.ma_3 = ACTU.ma_3 + u.ma_3,
     ACTU.ma_4 = ACTU.ma_4 + u.ma_4,
     ACTU.y_1 = ACTU.y_1 + u.y_1,
     ACTU.y_2 = ACTU.y_2 + u.y_2,
     ACTU.y_3 = ACTU.y_3 + u.y_3,
     ACTU.y_4 = ACTU.y_4 + u.y_4
	where ACTU.g_emp_id = 3 and ACTU.g_class = 3 and u.g_emp_id = 31 and u.g_class = 3;
    delete from ACTU where g_emp_id = 31 and g_class = 3;
	drop table ACT31;
  end if;
end if;

-- ok, here ACTU is ready
	select g_class as category, emp_uname as uname, emp_id,
	   g_1ytd as goal1,   g_2ytd as goal2,   g_3ytd as goal3,   g_4ytd as goal4,
	   a_1 as act1,   a_2 as act2,   a_3 as act3,   a_4 as act4,
	   g_1 as moal1, g_2 as moal2, g_3 as moal3, g_4 as moal4,
	   ma_1 as mact1, ma_2 as mact2, ma_3 as mact3, ma_4 as mact4,
	   y_1 as yoal1, y_2 as yoal2, y_3 as yoal3, y_4 as yoal4,
	   emp_status
	from ACTU join lstemployees on g_emp_id = emp_id
	order by category, emp_uname;

	drop table ACTU;
end$$
DELIMITER ;
