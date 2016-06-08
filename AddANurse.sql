DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `AddANurse`(
/*------------------ contact info - main & home address */
name0 varchar(127), /*-- mandatory*/
title varchar(63),
phone decimal, ext1 char(6),
fax decimal, ext2 char(6),
cell decimal, pager decimal, ext3 char(6),
hphone decimal, hfax decimal,
email varchar(63),
addr_1 varchar(63), addr_2 varchar(63),  addr_c varchar(50),
   addr_z char(10), st_code char(2) /*= '--'*/ ,
/*----------------- nurse info */
type_main char(10),
bc tinyint /*= 0*/ ,
bc_state varchar(50), 
cert varchar(255),
status0 tinyint /*= 1, -- bound to contactStatus, too*/ ,
cv_url varchar(255),
experience tinyint /*= 0*/ ,
DOB datetime,
sex tinyint /*= 0, -- 1 male 0 female*/ ,
locums tinyint /*= 0*/ ,
citizen tinyint /*=0*/ ,
lang varchar(80),
licenses varchar(155),
dea tinyint /*=0*/ ,
avail datetime,
pref_states varchar(50), pref_city varchar(50),
/*----------------- system*/
user_mod char(32), date_mod datetime
)
    MODIFIES SQL DATA
begin
	declare ctid,id int;
	SET date_mod=NOW();
	start transaction;
	call AddAContact (ctid,name0,title,NULL,phone,ext1,fax,ext2,
		cell,pager,ext3,hphone,hfax,email,addr_1,addr_2,addr_c,addr_z,
		st_code,NULL,15 /* ctct_type */ ,status0,user_mod,date_mod,0);
	insert into lstalliednurses
 (an_ctct_id,an_type,an_bc,
  an_bc_state,an_certificates,an_status,an_cv_url,an_user_mod,an_date_mod,
  an_experience,an_dob,an_sex,an_citizen,an_lang,an_dea,
  an_licenses,an_avail,an_pref_states,an_pref_city,
  an_date_add, an_locums, an_user_add
 )
	values 
 (ctid,type_main,bc,bc_state,cert,status0,cv_url,user_mod,date_mod,
  experience,DOB,sex,citizen,lang,dea,licenses,
  avail,pref_states,pref_city,date_mod,locums,user_mod
 );
	set id = LAST_INSERT_ID();
	update lstcontacts set ctct_backref = id where ctct_id = ctid;
	commit;
/*--return id*/
	select id as `id`;

end$$
DELIMITER ;
