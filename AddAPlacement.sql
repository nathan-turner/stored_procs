DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `AddAPlacement`(
/*-- for tPlacement*/
sent_date datetime, /*-- null*/
date1 datetime, /*-- -> pl_date*/
ref_emp int, /*-- null*/
source0 varchar(80), /*-- null*/
term varchar(20), /*--null*/
guar_net tinyint(1), guar_gross tinyint(1),
annual decimal(19,4), guar decimal(19,4), /*-- null,null*/
incent tinyint(1), met_coll tinyint(1), met_pro tinyint(1), met_num tinyint(1),
met_oth varchar(50), /*-- null*/
partner tinyint(1),
partner_yrs varchar(20), buyin varchar(30), /*-- null,null*/
based_ass tinyint(1), based_rec tinyint(1), based_sto tinyint(1),
based_oth varchar(50), /*-- null*/
loan tinyint(1),
vacat smallint, cme_wks smallint, /*-- null,null*/
cme decimal(19,4), reloc decimal(19,4), /*-- null,null*/
health tinyint(1), dental tinyint(1), fam_health tinyint(1), fam_dental tinyint(1),
st_dis tinyint(1), lt_dis tinyint(1), life tinyint(1),
oth_ben varchar(1023), /*-- null*/
replacement tinyint(1), emp_id int,
signing decimal(19,4), exp_years tinyint,
split int,
src_id decimal,
/*-- success story*/
text1 varchar(8000) /*= null*/ ,
text2 varchar(8000) /*= null*/ ,
text3 varchar(8000) /*= null*/ ,
text4 varchar(8000) /*= null*/ ,
/*-- appendix*/
user_mod char(32), date_mod datetime,
/*-- for tCtrPIPL*/
ctrid decimal, /*-- emp_id,*/
phid int, /*-- date1 -> pipl_date*/
anid int /*= NULL*/
)
    MODIFIES SQL DATA
begin
	declare plid decimal;
	declare pist,nurse tinyint;
	set pist = if(replacement = 1,5,4);
	start transaction;
	update allcontracts set ctr_status = 7+replacement,ctr_user_mod = user_mod, ctr_date_mod = date_mod
		where ctr_id = ctrid;
	delete from tctrsourceshed where sh_ctr_id = ctrid;
	insert into tsourcetrack (cst_csr_id,cst_user_mod,cst_status,cst_why_cancel,cst_note,  
		cst_schedule,cst_startyear,cst_appr_date,cst_date_placed,cst_dm_code,cst_dm_count,  
		cst_price)  
		select csr_id,user_mod,csr_status,csr_why_cancel,csr_note,  
			csr_schedule,csr_startyear,csr_appr_date,csr_date_placed,csr_dm_code,csr_dm_count,  
			csr_price from  tctrsourcesn  
			where  csr_ctr_id = ctrid and csr_status < 2;
	update tctrsourcesn set csr_status = 4-csr_status, csr_why_cancel='Placement', csr_date_cancel = date1,
		csr_user_mod = user_mod where csr_ctr_id = ctrid and csr_status <= 1;

	set nurse=if( anid is NULL, 0, 1);

	insert into  tCtrPIPL (pipl_ctr_id,pipl_emp_id,pipl_ph_id,pipl_status,pipl_date,pipl_an_id,pipl_nurse)
		values (ctrid,emp_id,phid,pist,date1,anid,nurse);
	set plid = LAST_INSERT_ID();
	insert into tplacements values (
		plid,sent_date,date1,ref_emp,src_id,term,guar_net, guar_gross,annual, guar,
		incent, met_coll, met_pro, met_num,met_oth,partner,partner_yrs, buyin,
		based_ass, based_rec, based_sto,based_oth,loan,vacat, cme_wks,cme, reloc,
		health, dental, fam_health, fam_dental,st_dis, lt_dis, life,oth_ben,
		replacement, emp_id,user_mod, date_mod,signing,source0,exp_years,split,
		text1,text2,text3,text4
	);

	if nurse = 1 then
		update lstalliednurses set an_status = 7+replacement,
			an_user_mod = user_mod, an_date_mod = date_mod
		where an_id = anid;
		update tctrpipl set pipl_cancel = 1,pipl_date_cancel = date_mod
		where (pipl_ctr_id = ctrid or pipl_an_id=anid) and pipl_status = 10 and pipl_cancel = 0;
	else
		update lstphysicians set ph_status = 7+replacement,
			ph_user_mod = user_mod, ph_date_mod = date_mod
		where ph_id = phid;
		update tctrpipl set pipl_cancel = 1,pipl_date_cancel = date_mod
		where (pipl_ctr_id = ctrid or pipl_ph_id=phid) and pipl_status = 10 and pipl_cancel = 0;
	end if;

	commit;
/*--return id*/
	select plid as `pl_id`;

end$$
DELIMITER ;
