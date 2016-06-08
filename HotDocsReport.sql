DELIMITER $$
CREATE  PROCEDURE `HotDocsReport`(
 date1 datetime,
 date2 datetime,
sort varchar(20)
)
    READS SQL DATA
begin
-- V.2

if isnull(sort) or sort='' then
	set sort = 'note_dt';
end if;

SET @sql = CONCAT('
SELECT  lstphysicians.ph_id,  lstcontacts.ctct_name, 
    CAST( lstcontacts.ctct_phone as char) as phone_w,
    CAST( lstcontacts.ctct_hphone as char) as phone_h, 
     lstphysicians.ph_spec_main,  lstphysicians.ph_prot_date,
     lstemployees.emp_uname, 
     lstphysicians.ph_med_school,  allnotes.note_dt, 
     allnotes.note_text,  lstphysicians.ph_src_date
    AS src_date_last,  lstcontacts.ctct_email
FROM  lstphysicians INNER JOIN
     lstcontacts ON      lstphysicians.ph_ctct_id =  lstcontacts.ctct_id INNER JOIN
     lstemployees ON     lstphysicians.ph_recruiter =  lstemployees.emp_id INNER JOIN
     allnotes  /*use index (ix_note_ref)*/ ON 
    (( lstphysicians.ph_id =  allnotes.note_ref_id) AND ( allnotes.note_type = 3))
WHERE 
    lstphysicians.ph_status = 1
   and  allnotes.note_dt between  "',date1,'" and "', date2,'"
   and length( allnotes.note_text) >= 12
UNION

SELECT  lstphysicians.ph_id,  lstcontacts.ctct_name, 
    CAST( lstcontacts.ctct_phone as char) as phone_w,
    CAST( lstcontacts.ctct_hphone as char) as phone_h, 
     lstphysicians.ph_spec_main,  lstphysicians.ph_prot_date,
     lstemployees.emp_uname, 
     lstphysicians.ph_med_school,  allnotes.note_dt, 
     allnotes.note_text,  lstphysicians.ph_src_date
    AS src_date_last,  lstcontacts.ctct_email
FROM  lstphysicians INNER JOIN
     lstcontacts ON      lstphysicians.ph_ctct_id =  lstcontacts.ctct_id INNER JOIN
     lstemployees ON      lstphysicians.ph_recruiter =  lstemployees.emp_id LEFT OUTER
     JOIN
     allnotes ON (( lstphysicians.ph_id =  allnotes.note_ref_id) AND ( allnotes.note_type = 3))
WHERE 
    lstphysicians.ph_status = 1 and   allnotes.note_dt is Null
   and  lstphysicians.ph_src_date between  "',date1,'" and "', date2,'" order by ',sort,' desc;');

prepare stmt FROM @sql;
execute stmt;

-- END

end$$
DELIMITER ;
