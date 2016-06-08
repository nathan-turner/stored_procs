DELIMITER $$
CREATE  PROCEDURE `addAFuzion`(
cid int,
fact char(10),
fud datetime,
ful int,
fur datetime,
fui datetime,
fst tinyint(4),
fus datetime,
fam decimal(19,4),
usr char(32),
nonw tinyint(1),
note varchar(200)
)
    MODIFIES SQL DATA
begin
	declare id int;
	start transaction;

	insert into allfuzion (fu_acct, fu_client, fu_date, fu_length, fu_renewal, fu_invoice, fu_status, fu_start,
 fu_amount, fu_usermod, fu_notes,fu_nonew) 
	values(fact, cid, fud, ful, fur, fui, fst, fus, fam, usr, note, nonw);
	set id = LAST_INSERT_ID();
	update  lstclients set cli_fuzion = id where cli_id = cid;
	
	commit;
end$$
DELIMITER ;
