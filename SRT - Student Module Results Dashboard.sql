/*
This file was created on 24 November 2023 by Linda Bathgate, Returns Data Quality Assistant, Strategic Intelligence Unit, Strategic Planning
Source:     SRT - Students on Modules Dashboard (which cam from Cognos > Students on Modules Version 5.5 (090622) (run as CSV)
            with some data elements/coding coming from Student Numbers Dashboard SQL with MCI and ADD (031022)  )
As at:      24/11/23
Why:        I didn't get to replicate this one before Cognos was shutdown and so didn;t have the Cognos build to work from
In the Student Data SQL Files the file name is SRT - Student Module Results Dashboard

Used in
Module Exam Results v6.2 - Excel
SIU - Module Dashboard Data Source (sipr) v1 - power bi


DEV - JACS3 classification to HECoS CAH1 classification - SUB JACS > HECoS mapping in progress by IB as at 31/07/23
27/10/23 - Do we exclude MEDX/TT/VLE MOT_CODEs as these don't have TOP records? - thinkso, they weren't in the 270623 dashboard - now added to the criteria alongide APL and indplace
17/03/25 - Retention Progression codes added (copied from Student Numbers and Data Requests; EIS comparitors for 2023/4 results created
*/

select distinct

sce.sce_scjc "SCJ Code",
smr.ayr_code "Module Exam Year",
smr.psl_code "Module Semester",
smr.mod_code "Module Code",
mods.mod_code||': '||mods.mod_name "Module Code and Name",
fac2.fac_name "Module School",
dpt2.dpt_name "Module Discipline",
smr.mav_occur "Module Occurrence",
--smr.smr_levc "Module Level",
--Having Module level as a number, causes Excel to have mis-matches when these are stored as text, creating multiple entries in the pivot table slicer. Added 06/09/24 ahead of 5-year refresh to resolve the issue longer term
'Level '||smr.smr_levc "Module Level",
smr.smr_coma "Completed attempts",
smr.smr_cura "Number of attempts",
case
when smr.smr_agrg in ('A1','A2','A3','A4','A5','B1','B2','B3','C1','C2','C3','D1','D2','D3','M1','M2','M3','MF','CF','BF','QF')
then 'Scale: A1 to QF Scale'
when smr.smr_agrg in ('CO','AB','CA','DC','DS','MC','ME','NM','QF','ST','WD')
then 'Scale: Condition Applied'
when smr.smr_agrg in ('P','F')
then 'Scale: Pass or Fail'
when smr.smr_agrg is null then 'Scale: Not Recorded'
else 'Scale not in Lookup on _Assessment Scale'
end as "Scale",
smr.smr_actg "Calculated Grade",
smr.smr_agrg "Awarded Grade",


--"Aggregation Scale",
case
when smr.ayr_code >='2015/6' and smr.smr_agrg = 'A1' then to_number('23')
when smr.ayr_code >='2015/6' and smr.smr_agrg = 'A2' then to_number('22')
when smr.ayr_code >='2015/6' and smr.smr_agrg = 'A3' then to_number('21')
when smr.ayr_code >='2015/6' and smr.smr_agrg = 'A4' then to_number('20')
when smr.ayr_code >='2015/6' and smr.smr_agrg = 'A5' then to_number('19')
when smr.ayr_code >='2015/6' and smr.smr_agrg = 'M1' then to_number('9')
when smr.ayr_code >='2015/6' and smr.smr_agrg = 'M2' then to_number('8')
when smr.ayr_code >='2015/6' and smr.smr_agrg = 'M3' then to_number('7')
when smr.ayr_code >='2015/6' and smr.smr_agrg = 'CF' then to_number('5')
when smr.ayr_code >='2015/6' and smr.smr_agrg = 'BF' then to_number('2')
when smr.ayr_code >='2015/6' and smr.smr_agrg = 'QF' then to_number('0')
when smr.ayr_code < '2015/6' and smr.smr_agrg = 'A1' then to_number('21')
when smr.ayr_code < '2015/6' and smr.smr_agrg = 'A2' then to_number('20')
when smr.ayr_code < '2015/6' and smr.smr_agrg = 'A3' then to_number('19')
when smr.ayr_code < '2015/6' and smr.smr_agrg = 'MF' then to_number('9')
when smr.ayr_code < '2015/6' and smr.smr_agrg = 'CF' then to_number('6')
when smr.ayr_code < '2015/6' and smr.smr_agrg = 'BF' then to_number('2')
when smr.ayr_code < '2015/6' and smr.smr_agrg = 'QF' then to_number('99')
when smr.smr_agrg = 'B1' then to_number('18')
when smr.smr_agrg = 'B2' then to_number('17')
when smr.smr_agrg = 'B3' then to_number('16')
when smr.smr_agrg = 'C1' then to_number('15')
when smr.smr_agrg = 'C2' then to_number('14')
when smr.smr_agrg = 'C3' then to_number('13')
when smr.smr_agrg = 'D1' then to_number('12')
when smr.smr_agrg = 'D2' then to_number('11')
when smr.smr_agrg = 'D3' then to_number('10')
else to_number('0')
end as "Aggregation Scale",


