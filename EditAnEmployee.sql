DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `EditAnEmployee`(
 id int,
-- ---------------- contact info
 name0 varchar(127),
 title varchar(63),
 phone decimal,  ext1 char(6),
 fax decimal,  
 cell decimal, 
 hphone decimal,
 addr_1 varchar(63),  addr_2 varchar(63),   addr_c varchar(50),
    addr_z char(10),  st_code char(2) /*= '--'*/ ,
 url varchar(127) /*= 'http://www.phg.com'!*/ ,
-- --------------- user info
 uname varchar(64),
 status0 tinyint(4) /*= 1*/ , -- 0 = former/retired,etc.
 admin0 tinyint(1) /*= 0*/ ,
 access0 tinyint,
 dept char(2), password0 varchar(100),
-- --------------- system
 user_mod char(32),  date_mod datetime
)
    MODIFIES SQL DATA
begin
	declare rname varchar(127);
	start transaction;
	set rname = (case when (locate(',',name0) = 0) then name0 
		else concat(substr(name0,(locate(',',name0) + 1)),' ',left(name0,(locate(',',name0) - 1))) end);

update  lstemployees set
 emp_uname= uname,emp_status= status0,emp_admin= admin0,
 emp_user_mod= user_mod,emp_date_mod= date_mod,emp_dept= dept,
 emp_access= access0, emp_realname = rname
where emp_id =  id;
update lstemployees set emp_password=
sha1(concat(emp_uname,password0,emp_realname,'Умбикири арандаш'))
where emp_id = id and password0 is not null and char_length(password0)>=6;
update  lstcontacts,lstemployees set
 ctct_name= name0,ctct_title= title,
 ctct_phone= phone,ctct_ext1= ext1,ctct_fax= fax, ctct_cell= cell,
 ctct_hphone= hphone,ctct_email= uname,
 ctct_addr_1= addr_1,ctct_addr_2= addr_2,ctct_addr_c= addr_c,
 ctct_addr_z= addr_z,ctct_st_code= st_code,ctct_url= url,
 ctct_status= status0,ctct_user_mod= user_mod,ctct_date_mod= date_mod
where emp_ctct_id = ctct_id and emp_id =  id;


	commit;

end$$
DELIMITER ;
