DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `DeleteEmailList`($id int, $uid int)
BEGIN

DELETE FROM custlistdesc where uid=$uid and list_id=$id LIMIT 1;

DELETE FROM custlistsus where owneruid=$uid and listid=$id;


END$$
DELIMITER ;