smr.smr_cred "Module Credits",
case
when smr.smr_rslt = 'P' then 'Pass'
when smr.smr_rslt = 'F' then 'Fail'
else 'No Result'
end as "Result",
--smr.smr_sass "Initial Calculated Result Code", --- for testing only
case
when smr.smr_sass = 'A' then '(A) Complete'
when smr.smr_sass = 'L' then '(L) Late'
when smr.smr_sass = 'R' then '(R) Re-assessment'
when smr.smr_sass = 'H' then '(H) Hold'
when smr.smr_sass is null then '(Z) <blank>'
else null
end as "Initial Calculated Result",
--smr.smr_prcs "Final Calc result code", --- for testing only
case
when smr.smr_prcs = 'A' then '(A) Complete'
when smr.smr_prcs = 'C' then '(C) Calculated'
when smr.smr_prcs = 'H' then '(H) Held'
when smr.smr_prcs is null then '(Z) <blank>'
else null
end as "Final Calculated Result",
--smr.smr_proc "module award process code", --- for testing only
case
when smr.smr_proc = 'COM' then '01_Completed'
when smr.smr_proc = 'SAS' then '02_Initial Calc/process'
when smr.smr_proc = 'IAS' then '03_Initial Calc/process'
when smr.smr_proc = 'LAS' then '04_Late Calc/process'
when smr.smr_proc = 'RAS' then '05_Re-assessment Calc/process'
else null
end as "Module Award Process",

case
when smr.smr_rtsc = 'AF' then '1_Academic Failure'
when smr.smr_rtsc = 'CC' then '2_Compensation/Condonement'
when smr.smr_rtsc = 'CCWD' then 'CCWD'
when smr.smr_rtsc = 'CH' then '3_Change Made To Mark'
when smr.smr_rtsc = 'COMP' then '2_Compensatory Pass'
when smr.smr_rtsc = 'COND' then '2_Condonment'
when smr.smr_rtsc = 'DISC' then '7_Module Discounted'
when smr.smr_rtsc = 'EDP' then '4_Extended Due Performance'
when smr.smr_rtsc = 'EDP09' then '4_Extended Due Performance'
when smr.smr_rtsc = 'EDP010' then '4_Extended Due Performance'
when smr.smr_rtsc = 'EDP011' then '4_Extended Due Performance'
when smr.smr_rtsc = 'EDP12' then '4_Extended Due Performance'
when smr.smr_rtsc = 'EDP13' then '4_Extended Due Performance'
when smr.smr_rtsc = 'EDP14' then '4_Extended Due Performance'
when smr.smr_rtsc = 'EDP15' then '4_Extended Due Performance'
when smr.smr_rtsc = 'EDP16' then '4_Extended Due Performance'
when smr.smr_rtsc = 'EDP17' then '4_Extended Due Performance'
when smr.smr_rtsc = 'EDPC' then '2_Extended Due Performance with Compensation'
when smr.smr_rtsc = 'EDPR' then '4_Extended Due Performance'
when smr.smr_rtsc = 'EDPRC' then '4_Extended Due Performance'
when smr.smr_rtsc = 'NORES' then '5_No Resit Allowed'
when smr.smr_rtsc = 'PL' then '6_Plagiarism'
when smr.smr_rtsc = 'S1' then '7_S1 Exam In S2 Due To Snow'
when smr.smr_rtsc = 'T' then '7_For Testing Only'
when smr.smr_rtsc = 'VIS' then '8_Incoming Visiting/Exchange'
when smr.smr_rtsc = 'EDP19' then '4_Extended Due Performance'
else 'No Adjustment'
end as "Grade Adjustment",

