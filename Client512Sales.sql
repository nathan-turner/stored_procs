DELIMITER $$
CREATE DEFINER=`phgadmin`@`%` PROCEDURE `Client512Sales`(
cli_id int,
emp_id int,
step tinyint,
rank tinyint,
uname char(32)
)
    MODIFIES SQL DATA
begin
	if rank <> 0 or step <> 0 then
		delete from  tcallschedule where sch_cli_id = cli_id;
	end if;
	if rank <> 0 then
		update lstclients set cli_steprat = rank, cli_step6e = emp_id,
		cli_user_mod = uname, cli_date_mod = current_date(), cli_call_sched = current_date()
		where cli_id = cli_id;
	end if;
	if step = 5 then
	   update lstclients set
		 cli_step1 = ifnull(cli_step1, current_date()),
		 cli_step2 = ifnull(cli_step2, current_date()),
		 cli_step3 = ifnull(cli_step3, current_date()),
		 cli_step4 = ifnull(cli_step4, current_date()),
		 cli_step5 = ifnull(cli_step5, current_date()),
		 cli_step1e = ifnull(cli_step1e, emp_id),
		 cli_step2e = ifnull(cli_step2e, emp_id),
		 cli_step3e = ifnull(cli_step3e, emp_id),
		 cli_step4e = ifnull(cli_step4e, emp_id),
		 cli_step5e = ifnull(cli_step5e, emp_id),
		 cli_user_mod = uname, cli_date_mod = current_date(), cli_call_sched = current_date()
	   where cli_id = cli_id;
	elseif step = 4 then
	   update lstclients set
		 cli_step4 = ifnull(cli_step4, current_date()),
		 cli_step4e = ifnull(cli_step4e, emp_id),
		 cli_user_mod = uname, cli_date_mod = current_date(), cli_call_sched = current_date()
	   where cli_id = cli_id;
	elseif step = 3 then
	   update lstclients set
		 cli_step1 = ifnull(cli_step1, current_date()),
		 cli_step2 = ifnull(cli_step2, current_date()),
		 cli_step3 = ifnull(cli_step3, current_date()),
		 cli_step1e = ifnull(cli_step1e, emp_id),
		 cli_step2e = ifnull(cli_step2e, emp_id),
		 cli_step3e = ifnull(cli_step3e, emp_id),
		 cli_user_mod = uname, cli_date_mod = current_date(), cli_call_sched = current_date()
	   where cli_id = cli_id;
	elseif step = 2 then
	   update lstClients set
		 cli_step1 = ifnull(cli_step1, current_date()),
		 cli_step2 = ifnull(cli_step2, current_date()),
		 cli_step1e = ifnull(cli_step1e, emp_id),
		 cli_step2e = ifnull(cli_step2e, emp_id),
		 cli_user_mod = uname, cli_date_mod = current_date(), cli_call_sched = current_date()
	   where cli_id = cli_id;
	elseif step = 1 then
	   update lstclients set
		 cli_step1 = ifnull(cli_step1, current_date()),
		 cli_step1e = ifnull(cli_step1e, emp_id),
		 cli_user_mod = uname, cli_date_mod = current_date(), cli_call_sched = current_date()
	   where cli_id = cli_id;
	else
	   update lstclients set
		 cli_steprat = rank, cli_step6e = emp_id,
		 cli_user_mod = uname, cli_date_mod = current_date(), cli_call_sched = current_date()
	   where cli_id = cli_id;
	end if;

end$$
DELIMITER ;
