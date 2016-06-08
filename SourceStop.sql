DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SourceStop`(
 csrid int,
 stus tinyint,
 why varchar(63),
 user char(32) 
)
    MODIFIES SQL DATA
begin
-- deactivate, admin cancel or hold of approved src
	declare  olds tinyint;
	declare  ctrid,  termd datetime;
	start transaction;

	delete from tctrsourceshed where sh_csr_id =  csrid;

	insert into  tsourcetrack (cst_csr_id,cst_date_mod,cst_user_mod,cst_status,cst_why_cancel,cst_note,  
		cst_schedule,cst_startyear,cst_appr_date,cst_date_placed,cst_dm_code,cst_dm_count,  
		cst_price)  
		select csr_id, NOW(),user,csr_status,csr_why_cancel,csr_note,  
			csr_schedule,csr_startyear,csr_appr_date,csr_date_placed,csr_dm_code,csr_dm_count,  
			csr_price from  tctrsourcesn  
		where  csr_id =  csrid;

	select csr_status, csr_ctr_id into olds, ctrid from  tctrsourcesn   where  csr_id =  csrid;
	if  olds = 5 then
		select  ctr_src_termdt into termd from  allcontracts where ctr_id =  ctrid;
		update  tctrsourcesn set csr_status =  stus,csr_schedule=null,csr_startyear=year( termd),
			csr_appr_date=null,csr_revision=1, csr_user_mod= user where csr_id =  csrid;
	elseif  stus = 4 then
		update  tctrsourcesn set csr_status =  stus,csr_why_cancel= why,csr_date_cancel = curdate(),
			csr_user_mod= user where csr_id =  csrid;
	else
		update  tctrsourcesn set csr_status =  stus,csr_why_cancel= why,csr_date_cancel = curdate(),
			csr_appr_date=null,csr_revision=1, csr_user_mod= user where csr_id =  csrid;
	end if;

	commit;
end$$
DELIMITER ;
