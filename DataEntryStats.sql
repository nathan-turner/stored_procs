DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `DataEntryStats`(
date1 datetime,
date2 datetime
)
    READS SQL DATA
begin

	SET sql_safe_updates=0;

	create temporary table DE (
		emp_uname char(32) not null,
		notes int, cli_add int, cli_mod int, 
		ph_add int, ph_mod int, ctct_mod int,
		an_add int, an_mod int,
		primary key(`emp_uname`)
	) engine=memory;

	insert into DE
		select REPLACE(emp_uname,'@phg.com',''), 
		0 as notes, 0 as cli_add, 0 as cli_mod, 
		0 as ph_add, 0 as ph_mod, 0 as ctct_mod,
		0 as an_add, 0 as an_mod
		from lstemployees where emp_status = 1;

	insert into DE values ('iis_iser',0,0,0,0,0,0,0,0);
	

	/*update DE,(select  allnotes.note_user, count(*) as cnt from  allnotes
		where allnotes.note_dt between date1 and date2 group by allnotes.note_user) n 
		set notes = n.cnt
	where n.note_user = emp_uname;*/

	update DE,(select  allnotes.note_user, count(*) as cnt from  allnotes
		where allnotes.note_dt between date1 and date2 group by allnotes.note_user) n 
		set DE.notes = n.cnt
	where n.note_user = emp_uname;

	update DE,(select  lstclients.cli_user_mod, count(*) as cnt from  lstclients 
		where  lstclients.cli_date_mod between date1 and date2 group by  lstclients.cli_user_mod)  c
		set cli_mod = c.cnt
	where c.cli_user_mod = emp_uname;

	update DE,(select  lstclients.cli_user_add, count(*) as cnt from  lstclients 
		where  lstclients.cli_date_add between date1 and date2 group by  lstclients.cli_user_add) c
		set cli_add = c.cnt
	where c.cli_user_add = emp_uname;

	update DE,(select  lstphysicians.ph_user_mod, count(*) as cnt from  lstphysicians
		where  lstphysicians.ph_date_mod between date1 and date2 group by  lstphysicians.ph_user_mod) p
		set ph_mod = p.cnt
	where p.ph_user_mod = emp_uname;

	update DE,(select  lstphysicians.ph_user_add, count(*) as cnt from  lstphysicians
		where  lstphysicians.ph_date_add between date1 and date2 group by  lstphysicians.ph_user_add) p
		set ph_add = p.cnt
	where p.ph_user_add = emp_uname;

	update DE,(select  lstalliednurses.an_user_mod, count(*) as cnt from  lstalliednurses
		where  lstalliednurses.an_date_mod between date1 and date2 group by  lstalliednurses.an_user_mod) p
		set an_mod = p.cnt
	where p.an_user_mod = emp_uname;

	update DE,(select  lstalliednurses.an_user_add, count(*) as cnt from  lstalliednurses
		where  lstalliednurses.an_date_add between date1 and date2 group by  lstalliednurses.an_user_add) p
	set an_add = p.cnt
	where p.an_user_add = emp_uname;

	update DE,(select  lstcontacts.ctct_user_mod, count(*) as cnt from  lstcontacts
		where  lstcontacts.ctct_date_mod between date1 and date2 group by  lstcontacts.ctct_user_mod) c
		set ctct_mod = c.cnt
	where c.ctct_user_mod = emp_uname;

	delete from DE where notes = 0 and cli_add = 0 and cli_mod = 0 and
		ph_add=0 and ph_mod=0 and  an_add=0 and an_mod=0 and ctct_mod = 0;

	select * from DE order by emp_uname; -- result set

	drop table DE;

end$$
DELIMITER ;
