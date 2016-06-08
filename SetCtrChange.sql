DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SetCtrChange`(
 id int,
 status0 tinyint,
 type0 tinyint,
 /*dte datetime,*/
 ctr decimal,
 user char(32)
)
    MODIFIES SQL DATA
begin
	declare dte datetime;
	declare  statstr varchar(20);
	declare cliid,req int;
	declare  spc char(3);
	declare  nutype char(10);
set dte = NOW();
	start transaction;

update  tctrchanges set chg_status =  status0, chg_appr_date =  dte
  where chg_id =  id;

if  status0 = 1 and (select ctr_status from  allcontracts where ctr_id =  ctr)<>14 then

	if not exists (select * from  tctrchangesaux where cha_id =  id) then
	  insert  tctrchangesaux
		select chg_id, chg_ctr_id, ctr_pro_date, ctr_pro_sces, ctr_pro_sheet, ctr_pro_lett,
			ctr_spec, ctr_recruiter, ctr_chs_hold, ctr_chs_canc, ctr_chs_re, ctr_src_termdt, ctr_nurse, ctr_nu_type
		from  tctrchanges join allcontracts on chg_ctr_id = ctr_id where chg_id =  id;
	end if;
	if  type0 = 0 then
		update  allcontracts set ctr_chs_canc =  dte, ctr_user_mod =  user,
			ctr_pro_date = null, ctr_pro_sces = null, ctr_pro_sheet = null, ctr_pro_lett = null,
			ctr_date_mod =  dte, ctr_status = 4 where ctr_id =  ctr;
		delete from tctrsourceshed where sh_ctr_id =  ctr;

		insert into  tsourcetrack (cst_csr_id,cst_date_mod,cst_user_mod,cst_status,cst_why_cancel,cst_note,  
			cst_schedule,cst_startyear,cst_appr_date,cst_date_placed,cst_dm_code,cst_dm_count,  
			cst_price)  
			select csr_id, NOW(),user,csr_status,csr_why_cancel,csr_note,  
				csr_schedule,csr_startyear,csr_appr_date,csr_date_placed,csr_dm_code,csr_dm_count,  
				csr_price from  tctrsourcesn  
			where  csr_ctr_id =  ctr and csr_status < 2;
		update  tctrsourcesn set csr_status = 4,csr_why_cancel='Contract Cancelled',csr_date_cancel =  dte,
			csr_user_mod= user where csr_ctr_id =  ctr and csr_status < 2;
		-- cancel pendings
		update  tctrpipl set pipl_cancel = 1,pipl_date_cancel =  dte
			where pipl_ctr_id =  ctr and pipl_status = 10 and pipl_cancel = 0;
		set  statstr = ' was Cancelled';
	elseif  type0 = 1 then
		update  allcontracts set ctr_chs_hold =  dte, ctr_user_mod =  user,
			ctr_date_mod =  dte, ctr_status = 5 where ctr_id =  ctr;
		delete from tctrsourceshed where sh_ctr_id =  ctr;
		insert into  tsourcetrack (cst_csr_id,cst_user_mod,cst_status,cst_why_cancel,cst_note,  
			cst_schedule,cst_startyear,cst_appr_date,cst_date_placed,cst_dm_code,cst_dm_count,  
			cst_price)  
			select csr_id, user,csr_status,csr_why_cancel,csr_note,  
				csr_schedule,csr_startyear,csr_appr_date,csr_date_placed,csr_dm_code,csr_dm_count,  
				csr_price from  tctrsourcesn  
			where  csr_ctr_id =  ctr and csr_status < 2;
		update  tctrsourcesn set csr_status = 5,csr_why_cancel='Contract Put on Hold',csr_date_cancel =  dte,
			csr_user_mod= user where csr_ctr_id =  ctr and csr_status < 2;
		update  tctrpipl set pipl_cancel = 1,pipl_date_cancel =  dte
			where pipl_ctr_id =  ctr and pipl_status = 10 and pipl_cancel = 0;
		set  statstr = ' was Put On Hold';
	elseif  type0 = 6 then
		update  allcontracts set ctr_chs_zo =  dte, ctr_user_mod =  user,
			ctr_date_mod =  dte, ctr_status = 16 where ctr_id =  ctr;
		insert into  tsourcetrack (cst_csr_id,cst_user_mod,cst_status,cst_why_cancel,cst_note,  
			cst_schedule,cst_startyear,cst_appr_date,cst_date_placed,cst_dm_code,cst_dm_count,  
			cst_price)  
			select csr_id, user,csr_status,csr_why_cancel,csr_note,  
				csr_schedule,csr_startyear,csr_appr_date,csr_date_placed,csr_dm_code,csr_dm_count,  
				csr_price from  tctrsourcesn  
			where  csr_ctr_id =  ctr and csr_status < 2;
		set  statstr = ' Became Zombie';
	elseif  type0 = 2 or  type0 = 5 then
		update  tctrsourcesn set csr_status = 0,csr_why_cancel=null,csr_date_cancel = null,csr_revision=1,
			csr_appr_date=null,csr_startyear=year( dte),csr_schedule=null,
			csr_user_mod= user where csr_ctr_id =  ctr and csr_status = 5;
		update  tctrsourcesn set csr_status = 1,csr_why_cancel=null,csr_date_cancel = null,csr_revision=1,
			csr_appr_date= dte,csr_startyear=year( dte),csr_schedule=null,
			csr_user_mod= user where csr_ctr_id =  ctr and csr_src_id in (742,743,744,764);
		if not exists (select * from  tctrsourcesn where csr_ctr_id =  ctr and csr_src_id = 764) and
			not exists (select * from  allcontracts where ctr_nurse =1 and ctr_id =  ctr) then -- exclude midlevels
				call OrderNewSource (764,  ctr,  user, 0, 1, NULL);
		end if;
		update  allcontracts set ctr_chs_re =  dte, ctr_user_mod =  user,
			ctr_date_mod =  dte, ctr_status = 1, ctr_src_termdt =  dte 
			where ctr_id =  ctr;
		set  statstr = ' was Reactivated';
	elseif  type0 = 3 then
		select chg_spec, chg_nu_type into spc,  nutype from  tctrchanges where chg_id =  id;
		update  allcontracts set ctr_chs_spec =  dte, ctr_user_mod =  user,
			ctr_pro_date = null, ctr_pro_sces = null, ctr_pro_sheet = null, ctr_pro_lett = null,
			ctr_date_mod =  dte, ctr_spec =  spc, ctr_nu_type =  nutype, 
			ctr_src_term=0,ctr_src_termdt=null where ctr_id =  ctr;
		delete from tctrsourceshed where sh_ctr_id =  ctr;
		insert into  tsourcetrack (cst_csr_id,cst_user_mod,cst_status,cst_why_cancel,cst_note,  
			cst_schedule,cst_startyear,cst_appr_date,cst_date_placed,cst_dm_code,cst_dm_count,  
			cst_price)  
			select csr_id, user,csr_status,csr_why_cancel,csr_note,  
				csr_schedule,csr_startyear,csr_appr_date,csr_date_placed,csr_dm_code,csr_dm_count,  
				csr_price from  tctrsourcesn  
			where  csr_ctr_id =  ctr and csr_status < 2 and csr_src_id not in (742,743,744,764);
		update  tctrsourcesn set csr_status = 4-csr_status,csr_why_cancel='Specialty Changed',csr_date_cancel =  dte,
			csr_user_mod= user where csr_ctr_id =  ctr and csr_status <= 1 and csr_src_id not in (742,743,744,764);
		set  statstr = concat('\'s Specialty Changed to ', spc,' ', nutype);
	elseif  type0 = 4 then
		select chg_req into req from  tctrchanges where chg_id =  id;
		update  allcontracts set ctr_chs_req =  dte, ctr_user_mod =  user, ctr_recruiter =  req, 
			ctr_manager= req, ctr_date_mod =  dte where ctr_id =  ctr;
		set  statstr = '\'s Recruiter Changed';
	end if;
	select ctr_cli_id into cliid from  allcontracts where ctr_id =  ctr;
	insert into  allnotes (note_dt,note_user,note_ref_id,note_type,note_emp_id,note_text,note_reserved) values
		( dte, user, cliid,2,31,
		concat('<b>Automatic Note:</b> <a href="ctrchange4.asp?chg_id=',cast( id as char),
			'">Contract', statstr,'</a> '), ctr);
	-- pipl type = 5
	if  type0 = 5 then
		update  tctrpipl,tctrchanges t set pipl_cancel = 1
			where pipl_id = t.chg_reserved and t.chg_id =  id;
	end if;
end if; -- if status = 1

	commit;
end$$
DELIMITER ;
