DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `EditAContRact`(
 id decimal,  cliid int,
 cno char(25),   cbill int,
 cdate datetime,  cspec char(3),
 cstatus tinyint(4) /*= 1*/ ,
 crecruiter int,  cmanager int,   camount decimal(19,4),
 cmonthly decimal(19,4),  cguarantee int,
 clocationc varchar(50), clocations char(2) /*= '--'*/ ,
 cuser_mod char(32),  cdate_mod datetime,
 ctype char(2),  cmarketer int /*= 31*/ ,
-- added 09/27/05
 cretain datetime /*= NULL*/ ,  csnote varchar(255) /*= NULL*/ ,
 cnomk tinyint(1) /*= 0*/ ,
-- added 09/07/11
 cnurse tinyint(1) /*= 0*/ ,  cnutype char(10) /*= NULL*/ ,  cwk tinyint(1) /*= 1*/
)
    MODIFIES SQL DATA
begin
	declare  oldbill int;

	IF cbill='' OR cbill<=0 OR ISNULL(cbill) THEN
		SET cbill=NULL;
	END IF;
	select ctr_cli_bill into oldbill from  allcontracts where ctr_id =  id;
	set oldbill = nullif(oldbill,cbill);
	
	start transaction;
/*select ctr_cli_bill, oldbill, cbill from  allcontracts where ctr_id =  id;*/
	update  allcontracts set
	 ctr_no= cno, ctr_cli_bill= cbill, ctr_date= cdate, ctr_spec= cspec,
	 ctr_status= cstatus, ctr_recruiter= crecruiter, ctr_amount= camount,
	 ctr_monthly= cmonthly, ctr_guarantee= cguarantee,
	 ctr_location_c= clocationc, ctr_location_s= clocations,
	 ctr_user_mod= cuser_mod, ctr_date_mod= cdate_mod, ctr_type= ctype,
	 ctr_manager= cmanager, ctr_marketer =  cmarketer,
	 ctr_retain_date =  cretain, ctr_shortnote =  csnote,
	 ctr_nomktg =  cnomk, ctr_nurse =  cnurse, ctr_nu_type =  cnutype,
	 ctr_wkupdate =  cwk
	where ctr_id =  id;
	-- now, update a client status(es)
	update  lstclients set cli_status = 10 where (cli_id <=> oldbill)
        and not exists (
			select * from  allcontracts where (ctr_cli_id = cli_id
			or ctr_cli_bill = cli_id) and ctr_status = 1
        );
	-- wow, there already is a trigger that does the below thing... but there's no harm
	if  cstatus = 1 then -- active
		update  lstclients set cli_status = 1 where cli_id =  cliid or cli_id <=> cbill;
	else -- Hold, Cancel, etc. -- client goes to inactive if no other active contracts
		update  lstclients set cli_status = 10 where 
			(cli_id =  cliid or cli_id <=> cbill)
			and not exists (
				select * from  allcontracts where (ctr_cli_id = cli_id
				or ctr_cli_bill = cli_id) and ctr_status = 1
			);
	end if;

	commit;
end$$
DELIMITER ;
