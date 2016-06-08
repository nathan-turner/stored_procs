DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `AddAClient2`(
name0 varchar(127), /*-- mandatory */
title varchar(63), /*-- additional info. Phone notes */
company varchar(63),
phone decimal, ext1 char(6),
fax decimal, ext2 char(6),
email varchar(63),
addr_1 varchar(63), addr_2 varchar(63),  addr_c varchar(50),
   addr_z char(10), st_code char(2),
url varchar(127),
xid char(10), 
sys varchar(50),
beds int,
grp char(10),
$emp_id varchar(50),
 date_mod datetime
)
BEGIN

SELECT * from lstemployees where emp_id=1;

END$$
DELIMITER ;
