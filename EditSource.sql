DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `EditSource`(
 srcid int, -- mandatory
-- --source info
 sname varchar(64), -- mandatory
 rating real,
 price decimal(19,4),
 pricing varchar(50),
 spec varchar(450),
 stype tinyint,
-- ---------------- contact info - main & home address
 name0 varchar(127), -- optional. if none, then delete or do not insert contact.
 title varchar(63), 
 company varchar(63), 
 phone decimal,  ext1 char(6),
 fax decimal,  ext2 char(6),
 phone2 decimal,  ext3 char(6),
 fax2 decimal,
 email varchar(63),
 addr_1 varchar(63),  addr_2 varchar(63),   addr_c varchar(50),
    addr_z char(10),  st_code char(2) /*= '--'*/ ,
 url varchar(127),
-- --------------- system
 user_mod char(32),  date_mod datetime,
-- --------------- src again
 quot tinyint(1) /*= 0*/ ,
 propos tinyint(1) /*= 0*/ ,
 target varchar(127) /*= 'All'*/ ,
 webuser varchar(50) /*= null*/ ,
 webpass varchar(50) /*= null*/ ,
 webcv tinyint(1) /*= 0*/ ,
 circa int /*= 0*/ ,
 publ smallint /*= 0*/ ,
 mpdesc varchar(870) /*= null*/ ,
 presto tinyint(1) /*= 0*/ ,  monthly tinyint(1) /*= 0*/
)
    MODIFIES SQL DATA
begin
	declare  ctid int; 
	start transaction;

	select src_ctct_id into ctid from  tsources where src_id =  srcid;
	update  tsources set src_name= sname, src_rating= rating,
	 src_price= price, src_pricing= pricing, 
	 src_sp_code= spec, src_type= stype, 
	 src_user_mod= user_mod, src_date_mod= date_mod,
	 src_quota =  quot, src_target =  target,
	 src_webuser =  webuser, src_webpass =  webpass, src_webcv =  webcv,
	 src_proposal =  propos, src_circulation =  circa, src_published =  publ,
	 src_mp_descr =  mpdesc, src_estprice =  presto, src_monthly =  monthly
	where src_id =  srcid;

-- if  ctid is null and  name is not, insert contact
	IF ctid is null and  name0 is not null and  name0 <> '' then
		call AddAContact (ctid, name0, title, company, phone, ext1, fax, ext2,
			NULL,NULL, ext3, -- cell, pager, ext3,
			phone2, fax2, email, addr_1, addr_2, addr_c, addr_z,
			st_code, url,11 /* ctct_type */ ,1, user_mod, date_mod, srcid);
		update tsources set src_ctct_id =  ctid where src_id =  srcid;

-- if  ctid is not null and  name is not null, update contact
	ELSEIF ctid is not null and name0 is not null and name0 <> '' then
	  update  lstcontacts set
		ctct_name =  name0, ctct_title= title, ctct_company= company,
		ctct_phone= phone, ctct_ext1= ext1, ctct_fax= fax,
		ctct_ext2= ext2, ctct_ext3= ext3, ctct_hphone= phone2,
		ctct_hfax= fax2, ctct_email= email, ctct_addr_1= addr_1,
		ctct_addr_2= addr_2, ctct_addr_c= addr_c, ctct_addr_z= addr_z,
		ctct_st_code= st_code, ctct_url= url,
		ctct_user_mod= user_mod, ctct_date_mod= date_mod
	  where ctct_id =  ctid;

-- if  ctid is not null and  name is, delete contact
	ELSEIF ctid is not null and (name0 is null or name0 = '') then
		update  tsources set src_ctct_id = NULL where src_id =  srcid;
		delete from  lstcontacts where ctct_id= ctid;
	END IF;

	commit;
end$$
DELIMITER ;
