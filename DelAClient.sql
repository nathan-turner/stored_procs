DELIMITER $$
CREATE  PROCEDURE `DelAClient`(
id decimal
)
    MODIFIES SQL DATA
begin
	declare cid decimal;
	declare goon tinyint default true;
	declare contracts cursor for
		select ctr_id from  allcontracts where ctr_cli_id = id;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET goon = FALSE;

	start transaction;
	open contracts;
	fetch contracts into cid;
	while goon do
		call DelAContract (cid);
		fetch contracts into cid;
	end while;
	close contracts;

	update  allcontracts set ctr_cli_bill = NULL where
		ctr_cli_bill = id;
	delete from  tclihotlist where ch_cli_id = id;
	delete from  tclimeetings where cm_cli_id = id;
	delete from  lstclients where cli_id = id;
	delete from  lstcontacts where
		ctct_id <> 13 and ctct_type in (2,4,5) and ctct_backref = id;
	
	commit;
end$$
DELIMITER ;