case 
when smr.smr_agrg = 'CA' then 'Absent'
when smr.smr_agrg = 'MC' then 'Absent'
when smr.smr_agrg = 'A1' then 'A'
when smr.smr_agrg = 'A2' then 'A'
when smr.smr_agrg = 'A3' then 'A'
when smr.smr_agrg = 'A4' then 'A'
when smr.smr_agrg = 'A5' then 'A'
when smr.smr_agrg = 'B1' then 'B'
when smr.smr_agrg = 'B2' then 'B'
when smr.smr_agrg = 'B3' then 'B'
when smr.smr_agrg = 'M1' then 'MF'
when smr.smr_agrg = 'M2' then 'MF'
when smr.smr_agrg = 'M3' then 'MF'
when smr.smr_agrg = 'CF' then 'CF'
when smr.smr_agrg = 'BF' then 'BF'
when smr.smr_agrg = 'QF' then 'QF'
when smr.smr_agrg = 'F' then 'F'
when smr.smr_agrg = 'AB' then 'F'
when smr.smr_agrg = 'QF' then 'F'
when smr.smr_agrg = 'ST' then 'F'
when smr.smr_agrg = 'MF' then 'F'
when smr.smr_agrg = 'NM' then 'No Mark Awarded'
when smr.smr_agrg = 'C1' then 'C'
when smr.smr_agrg = 'C2' then 'C'
when smr.smr_agrg = 'C3' then 'C'
when smr.smr_agrg = 'D1' then 'D'
when smr.smr_agrg = 'D2' then 'D'
when smr.smr_agrg = 'D3' then 'D'
when smr.smr_agrg = 'DC' then 'Module Discounted'
when smr.smr_agrg = 'P' then 'P'
when smr.smr_agrg = 'DS' then 'P'
when smr.smr_agrg = 'ME' then 'P'
when smr.smr_agrg = 'WD' then 'WD'
else 'z_No Grade Group 1'
end as "Grade Group",

case
when smr.smr_agrg = 'CA' then '03_Absence'
when smr.smr_agrg = 'MC' then '03_Absence'
when smr.smr_agrg = 'A1' then '01_B3 or above'
when smr.smr_agrg = 'A2' then '01_B3 or above'
when smr.smr_agrg = 'A3' then '01_B3 or above'
when smr.smr_agrg = 'A4' then '01_B3 or above'
when smr.smr_agrg = 'A5' then '01_B3 or above'
when smr.smr_agrg = 'B1' then '01_B3 or above'
when smr.smr_agrg = 'B2' then '01_B3 or above'
when smr.smr_agrg = 'B3' then '01_B3 or above'
when smr.smr_agrg = 'M1' then '02_C1 or below'
when smr.smr_agrg = 'M2' then '02_C1 or below'
when smr.smr_agrg = 'M3' then '02_C1 or below'
when smr.smr_agrg = 'CF' then '02_C1 or below'
when smr.smr_agrg = 'BF' then '02_C1 or below'
when smr.smr_agrg = 'QF' then '02_C1 or below'
when smr.smr_agrg = 'F' then '02_C1 or below'
when smr.smr_agrg = 'AB' then '02_C1 or below'
when smr.smr_agrg = 'QF' then '02_C1 or below'
when smr.smr_agrg = 'ST' then '02_C1 or below'
when smr.smr_agrg = 'MF' then '02_C1 or below'
when smr.smr_agrg = 'NM' then '02_C1 or below'
when smr.smr_agrg = 'C1' then '02_C1 or below'
when smr.smr_agrg = 'C2' then '02_C1 or below'
when smr.smr_agrg = 'C3' then '02_C1 or below'
when smr.smr_agrg = 'D1' then '02_C1 or below'
when smr.smr_agrg = 'D2' then '02_C1 or below'
when smr.smr_agrg = 'D3' then '02_C1 or below'
when smr.smr_agrg = 'DC' then '04_n/a'
when smr.smr_agrg = 'P' then '04_n/a'
when smr.smr_agrg = 'DS' then '04_n/a'
when smr.smr_agrg = 'ME' then '04_n/a'
when smr.smr_agrg = 'WD' then '04_n/a'
else 'z_No Grade Group 2'
end as "Grade Group 2",

case
when smr.smr_agrg = 'CA' then '03_Absence'
when smr.smr_agrg = 'MC' then '03_Absence'
when smr.smr_agrg = 'A1' then '01_Pass'
when smr.smr_agrg = 'A2' then '01_Pass'
when smr.smr_agrg = 'A3' then '01_Pass'
when smr.smr_agrg = 'A4' then '01_Pass'
when smr.smr_agrg = 'A5' then '01_Pass'
when smr.smr_agrg = 'B1' then '01_Pass'
when smr.smr_agrg = 'B2' then '01_Pass'
when smr.smr_agrg = 'B3' then '01_Pass'
when smr.smr_agrg = 'M1' then '02_Fail'
when smr.smr_agrg = 'M2' then '02_Fail'
when smr.smr_agrg = 'M3' then '02_Fail'
when smr.smr_agrg = 'CF' then '02_Fail'
when smr.smr_agrg = 'BF' then '02_Fail'
when smr.smr_agrg = 'QF' then '02_Fail'
when smr.smr_agrg = 'F' then '02_Fail'
when smr.smr_agrg = 'AB' then '03_Absence'
when smr.smr_agrg = 'ST' then '02_Fail'
when smr.smr_agrg = 'MF' then '02_Fail'
when smr.smr_agrg = 'NM' then '05_No Mark Awarded'
when smr.smr_agrg = 'C1' then '01_Pass'
when smr.smr_agrg = 'C2' then '01_Pass'
when smr.smr_agrg = 'C3' then '01_Pass'
when smr.smr_agrg = 'D1' then '01_Pass'
when smr.smr_agrg = 'D2' then '01_Pass'
when smr.smr_agrg = 'D3' then '01_Pass'
when smr.smr_agrg = 'DC' then '06_Module Discounted'
when smr.smr_agrg = 'P' then '01_Pass'
when smr.smr_agrg = 'DS' then '01_Pass'
when smr.smr_agrg = 'ME' then '01_Pass'
when smr.smr_agrg = 'WD' then '04_Withdrawn'
else 'z_No Result Group 1'
end as "Result Group 1",

