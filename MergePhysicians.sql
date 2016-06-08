DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `MergePhysicians`(master_ph_id int, tbd_ph_id int, user varchar(20), userid int)
BEGIN

DECLARE cnt1, cnt2 int;
DECLARE comments text;

SET comments = CONCAT("This record has been merged with record ", master_ph_id);
SET cnt1 = (SELECT COUNT(*) FROM lstphysicians WHERE ph_id=master_ph_id);
SET cnt2 = (SELECT COUNT(*) FROM lstphysicians WHERE ph_id=tbd_ph_id);

IF cnt1>0 AND cnt2>0 THEN
	start transaction;
	
	/*SELECT * FROM allnotes WHERE note_ref_id=tbd_client_id AND note_type=2;*/
	UPDATE allnotes SET note_ref_id = master_ph_id WHERE note_ref_id = tbd_ph_id AND note_type=3; 
	UPDATE tctrpipl SET pipl_ph_id = master_ph_id WHERE pipl_ph_id = tbd_ph_id;
	UPDATE cvs2 SET cv_ph_id = master_ph_id WHERE cv_ph_id = tbd_ph_id;
	UPDATE tphpasses SET pp_ph_id = master_ph_id WHERE pp_ph_id = tbd_ph_id;
	UPDATE tphhotlist SET phh_ph_id = master_ph_id WHERE phh_ph_id = tbd_ph_id;
	UPDATE ltpresents SET ph_id = master_ph_id WHERE ph_id = tbd_ph_id;
	UPDATE tvistapasses SET vp_ref_id = master_ph_id WHERE vp_ref_id = tbd_ph_id;
	/*UPDATE tplacements SET pl_ref_emp = master_ph_id WHERE pl_ref_emp = tbd_ph_id; ??not tied to ph_id*/
	UPDATE tassesments SET as_ph_id = master_ph_id WHERE as_ph_id = tbd_ph_id;
	UPDATE tphsourcesn SET psr_ph_id = master_ph_id WHERE psr_ph_id = tbd_ph_id;
	UPDATE tphsources SET psr_ph_id = master_ph_id WHERE psr_ph_id = tbd_ph_id;

	UPDATE lstphysicians SET ph_status=12 WHERE ph_id=tbd_ph_id LIMIT 1; 
	 

	INSERT INTO allnotes (note_dt, note_user, note_ref_id, note_type, note_text, note_emp_id) VALUES (NOW(), user, tbd_ph_id, 3, comments, userid ); 
	
	commit;
END IF;

END$$
DELIMITER ;
