DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetReferenceReq`(
 phid int,
 ctrid int
)
    READS SQL DATA
begin
-- this SP will produce a single record, generated from various fields/tables.
-- this is for the Physician Ref form (obsolete) and Ref Billing form.
-- HEADER
declare rname,cname,pname varchar(127);
declare ctrno varchar(10);
declare spec,spec0 varchar(56);
declare ccity,pcity varchar(50);
declare cst,pstate char(2);
declare psex varchar(6);
declare phone decimal;
declare  cliid,  ctrreq, worka int;
-- REFERENCES
declare  N1,N2,N3,N4 varchar(127);
declare  R1,R2,R3,R4 varchar(63);
declare  C1,C2,C3,C4 varchar(50);
declare  S1,S2,S3,S4 char(2);
declare  O1,O2,O3,O4,  H1,H2,H3,H4 decimal;
-- CURSOR
declare goon tinyint default true;
declare ref_cur cursor for
 select ctct_name, left(concat(ctct_title,'/',ctct_reserved2),63), ctct_addr_c,
  ctct_st_code, ctct_phone, ctct_hphone from
   lstcontacts where ctct_backref =  phid and ctct_type = 9;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET goon = FALSE;
-- 1. fill the header
--  rname,  ctrno,  spec,  cname,  ccity,  cst
select  ctr_cli_id,  ctr_recruiter,  ctr_no,  ctr_spec into  cliid,  ctrreq,  ctrno,  spec0
from  allcontracts where ctr_id =  ctrid;
select  ctct_name into rname
from  lstcontacts where ctct_backref =  ctrreq and ctct_type = 1;
select ctct_name, ctct_addr_c, ctct_st_code into cname,  ccity,  cst
from  lstcontacts where ctct_backref =  cliid and ctct_type = 2;
select  concat(RTRIM(sp_name),' (', sp_code, ')') into spec
from  dctspecial where sp_code =  spec0;
--  pname,  psex,  phone,  pcity,  pstate
select case when ph_sex = 0 then 'Female' else 'Male' end, ph_ctct_id into  psex, worka
from  lstphysicians where ph_id =  phid;
select  ctct_name, ctct_phone, ctct_addr_c, ctct_st_code into  pname,  phone,  pcity,  pstate
from  lstcontacts where ctct_id =  worka; -- really it is not a work addr any more
-- 2. N#, R#, C#, S#, O#, H#
open ref_cur;
fetch ref_cur into  N1,  R1,  C1,  S1,  O1,  H1;
if goon then
  fetch ref_cur into  N2,  R2,  C2,  S2,  O2,  H2;
  if goon then
    fetch ref_cur into  N3,  R3,  C3,  S3,  O3,  H3;
    if goon then
      fetch ref_cur into  N4,  R4,  C4,  S4,  O4,  H4;
    END IF;
  END IF;
END IF;
close ref_cur;
-- Return the Resultset (a record)
select rname as `rn`, ctrno as `no`, spec as `sp`, cname as `cn`, ccity as `cc`, cst as `cs`,
 pname as `pn`, psex as `px`, phone as `pp`, pcity as `pc`, pstate as `ps`,
 N1 as `n1`, R1 as `r1`, C1 as `c1`, S1 as `s1`, O1 as `o1`, H1 as `h1`,
 N2 as `n2`, R2 as `r2`, C2 as `c2`, S2 as `s2`, O2 as `o2`, H2 as `h2`,
 N3 as `n3`, R3 as `r3`, C3 as `c3`, S3 as `s3`, O3 as `o3`, H3 as `h3`,
 N4 as `n4`, R4 as `r4`, C4 as `c4`, S4 as `s4`, O4 as `o4`, H4 as `h4`;

end$$
DELIMITER ;