sce.sce_ayrc "Academic Year (Study)",
sce.sce_blok "Year of Course",
case
when sce.sce_moac in ('BOC','DDL','DL','DLO','WBL','FOC','FOCF','FOCP')
	then 'Distance Learning'
when sce.sce_moac in ('CFT','CYR','DFT','EYR','FT','FTARCH','FTF','FTIP','FTO','GYRY','OYR','SAB','STE','TYR','WFT','IYR')
	then 'Full-time'
when sce.sce_moac in ('CPT','DPT','PT','PTO','WPT','WMS')
	then 'Part-time'
when sce.sce_moac = 'AS' then 'Associate Student'
when sce.sce_moac = 'DOR' then 'Dormant'
else 'z_Not recorded'
end "Mode of Attendance",
rou.rou_name||' ('||rou.rou_code||')' "Programme Name (Route)", --"ROU - Programme Route"
case
when substr(crs.crs_code,1,1) = 'U' then '(01) Undergraduate'
when substr(crs.crs_code,1,1) = 'T' then '(02) Taught Postgraduate'
when substr(crs.crs_code,1,1) = 'R' then '(03) Research'
when substr(crs.crs_code,1,1) = 'A' then '(05) Access'
else 'Other'
end "Course Level",
fac.fac_name "School", --"ROU - School"
dpt.dpt_name "Discipline",
case
    when stu.stu_dsbc in ('0','N','U','A','99','98','95')    
        then 'No'
     when stu.stu_dsbc is null then 'No'
else 'Yes'
end "Disability",
nvl(gen.gen_name, 'z_Not recorded') "Gender",
case
when sce.sce_fstc in ('CIOMC','H','HC','HEU','HFP','HFW','HH','HHC','HNF','HNFS','HNI','HNIC','HNIPR','HSEU','HTH')
	then 'HomeEU'
when sce.sce_fstc = 'HS'
	then 'HomeScottish'
when sce.sce_fstc like 'O%'
	then 'Overseas'
when sce.sce_fstc in ('CIOM','CIOMF','CIOMN','HRUK','HRUKF','HRUKN','HRUK1','RUK')
	then 'RUK'
else 'z_Not recorded'
end "Student SCE Fees",
case
when mci.mci_natc is not null then to_char(nat2.nat_name)
when stu.stu_natc is not null then to_char(nat.nat_name)
else 'Not recorded'
end "Nationality",
case                       
    when mci.mci_ethc in ('10','11','12','13','19','161','164','166', '167', '168', '169','170','179')                         
        then 'White'
    when mci.mci_ethc in ('14','21','22','29','31','32','33','34','39','41','42','43','49','50','80','16','100','101','103','104','119','120','121','139','140','141','142','159','180','899')                                
        then 'BAME'
    when mci.mci_ethc in ('90','98','99','997','998')                              
        then 'Not known / Prefer not to say'         
    when stu.stu_ethc in ('10','11','12','13','19','161','164','166', '167', '168', '169','170','179')                           
        then 'White'                              
    when stu.stu_ethc in ('14','21','22','29','31','32','33','34','39','41','42','43','49','50','80','16','100','101','103','104','119','120','121','139','140','141','142','159','180','899')                                
        then 'BAME'              
    when stu.stu_ethc in ('90','98','99','997','998')                                
        then 'Not known / Prefer not to say'               
    when stu.stu_ethc is null          
        then 'z_Not recorded'
else '###ERROR###'                        
end "Ethnicity Group",
case 
    when scj.scj_agoe <21 
        then'20 and under'
    when scj.scj_agoe between 21 and 24
        then'21-24'
    when scj.scj_agoe between 25 and 29 
        then'25-29'
    when scj.scj_agoe >=30 
        then '30 and over'
