DELIMITER $$
CREATE DEFINER=`phgadmin`@`%` PROCEDURE `DelANurse`(
id int
)
    MODIFIES SQL DATA
begin
	start transaction;
-- tplacements
	delete tplacements.* from tplacements, tctrpipl d where
		pl_id = d.pipl_id and d.pipl_an_id = id;
-- tctrpipl
	delete from  tctrpipl where pipl_an_id = id;
-- tassesments
	delete from  tassesments where as_ph_id = id and as_nurse = 1;
-- tNuSources NEW
	delete from  tnusourcesn where nsr_an_id = id;
-- allNotes
	delete from  allnotes where note_type = 15 and note_ref_id = id;
-- tNuPasses
	delete from  tnupasses where np_an_id = id;
-- lstAlliedNurses
	delete from  lstalliednurses where an_id = id;
-- lstContacts
	delete from  lstcontacts where ctct_type = 15 and ctct_backref = id;
	
	commit;
end$$
DELIMITER ;
