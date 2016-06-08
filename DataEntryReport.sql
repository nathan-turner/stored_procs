DELIMITER $$
CREATE  PROCEDURE `DataEntryReport`(
d1 datetime, d2 datetime, empid int
)
    READS SQL DATA
begin

select	 lstphysicians.ph_id, lstcontacts.ctct_name, lstphysicians.ph_spec_main,
	 lstphysicians.ph_date_mod, lstphysicians.ph_src_date, ' ' as abbr 
from	 lstphysicians join  lstcontacts on  lstphysicians.ph_ctct_id =  lstcontacts.ctct_id
	left outer join  lstemployees on  lstphysicians.ph_user_mod =  lstemployees.emp_uname
where	( lstemployees.emp_id = empid and  lstphysicians.ph_date_mod between d1 and d2)
	or exists (select * from  tphsourcesn where  lstphysicians.ph_id =  tphsourcesn.psr_ph_id
	and  tphsourcesn.psr_date between d1 and d2 and  tphsourcesn.psr_emp_id = empid)
UNION
select	 lstalliednurses.an_id, lstcontacts.ctct_name, lstalliednurses.an_type,
	 lstalliednurses.an_date_mod, lstalliednurses.an_src_date,  dctalliedtypes.at_abbr as abbr
from	 lstalliednurses join  lstcontacts on  lstalliednurses.an_ctct_id =  lstcontacts.ctct_id
	join  dctalliedtypes on  lstalliednurses.an_type =  dctalliedtypes.at_code
	left outer join  lstemployees on  lstalliednurses.an_user_mod =  lstemployees.emp_uname
where	( lstemployees.emp_id = empid and  lstalliednurses.an_date_mod between d1 and d2)
	or exists (select * from  tnusourcesn where  lstalliednurses.an_id =  tnusourcesn.nsr_an_id
  	and  tnusourcesn.nsr_date between d1 and d2 and  tnusourcesn.nsr_emp_id = empid)
order by ph_date_mod,ph_src_date;

end$$
DELIMITER ;