else 'Not recorded'
end "Age on Entry",     --Age on Entry UoD
scj.scj_ayrc "Academic Year (Entry)",
case
when scj.scj_udf8 is null
	or scj.scj_udf8 = 'Not applicable' or scj.scj_udf8 = 'NA'
	then 'Not applicable'
else upper(to_char(scj.scj_udf8))
end "MD Quintile",
case
	when sce.sce_2ndr = 'S' and sce.sce_moac = 'FOC' and sce.sce_elsc = '10' 
        then 'Overseas Based Student'
    when sce.sce_2ndr = 'S'
		then 'UK Based Student' 
	when sce.sce_2ndr = 'O'
		then 'Overseas Based Student'                              
	else 'Not Yet Categorised/Excluded from HESA'
end "Location of Student",

case
when scj.scj_qenc = 'J30' and scj.scj_blok >=2 and scj.scj_arti in ('1','2','3','4') then 'Advance Standing (HND)'
when scj.scj_qenc = 'C30' and scj.scj_blok >=2 and scj.scj_arti in ('1','2','3','4') then 'Advance Standing (HNC)'
else 'Not Advance Standing'
end as "Articulation (SFC)",

/*
---------------Retention---------------
nvl(sce.sce_pgsc,'N/A') "SCE Progression Code",

case
	when sce.sce_blok = '1' then 'Year 1 to 2'
	when sce.sce_blok = '2' then 'Year 2 to 3'
	when sce.sce_blok = '3' then 'Year 3 to 4'
	when sce.sce_blok = '4' then 'Year 4 to 5'
	when sce.sce_blok = '5' then 'Year 5 to 6'
	when sce.sce_blok = '6' then 'Year 6 to 7'
	when sce.sce_blok = 'A' then 'Placement Year'
else '###ERROR###'
end "Retention Year",

case
when sce.sce_blok <> '1' then 'Year 2+'
else 'Year 1'
end "Retention Grouping",

case
when sce.sce_pgsc in ('PP', 'PR', 'PC', 'RC', 'RP', 'D', 'RY', 'SB', '1', 'NFY')
then '(01) Retained'
when sce.sce_pgsc in ('LAE','ST','LST','W')
then '(02) Not Retained'
when sce.sce_pgsc in ('LT','N','GA')
then '(05) Not Yet Known'
when sce.sce_pgsc in ('FA', 'IT', 'AWD', 'FR', 'LA', 'NC', 'STP', 'NS', 'ICD')
then '(99) Do Not Count'
when sce.sce_pgsc is null
then '(05) Not Yet Known'
else '###ERROR###'
end "Retention Status", --"SCE - Retention Status"


---------------Progression---------------
--the order of the codes here matches the order of the codes in the 'lookup' table on the dashboard info page - I am not sure where or when the numbering of e.g. 02-01 was decided
case
when sce.sce_pgsc in ('1','NFY','PP') then '(01-01) PP - Pass Proceed'      --contains 2 NIU codes (1, NFY) that are equivalent to PP and remain included as was in use for historical data
when sce.sce_pgsc in ('PR','PRF') then '(01-04) PR - Pass but has resits'   --contains 1 NIU code (PRF) that is equivalent to PR and remains included as was in use for historical data
when sce.sce_pgsc = 'PC' then '(01-03) PC - Pass Carrying Module(s)'
when sce.sce_pgsc = 'RC' then '(01-05) RC - Pass at Resit Carrying Module(s)'
when sce.sce_pgsc = 'RP' then '(01-02) RP - Pass after Resits'
when sce.sce_pgsc = 'D' then '(02-01) D - Year Discounted'
when sce.sce_pgsc = 'RY' then '(02-03) RY - Repeat year of course'
when sce.sce_pgsc = 'SB' then '(02-04) SB - Study Break'
when sce.sce_pgsc = 'LST' then '(02-02) LST - Liable Studies Terminated following yr'
when sce.sce_pgsc = 'LAE' then '(03-01) LAE - Lesser Award Early Exit'
when sce.sce_pgsc = 'ST' then '(02-05) ST - Studies Terminated'
when sce.sce_pgsc = 'W' then '(02-06) W - Withdrawn'
when sce.sce_pgsc in ('FA','AWD','NC') then '(01-06) FA - Student obtained Full Award'
when sce.sce_pgsc = 'LT' then '(05-01) LT - Liable for Termination'
when sce.sce_pgsc = 'IT' then '(01-07) IT - Internal Transfer'
when sce.sce_pgsc = 'FR' then '(02-07) FR - Fail with Resit'
when sce.sce_pgsc = 'LA' then '(04-01) LA - Lesser Award'
when sce.sce_pgsc = 'N' then '(05-01) N - Awaiting Results'
when sce.sce_pgsc = 'STP' then '(02-05) STP - Studies Terminated (from previous year)'
when sce.sce_pgsc = 'NS' then '(05-04) NS - Never Started'
when sce.sce_pgsc = 'GA' then '(05-02) GA - Graduate Apprentice - progression not known'
when sce.sce_pgsc = 'ICD' then '(05-03) ICD - ICD'
when sce.sce_pgsc is null then '(99) Progression Code not present'
else '###ERROR###'
end "Progression Code Name", --"SCE - Progression Code"

case
when sce.sce_pgsc ='PP' 
	then '(01) Passed at 1st Diet'
when sce.sce_pgsc in ('PR', 'PC', 'RC', 'RP', 'D', 'ERY', 'SB', 'LT', 'RY') --RY added 090524 during review of PGSC
	then '(02) Not Passed at 1st Diet'
else '(99) Do not Count'
end "Progression 1st Diet",

case
when sce.sce_pgsc in ('PP', '1', 'NFY', 'PR', 'PC', 'RC', 'RP')
	then '(01) Progressed'
when sce.sce_pgsc in ('D', 'RY', 'SB', 'LST', '2')          --FR, ST and W removed 08/05/24 during review/mop-up of codes versus dashbaord table of definitions; added to not counted
	then '(02) Not Progressed'
when sce.sce_pgsc in ('LT','N','GA')
	then '(05) Not Yet Known'
when sce.sce_pgsc = 'LAE'
	then '(03) Lesser Award, Early Exit'
when sce.sce_pgsc in ('IT','STP','AWD','LA','NC','NS','FA','ICD', 'FR', 'ST', 'W')     --FA ICD moved from Progressed to Do Not Count 290424; FR, ST, W moved to Do Not Count 080524
	then '(99) Do Not Count'
when sce.sce_pgsc is null 
	then '(05) Not Yet Known'
else '###ERROR###'
end "Progression Status",
*/

