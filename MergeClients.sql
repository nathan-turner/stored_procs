DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `MergeClients`(master_client_id int, tbd_client_id int, user varchar(20), userid int)
BEGIN

DECLARE cnt1, cnt2 int;
DECLARE comments text;

SET comments = CONCAT("This record has been merged with record ", master_client_id);
SET cnt1 = (SELECT COUNT(*) FROM lstclients WHERE cli_id=master_client_id);
SET cnt2 = (SELECT COUNT(*) FROM lstclients WHERE cli_id=tbd_client_id);

IF cnt1>0 AND cnt2>0 THEN
	start transaction;
	
	/*SELECT * FROM allnotes WHERE note_ref_id=tbd_client_id AND note_type=2;*/
	UPDATE allnotes SET note_ref_id=master_client_id WHERE note_ref_id=tbd_client_id AND note_type=2; 
	UPDATE lstcontacts SET ctct_backref=master_client_id WHERE ctct_backref=tbd_client_id; 
	UPDATE allfuzion SET fu_client=master_client_id WHERE fu_client=tbd_client_id; 
	UPDATE allcontracts SET ctr_cli_id=master_client_id, ctr_cli_bill=master_client_id WHERE ctr_cli_id=tbd_client_id; 
	UPDATE allcontracts SET ctr_cli_bill=master_client_id WHERE ctr_cli_bill=tbd_client_id; 

	UPDATE lstclients SET cli_status=12 WHERE cli_id=tbd_client_id LIMIT 1; 
	UPDATE lstclients SET primary_record=1 WHERE cli_id=master_client_id LIMIT 1; 

	INSERT INTO allnotes (note_dt, note_user, note_ref_id, note_type, note_text, note_emp_id) VALUES (NOW(), user, tbd_client_id, 2, comments, userid ); 
	
	commit;
END IF;

END$$
DELIMITER ;
