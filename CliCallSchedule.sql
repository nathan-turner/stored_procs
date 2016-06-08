DELIMITER $$
CREATE DEFINER=`phgadmin`@`%` PROCEDURE `CliCallSchedule`()
    MODIFIES SQL DATA
begin
	declare empid,target,cliid int;
	declare over char(2);
	declare goon tinyint default true;
	declare mark cursor for
		select emp_id from lstemployees where emp_dept IN ('M','MA','RM') and emp_status = 1;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET goon = FALSE;

	start transaction;
	delete from tcallschedule where sch_hidden = 1
		or datediff(current_date,sch_date) > 180; -- clean up 6 mo olds, too

	open mark;
	fetch mark into empid;
	while goon do
		set target = if( empid = 31, 3, empid );
		set over = null;
		select over_st_code into over from tcalloverride 
			where over_emp_id = empid and over_month = Month(current_date());
		if over is null then
			insert into tcallschedule (sch_emp_id,sch_cli_id)
				select target,cli_id from lstclients join lstcontacts on cli_ctct_id = ctct_id
				where cli_status <> 1 and cli_type = 2 and cli_emp_id = empid 
				and (cli_call_sched is null or datediff(current_date,cli_call_sched) > 90)
				and ctct_st_code in 
('PA', 'NJ', 'NY', 'MD', 'VA', 'AR', 'MO', 'IL', 'IA', 'KS', 'WI', 'MI', 'WV', 'KY', 'IN', 'OH', 'GA', 'FL', 'AL', 'MS', 'LA', 'TN', 'NC', 'SC')
				order by cli_call_sched, ctct_st_code, ctct_addr_z, ctct_phone;
		elseif over <> '--' then
			insert into tcallschedule (sch_emp_id,sch_cli_id) 
				select target,cli_id from lstclients join lstcontacts on cli_ctct_id = ctct_id
				where cli_status <> 1 and cli_type = 2 and cli_emp_id = empid and ctct_st_code = over
				and (cli_call_sched is null or datediff(current_date,cli_call_sched) > 90)
				order by cli_call_sched, ctct_addr_z, ctct_phone;
		end if;
		fetch mark into empid;
	end while;
	close mark;

    insert into  allActivities (aact_date_mod,aact_user_mod,
	aact_act_code,aact_src_emp_id,aact_trg_emp_id,aact_trg_dt,
	aact_ref1,aact_ref_type1)
    values ( current_date(), 'system', 14, 31, 10, curdate(), 0, 0); -- 10 is jpolver
/*--MONITOR*/
    insert into  allActivities (aact_date_mod,aact_user_mod,
	aact_act_code,aact_src_emp_id,aact_trg_emp_id,aact_trg_dt,
	aact_ref1,aact_ref_type1)
    values ( current_date(), 'system', 14, 31, 1, curdate(), 0, 0); -- 1 is me

	commit;
end$$
DELIMITER ;
