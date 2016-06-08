DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SourcingExt`(
-- extension of the rerm by 3, 6, or 9 months - no more than 12 total
ctr decimal,
ext int,
user char(32)
)
begin
	update  allcontracts set ctr_src_term=ctr_src_term+ext, ctr_user_mod=user,ctr_date_mod=curdate()
		where ctr_id = ctr;
end$$
DELIMITER ;
