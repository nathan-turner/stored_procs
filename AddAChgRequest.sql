DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `AddAChgRequest`(ctr_id int, typ tinyint,
reason varchar(255), /*--null*/
c0mment varchar(255), /*--null*/
spec char(3), req int,
dat datetime, emp_id int,
pipl decimal, /*--null */
nu_type char(10)
)
    MODIFIES SQL DATA
begin
SET dat = NOW();
	insert into tctrchanges (chg_ctr_id,chg_type,chg_reason,chg_comment,chg_spec,chg_req,chg_date,chg_emp_id,chg_reserved,chg_nu_type )
	values (ctr_id,typ,reason,c0mment,spec,req,dat,emp_id,pipl,nu_type);
	select LAST_INSERT_ID() as chg_id;
end$$
DELIMITER ;
