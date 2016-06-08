DELIMITER $$
CREATE DEFINER=`phgadmin`@`%` PROCEDURE `CliCallRoll`(empid int)
    MODIFIES SQL DATA
begin
	declare trgid int;
	declare dt datetime;
	start transaction;

	set dt = current_date + interval (9-dayofweek(current_date)) day; /* monday of the next week*/
	if empid <> 0 then
		update lstclients,tcallschedule set cli_call_sched = current_date()  
			where sch_cli_id = cli_id and sch_hidden = 1 and sch_emp_id = empid;
		update tcallschedule set sch_hidden = 0 where sch_emp_id = empid;
		insert into  allactivities (aact_date_mod,aact_user_mod,
			aact_act_code,aact_src_emp_id,aact_trg_emp_id,aact_trg_dt,
			aact_ref1,aact_ref_type1)
		values ( current_date(), 'system', 13, 31, empid, dt, 0, 0);
	else /*-- empid = 0*/
		update lstclients,tcallschedule set cli_call_sched = current_date()  
			where sch_cli_id = cli_id and sch_hidden = 1;
		update  tcallschedule set sch_hidden = 0;
		insert into allactivities (aact_date_mod,aact_user_mod,
			aact_act_code,aact_src_emp_id,aact_trg_emp_id,aact_trg_dt,
			aact_ref1,aact_ref_type1)
			select current_date(), 'system', 13, 31, emp_id, dt, 0, 0 
			from  lstemployees 
			where emp_dept IN ('M','MA','RM') and emp_status = 1 and emp_id <> 31;
	end if;

	commit;
end$$
DELIMITER ;
