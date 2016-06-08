DELIMITER $$
CREATE DEFINER=`phgadmin`@`%` PROCEDURE `DelASource`(
id int
)
    MODIFIES SQL DATA
begin
	declare cid int;
	start transaction;

	delete from  allnotes where note_type=11 and note_ref_id = id;
	delete tctrsourceshed.* from tctrsourceshed, tctrsourcesn where sh_csr_id = csr_id and csr_src_id = id;
	delete from  tctrsourcesn where csr_src_id = id;
	delete from  lstcontacts where ctct_type = 12 and ctct_backref = id;
	select src_ctct_id into cid from  tsources where src_id = id;
	delete from  tsources where src_id = id;
	delete from  lstcontacts where ctct_id = cid;
	
	commit;
end$$
DELIMITER ;
