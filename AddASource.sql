DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `AddASource`(
/*----source info*/
sname varchar(64), /*-- mandatory*/
rating real,
price decimal(19,4),
pricing varchar(50),
spec varchar(450),
stype tinyint,
/*------------------ contact info - main & home address*/
name0 varchar(127), /*-- optional. if none, then do not insert contact.*/
title varchar(63), 
company varchar(63), 
phone decimal, ext1 char(6),
fax decimal, ext2 char(6),
phone2 decimal, ext3 char(6),
fax2 decimal,
email varchar(63),
addr_1 varchar(63), addr_2 varchar(63),  addr_c varchar(50),
   addr_z char(10), st_code char(2) /*= '--'*/ ,
url varchar(127),
/*----------------- system*/
user_mod char(32), date_mod datetime,
quot tinyint(1) /*= 0*/ , 
propos tinyint(1) /*= 0*/ ,
target varchar(127) /*= 'All'*/ ,
webuser varchar(50) /*= null*/ ,
webpass varchar(50) /*= null*/ ,
webcv tinyint(1) /*= 0*/ ,
circa int /*= 0*/ ,
publish smallint /*= 0*/ ,
mpdesc varchar(870) /*= null*/ ,
presto tinyint(1) /*= 0*/ , monthly tinyint(1) /*= 0*/
)
    MODIFIES SQL DATA
begin
	declare ctid,id int;
	start transaction;

	insert into  tsources (src_name, src_rating, src_price, src_pricing, 
		src_sp_code, src_type, src_user_mod, src_date_mod, src_quota,
		src_target, src_webuser, src_webpass, src_webcv, src_proposal,
		src_circulation,src_published,src_mp_descr,src_estprice,src_monthly)
	values (
		sname, rating, price, pricing, spec, stype, user_mod, date_mod, quot,
		target,webuser,webpass,webcv, propos,circa,publish,mpdesc,presto,monthly);
	set id = LAST_INSERT_ID();

	if name0 is not null and name0 <> '' then 
		call AddAContact (ctid,name0,title,company,phone,ext1,fax,ext2,
			NULL,NULL,ext3, phone2,fax2,email,addr_1,addr_2,addr_c,addr_z,
			st_code,url,11 /* ctct_type */ ,1,user_mod,date_mod,id);
		update tsources set src_ctct_id = ctid where src_id = id;
	END if;
	commit;
/*--DOES NOT return id*/
	select id;

end$$
DELIMITER ;
