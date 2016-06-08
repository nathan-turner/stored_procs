DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SourcingEnd`(
 ctr decimal,
 dt datetime,
 user char(32),
 automat int /*= 0*/
)
    MODIFIES SQL DATA
begin
-- premature ending of sourcing campaign
-- new version 9/13/7
	start transaction;

if automat = 1 then
   -- delete  tCtrSourceShed where sh_ctr_id =  ctr

   insert into  tsourcetrack (cst_csr_id,cst_date_mod,cst_user_mod,cst_status,cst_why_cancel,cst_note,  
      cst_schedule,cst_startyear,cst_appr_date,cst_date_placed,cst_dm_code,cst_dm_count,  
      cst_price)  
   select csr_id, NOW(), user,csr_status,csr_why_cancel,csr_note,  
     csr_schedule,csr_startyear,csr_appr_date,csr_date_placed,csr_dm_code,csr_dm_count,  
     csr_price from  tctrsourcesn  join  allcontracts on csr_ctr_id = ctr_id
   where csr_ctr_id =  ctr and ((csr_src_id not in (742,743,744,764) and (ifnull(ctr_nurse,0)=0 or ctr_nurse<>1)) or (csr_src_id not in (742,743,744) and ctr_nurse=1)) and csr_status = 1;

   update  tctrsourcesn set 
     csr_status = 4, csr_user_mod =  user, csr_date_cancel =  dt, csr_why_cancel = '[auto] campaign finished'
     where csr_ctr_id =  ctr and csr_src_id not in (742,743,744,764);

   update  tctrsourcesn,allcontracts set 
     csr_status = 4, csr_user_mod =  user, csr_date_cancel =  dt, csr_why_cancel = '[auto] campaign finished'
     where csr_ctr_id =  ctr and csr_ctr_id = ctr_id and ctr_nurse=1 and csr_src_id = 764;

   update  allcontracts set ctr_src_term=0, ctr_src_termdt = null,ctr_user_mod= user,ctr_date_mod=curdate()
       where ctr_id =  ctr;
else
	update  tctrsourcesn set 
	  csr_status = 4, csr_user_mod =  user, csr_date_cancel =  dt, csr_why_cancel = concat(rtrim( user),' requested a replacement campaign')
	  where csr_ctr_id =  ctr and csr_status <> 1 and csr_src_id not in (742,743,744,764);

   update  tctrsourcesn,allcontracts set 
     csr_status = 4, csr_user_mod =  user, csr_date_cancel =  dt, csr_why_cancel = concat(rtrim( user),' requested a replacement campaign')
     where csr_ctr_id =  ctr and csr_ctr_id = ctr_id and ctr_nurse=1 and csr_src_id = 764;

	update  allcontracts set ctr_src_term=0, ctr_src_termdt = null,ctr_user_mod= user,ctr_date_mod=curdate()
    where ctr_id =  ctr and not exists
	(select * from  tctrsourcesn where csr_ctr_id =  ctr and csr_status = 1 and csr_src_id not in (742,743,744,764));
end if;

	commit;
end$$
DELIMITER ;
