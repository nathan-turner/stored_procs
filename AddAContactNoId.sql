DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `AddAContactNoId`(
name0 varchar(127),
title varchar(63),
company varchar(63),
phone decimal, ext1 char(6),
fax decimal, ext2 char(6),
cell decimal, pager decimal, ext3 char(6),
hphone decimal, hfax decimal,
email varchar(63),
addr_1 varchar(63), addr_2 varchar(63),  addr_c varchar(50),
   addr_z char(10), st_code char(2) /*= '--'*/ ,
url varchar(127),
type0 tinyint /*= 0*/ , status0 int /*= 0*/ ,
user_mod char(32), date_mod datetime,
backref int /*= 0*/
)
    MODIFIES SQL DATA
begin
insert into lstcontacts (ctct_name,ctct_title,ctct_company,ctct_phone,
 ctct_ext1,ctct_fax,ctct_ext2,ctct_cell,ctct_pager,ctct_ext3,
 ctct_email,ctct_addr_1,ctct_addr_2,ctct_addr_c,ctct_addr_z,
 ctct_st_code,ctct_url,ctct_type,ctct_status,ctct_user_mod,ctct_date_mod,
 ctct_hphone,ctct_hfax,ctct_backref)
values (name0,title,company,phone,
 ext1,fax,ext2,cell,pager,ext3,
 email,addr_1,addr_2,addr_c,addr_z,
 st_code,url,type0,status0,user_mod,date_mod,
 hphone,hfax,backref);
select LAST_INSERT_ID() as id;

end$$
DELIMITER ;
