DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `AddAPhysician`(
/*------------------ contact info - main & home address */
name0 varchar(127), /*-- mandatory*/
title varchar(63),
company varchar(63), /*-- unused*/
phone decimal, ext1 char(6),
fax decimal, ext2 char(6),
cell decimal, pager decimal, ext3 char(6),
hphone decimal, hfax decimal,
email varchar(63),
addr_1 varchar(63), addr_2 varchar(63),  addr_c varchar(50),
   addr_z char(10), st_code char(2) /*= '--'*/ ,
/*--@url varchar(127),*/
/*------------------ contact info - work address - UNUSED *** */
/*--@wemail varchar(63), */
waddr_1 varchar(63), waddr_2 varchar(63),  waddr_c varchar(50),
   waddr_z char(10), wst_code char(2) /*= '--'*/ ,
wurl varchar(127), 
/*----------------- Physisian info*/
/*--@marital tinyint = 0, -- single*/
/*--@children tinyint = 0, -- not more than 255 :)*/
spec_main char(3), /*--@spec_aux char(3),*/
spm_bc char(2), /*--@spa_bc char(2),*/
spm_year smallint, /*--@spa_year smallint,*/
med_school varchar(90),
status0 tinyint /*= 1, -- bound to contactStatus, too*/ ,
cv_url varchar(127), cv_date datetime,
recruiter int, /*-- who is this? can't remember/ see also ph_prot_emp field*/
/*--@old_id decimal,*/
practice tinyint /*= 0*/ ,
DOB datetime,
sex tinyint /*= 0, -- 1 male 0 female*/ ,
locums tinyint /*= 0*/ ,
citizen char(3),
lang char(64),
v_skills tinyint /*= 0, -- 0 = none, etc.*/ ,
/*--@hometown varchar(50), @homestate char(2),*/
licenses varchar(50),
first_inq datetime, /*-- ph_1st_inq*/
avail datetime,
pref_state char(2), pref_region tinyint,
/*----------------- system*/
user_mod char(32), date_mod datetime,
sub tinyint /*= 0*/ ,
subspec varchar(50) /*= null*/ ,
skill char(2) /*= null*/ ,
cv_text longtext
)
    MODIFIES SQL DATA
    COMMENT 'first version was 09.07.2001; needs revision'
begin
	declare ctid,id, wctid int;
	start transaction;
	call AddAContact (ctid,name0,title,company,phone,ext1,fax,ext2,
		cell,pager,ext3,hphone,hfax,email,addr_1,addr_2,addr_c,addr_z,
		st_code,NULL,3 /* ctct_type */ ,status0,user_mod,date_mod,0);
	insert into  lstphysicians
 (ph_ctct_id,ph_spec_main,ph_spm_bc,
  ph_spm_year,ph_med_school,ph_status,ph_cv_url,ph_user_mod,ph_date_mod,ph_recruiter,
  ph_practice,ph_DOB,ph_sex,ph_citizen,ph_lang,ph_v_skills,
  ph_licenses,ph_workaddr,ph_1st_inq,ph_avail,ph_cv_date,ph_pref_state,ph_pref_region,
  ph_user_add,ph_date_add, ph_sub, ph_subspec, ph_locums,ph_skill,ph_cv_text
 )
	values 
 (ctid,spec_main,spm_bc,spm_year,
  med_school,status0,cv_url,user_mod,date_mod,recruiter,practice,DOB,sex,
  citizen,lang,v_skills,licenses,NULL,first_inq,
  avail,cv_date,pref_state,pref_region,user_mod,date_mod,
  sub, subspec, locums, skill, cv_text
 );
	set id = LAST_INSERT_ID();
	update lstcontacts set ctct_backref = id where ctct_id = ctid;

	call AddAContact (wctid,name0,title,company,phone,ext1,fax,ext2,
		cell,pager,ext3,hphone,hfax,email,waddr_1,waddr_2,waddr_c,waddr_z,
		wst_code,NULL,7 /* ctct_type */ ,status0,user_mod,date_mod,id);
	
	/*SET wctid=LAST_INSERT_ID();*/
	update lstphysicians set ph_workaddr=wctid, ph_user_mod= user_mod, ph_date_mod=NOW() WHERE ph_id=id LIMIT 1;

	commit;
/*--return id*/
	select id as `id`;

end$$
DELIMITER ;
