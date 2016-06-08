DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `AddContCont`(
/* add a contingecy present type contract */
cliid int, /*-- mandatory*/
cspec char(3),
cstatus tinyint /*= 1*/ , cmarketer int,
crecruiter int, camount decimal(19,4) /*= 0*/ ,
clocationc varchar(50),clocations char(2) /*= '--'*/ ,
cuser_mod char(32)
)
    MODIFIES SQL DATA
begin
	declare cno char(10); 
	declare cdt datetime;
	set cdt = NOW();
	set cno = date_format(cdt,'%y%m%d%H%i');
	/*-- make up a @cno as 'YYMMDDHHMM'*/
	set cdt = date(cdt);
	call AddAContRact (cliid, cno, NULL, cdt, cspec,
		cstatus, cmarketer, crecruiter,camount, 0, 0, clocationc, clocations,
		cuser_mod, cdt, 'CP',NULL,NULL,0,NULL);
 
end$$
DELIMITER ;