---EIS 2023/4 comparator cohorts---
--When not running this EIS section, exclude the EIS additional joins below

case
when (smr2.mod_code = 'AG11058' or smr3.mod_code = 'AG11058') then 'Campus PSE - 11 week'
when (smr2.mod_code = 'AG11059' or smr3.mod_code = 'AG11059') then 'Campus PSE - 6 week'
when (smr2.mod_code = 'AG11066' or smr3.mod_code = 'AG11066') then 'Online PSE - 8 week'
when (smr2.mod_code = 'AG11063' or smr3.mod_code = 'AG11063') then 'PSE - 14 week'
when (smr2.mod_code = 'AG00002' or smr3.mod_code = 'AG00002') then 'Online PSE - Language for Law 4 week'
when (smr2.mod_code like 'AG%' or smr3.mod_code like 'AG%') then 'Other PSE'
--Test - could you have been enrolled on a PSE CRS_CODE but not have one of these specified modules
else 'No PSE enrolment'
end "Has PSE module (EIS)",

case when smr.mod_code in ('AG11058', 'AG11059', 'AG11066', 'AG00002', 'AG11063')
then 'PSE module'
else 'Not PSE module'
end "Is a PSE module (EIS)",

--smr2.mod_code, --added when testing
--smr3.mod_code, --added when testing
/*
case
when smr2.smr_agrg is not null then smr2.mod_code||' - '||smr2.smr_agrg||' - '||smr2.ayr_code
when smr3.smr_agrg is not null then smr3.mod_code||' - '||smr3.smr_agrg||' - '||smr3.ayr_code
else null
end "PSE Grade",
*/

case 
when smr4.mod_code is not null
then 'EIS English module enrolment'
else 'Not EIS English module enrolment'
end "Has EIS module (EIS)",

case 
when smr.mod_code in ('BU11006', 'BU12007', 'AG11073', 'AG11074', 'AG11075', 'AG11076', 'LW11014', 'AG11081')
then 'EIS module'
else 'Not EIS module'
end "Is an EIS module (EIS)",

case
when smr5.mod_code is not null
then 'Core module enrolment'
else 'Not Core module enrolment'
end "Has Core school module (EIS)",

case when smr.mod_code in ('BU51024', 'BU52008', 'BU52025', 'BU52050', 'BU51016', 'BU52046', 'BU52043', 'SW50018', 'PD50177', 'PD50189', 'PD50206', 'LW50107', 'PY51015', 'PY51009')
then 'Core module'
else 'Not Core Module'
end "Is a Core School module (EIS)",

cdd.cdd_name "Country of Domicile", 
reg.reg_name "Country of Domicile Region",
geg.geg_name "Country of Domicile Geographical Group" ,

case
when cdd.cdd_code in ('AU', 'NZ', 'US', 'CA')
then 'USA/Canada/Australia/New Zealand'
else 'Other'
end "Overseas English-speaking domicile",

