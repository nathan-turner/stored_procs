DELIMITER $$
CREATE DEFINER=`phgadmin`@`%` PROCEDURE `AddImportNurse`(
/*------------------ contact info - main & home address */
name0 varchar(127), /*-- mandatory*/
title varchar(63),
phone varchar(20), ext1 char(6),
fax decimal, ext2 char(6),
cell decimal, hphone decimal,
email varchar(63),
addr_1 varchar(63), addr_2 varchar(63),  addr_c varchar(50),
   addr_z char(10), st_code char(2) /*= '--'*/ ,
/*----------------- nurse info */
type_main char(10),
bc tinyint(1) /*= 0*/ ,
bc_state varchar(50), 
experience int /*= 0*/ ,
cert varchar(255),
locums tinyint(1) /*= 0*/ ,
citizen tinyint /*=0*/ ,
licenses varchar(155),
avail datetime,
pref_states varchar(50), pref_city varchar(50),
/*----------------- system*/
user_mod char(32), date_mod datetime,
src_date datetime, note varchar(214)
)
    MODIFIES SQL DATA
begin
	declare ctid,id int;
	set id = NULL;
	if email is not null and not exists (select * from lstcontacts where ctct_email = email) then
		start transaction;
		call AddAContact (ctid,name0,title,NULL,phone,ext1,fax,ext2,
		cell,NULL,NULL,hphone,NULL,email,addr_1,addr_2,addr_c,addr_z,
		st_code,NULL,15 /* ctct_type */ ,1,user_mod,date_mod,0);
		insert into lstalliednurses
			(an_ctct_id,an_type,an_bc,
			an_bc_state,an_certificates,an_status,an_user_mod,an_date_mod,an_src_date,
			an_citizen,an_experience,
			an_licenses,an_avail,an_pref_states,an_pref_city,
			an_date_add, an_locums, an_user_add
		) values 
		(ctid,type_main,bc,bc_state,cert,1,user_mod,date_mod,src_date,
		citizen,experience,licenses,
		avail,pref_states,pref_city,date_mod,locums,user_mod
		);
		set id = LAST_INSERT_ID();
		update lstcontacts set ctct_backref = id where ctct_id = ctid;
		/*--bookkeeping*/
		insert into tnusourcesn (nsr_ctr_id,nsr_an_id,nsr_date,nsr_emp_id,nsr_source)
		values (3069,id,src_date,31,'ISC - Internet Sourcing Campaign');
		insert into allnotes (note_dt,note_user,note_ref_id,note_type,note_emp_id,note_text)
		values (date_mod,user_mod,id,15,31,CONCAT('Imported from Absolutely Healthcare: ',note));

		commit;
	end if;
/*--return id*/
	select id as `id`;

end$$
DELIMITER ;
