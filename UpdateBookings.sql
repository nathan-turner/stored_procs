DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateBookings`(
$id int,
$usermod int,
  $billable tinyint(4) ,
  $recruiterid int(11) ,
  $marketerid int(11) ,
  $physid int(11) ,
$physname varchar(45) ,
  $clientid int(11) ,
  $clienttxt varchar(45) ,
  $statetxt varchar(45) ,
  $citytxt varchar(45) ,
  $credentialing_manager varchar(45) ,
  $provider_pay decimal(6,2) ,
  $billing_pay decimal(6,2) ,
  $phys_per_diem decimal(6,2) ,
  $bill_per_diem decimal(6,2) ,
  $phys_malpractice decimal(6,2) ,
  $bill_malpractice decimal(6,2) ,
  $dr_holiday_rate decimal(6,2) ,
  $cl_holiday_rate decimal(6,2) ,
  $dr_overtime decimal(6,2) ,
  $cl_overtime decimal(6,2) ,
  $dr_night_call decimal(6,2) ,
  $cl_night_call decimal(6,2) ,
  $dr_weekend decimal(6,2) ,
  $cl_weekend decimal(6,2) ,
  $dr_mileage decimal(6,2) ,
  $cl_mileage decimal(6,2) ,
  $flight_arrangedby varchar(45) ,
  $fly_from varchar(45) ,
  $fly_to varchar(45) ,
  $depart_date datetime ,
  $return_date datetime ,
  $rental_arrangedby varchar(45) ,
  $pickup_loc varchar(45) ,
  $dropoff_loc varchar(45) ,
  $rental_agency varchar(45) ,
  $housing_arrangedby varchar(45) ,
  $housing_loc varchar(45) ,
  $housing_city varchar(45) ,
  $pets int(11) ,
  $smoking int(11) ,
  $family_members varchar(45) ,
  $contract_attached int(11) ,
  $dr_confirmed int(11) ,
  $timesheets int(11) ,
  $malpractice_ins int(11) ,
  $credentials int(11) ,
  $pay_addendum int(11) ,
  $contract_ext int(11) ,
  $work_addr varchar(45) ,
  $assignment varchar(45) ,
  $deposit int(11) ,
  $prepay int(11) ,
  $deposit_amt varchar(45) ,
  $prepay_amt varchar(45),
  $book_status varchar(45)
)
BEGIN

UPDATE bookings SET

  mod_date=NOW(),
  usermod=$usermod,
  billable=$billable,
  recruiterid=$recruiterid,
  marketerid=$marketerid,
  physid=$physid,
physname=$physname,
  clientid=$clientid,
  clienttxt=$clienttxt,
  statetxt=$statetxt,
  citytxt=$citytxt,
  credentialing_manager=$credentialing_manager,
  provider_pay=$provider_pay,
  billing_pay=$billing_pay,
  phys_per_diem=$phys_per_diem,
  bill_per_diem=$bill_per_diem,
phys_malpractice=$phys_malpractice,
  bill_malpractice=$bill_malpractice,
  dr_holiday_rate=$dr_holiday_rate,
  cl_holiday_rate=$cl_holiday_rate,
  dr_overtime=$dr_overtime,
  cl_overtime=$cl_overtime,
  dr_night_call=$dr_night_call,
  cl_night_call=$cl_night_call,
  dr_weekend=$dr_weekend,
  cl_weekend=$cl_weekend,
  dr_mileage=$dr_mileage,
  cl_mileage=$cl_mileage,
  flight_arrangedby=$flight_arrangedby,
  fly_from=$fly_from,
  fly_to=$fly_to,
  depart_date=$depart_date,
  return_date=$return_date,
  rental_arrangedby=$rental_arrangedby,
  pickup_loc=$pickup_loc,
  dropoff_loc=$dropoff_loc,
  rental_agency=$rental_agency,
  housing_arrangedby=$housing_arrangedby,
  housing_loc=$housing_loc,
  housing_city=$housing_city,
  pets=$pets,
  smoking=$smoking,
  family_members=$family_members,
  contract_attached=$contract_attached,
  dr_confirmed=$dr_confirmed,
  timesheets=$timesheets,
  malpractice_ins=$malpractice_ins,
  credentials=$credentials,
  pay_addendum=$pay_addendum,
  contract_ext=$contract_ext,
  work_addr=$work_addr,
  assignment=$assignment,
  deposit=$deposit,
  prepay=$prepay,
  deposit_amt=$deposit_amt,
  prepay_amt=$prepay_amt,
  book_status=$book_status
WHERE idbookings = $id LIMIT 1;

DELETE FROM booking_dates WHERE bookingsid=$id;

END$$
DELIMITER ;