--sce.sce_stac||' ('||sce.sce_ayrc||')',
--sce4.sce_stac||' ('||sce4.sce_ayrc||')',

case
when sce4.sce_stac is null then sce.sce_stac||' ('||sce.sce_ayrc||')'
else sce4.sce_stac||' ('||sce4.sce_ayrc||')'
end "Most Recent SCE Status",



case
    when sce4.sce_stac in ('X','X-BP','X-NC','X-NS','X-W','XB')
        then 'Associate'
    when sce4.sce_stac in ('C','CH','CO','CT')
        then 'Current'
    when sce4.sce_stac in ('B','BP','BX','CB','DIS','EDP')
        then 'Dormant'
    when sce4.sce_stac in ('ST','W')
        then 'Ended studies'
    when sce4.sce_stac in ('NC')
        then 'Awarded'  
    when sce4.sce_stac in ('IT')
        then 'Internal transfer'
    when sce4.sce_stac in ('MT','NS')
        then 'Never active'
    when sce4.sce_stac in ('LT','PA','PE','PT')
        then 'Not active'
    when sce4.sce_stac in ('P','P1','P2','P3','P4')
        then 'Pending'
   
    when sce.sce_stac in ('X','X-BP','X-NC','X-NS','X-W','XB')
        then 'Associate'
    when sce.sce_stac in ('C','CH','CO','CT')
        then 'Current'
    when sce.sce_stac in ('B','BP','BX','CB','DIS','EDP')
        then 'Dormant'
    when sce.sce_stac in ('ST','W')
        then 'Ended studies'
    when sce.sce_stac in ('NC')
        then 'Awarded'  
    when sce.sce_stac in ('IT')
        then 'Internal transfer'
    when sce.sce_stac in ('MT','NS')
        then 'Never active'
    when sce.sce_stac in ('LT','PA','PE','PT')
        then 'Not active'
    when sce.sce_stac in ('P','P1','P2','P3','P4')
        then 'Pending'        
else '###ERROR###'
end "Enrolment Status Grouping",

--scj.scj_endd, --used in testing groupings

case
when scj.scj_udff = 'Y'
		and rou.rou_udf7 <> 'ICD'
        then 'ICD on UoD Course'
when scj.scj_udff = 'Y'
      and rou.rou_udf7 = 'ICD'
      then 'ICD on ICD Course'       -- otherwise these are getting classified as Direct
else 'Not ICD'
end "ICD Student"
--scj.scj_udff  --used in testing


from sipr.ins_stu stu 

left join sipr.srs_scj scj on scj.scj_stuc = stu.stu_code
left join sipr.srs_sce sce on sce.sce_scjc = scj.scj_code 
left join sipr.ins_spr spr on spr.spr_code = scj.scj_sprc

left join sipr.ins_rou rou on sce.sce_rouc = rou.rou_code -- ROU Table
left join sipr.srs_crs crs on sce.sce_crsc = crs.crs_code -- CRS table
left join sipr.srs_qul qul on qul.qul_code = crs.crs_qulc -- CRS > QUL > EQA
left join sipr.ins_eqa eqa2 on eqa2.eqa_code = qul.qul_eqac -- EQA table attached to CRS table
left join sipr.ins_dpt dpt on dpt.dpt_code = rou.rou_udf6 -- Discipline on ROU
left join sipr.srs_fac fac on fac.fac_code = rou.rou_udf5 -- School on ROU

left join sipr.srs_gen gen on gen.gen_code = stu.stu_gend -- Gender table
left join sipr.srs_eth eth on stu.stu_ethc = eth.eth_code -- ETH table for STU ethnicity
left join sipr.srs_nat nat on stu.stu_natc = nat.nat_code -- NAT table for STU nationality
--left join sipr.srs_mci mci on mci.mci_mstc = stu.stu_code
left join sipr.men_mre mre on mre.mre_code = stu.stu_code
    and mre.mre_mrcc = 'STU'
left join sipr.srs_mci mci on mci.mci_mstc = mre.mre_mstc
    and mre.mre_mrcc = 'STU'
--I have used the 2 in the name so that it is obvious throughtout the script when MCI is source of data 
left join sipr.srs_nat nat2 on nat2.nat_code = mci.mci_natc
left join sipr.srs_eth eth2 on eth2.eth_code = mci.mci_ethc

left join sipr.ins_smr smr on smr.spr_code = sce.sce_scjc
    and sce.sce_ayrc = smr.ayr_code 
left join sipr.ins_mod mods on mods.mod_code = smr.mod_code
left join sipr.cam_lev lev on lev.lev_code = mods.lev_code
left join sipr.ins_dpt dpt2 on dpt2.dpt_code = mods.dpt_code -- Discipline on MOD
left join sipr.srs_fac fac2 on fac2.fac_code = mods.mod_facc -- School on MOD

