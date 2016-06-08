DELIMITER $$
CREATE  PROCEDURE `DelAPhysician`(
id int
)
    MODIFIES SQL DATA
begin
	start transaction;
-- tplacements
	delete tplacements.* from tplacements, tctrpipl d where
		pl_id = d.pipl_id and d.pipl_ph_id = id;
-- tctrpipl
	delete from  tctrpipl where pipl_ph_id = id;
-- tassesments
	delete from  tassesments where as_ph_id = id and as_nurse = 0;
-- tphsources OLD
	delete from  tphsources where psr_ph_id = id;
-- tphsources NEW
	delete from  tphsourcesn where psr_ph_id = id;
-- allNotes
	delete from  allnotes where note_type = 3 and note_ref_id = id;
-- tPhHotList
	delete from  tphhotlist where phh_ph_id = id;
-- tPhPasses
	delete from  tphpasses where pp_ph_id = id;
-- lstPhysicians
	delete from  lstphysicians where ph_id = id;
-- lstContacts
	delete from  lstcontacts where ctct_type in (3, 7, 9) and ctct_backref = id and ctct_id <> 9;
	
	commit;
end$$
DELIMITER ;
