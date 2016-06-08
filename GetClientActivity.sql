DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetClientActivity`(id int, contract_id int, startdate datetime, enddate datetime)
BEGIN



CREATE TEMPORARY TABLE tmpcliacttbl (
tid int AUTO_INCREMENT,
physician varchar(50), 
ph_id int,
ph_spec varchar(50),
pipl_date datetime,
pdate datetime,
idate datetime,
pldate datetime,
pendate datetime,
status varchar(20),
ctr_id int,
city varchar(30),
pipl_status int,
state varchar(2),
facility varchar(20),
cli_sys varchar(20),
ph_spec_main varchar(5),
pipl_nurse int,
ctr_cli_id int,
pipl_id int,
ctr_no int,
ctct_phone varchar(15),
ctct_cell varchar(15),
PRIMARY KEY (tid)
);

INSERT INTO tmpcliacttbl (
physician,
ph_id, 
ph_spec,
pdate,
status,
ctr_id,
city,
pipl_status,
state,
facility,
cli_sys,
ph_spec_main,
pipl_nurse,
ctr_cli_id,
pipl_id,
ctr_no,
ctct_phone,
ctct_cell)
select 
*
from vcliarhreport where ctr_cli_id=id and ctr_id=contract_id and (pipl_status=2 or pipl_status=8) and pipl_date between startdate and enddate
union 
select *
from vcliarhreport3 
where ctr_cli_id=id   and ctr_id=contract_id and (pipl_status=2 or pipl_status=8) and pipl_date between startdate and enddate
order by ctr_id, ph_id, pipl_status;


UPDATE tmpcliacttbl as t
LEFT JOIN vcliarhreport as v1
ON v1.ph_id=t.ph_id and v1.ctr_id=t.ctr_id
set t.idate=v1.pipl_date
where v1.ctr_cli_id=id   and v1.ctr_id=contract_id and v1.pipl_status=3 and v1.pipl_id>0 and t.pipl_id>0 and tid>0;

UPDATE tmpcliacttbl as t
LEFT JOIN vcliarhreport3 as v1
ON v1.an_id=t.ph_id and v1.ctr_id=t.ctr_id
set t.idate=v1.pipl_date
where v1.ctr_cli_id=id and v1.ctr_id=contract_id and v1.pipl_status=3 and v1.pipl_id>0 and t.pipl_id>0 and tid>0;

UPDATE tmpcliacttbl as t
LEFT JOIN vcliarhreport as v1
ON v1.ph_id=t.ph_id and v1.ctr_id=t.ctr_id
set t.pldate=v1.pipl_date
where v1.ctr_cli_id=id and v1.ctr_id=contract_id and (v1.pipl_status=4 or v1.pipl_status=5) and v1.pipl_id>0 and t.pipl_id>0 and tid>0;

UPDATE tmpcliacttbl as t
LEFT JOIN vcliarhreport3 as v1
ON v1.an_id=t.ph_id and v1.ctr_id=t.ctr_id
set t.pldate=v1.pipl_date
where v1.ctr_cli_id=id and v1.ctr_id=contract_id and (v1.pipl_status=4 or v1.pipl_status=5) and v1.pipl_id>0 and t.pipl_id>0 and tid>0;

UPDATE tmpcliacttbl as t
left join tctrpipl AS p ON p.pipl_ctr_id=t.ctr_id and p.pipl_ph_id=t.ph_id 
set t.pendate=p.pipl_date
where p.pipl_cancel = 0  and p.pipl_status = 10;

/*select * from tmpcliacttbl as t left join sysrepcomments on sys_pipl_id=pipl_id where commentid=(SELECT comment FROM sysrepcomments WHERE sys_pipl_id=pipl_id ORDER BY commentid DESC LIMIT 1) group by sys_pipl_id order by commentid desc;*/
select *, (SELECT comment FROM sysrepcomments WHERE sys_pipl_id=pipl_id ORDER BY commentid DESC LIMIT 1) as comment from tmpcliacttbl as t ;

DROP TEMPORARY TABLE tmpcliacttbl;

END$$
DELIMITER ;