/*
left join sipr.cam_top top on top.mod_code = mods.mod_code
    and top.top_iuse = 'Y'
left join sipr.ins_dpt dpt3 on dpt3.dpt_code = top.dpt_code -- Discipline on TOP
left join sipr.srs_fac fac3 on fac3.fac_code = dpt3.dpt_facc -- School on TOP via DPT
left join sipr.ins_sub sub on sub.sub_code = top.sub_code
*/
--/* EIS additional joins
left join sipr.srs_sce sce2 on sce2.sce_stuc = sce.sce_stuc
    and sce2.sce_crsc like '%PRES%'
    and sce2.sce_ayrc = '2023/4'
left join sipr.ins_smr smr2 on smr2.spr_code = sce2.sce_scjc
    and smr2.ayr_code = '2023/4'    
    and smr2.mod_code in ('AG11058', 'AG11059', 'AG11066', 'AG00002', 'AG11063')
    --these are the module codes provided by Annie McKinney 13/03/25 as a "EIS Pre-sessional English course modules"
    
left join sipr.srs_sce sce3 on sce3.sce_stuc = sce.sce_stuc
    and sce3.sce_crsc like '%PRES%'
    and sce3.sce_ayrc = '2022/3'
left join sipr.ins_smr smr3 on smr3.spr_code = sce3.sce_scjc
    and smr3.ayr_code = '2022/3'   
    and smr3.mod_code in ('AG11058', 'AG11059', 'AG11066', 'AG00002', 'AG11063')
    --these are the module codes provided by Annie McKinney 13/03/25 as a "EIS Pre-sessional English course modules"

left join sipr.ins_smr smr4 on smr4.spr_code = sce.sce_scjc
    and smr4.ayr_code = '2023/4'
    and smr4.mod_code in ('BU11006', 'BU12007', 'AG11073', 'AG11074', 'AG11075', 'AG11076', 'LW11014', 'AG11081')
    --these are the module codes provided by Annie McKinney 13/03/25 as an "EIS English module"

left join sipr.ins_smr smr5 on smr5.spr_code = sce.sce_scjc
    and smr5.ayr_code = '2023/4'
    and smr5.mod_code in ('BU51024', 'BU52008', 'BU52025', 'BU52050', 'BU51016', 'BU52046', 'BU52043', 'SW50018', 'PD50177', 'PD50189', 'PD50206', 'LW50107', 'PY51015', 'PY51009')
    --these are the module codes provided by Annie McKinney 13/03/25 as a "Core School Module" for the comparators
    
left join sipr.srs_sce sce4 on sce4.sce_scjc = sce.sce_scjc
    and sce4.sce_ayrc = '2024/5'    
--*/

left join sipr.srs_cod cod on scj.scj_codc = cod.cod_code -- Country of domicile on SCJ
left join sipr.srs_cdd cdd on cdd.cdd_code = cod.cod_cddc -- Higher level COD on SCJ
left join sipr.srs_geg geg on cod.cod_gegc = geg.geg_code -- GEG table for country of domicile geographical area
left join sipr.srs_reg reg on cod.cod_regc = reg.reg_code -- REG table added 05/05/21 for Country of Domicile regional grouping 
    
where 
mods.mot_code not in ('APL', 'VLE', 'TT', 'MEDX')
and mods.mod_code <> 'INDPLACE'
and mods.mod_code not like 'TEST%'
and crs.crs_code not like 'ASSOC%'      --when student moves from ASSOC10/BMENNEU to UFBENG2/BMEN, the Level 1-3 SMR records are recorded against the second SCJ AND the first
and stu.stu_udf7 is null -- No test records
and sce.sce_stac not in ('NS', 'P', 'P1')
and smr.smr_agrg is not null        --we are only interested in agreed grades for the SMR and BoE datasets so have excuded these here, as I am running this as an export from sql developer instead of through PBi (13/06/24)
and smr.smr_agrg not in ('9', 'CT', 'WF')    --based on refresh of 2019/0 onwards, these are the grades not part of the assessment scale

--and sce.sce_ayrc >= '2019/0' and sce.sce_ayrc <= '2023/4'
and sce.sce_ayrc = '2023/4' 
--and stu.stu_code = '2581287'
--and stu.stu_code = '2565806'
--and scj.scj_code = '2613841/1' until select distinct was added, was generating duplicate rwos, has two SCE records 
--and stu.stu_code = '2567551' -- returning one 6-week PSE per module and one not-PSE per module 
--and scj.scj_code = '2631187/1' --has two AG modules, gets pick up for AG11059
--and scj.scj_code = '2601361/1'