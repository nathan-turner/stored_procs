DELIMITER $$
CREATE DEFINER=`phgadmin`@`%` PROCEDURE `FuzionCheck`(
phid int,
uname char(32)
)
    COMMENT 'obsolete'
begin
	select 1 as access, 'OK' as reason;
end$$
DELIMITER ;
