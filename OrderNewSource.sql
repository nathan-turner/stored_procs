DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `OrderNewSource`(sid int,
ctr decimal,
uname varchar(32),
nterm tinyint /*= 6*/ ,
stat tinyint /*= 0*/ ,
dte datetime /* = NULL -- dte MUST BE NULL if old campaign is active already */
)
    MODIFIES SQL DATA
    COMMENT 'version 3, 03/24/2006'
begin
	declare cid decimal;
	declare term,frst,mon,srt,shcan tinyint;
	declare prod,ctrd,tdt,ndt datetime;
	declare yr smallint;
	declare shed varchar(14);
set dte=dte;
	start transaction;
	select src_type into srt from tsources where src_id = sid;
	insert into tctrsourcesn (csr_ctr_id,  csr_src_id, csr_user_mod, csr_price, csr_rating, csr_status)
		select ctr, sid, uname, src_price, src_rating, stat from
		tsources where src_id = sid;
	set cid = LAST_INSERT_ID();

	if nterm > 0 then
		/*-- totally new campaign*/
		select ctr_src_term, ctr_pro_date, ctr_date, ctr_src_termdt into term,prod,ctrd,tdt
		from  allcontracts where ctr_id = ctr;
		if ISNULL(dte) THEN
			set ndt = ifnull(ndt,curdate()); /*-- @ndt is the date of new campaign*/
		else
			set ndt = dte;
		end if;
		if term is null or term = 0 or tdt is null then
			set term = nterm;
			set tdt = ndt;
			update allcontracts set ctr_src_term = nterm, 
				ctr_src_termdt = ndt, ctr_user_mod = uname, ctr_date_mod = curdate()
			where ctr_id = ctr;
		else /*-- old/continued campaign*/
			if term - MonthDiff(ndt,tdt) <=0 then
				/*-- old campaign expired or expires this month*/
				set term = nterm;
				set tdt = ndt;
				update allcontracts set ctr_src_term = nterm, 
					ctr_src_termdt = ndt, ctr_user_mod = uname, ctr_date_mod = curdate()
				where ctr_id = ctr;
				/*-- obsolete old active sources, if any*/
				insert into tsourcetrack (cst_csr_id,cst_date_mod,cst_user_mod,cst_status,cst_why_cancel,cst_note,
					cst_schedule,cst_startyear,cst_appr_date,cst_date_placed,cst_dm_code,cst_dm_count,
					cst_price)
				  select csr_id,NOW(),uname,csr_status,csr_why_cancel,csr_note,
					csr_schedule,csr_startyear,csr_appr_date,csr_date_placed,csr_dm_code,csr_dm_count,
					csr_price from  tctrsourcesn
					where csr_ctr_id = ctr and csr_status <= 1 and csr_src_id not in (742,743,744,764)
						and csr_add_date < (curdate() - INTERVAL 1 MONTH); /*-- 1 month grace period is good enough for now*/
				update tctrsourcesn set csr_status = 4-csr_status, csr_why_cancel='Obsoleted by new campaign',
					csr_date_cancel = curdate(), csr_user_mod = uname
					where csr_ctr_id = ctr and csr_status <= 1 and csr_src_id not in (742,743,744,764)
						and csr_add_date < (curdate() - INTERVAL 1 MONTH); /*-- 1 month grace period is good enough for now*/
			else
				set ndt = tdt;
				set nterm = term;
			end if;
		end if; /* term is null... */
		set frst = 0;
		set shed = '';
		set mon = month(tdt);
		while term > 0 do
			set shcan = if(tdt < current_date - interval 1 month,1,0);
			if not (srt in (3,4,10)) and shcan = 0 and sid != 764 then
				/*-- non-internet - enable only the first current record*/
				set shcan = frst;
				set frst = 1;
			end if;
			if shcan = 0 then 
				set shed = concat(shed,char(64+mon));
			end if;
			set term = term - 1;
			set mon = mon + 1;
			set tdt = tdt + interval 1 month;
		end while;
		update tctrsourcesn set csr_term = nterm, csr_startyear = year(ndt),
			csr_schedule = shed where csr_id = cid;
	end if; /* nterm > 0 */
	commit;
end$$
DELIMITER ;
