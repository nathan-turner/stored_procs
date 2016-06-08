DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SetSourceDate`(
 csr decimal,
 ctr decimal,
 sht tinyint,
 dt datetime,
 user char(32)
)
    MODIFIES SQL DATA
begin
-- used by srcaction4.asp

	start transaction;
	insert into  tsourcetrack (cst_csr_id,cst_date_mod,cst_user_mod,cst_status,cst_why_cancel,cst_note,  
		cst_schedule,cst_startyear,cst_appr_date,cst_date_placed,cst_dm_code,cst_dm_count,  
		cst_price)  
		select csr_id, NOW(), user,csr_status,csr_why_cancel,csr_note,  
			csr_schedule,csr_startyear,csr_appr_date,csr_date_placed,csr_dm_code,csr_dm_count,  
			csr_price from  tctrsourcesn  
		where  csr_id =  csr;
	update  tctrsourcesn set csr_appr_date =  dt, csr_status = 1, csr_user_mod =  user 
		where csr_id =  csr;

	commit;
end$$
DELIMITER ;
