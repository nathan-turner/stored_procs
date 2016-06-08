DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `AddImportPhys3`(
name0 varchar(127), /*-- mandatory*/
title varchar(63),
phone varchar(30), ext1 char(6),
fax decimal, ext2 char(6),
cell varchar(30), hphone varchar(30),
email varchar(63),
addr_1 varchar(63), addr_2 varchar(63),  addr_c varchar(50),
   addr_z char(10), st_code char(2) /*= '--'*/ ,
/*----------------- Physisian info*/
spec_main char(3), 
spm_bc char(2), 
practice tinyint /*= 0*/ ,
locums tinyint(1) /*= 0*/ ,
citizen char(3),
licenses varchar(50),
avail datetime,
pref_state char(2),
src_date datetime,
/*----------------- system*/
user_mod char(32), date_mod datetime,
sub tinyint(1) /*= 0*/ ,
subspec varchar(50) /*= null*/ ,
skill char(2) /*= null*/ ,
note varchar(214)
)
BEGIN

declare ctid,id int;
	set id = NULL;
SET locums=1;
	if  not exists (select * from lstcontacts where ctct_name = name0) then
		start transaction;
		call AddAContact (ctid,name0,title,NULL,phone,ext1,fax,ext2,
		cell,NULL,NULL,hphone,NULL,email,addr_1,addr_2,addr_c,addr_z,
		st_code,NULL,3 /* ctct_type */ ,1,user_mod,date_mod,0);
		insert into  lstphysicians
		 (ph_ctct_id,ph_spec_main,ph_spm_bc,
		  ph_status,ph_user_mod,ph_date_mod,ph_src_date,
		  ph_practice,ph_citizen,
		  ph_licenses,ph_avail,ph_pref_state,ph_pref_region,
		  ph_user_add,ph_date_add, ph_sub, ph_subspec, ph_locums,ph_skill
		 )
		values 
		 (ctid,spec_main,spm_bc,1,user_mod,date_mod,src_date,
		  practice,citizen,licenses,avail,pref_state,0,user_mod,date_mod,
		  sub, subspec, locums,skill
		 );

		set id = LAST_INSERT_ID();
		update lstcontacts set ctct_backref = id where ctct_id = ctid;
		/*--bookkeeping*/
		insert into tphsourcesn (psr_ctr_id,psr_ph_id,psr_date,psr_emp_id,psr_source)
		values (4317,id,src_date,31,'ISC - Internet Sourcing');
		insert into allnotes (note_dt,note_user,note_ref_id,note_type,note_emp_id,note_text)
		values (date_mod,user_mod,id,3,31,CONCAT('Internet Sourcing Bulk Import: ',note));

		insert into tmp4 (phid, date_add) values (id, NOW());
		commit;
	end if;
/*--return id*/
	select id as `id`;

END$$
DELIMITER ;
