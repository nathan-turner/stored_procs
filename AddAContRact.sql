DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `AddAContRact`(cliid int, /*-- mandatory*/
cno char(25),  cbill int,
cdate datetime, cspec char(3),
cstatus tinyint /*= 1*/ , cmarketer int,
crecruiter int,  camount decimal(19,4),
cmonthly decimal(19,4), cguarantee int,
clocationc varchar(50), clocations char(2) /*= '--'*/ ,
cuser_mod char(32), cdate_mod datetime,
ctype char(2),
/*-- added 09/27/05 */
cretain datetime /*= NULL*/ , csnote varchar(255) /*= NULL*/ ,
/* -- added 09/07/11 */
nurse int /*= 0*/ , nu_type char(10) /*= NULL*/
)
    MODIFIES SQL DATA
begin
	declare ctrid decimal;

	start transaction;
	/*-- insert a contract first*/
	insert into  allcontracts (
 ctr_no, ctr_cli_id, ctr_cli_bill, ctr_date, ctr_spec, ctr_status,
 ctr_marketer, ctr_recruiter, ctr_amount, ctr_monthly, ctr_guarantee,
 ctr_location_c, ctr_location_s, ctr_user_mod, ctr_date_mod, ctr_type, ctr_retain_date, ctr_shortnote,
 ctr_nurse, ctr_nu_type
	) values (
 cno, cliid, cbill, cdate, cspec, cstatus,
 cmarketer, crecruiter, camount, cmonthly, cguarantee,
 clocationc, clocations, cuser_mod, cdate_mod, ctype, cretain, csnote,
 nurse, nu_type
	);
	set ctrid = LAST_INSERT_ID();
	/*-- now, update a client status(es)*/
	if cstatus = 1 then /*-- active*/
		update  lstclients set cli_status = 1, cli_locumactive = if(ctype = 'LT',1,cli_locumactive)
			where cli_id = cliid or cli_id <=> cbill;
		call OrderNewSource (742, ctrid, cuser_mod, 0, 1, null);
		call OrderNewSource (743, ctrid, cuser_mod, 0, 1, null);
		call OrderNewSource (744, ctrid, cuser_mod, 0, 1, null);
		if nurse = 0 and ctype <> 'LT' then 
			call OrderNewSource (764, ctrid, cuser_mod, 0, 0, null);
		end if;
	else /*-- Hold, Cancel, etc. -- client goes to inactive if no other active contracts*/
		update lstclients set cli_status = 10 where 
			(cli_id = cliid or cli_id <=> cbill)
			and not exists (
			select * from allcontracts where (ctr_cli_id = cli_id
				or ctr_cli_bill = cli_id) and ctr_status = 1
			);
	end if;

	commit;
end$$
DELIMITER ;
