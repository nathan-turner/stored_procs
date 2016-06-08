DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SetCtrProDate`(
 ctrid decimal,
 prod datetime,
 unam char(32),
 udat datetime,
 editprof tinyint(1) /*= 0*/
)
    MODIFIES SQL DATA
begin

if  prod is not null then
   update  allcontracts set
	 ctr_pro_date =  prod, ctr_tqc_wl_1 = ifnull(ctr_tqc_wl_1, prod),
	 ctr_tqc_45_1 = ifnull(ctr_tqc_45_1,adddate(prod,45)),
	 ctr_tqc_180_1 = ifnull(ctr_tqc_180_1,adddate(prod,180)),
	 ctr_tqc_ann_1 = ifnull(ctr_tqc_ann_1,adddate(prod,365)),
	 ctr_user_mod =  unam, ctr_date_mod =  udat,
	 ctr_pro_sheet = case when  editprof = 1 then curdate() else ctr_pro_sheet end
   where ctr_id =  ctrid;
end if;

end$$
DELIMITER ;
