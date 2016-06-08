DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `AddAnEmployeeNoId`(
/*------------------ contact info*/
name0 varchar(127),
title varchar(63),
/*company varchar(63) = 'Pinnacle Health Group',*/
phone decimal, ext1 char(6),
fax decimal,
cell decimal, /* pager decimal, ext3 char(6), */
hphone decimal,
addr_1 varchar(63), addr_2 varchar(63), addr_c varchar(50),
   addr_z char(10), st_code char(2) /*= '--'*/ ,
url varchar(127) /*= 'http://www.phg.com'*/ ,
/*----------------- user info*/
uname varchar(64),
status0 tinyint /*= 1, -- 0 = former/retired,etc.*/ ,
admin0 tinyint(1) /*= 0*/ ,
access0 tinyint,
dept char(2), password0 varchar(100),
/*----------------- system*/
user_mod char(32), date_mod datetime
)
    MODIFIES SQL DATA
begin
	declare ctid,id int;
    declare rname varchar(127);

	start transaction;

	call AddAContact (ctid,name0,title,'Pinnacle Health Group',phone,ext1,fax,null,
		cell,NULL,NULL,hphone,null,uname,addr_1,addr_2,addr_c,addr_z,
		st_code,url,1 /* ctct_type */ ,status0,user_mod,date_mod,0);
	set rname = (case when (locate(',',name0) = 0) then name0 
		else concat(substr(name0,(locate(',',name0) + 1)),' ',left(name0,(locate(',',name0) - 1))) end);
	insert into lstemployees
		(emp_uname,emp_status,emp_ctct_id,emp_admin,emp_user_mod,emp_date_mod,emp_dept,
		 emp_access,emp_password,emp_realname)
	values (uname,status0,ctid,admin0,user_mod,date_mod,dept,access0,
			(sha1(concat(uname,password0,rname))),rname);
			/*(sha1(concat(uname,password0,rname,'Умбикири арандаш'))),rname);*/
	set id = LAST_INSERT_ID();
	update lstcontacts set ctct_backref = id where ctct_id = ctid;

	commit;

end$$
DELIMITER ;
