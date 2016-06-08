DELIMITER $$
CREATE  PROCEDURE `GetGoalsActualsSec`(
 d1 datetime,  d2 datetime
)
    READS SQL DATA
begin
	call GetGoalsActualsNew(d1,d2);
end$$
DELIMITER ;
