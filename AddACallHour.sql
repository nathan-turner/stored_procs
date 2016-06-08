DELIMITER $$
CREATE  PROCEDURE `AddACallHour`(ext char(3),
 numin int, numout int, timein int, timeout int
)
    MODIFIES SQL DATA
begin
	declare emp int;
	select max(emp_id) into emp 
	from lstEmployees join lstcontacts on emp_ctct_id = ctct_id
	where emp_status = 1 and ctct_ext1 = ext;
	if emp is not null then
		begin
			start transaction;
			delete from tcallshour where call_emp_id = emp;
			insert into tcallshour (call_emp_id,call_date,call_numin,call_numout,call_timein,call_timeout)
				values (emp,current_date(),numin,numout,timein,timeout);
			commit;
		end;
	end if;
end$$
DELIMITER ;
