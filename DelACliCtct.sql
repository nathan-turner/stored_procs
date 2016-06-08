DELIMITER $$
CREATE  PROCEDURE `DelACliCtct`(
typ tinyint, id int
)
    MODIFIES SQL DATA
begin
	delete from  lstcontacts where ctct_id = id and ctct_type = typ;
end$$
DELIMITER ;
