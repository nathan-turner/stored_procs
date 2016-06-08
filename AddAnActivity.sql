DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `AddAnActivity`(
user_mod char(32), 
act_type tinyint, src_emp int, trg_emp int, trg_date datetime,
db_ref decimal, ref_type tinyint,
notes varchar(255), ctct_id int
)
    MODIFIES SQL DATA
begin
	declare nomeet tinyint;
	start transaction;

	insert into  allactivities (aact_date_mod,aact_user_mod,
		aact_act_code,aact_src_emp_id,aact_trg_emp_id,aact_trg_dt,
		aact_ref1,aact_ref_type1,aact_shortnote,aact_ctct_id)
	values ( current_date(), user_mod, act_type, src_emp, trg_emp,
		trg_date, db_ref, ref_type, notes, ctct_id
	);

	set nomeet=case act_type when 9 then 1 when 11 then 1 else 0 end;

	if act_type in (6,7,9,11) and ref_type = 2 then
		insert into tclimeetings (cm_cli_id, cm_emp_id, cm_date,
			cm_user_mod, cm_date_mod,cm_shortnote, cm_nomeet)
		values ( db_ref, trg_emp, trg_date, user_mod, current_date(), notes, nomeet);
	end if;
	commit;

end$$
DELIMITER ;
