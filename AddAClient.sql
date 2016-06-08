DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `AddAClient`(/*OUT id int,*/
/*------------------ contact info - main & home address */
name0 varchar(127), /*-- mandatory */
title varchar(63), /*-- additional info. Phone notes */
company varchar(63), /*-- Fax Notes */
phone decimal, ext1 char(6),
fax decimal, ext2 char(6),
/*-- @cell decimal, @pager decimal, @ext3 char(6),*/
email varchar(63),
addr_1 varchar(63), addr_2 varchar(63),  addr_c varchar(50),
   addr_z char(10), st_code char(2) /*= '--'*/ ,
url varchar(127),
/*----------------- Client info*/
xid char(10), /*-- old id*/
sys varchar(50), /*-- client's system*/
beds int,
grp char(10),
$emp_id int, /*-- marketer*/
status0 tinyint /*= 1, -- bound to ctct_status, too */ ,
/*----------------- system*/
user_mod char(32), date_mod datetime
)
    MODIFIES SQL DATA
begin

	declare ctid int;
    declare id int; /*remove*/
    DECLARE usermod char(32);
	SET usermod = (SELECT emp_user_mod from lstemployees WHERE emp_id=user_mod);

	start transaction;
	call AddAContact (ctid,name0,title,company,phone,ext1,fax,ext2,
		NULL,NULL,NULL,NULL,NULL, /*--@cell,@pager,@ext3,@hphone,@hfax*/
		email,addr_1,addr_2,addr_c,addr_z,
		st_code,url,2 /* ctct_type */ ,status0,usermod,date_mod,0);
	insert into lstclients (cli_xid,cli_ctct_id,cli_sys,cli_beds,cli_grp,cli_emp_id,
		cli_status,cli_user_mod,cli_date_mod,cli_user_add,cli_date_add)
	values 
		(xid,ctid,sys,beds,grp,$emp_id,status0,usermod,date_mod,usermod,date_mod);
	set id = LAST_INSERT_ID();

	update lstcontacts set ctct_backref = id where ctct_id = ctid;
	commit;
	select id;
end$$
DELIMITER ;
