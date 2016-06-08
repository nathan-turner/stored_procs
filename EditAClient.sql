DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `EditAClient`(
 id int,
/*------------------ contact info - main & home address */
 name0 varchar(127), -- mandatory
 title varchar(63), -- additional info. Phone notes
 company varchar(63), -- Fax Notes
 phone decimal,  ext1 char(6),
 fax decimal,  ext2 char(6),
--  cell decimal,  pager decimal,  ext3 char(6),
 email varchar(128),
 addr_1 varchar(63),  addr_2 varchar(63),   addr_c varchar(50),
    addr_z char(10),  st_code char(2) /*= '--'*/ ,
 url varchar(127),
-- --------------- Client info
 xid char(10), -- old id
 sys varchar(50), -- client's system
 beds int,
clistatus int,
 grp tinyint,
 emp_id int, -- marketer
-- --------------- system
 user_mod char(32),  
 todo tinyint, -- 0 = normal, 1 = tbd, 2 = dup
 source0 tinyint /*= 11*/ ,
 popu varchar(40) /*= ' '*/ ,
 spec varchar(80) /*= ' '*/ ,
 fuz int /*= NULL*/ ,
 snot varchar(400), /*= NULL*/
 locum tinyint, -- 0
 fedtax varchar(20), -- null
date_mod datetime
)
    MODIFIES SQL DATA
begin
DECLARE usermod char(32);
SET usermod = (SELECT emp_uname from lstemployees WHERE emp_id=user_mod and emp_status=1 LIMIT 1);

	start transaction;
update  lstcontacts,lstclients set
 ctct_name =  name0, ctct_title =  title, ctct_company =  company,
 ctct_phone =  phone, ctct_ext1 =  ext1, ctct_fax =  fax, ctct_ext2 =  ext2,
 ctct_email =  email, ctct_addr_1 =  addr_1, ctct_addr_2 =  addr_2,
 ctct_addr_c =  addr_c, ctct_addr_z =  addr_z,
 ctct_st_code =  st_code, ctct_url =  url, 
 ctct_user_mod =  usermod, ctct_date_mod =  date_mod
where ctct_id=cli_ctct_id and cli_id= id and ctct_id <> 13;
if  todo = 0 then
  update  lstclients set
   cli_xid =  xid, cli_sys =  sys, cli_beds =  beds, cli_type =  grp,
   cli_emp_id =  emp_id,
   cli_user_mod =  usermod, cli_date_mod =  date_mod,
   cli_source =  source0, cli_population =  popu,
   cli_specialty =  spec, 
	cli_status=clistatus, cli_fuzion =  fuz,
   cli_specnote =  snot,
   cli_locumactive = locum, cli_fed_tax = fedtax
  where cli_id =  id;
else
  update  lstclients set
   cli_xid =  xid, cli_sys =  sys, cli_beds =  beds, cli_type =  grp,
   cli_emp_id =  emp_id,
   cli_user_mod =  usermod, cli_date_mod =  date_mod,
   cli_source =  source0, cli_population =  popu,
   cli_specialty =  spec, 
   cli_status = 11 +  todo, cli_fuzion =  fuz,
   cli_specnote =  snot,
   cli_locumactive = locum, cli_fed_tax = fedtax
  where cli_id =  id;
end if;

	commit;
end$$
DELIMITER ;
