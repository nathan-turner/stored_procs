DELIMITER $$
CREATE  PROCEDURE `DelAContract`(
id decimal
)
    MODIFIES SQL DATA
begin
	start transaction;
	delete tplacements.* from tplacements, tctrpipl d where
		pl_id = d.pipl_id and d.pipl_ctr_id = id;
	delete from tctrpipl where pipl_ctr_id = id;
	delete from tctrprofiles where pro_id = id;
	-- old
	delete tphsources.* from tphsources, tctrsources d where
		psr_src_id = d.src_id and d.src_ctr_id = id;
	delete from tctrsources where src_ctr_id = id;
	-- new
	delete from tphsourcesn where psr_ctr_id = id;
	delete from tnusourcesn where nsr_ctr_id = id;
	delete from tctrsourceshed where sh_ctr_id = id;
	delete from tctrsourcesn where csr_ctr_id = id;
	--
	delete from tassesments where as_ctr_id = id;
	delete from tctrdescription where cd_ctr_id = id;
	delete from tctrchangesaux where cha_ctr_id = id;
	delete from tctrchanges where chg_ctr_id = id;
	delete from tupdates where tu_ctr_id = id;
	delete from allcontracts where ctr_id = id;
	commit;
end$$
DELIMITER ;
