/*

By removing all of the _ A new Power BI report will have to built so that you can replace all of the column titles and headers and filters correctly ie have the existing one as your reference

ANY AND ALL UPDATES TO THIS SQL SCRIPT MUST BE DONE AT SOURCE > Opening the file in SQL Developer and edit and test> Updating the Power BI file(s) > DO NOT EDIT WITHIN POWER BI FILE(S) ONLY

This file was created on 18/04/23 by Linda Bathgate, Returns Data Quality Assistant, Strategic Intelligence Unit, Strategic Planning
Saved as:   SRT - Student Numbers and Data Requests
Purpose:    To replace Student Numbers Dashboard SQL with MCI and ADD (031022)
Used in:    SIU - Dashboard Data Source (Reporting) (290923) v3.4 > SEN_DataRequests


Over-arching changes and amendments
-removing manual text case statements
-update all field codes to actual names e.g SCJ_AGOE to Age on Entry
-removing the leading _ in column headers
-taking out commented out lines that don't work and/or don't get used
-new entrant calc to take into account HESA start date for xfer records - over 250 records were mis-calced as new in 2022/3 initial batching for HESA RPBT     NEEDS UPDATED ANNUALY


Major Changes and Amendments
SCE - Record Error Filter   Grouped in with HESA - SCE Initial Include_Exclude to provide a non-HESA MI appropriate filter; updated to no longer exclude records who are continuing students submitted to HESA; updated to include IT records at first pass
                            Now called Flag - SCE Initial Include_Exclude
STUA                        The STUA logic / updates are now in code    
Recruitment Pathway         Updated to show ICD students NOT on ICD route - ie those who are in UoD via ICD only
Nationality Area           Removed - this was a manually coded case statement essentially providing the GEG value for Nationalities, and to my knowledge has never been used. If re-required, NAT should be joined to GEG in the SQL for the mapping
MD Status                  Removed - It didn't work anyway
UoD populations             Added in the line needed for the Surname check for the Annual Clan MacThomas Bursary 15/04/24


Queries:
Line 853-ish General Student Populations - some of these are outdated, some are just wrong and don't account for new combinations or nuance - do we want to keep any of these? create new ones? - 849 - 925 neither IB nor LB use these; remove these for now
Line 346-ish - ICD students on and not on ICD routes, how to classify - exclude them or call them something else? Exclude for now
Line 441-ish - how many differnt ways do we need SIMD worked out? Actual Q1-Q5, MD20;MD40/NA_non-scottish? - with IB 10/07/23
-- DONE DEC 2024 Location of Study - needs refined or re-labelled, or split out differently - especially in conjunction with Course Types - IB having thoughts about using SCE_ELSC actual value - LB to add ELS Line 556-ish - DONE
HESA return status
"HESA Populations" needs a manual update every AYR after HESA - is there different way of looking at this? IB does use the HESA Populations one (SCE_UDF1) - IB will have a look at the SQL and let me know if changes need to be make; remove the internal one - updated 061224 to remove AYR-specific requirement
Disability is now also held in DSH records - of which there can be zero for a given year, or multiple within a given year - I have intentionally not updated away from STU_DSBC but how do we deal with that - data subset?
How much does the order of the SQL matter?
ScotGEM - no need to change and introduce a ScotGEM coverage for SEN and FOI purposes
-- DONE MAY 2024 retention and progression - checking summary tables in MI dashboards with coding reviewed IT, FA, LAE, LST, LT with IB on 290424 - mainly the dashboard table needs updating, and added with ICD and GA - can't find original (from TH's time!) so will create a new one


Historical Notes
Need the SFC articulation rule in here to support PPR - it is in here as _Advance Standing
Not all students will have MCI records - these existed in SITS from approx Aug 2021 but not all 2021/2 students matricualted AFTER the task that creates MCI records was implemented
The MCI table was first available in SITS AYR 2021/2, but the roll out of the eVision matric task didn't come until after the start of the year
The following table values and/or text have been changed in Live SITS as a result of the HESA Data Futures data model. This code was checked and updated where any of these tables were in use:
CAR (CAR1 to call up in SITS); CLV; DEP; DSB; ETH; ETR; RLG; SCA; SLU; SVL; SXO; TRN (TRN1 to call up in SITS)



DEV / Issues
Not yet coded to HESA Data Futures data items or tables
ROU_UDF2 for articulation routes
21/09/23 - Sorry dear, we don't currently provide 'location' as a data item for filtering but it was added to the DEV list after all the work we did on updating CBO's etc. Once I get past DF and make sure I know what the 'rules' and 'combinations' actually mean I will be writing something into our Student Enrolment Numbers dashboard. Thank you for picking it up.
DONE 07/02/24 - pulling data together for CCF highlighted that both Location types are wrong e.g. ASSOC9 classified as Studying in UK becuase they are S not O.
DONE 05/09/24 - Fundability added following request from planning team
DONE 11/09/24 - SRS.INI table added to reporting schema to allow reporting of Initiative name.  Enrolment Status Grouping added 
*/

select distinct

-----Report Level Columns-----

case
	when stu.stu_udf7 is not null
        then '(03) Exclude - Test Record'
    when sce.sce_endd = ('01-AUG-'||substr(sce.sce_ayrc,3,2))
         and sce.sce_2ndr not in ('S','P','O')
        then '(03) Exclude - SCE 1 Aug Filter'    
	when sce.sce_moac = 'SAB'
		then '(03) Exclude - DUSA Sabbatical Officer'	
	when (sce.sce_crsc = 'UFMBCHB3'
			and sce.sce_blok in ('1', '2'))
		then '(03) Exclude - SCOTGEM Years 1-2'
        --the HESA requirement has changed so that we report alternate intakes, but for MI purposes we continue to exclude ScotGEM in years 1 and 2 when they are being taught by St Andrews
    when sce.sce_stac in ('NS','MT','X','X-BP','X-NC','X-W','X-NS')
		then '(03) Exclude - SCE status'
	when sce.sce_stac = 'P'
		then '(02) Pending - STAC is P'
    when sce.sce_stac = 'P1'
        then '(02) Pending - STAC is P1'
	when sce.sce_stac = 'IT'
		then '(01) Include - Internal Transfer (IT)'
	else '(01) Include - All other SCEs'
end "Flag - SCE Initial Include_Exclude",


-----STU table-----

stu.stu_code "Student Code",
stu.stu_sta2 "STU Student Status",
initcap(stu.stu_titl) "STU Title",
initcap(stu.stu_fnm1) "STU Forename",
initcap(stu.stu_surn) "STU Surname",
initcap(stu.stu_fusd) "STU Known as name",
stu.stu_name "STU Official name",
--stu.stu_deps "Type of Dependants",
stu.stu_inem "STU Institution Email",
nvl(shi.shi_stid, stu.stu_esid) "Student HESA ID",

-----STU_ADD table-----Current Home-----

add1.add_updd "Current Home Address Update Date",
add1.add_begd "Current Home Address Start Date",
add1.add_add1 "Current Home Address Line 1",
add1.add_add2 "Current Home Address Line 2",
add1.add_add3 "Current Home Address Line 3",
add1.add_add4 "Current Home Address Line 4",
add1.add_add5 "Current Home Address Line 5",
add1.add_pcod "Current Home Address Postcode",
add1.add_codc "Current Home Address Country Code",
cdd4.cdd_name "Current Home Address Country Name",
add1.add_emad "Current Home Address Email",


case
	when cod4.cod_cddc in ('XF','XG','XH','XI','XK')
		then 'UK exc Channel Islands'
	when cod4.cod_cddc in ('XL','GG','JE','IM')
		then 'Channel Islands'
	when cod4.cod_cddc not in ('XF','XG','XH','XI','XK','XL','GG','JE','IM')
		then 'Overseas exc Channel Islands'
	else '#Error#'
end as "Flag - Current Home Address Country Group",

-----STU_ADD table-----Current Contact-----

add2.add_updd "Current Contact Address Update Date",
add2.add_begd "Current Contact Address Start Date",
add2.add_add1 "Current Contact Address Line 1",
add2.add_add2 "Current Contact Address Line 2",
add2.add_add3 "Current Contact Address Line 3",
add2.add_add4 "Current Contact Address Line 4",
add2.add_add5 "Current Contact Address Line 5",
add2.add_pcod "Current Contact Address Postcode",
add2.add_codc "Current Contact Address Country Code",
cdd5.cdd_name "Current Contact Address Country Name",
add2.add_emad "Current Contact Address Email",

case
	when cod5.cod_cddc in ('XF','XG','XH','XI','XK')
		then 'UK exc Channel Islands'
	when cod5.cod_cddc in ('XL','GG','JE','IM')
		then 'Channel Islands'
	when cod5.cod_cddc not in ('XF','XG','XH','XI','XK','XL','GG','JE','IM')
		then 'Overseas exc Channel Islands'
	else '#Error#'
end as "Flag - Current Contact Address Country Group",
   
---------------STU Table / MCI Table---------------

case
when mci.mci_rlgc is not null then to_char(rlg2.rlg_name)
when stu.stu_relb = '01' then 'No religion'
when stu.stu_relb = '02' then 'Buddhist'
when stu.stu_relb in ('03', '04', '05', '06', '07', '08', '09') then 'Christian'
when stu.stu_relb = '10' then 'Hindu'
when stu.stu_relb = '11' then 'Jewish'
when stu.stu_relb = '12' then 'Muslim'
when stu.stu_relb = '13' then 'Sikh'
when stu.stu_relb = '14' then 'Spiritual'
when stu.stu_relb = '80' then 'Other'
when stu.stu_relb = '98' then 'Information refused'
when stu.stu_relb = '99' then 'Not known'
when stu.stu_relb is null then 'Blank'
else '###ERROR###'
end "Religious Belief",

case
when mci.mci_sxoc is not null then to_char(sxo2.sxo_name)
when stu.stu_sxor = '01' then 'Bisexual'
when stu.stu_sxor = '02' then 'Gay man'
when stu.stu_sxor = '03' then 'Gay woman/lesbian'
when stu.stu_sxor = '04' then 'Heterosexual'
when stu.stu_sxor = '05' then 'Other'
when stu.stu_sxor = '98' then 'Information refused'
when stu.stu_sxor is null then 'Blank'
else '###ERROR###'
end "Sexual Orientation",

case
when mci.mci_gidc is not null then to_char(gid2.gid_name)
when stu.stu_gnid = '01' then 'Yes'
when stu.stu_gnid = '02' then 'No'
when stu.stu_gnid = '98' then 'Information refused'
when stu.stu_gnid is null then 'Blank'
else '###ERROR###'
end "Gender Identity",

nvl(gen.gen_name, 'Not recorded') "Gender",

case
when mci.mci_ethc is not null then to_char(eth2.eth_name)
when stu.stu_ethc is not null then to_char(eth.eth_name)
else 'Not recorded'
end "Ethnicity",

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
        then 'Not recorded'
else '###ERROR###'                        
end "Ethnicity Group",

case                       
    when mci.mci_ethc in ('119','33','100','34','101','31','103','39','32','104')                         
        then 'Asian'
    when mci.mci_ethc in ('139','22','120','121','29','21')                                
        then 'Black'
    when mci.mci_ethc in ('159','140','141','142','49','43','42','41')                              
        then 'Mixed'   
    when mci.mci_ethc in ('98','90','997','998','99')                              
        then 'Not known / Prefer not to say'     
    when mci.mci_ethc in ('899','50','16','80','14','180')                              
        then 'Other'     
    when mci.mci_ethc in ('179','19','11','161','164','166','167','168','169','170')                              
        then 'White'     
    when stu.stu_ethc in ('119','33','100','34','101','31','103','39','32','104')                         
        then 'Asian'
    when stu.stu_ethc in ('139','22','120','121','29','21')                                
        then 'Black'
    when stu.stu_ethc in ('159','140','141','142','49','43','42','41')                              
        then 'Mixed'   
    when stu.stu_ethc in ('98','90','997','998','99')                              
        then 'Not known / Prefer not to say'     
    when stu.stu_ethc in ('899','50','16','80','14','180')                              
        then 'Other'     
    when stu.stu_ethc in ('179','19','11','161','164','166','167','168','169','170')                              
        then 'White'
    when mci.mci_ethc is null
        then 'Not recorded'
    when stu.stu_ethc is null          
        then 'Not recorded'
else '###ERROR###'                        
end "Ethnicity Group 2",      --based on work done for Hari Hundal awards gap ethnicity data 110823 as added to NSS DPTs December 2025

		
case
when mci.mci_natc is not null then to_char(nat2.nat_name)
when stu.stu_natc is not null then to_char(nat.nat_name)
else 'Not recorded'
end "Nationality",

case
when mci.mci_clvc is not null then to_char(clv2.clv_name)
when stua.stua_clea is not null then to_char(stua.stua_clea)
else 'Not recorded'
end "Care Leaver",

case
when (apf.apf_cycl in ('2018','2019','2020','2021','2022') and (apf.apf_udfe like '%C%')) 
then 'Care Leaver'
else null
end "Care Leaver (Contextual Flag)",

case
when mci.mci_carc is not null then to_char(car2.car_name)
when stua.stua_carh is not null then to_char(stua.stua_carh)
else 'Not recorded'
end "Carer",

case
when mci.mci_serl is not null then to_char(svl2.svl_desc)
else 'Not recorded'
end "Service Leaver",

case
when mci.mci_sluc is not null then to_char(slu2.slu_name)
else 'Not recorded'
end "Sign Language User",

case
when mci.mci_etrc is not null then to_char(etr2.etr_name)
else 'Not recorded'
end "Estranged",

case
when mci.mci_scac is not null then to_char(sca2.sca_name)
else 'Not recorded'
end "Special Category Student",

case
when mci.mci_trnc is not null then to_char(trn2.trn_name)
else 'Not recorded'
end "Transgender",

case
    when stu.stu_dsbc in ('0','N','U','A','99','98','95')    
        then 'No'
     when stu.stu_dsbc is null then 'No'
else 'Yes'
end "Disability",

dsb.dsb_name "Disability Name",

case
when mci.mci_depc is not null then to_char(dep2.dep_name)
when stu.stu_deps = '01' then 'Young people/children'
when stu.stu_deps = '02' then 'Other relatives/friends'
when stu.stu_deps = '03' then 'No dependants'
when stu.stu_deps = '04' then 'Both young people/children and relatives/friends'
when stu.stu_deps = '98' then 'Prefer not to say'
when stu.stu_deps = '99' then 'Not available'
else 'Not recorded'
end "Dependent Type",

stu.stu_codc "STU - Country of Domicile Code",
cdd3.cdd_name "STU - Country of Domicile Name",



---------------SCJ Table---------------
scj.scj_code "Student Join Code",
scj.scj_ayrc "Academic Year (Entry)",
scj.scj_seq2 "SCJ Sequence",

case
when substr(scj.scj_blok,-1) = '1'
	and scj.scj_blok >5
	then '###ERROR###'
else to_char(scj.scj_blok)
end "Entry Year of Programme",

to_date(scj.scj_begd, 'DD-MON-YY') "SCJ Start Date",
to_date(scj.scj_hesd, 'DD-MON-YY') "SCJ HESA Start Date",
to_date(scj.scj_eend, 'DD-MON-YY') "SCJ Expected End Date",
to_date(scj.scj_endd, 'DD-MON-YY') "SCJ End Date",
to_date(scj.scj_hese, 'DD-MON-YY') "SCJ HESA End Date",


nvl(cdd.cdd_name,'Not recorded') "Country of Domicile",
nvl(geg.geg_name,'Not recorded') "Country of Domicile Area",
nvl(reg.reg_code,'Not recorded') "Country of Domicile Region Code",
nvl(reg.reg_name,'Not recorded') "Country of Domicile Region Name",


case
	when cdd.cdd_code in ('XF','XG','XH','XI','XK')
		then 'UK exc Channel Islands'
	when cdd.cdd_code in ('XL','GG','JE','IM')
		then 'Channel Islands'
	when cdd.cdd_code not in ('XF','XG','XH','XI','XK','XL','GG','JE','IM')
		then 'Overseas exc Channel Islands'
	else '###Error###'
    end as "Country of Domicile Group 1",


case
When cdd.cdd_name in ('Austria', 'Belgium', 'Ireland', 'Bulgaria', 'Croatia', 'Republic of Cyprus', 'Czech Republic', 'Denmark', 'Estonia', 'Finland', 'France', 'Germany', 'Greece', 'Hungary', 'Italy', 'Latvia', 'Lithuania', 'Luxembourg', 'Malta', 'Netherlands', 'Poland', 'Portugal', 'Romania', 'Slovakia', 'Slovenia', 'Spain', 'Sweden') then '(03) EU Student (by domicile)'
when cdd.cdd_name in ('England','Wales','Northern Ireland') then '(02) rUK student (by domicile)'
when cdd.cdd_name = 'Scotland' then '(01) Scottish student (by domicile)'
when cdd.cdd_name is null then '(99) Not recorded'
else '(04) Non-EU or other'
end "Country of Domicile Group 2",

case
when qen.qen_name||' ('||qen.qen_code||')' = ' ()'
	then 'Not recorded'
else to_char(qen.qen_name||' ('||qen.qen_code||')' )
end "Highest Qualification on Entry",

case
when scj.scj_udff = 'Y'
		and rou.rou_udf7 <> 'ICD'
        then 'ICD on UoD Course'
when scj.scj_udff = 'Y'
      and rou.rou_udf7 = 'ICD'
      then 'ICD on ICD Course'       -- otherwise these are getting classified as Direct
when sce.sce_crsc in ('ASSOC9','ASSOC10', 'UFBENG7', 'UFBSC7', 'UFBAARCH4','UFBSCCLS3')
		then 'Partnership'  
when crs.crs_udf4 = 'VALIDATION'
        then 'Validation'
when sce.sce_rouc = 'BMEN' and sce.sce_styc = 'Z'
        then 'Partnership'   
when rou.rou_udf7 = 'GLA'
        then 'Graduate Level Apprenticeship'      
when substr(agn.agn_code,0,1) = 'R' 
        then 'Articulation'
when substr(agn.agn_code,0,1) = 'P'
        then 'Partnership'
when substr(agn2.agn_code,0,1) = 'A'
        then 'Agent'
else 'Direct'
end "Recruitment Pathway",

scj.scj_hapc "Home Postcode",

initcap(nvl(scl.scl_name,'Not recorded')) "Last School",

case
when scj.scj_insc like '49%'
	and scl.scl_name is not null
	then to_char(initcap(scl.scl_name))
else to_char(initcap(nvl(ins.ins_name,'Not recorded')))
end "Last Institution",

case
when scj.scj_qenc in ('24','C30')
	then (case
	when scj.scj_blok > '1'
			then '(02) HNC Advance Standing'
		else '(02) HNC NOT Advance Standing'
		end)
when scj.scj_qenc = 'J30'
	then (case
	when scj.scj_blok > '2'
		then '(01) HND Advance Standing'		
		else '(01) HND NOT Advance Standing'
		end)
else '(03) Not HNC/HND'
end "Advance Standing (SFC)", --defined by SFC definition (31.10.19 DE)

case
when scj.scj_qenc in ('24','C30')
	and scj.scj_blok > '1'
			then '(01) HNC Advance Standing'
when scj.scj_qenc = 'J30'
	and scj.scj_blok > '2'
		then '(02) HND Advance Standing'		
else '(03) Not Advance Standing'
end "Advance Standing (PPR)", --broader grouping for PPR, different order with the pivot tables in mind

scj.scj_arti "Articulation (HESA)",

case
	when scj.scj_qenc in ('P41', 'P46', 'P47', 'P50', 'P51', 'P53', 'P54', 'P62', 'P63', 'P64', 'P65', 'P68', 'P80', 'P91', 'P93', 'P94')
        then '03 Higher / AH / A/AS Level'
	when scj.scj_qenc in ('X01','45')
        then '00 Access (Non-QAA)'
	when scj.scj_qenc in ('X00', '44', '48')
        then '00 Access (QAA)'
	when scj.scj_qenc in ('X02','93')
        then '00 Mature Student'
	when scj.scj_qenc in ('X05','98')
        then '00 No formal quals.'
	when scj.scj_qenc in ('X04', '30', '56', '61', '62', '63', '97')
        then '00 Other quals. not known.'
	when scj.scj_qenc in ('X06', '99','X99')
        then '00 Unknown'
	when scj.scj_qenc in ('92', '94')
        then '00 Vocational'
	when scj.scj_qenc in ('R51', 'R52', 'R80','43','53')
        then '01 INT1 / Standard Grade General / GSCE D-G / Foundation Diploma'
	when scj.scj_qenc in ('Q51', 'Q52', 'Q80', '15', '27', '38', '52', '54', '55','41','51')
        then '02 INT2 / Standard Grade Credit / GSCE A-C'
	when scj.scj_qenc in ('P42', 'P92', '26', '29', '31A', '32', '33', '34', '35', '36', '37', '39', '40')
        then '03 Higher / AH / A/AS Level'
	when scj.scj_qenc in ('P62', 'P63', '42', '46', '47')
        then '03.5 International Baccalaureate'
	when scj.scj_qenc in ('C30', '24')
        then '04 HNC'
	when scj.scj_qenc in ('J30','31')
        then '05 HND'
	when scj.scj_qenc in ('C20', 'J10', 'J20', 'J48', 'J49', 'J80','14','C80','H60')
        then '05 DipHE / CertHE'
	when scj.scj_qenc in ('C90', '22','21')
        then '05.5 UG Credits'
	when scj.scj_qenc in ('H11', 'H71', 'H80', 'HUK', 'HZZ', 'JUK', '1', '11', '12', '13','10')
        then '07 Honours Degree'
	when scj.scj_qenc in ('05','02','03','04','M2X', 'M41', 'M44', 'M71', 'M80', 'M90', 'MUK', 'MZZ', '2', '3', '4', '5', '16', '23', '25', '28','01', 'M-EU')
        then '08 Masters Degree - Taught'
	when scj.scj_qenc in ('D80', 'DUK', 'DZZ', 'D90')
        then '11 Doctoral Degree - Research'
	when scj.scj_qenc is null
		then '99 HQL not recorded'
    when scj.scj_qenc = 'C44'
        then '04 Higher Apprenticeship'
        --added to grouping 04 based on it being a C code and the C codes should be level 4 and this is "Higher Apprenticeship (level 4)" for the full HESA definition
else '###ERROR###'
end "Highest Qualification on Entry Group",

case
when scj.scj_udf8 is null
	or scj.scj_udf8 = 'Not applicable' or scj.scj_udf8 = 'NA'
	then 'Not applicable'
else upper(to_char(scj.scj_udf8))
end "MD Quintile",                  --In the PPR version of Student Numbers the text is Not MD40/Non Scottish Domicile - which I prefer. Think SEN needs actual value plus a MD20/MD40 grouping?

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
end "Age on Entry UoD",
case 
    when scj.scj_agoe <21 
        then'(01) Under 21'
else '(02) 21 and over'
end "Age on Entry SFC",

scj.scj_agoe "Age on Entry",

case
    when scj.scj_accp = '1' 
        then 'Access via SWAP'
    when scj.scj_accp = '2'
        then 'Access non-SWAP'
	when scj.scj_accp is null
		then 'Not Access Student'
else '###ERROR###'
end "Access Programme (HESA)",--"SCJ - Access Student"

scj.scj_ylen "SCJ Length of Study", 
scj.scj_udff "SCJ ICD Student",



-----SCJ_MCI-----

case
when mci.mci_pedc is not null then to_char(ped2.ped_name)
when scj.scj_pare is not null then to_char(scj.scj_pare)
else 'Not recorded'
end "Parental Education",

case
when mci.mci_secc is not null then to_char(sec2.sec_name)
when scj.scj_secl is not null then to_char(scj.scj_secl)
else 'Not recorded'
end "Socio-Economic Class",

case
when mci.mci_sobc is not null then to_char(sob2.sob_name)
when scj.scj_ocbc is not null then to_char(scj.scj_ocbc)
else 'Not recorded'
end "Occupational Background",


---------------SPR Table---------------

spr.spr_aprg "SPR Programme Code",
to_date(spr.spr_edate,'DD-MON-YY') "SPR Expected End Date",
spr.spr_ayre "SPR Expected End Year",
spr.ayr_code "SPR Award Year", 
awd.awd_name "Intended Award",


case
when eqa.eqa_hesa like 'D%' 
	then '(12) Doctorates (Research)'
when eqa.eqa_hesa like 'E%' 
	then '(12) Doctorates (Taught)'
when eqa.eqa_hesa like 'L%' 
	then '(11) Masters (Research)'
when eqa.eqa_hesa like 'M%' 
	then '(11) Masters (Taught)'
when eqa.eqa_hesa like 'H%' 
	then '(10) Honours degree, Graduate Diploma / Certificate'
when eqa.eqa_hesa like 'I%' 
	then '(09) Ordinary degree, Graduate Diploma / Certificate'
when eqa.eqa_hesa like 'J%' 
	then '(08) Higher National Diploma, Diploma in Higher Education, SVQ 4'
when eqa.eqa_hesa like 'C%'
	and eqa.eqa_hesa <>'C90'
	then '(07) Higher National Certificate, Certificate of Higher Education'
when eqa.eqa_hesa = 'C90'
	then '(06.5) UG Credits'
when eqa.eqa_hesa like 'P%' 
	then '(06) Advanced Higher / Higher'
when eqa.eqa_hesa like 'Q%' 
	then '(05) Intermediate 2 / Credit Standard Grade / SVQ2'
when eqa.eqa_hesa like 'R%' 
	then '(04) Intermediate 1 / Credit Standard Grade / SVQ1'
when eqa.eqa_hesa like 'S%' 
	then '(03) Access Levels'
when eqa.eqa_hesa like 'X%' 
	and eqa.eqa_hesa <> 'X99'
		then '(02) HE Education Access'
when eqa.eqa_hesa = 'X99'
	then '(01) No Award'
when eqa.eqa_hesa is null
	then 'Not recorded'
else to_char(eqa.eqa_hesa)
end "Intended Award SCQF Level",
spr.spr_udf1 "Attending Graduation",
spr.spr_udf2 "Allowed to Graduate",
spr.spr_udf4 "Graduation Ceremony",
spr.spr_awdd "SPR - Award Date",




---------------SCE Table---------------

sce.sce_ayrc "Academic Year (Study)", --"SCE - Enrolment Year"
sce.sce_seq2 "SCE Sequence", 
sce.sce_blok "Year of Course", --"SCE - Year of Study"      --should it be if SCE_BLOK = A use SCE_YPRG?
sce.sce_yprg "SCE_YPRG",
sce.sce_ysdy "SCE_YSDY",
sce.sce_udf1 "SCE XPSR01",
sce.sce_btch "SCE_BTCH",
sce.sce_prgc "SCE Programme Code",
prg.prg_name "SCE Programme Name",
sce.sce_2ndr "HESA Marker",
sce.sce_crsc "SCE Course code",
to_date(sce.sce_begd, 'DD-MON-YY') "SCE Start Date",
to_date(sce.sce_endd, 'DD-MON-YY') "SCE End Date",
sce.sce_occl "SCE Occurrence",
sce.sce_styc "SCE External Student Type",

case
when sce.sce_occl in ('A','B','C','D','E','BT','BF')
THEN 'Semester 1'
when sce.sce_occl in ('F','G','H','I','J','K','L')
then 'Semester 2'
else to_char(sce.sce_occl)
end "SCE Semester",

sce.sce_moac "SCE Mode of Attendance Code",
eqa2.eqa_hesa "SCE HESA Course Aim ",


sce.sce_elsc "SCE External Location of Study",

case
when substr(sce.sce_endd,4,3) = 'AUG'
	then '(01) August'
when substr(sce.sce_endd,4,3) = 'SEP'
	THEN '(02) September'
when substr(sce.sce_endd,4,3) = 'OCT'
	then '(03) October'
when substr(sce.sce_endd,4,3) = 'NOV' 
	then '(04) November'
when substr(sce.sce_endd,4,3) = 'DEC' 
	then '(05) December'
when substr(sce.sce_endd,4,3) = 'JAN' 
	then '(06) January'
when substr(sce.sce_endd,4,3) = 'FEB' 
	then '(07) February'
when substr(sce.sce_endd,4,3) = 'MAR' 
	then '(08) March'
when substr(sce.sce_endd,4,3) = 'APR' 
	then '(09) April'
when substr(sce.sce_endd,4,3) = 'MAY' 
	then '(10) May'
when substr(sce.sce_endd,4,3) = 'JUN' 
	then '(11) June'
when substr(sce.sce_endd,4,3) = 'JUL' 
	then '(12) July'
else 'Not Applicable'
end "Academic Month of Study End", --"SCE - Withdrawal Month"
nvl(rft.rft_name,'Not Applicable') "Reason for Leaving 1",
nvl(rft2.rft_name,'Not Applicable') "Reason for Leaving 2",

--nvl(sce.sce_stld/100,'Not Recorded') "SCE Student FTE",     --gave an error re invalid number 
--nvl(hin.hin_load/100,'Not Recorded') "HIN Student FTE",
sce.sce_stld/100 "SCE Student FTE",
hin.hin_load/100 "HIN Student FTE",
sta.sta_name||' ('||sta.sta_code||')' "Enrolment Status",

case
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

case 
    when sce.sce_crsc in ('ASSOC9', 'ASSOC10', 'UFBENG7', 'UFBSC7') --because these students can have dormant/erroneous coding, they need to be split out to show as FOC the whole time
		then 'Face-to-face off-campus' 
    when sce.sce_moac ='AS' 
        then'Associate Student'
	when sce.sce_crsc in ('UFBA31','UDBA3200')
		then 'Validation Programme' --Ballyfermot students to be removed from FT calculation
	when sce.sce_moac = 'WBL'
		then 'Work Based Learning'
    when sce.sce_moac in ('DDL','DL','DLO', 'DLF') --DFL added AYR 2024/5
		or (sce.sce_2ndr = 'O'
		and (sce.sce_moac like 'FT%'
			or sce.sce_moac like 'PT%'
			or sce.sce_moac like '%PT'
			or sce.sce_moac like '%FT')) --All students based Overseas should be DL.	
        then'Distance Learning'
	when sce.sce_moac = 'BOC'
		then 'Blended off-campus'
	when sce.sce_moac in ('FOC','FOCP','FOCF') 
		then 'Face-to-face off-campus'
    when sce.sce_moac ='DOR' 
        then'Dormant'
    when sce.sce_moac in ('CFT','CYR','DFT','EYR','FT','FTARCH','FTF','FTIP','FTO','GYRY','OYR','SAB','STE','TYR','WFT','IYR') 
        --then'Full-time on campus'
		then'Full-time'
    when sce.sce_moac in ('CPT','DPT','PT','PTO','WPT','WMS') 
        --then'Part-time on campus'
		then'Part-time'
else '###ERROR###'
end "Mode of Attendance",
case
	when sce.sce_crsc in ('ASSOC9', 'ASSOC10', 'UFBENG7', 'UFBSC7', 'UFBA31', 'UDBA3200') 
        then 'Studying off campus'
    when sce.sce_crsc = 'UFBSCCLS3' and sce.sce_elsc = '10'
         then 'Studying off campus'
    when sce.sce_moac in ('CFT','CYR','DFT','EYR','FT','FTARCH','FTF','FTIP','FTO','GYRY','OYR','SAB','STE','TYR','WFT','CPT','DPT','PT','PTO','WPT','WMS','IYR') 
		and (sce.sce_2ndr <> 'O' and sce.sce_elsc <> '10')
            then 'Studying on campus'
	else 'Studying off campus'
end "Location of Study 1",
/*
case
	when sce.sce_2ndr = 'S'
		then 'UK Based Student'
	when sce.sce_2ndr = 'O'
		then 'Overseas Based Student'                               --need to review this for the parternships students overseas, using SCE_ELSC as well? Def needs refined
	else 'Not Yet Categorised/Excluded from HESA'
end "Location of Study 2",
*/
case
	when sce.sce_crsc in ('ASSOC9', 'ASSOC10', 'UFBENG7', 'UFBSC7', 'UFBA31') 
        then 'Overseas Based Student'
    when sce.sce_crsc = 'UFBSCCLS3' and sce.sce_elsc = '10'
        then 'Overseas Based Student'
    when sce.sce_2ndr in ('S', 'P') and sce.sce_elsc = '10'
        then 'Overseas Based Student'
    when sce.sce_2ndr in ('S', 'P')
		then 'UK Based Student' 
	when sce.sce_2ndr = 'O'
		then 'Overseas Based Student'                               
	else 'Not Yet Categorised/Excluded from HESA'
end "Location of Study 2",
--I have chosen location and not SCE_STYC; SCE_ELSC comes from CBO and is therefore not subject to a data quality check for it to exist, whereas STYC is updated and entered manually.

CASE 
    when sce.sce_fstc ='HS' 
        then 'HomeScottish'
    when sce.sce_fstc in ('CIOMC','H','HC','HEU','HFP','HFW','HH','HHC','HNF','HNFS','HNI','HNIC','HNIPR','HSEU','HTH') 
        then 'HomeEU'
    --when sce.sce_fstc in ('O','OC','OFP','OH','ONF','ONFS','ONI','ONIPR','OTH') 
        --then 'Overseas'
    --added/amended 16/08/2024 and to be applied to 2023/4 onwards only re OH being considered as 'Home'
    when sce.sce_fstc in ('O','OC','OFP','ONF','ONFS','ONI','ONIPR','OTH') 
        then 'Overseas'
    when sce.sce_fstc = 'OH' and scj.scj_ayrc >= '2023/4'
        then 'HomeScottish'
    when sce.sce_fstc = 'OH' and scj.scj_ayrc <= '2022/3'
        then 'Overseas'  
    when sce.sce_fstc in ('CIOM','HRUK','HRUKF','HRUKN','CIOMF','CIOMN') 
        then'rUK'
	when sce.sce_fstc is null
		then 'Not recorded'
else '###ERROR###'
end "Student Fee Status", --"SCE - Fee Status"

-- Fundability assed to support student number planning

nvl (sce.sce_efid,'Not recorded') "SCE_Fundability code",
nvl (efu.efu_name,'Not recorded') "Fundability",

case
    when sce.sce_efid in ('1','J')
        then 'Funded by SFC'
    when sce.sce_efid = '2'
        then 'Not funded by SFC'
    when sce.sce_efid = '3'
        then 'Not eligible for funding'
    when sce.sce_efid is null
        then 'Not recorded'
else '###ERROR###'
end "Fundability Group", 

nvl(sce.sce_ini1,'Not recorded') "Initiative 1 code",
nvl(ini1.ini_desc,'Not recorded') "Initiative 1 name",
nvl (sce.sce_ini2,'Not recorded') "Initiative 2 code",
nvl (ini2.ini_desc,'Not recorded') "Initiative 2 name",

case
    when sce.sce_ayrc = scj.scj_ayrc
    and scj.scj_stnp is null        --not an IT; therefore exception report required
        then '(01) New Entrant'
else '(02) Continuing'
end "Entry Status UoD",         ---but this doesn't cover transfers does it? ie it will count an IT when it shouldn't? Would we be better of defining this by the SCJ_HESD perhaps?
case
    when hcd.hcd_srp1 = '1'
	THEN '(01) New Entrant'
else '(02) Continuing'
end "Entry Status SFC",
case
    when sce.sce_2ndr in ('S', 'P')
        then 'UK Based student'
    when sce.sce_2ndr = 'O'
		or (sce.sce_crsc = 'ASSOC9'
		or sce.sce_crsc = 'UFBA31') --add Ballyfermot and WUHAN students to Overseas population
        then 'Overseas Based Student'
	when sce.sce_2ndr is null
		then 'Not Yet Categorised'
	else 'Excluded from HESA'
end "HESA Return Status",

sce.sce_frn2 "SCE Franchised Out",
sce.sce_capc "SCE Termtime Postcode",
sce.sce_ttac "SCE Termtime Accommodation Type",
sce.sce_udf9 "SCE NSS Status",
sce.sce_moac "SCE Mode of Attendance Code",
sce.sce_stac "SCE Enrolment Status Code",
sce.sce_regd "SCE Matriculation Date",
sce.sce_stad "SCE Status Modified Date",
cbo.cbo_lcac "SCE CBO Location",
sce.sce_redi "SCE Reduced Return",

---------------ROU Table---------------
fac.fac_name "School", --"ROU - School"
dpt.dpt_name "Discipline", --"ROU - Discipline"
nvl(initcap(rou.rou_udf3),'###ERROR###') "Controlled Subject",
rou.rou_name||' ('||rou.rou_code||')' "Programme Name (Route)", --"ROU - Programme Route"
rou.rou_udf7 "ROU Admissions Process",


---------------CRS Table---------------
--crs.crs_code "_Course Code",
crs.crs_name "Course Name", --"CRS - Course Name"
crs.crs_ylen "Course Expected Length",

case
    when crs.crs_udf1 ='A'
        then'(05) Access'
   	when crs.crs_udf1 ='R' 
        then'(03) Research'
    when crs.crs_udf1 ='T' 
        then'(02) Taught Postgraduate'
	when sce.sce_prgc like'%PGDE%' --SFC level is TPG at UG fees. 
        then'(02) Taught Postgraduate'
	when sce.sce_prgc like'%PGCE%' 
        then'(02) Taught Postgraduate' --SFC level is TPG at UG fees. 
    when crs.crs_udf1 ='U' 
		then'(01) Undergraduate'
else '###ERROR###'
end "Course Level",

case
when eqa2.eqa_hesa like 'D%' 
	then '(12) Doctorates (Research)'
when eqa2.eqa_hesa like 'E%' 
	then '(12) Doctorates (Taught)'
when eqa2.eqa_hesa like 'L%' 
	then '(11) Masters (Research)'
when eqa2.eqa_hesa like 'M%' 
	then '(11) Masters (Taught)'
when eqa2.eqa_hesa like 'H%' 
	then '(10) Honours degree, Graduate Diploma / Certificate'
when eqa2.eqa_hesa like 'I%' 
	then '(09) Ordinary degree, Graduate Diploma / Certificate'
when eqa2.eqa_hesa like 'J%' 
	then '(08) Higher National Diploma, Diploma in Higher Education, SVQ 4'
when eqa2.eqa_hesa like 'C%'
	and eqa2.eqa_hesa <>'C90'
	then '(07) Higher National Certificate, Certificate of Higher Education'
when eqa2.eqa_hesa = 'C90'
	then '(06.5) UG Credits'
when eqa2.eqa_hesa like 'P%' 
	then '(06) Advanced Higher / Higher'
when eqa2.eqa_hesa like 'Q%' 
	then '(05) Intermediate 2 / Credit Standard Grade / SVQ2'
when eqa2.eqa_hesa like 'R%' 
	then '(04) Intermediate 1 / Credit Standard Grade / SVQ1'
when eqa2.eqa_hesa like 'S%' 
	then '(03) Access Levels'
when eqa2.eqa_hesa like 'X%' 
	and eqa2.eqa_hesa <> 'X99'
		then '(02) HE Education Access'
when eqa2.eqa_hesa = 'X99'
	then '(01) No Award'
when eqa2.eqa_hesa is null
	then '(99) No EQA level for CRS'
else to_char(eqa2.eqa_hesa)
end "Course Level (SCQF)",
nvl(initcap(crs_udf4),'Not recorded') "Course Type",
crs.crs_ttic "Course TTIC",  --needed for SFC and teacher training counts
tti.tti_name "Course TTIC Name",
crs.crs_ylen "Course Length in Years", --needed for completion rates of e.g. Year 2 student completing 2 AYR's later (but only for 4-year UG programmes :))
uom.uom_name "Course Units of Length",
crs.crs_leng "Course Length in Units",
crs.crs_udf5 "Course AOR Activity Type",

---------------Retention---------------

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
nvl(sce.sce_pgsc,'N/A') "SCE Progression Code",


---------------Progression---------------
--the order of the codes here matches the order of the codes in te 'lookup' table on the dashboard info page - I am not sure where or when the numbering of e.g. 02-01 was decided
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





---------------General Student Populations---------------
case 
    when sce.sce_moac in ('DDL','DFT','DPT')
        then 'Non-Active Students'
	else 'Select All Other Students'
end "Population - Non-Active",
case
when sce.sce_moac in ('WFT','WPT','CFT','CPT') 
        then 'Writing Up'
	else 'Select All Other Students'
end "Population - WritingUp",
case
    when sce.sce_stac like 'X%'
        then 'Associate Students'
else 'Select All Other Students'
end "Population - Associate",
/*case
    when sce.sce_prgc like 'NON%'
        and sce.sce_rouc like '1%0'
		then 'Non-Credit Bearing Students'
else 'Select All Other Students'
end "_Population - Non Graduating",*/ -- code parsed out as redundant (2.3.20 DE)
case
    when sce.sce_prgc like 'VIS%'
	then 'Visiting/Exchange Students'
else 'Select All Other Students'
end "Population - Visiting",
case
    when sce.sce_prgc like 'NON%'
        and sce.sce_rouc not like '1%0'
			then 'Non-Credit Bearing Students'
else 'Select All Other Students'
end "Population - NCB",
case 
    when sce.sce_moac in ('DDL','DFT','DPT')
        then 'Non-Active Students'
    when sce.sce_moac in ('EYR','TYR','GYRY','IYR')
        or sce.sce_styc in ('ERA','INTEX','IEO','TURO')
        then 'Outgoing Exchange Students'
    when sce.sce_moac in ('WFT','WPT','CFT','CPT') 
        then 'Writing Up'
    when sce.sce_stac like 'X%'
        then 'Associate Students'
    when sce.sce_prgc like 'NON%'
        then (case
        when sce.sce_rouc like '1%0'
        then 'Non-Graduating Students'
        else 'Non-Credit Bearing Students'
        end)
    when sce.sce_prgc like 'VIS%'
        then 'Visiting/Exchange Students'
else 'Normal Student Population'
end "Populations - DFT, WFT etc.",


---------------UoD Specific Student Populations--------
case
when sce.sce_rouc in ('ACWA','LSWA','ESWA')   ---19/06/23 these route codes need to be checked
	then '(01) UoD Co-curriculum Student'
else '(02) Not UoD Co-curriculum Student'
end "UoD Co-curriculum Student",                                           --this denotes CURRENT co-curriculm; Access is PREVIOUSLY an access student; SFC is CURRENT - should these all be the same, or at least update the name to reflect current/previous
case
    when scj2.scj_crsc in ('ADACSS7','ADACSS8','ADACSS86','AFACSS9')
		then '(01) UoD Access Student'
else '(02) Not UoD Access Student'
end "UoD Access Student", -- tested working (25.9.19 DE)
case
when scj.scj_udfa is null
	or scj.scj_udfa in ('A','B','C','F')
	then 'N/A'
when scj.scj_udfa = 'E'
	then 'E - UG Skills for Growth'
when scj.scj_udfa = 'J'
	then 'J - Articulation from D and A College'
when scj.scj_udfa = 'K'
	then 'K - Articulation from Fife College'
else 'N/A'
end "SFC Additional Funded Student",

case
when
stu.stu_surn in ('Combie', 'MacOmie', 'MacOmish', 'McColm', 'McComas', 'McCombe', 'McComb', 'McCombie', 'McComie', 'McComish', 'Tam', 'Thom', 'Thoms', 'Thomas', 'Thomson', 'MAC%OMIE', 'MAC%OMISH', 'MC%COLM', 'MC%COMAS', 'MC%COMBE', 'MC%COMBE', 'MC%COMBIE', 'MC%COMIE', 'MC%COMISH', 'Mac%Omie', 'Mac%Omish', 'Mc%Colm', 'Mc%Comas', 'Mc%Combe', 'Mc%Combe', 'Mc%Combie', 'Mc%Comie', 'Mc%Comish', 'COMBIE', 'MACOMIE', 'MACOMISH', 'MCCOLM', 'MCCOMAS', 'MCCOMBE', 'MCCOMB', 'MCCOMBIE', 'MCCOMIE', 'MCCOMISH', 'TAM', 'THOM', 'THOMS', 'THOMAS', 'THOMSON')
then 'Clan MacThomas Bursary'
else null
end "Clan MacThomas Bursary",


---------------HESA Populations--------
case
when hcd.hcd_srpp = '1' 
	then '(01) HESA SR HE Population'
when hcd.hcd_srpp = '2' 
	then '(02) HESA SR FE Population'
when hcd.hcd_srpp = '0' 
	then '(03) HESA Non-SR Population'

--added 10/02/22
when sce.sce_udf1 = '1'
    then '(01) HESA SR HE Population'
when sce.sce_udf1 = '2'
    then '(02) HESA SR FE Population'
when sce.sce_udf1 = '0'
    then '(03) HESA Non-SR Population'
--the sce_udf1 field had to be included as we have been having technical issues with uploading HCD data from the HESA core data files - Sammy Stewart is following this up with Tribal - and we are holding SR pop in this field
when sce.sce_udf1 = 'AOR'
    then '(04) HESA Aggregate Offshore Population'
when sce.sce_udf1 = 'EXL' 
    then 'Not applicable'   
when sce.sce_2ndr in ('X', 'E', 'N')
    then 'Not applicable'    
when sce.sce_udf1 is null 
    then '(05) HESA Population not yet defined'
--when sce.sce_2ndr = 'O' 
	--and sce.sce_Ayrc < '2024/5'            --manual update for every new academic year (2.3.20 DE)- updated from 2019/0 to 2021/2 on 10/02/22
	--then '(04) HESA Aggregate Offshore Population'
--when sce.sce_ayrc >= '2024/5'             --manual update for every new academic year (2.3.20 DE) - updated from 2019/0 to 2021/2 on 10/02/22
	--then '(05) HESA Population not yet defined'
--added 15/07/22

--when ((sce.sce_ayrc < '2024/5') and (sce.sce_2ndr is null))        --manual update for every new academic year
    --then 'Not applicable'                   
else '###ERROR###'
end "HESA Populations",


case
when hcd.hcd_srpp = '1' 
	then '(01) HESA SR HE Population'
when hcd.hcd_srpp = '2' 
	then '(02) HESA SR FE Population'
when hcd.hcd_srpp = '0' 
	then '(03) HESA Non-SR Population'
when sce.sce_2ndr = 'O' 
	then '(04) HESA Aggregate Offshore Population'
when sce.sce_2ndr in ('X','N','E')
	then '(99) Excluded from HESA'
--Null population
when hcs.hcs_gcqa = 'Z99'
			or
		(hin.hin_ayrc ='2015/6' 
		and to_date(hin.hin_comd, 'DD-MON-YY') >to_date('31-JUL-16','DD-MON-YY')
		or (hin.hin_ayrc ='2016/7' 
		and to_date(hin.hin_comd, 'DD-MON-YY') >to_date('31-JUL-17','DD-MON-YY'))
		or (hin.hin_ayrc ='2017/8' 
		and to_date(hin.hin_comd, 'DD-MON-YY') >to_date('31-JUL-18','DD-MON-YY'))
		or (hin.hin_ayrc ='2018/9' 
		and to_date(hin.hin_comd, 'DD-MON-YY') >to_date('31-JUL-19','DD-MON-YY'))
		or (hin.hin_ayrc ='2019/0' 
		and to_date(hin.hin_comd, 'DD-MON-YY') >to_date('31-JUL-20','DD-MON-YY'))
		)
			or
		(hin.hin_ayrc ='2015/6' 
		and to_date(hin.hin_endd, 'DD-MON-YY') <to_date('01-AUG-15','DD-MON-YY')
		or (hin.hin_ayrc ='2016/7' 
		and to_date(hin.hin_endd, 'DD-MON-YY') <to_date('01-AUG-16','DD-MON-YY'))
		or (hin.hin_ayrc ='2017/8' 
		and to_date(hin.hin_endd, 'DD-MON-YY') <to_date('01-AUG-17','DD-MON-YY'))
		or (hin.hin_ayrc ='2018/9' 
		and to_date(hin.hin_endd, 'DD-MON-YY') <to_date('01-AUG-18','DD-MON-YY'))
		or (hin.hin_ayrc ='2019/0' 
		and to_date(hin.hin_endd, 'DD-MON-YY') <to_date('01-AUG-19','DD-MON-YY'))
		)
			or
		hin.hin_mode in ('51','63','64','98')
			or
		hin.hin_exch in ('4','G')
			or
		hin.hin_locn = 'S'
			or
		hcs.hcs_ttci = 'F'
			then '(0.35) HESA Non-SR Population (Calculated)'
--Non-standard population
when hin.hin_mode in ('43','44')
			or
	hin.hin_typy = '5'
			or
	hin.hin_nota in ('1','2')
			or
	(to_number(to_date(hin.hin_endd, 'DD-MON-YY')-to_date(hin.hin_comd,'DD-MON-YY'))<=379
	and ((hin.hin_ulen = '3'
		and hin.hin_elen not in ('1','2'))
		or
		(hin.hin_ulen = '4'
		and hin.hin_elen not in ('1' , '2' , '3' , '4' , '5' , '6' , '7' , '8' , '9' , '10' , '11' , '12' , '13' , '14'))
		or
		(hin.hin_ulen = '5'
		and hin.hin_elen not in ('1' , '2' , '3' , '4' , '5' , '6' , '7' , '8' , '9' , '10' , '11' , '12' , '13' , '14' , '15' , '16' , '17' , '18' , '19' , '20' , '21' , '22' , '23' , '24' , '25' , '26' , '27' , '28' , '29' , '30' , '31' , '32' , '33' , '34' , '35' , '36' , '37' , '38' , '39' , '40' , '41' , '42'))
		or (hin.hin_ulen in ('1','2')
		or hin.hin_ulen is null))
		and (hin.hin_load <'0'
		or hin.hin_load is null
		or hcd.hcd_sceq <> '01'))
		--or (to_date(hin.hin_endd, 'DD-MON-YY')-to_date(hin.hin_comd,'DD-MON-YY'))>14
		then 
			'(0.35) HESA Non-SR Population (Calculated)'
-- Standard Reg Population
when (hcs.hcs_ttci in ('0', '1', '2', '5', '9', 'D', 'Q')
		or hcs.hcs_ttci is null)
			and
	(hin.hin_locn in ('6', '9', 'C', 'D', 'E', 'H', 'J', 'K', 'T', 'U', 'Z')
		or hin.hin_locn is null)
			and
	 (hin.hin_exch in ('N','Y','Z')
		or hin.hin_exch is null)
			and
	 hin.hin_mode in ('01', '02', '12', '13', '14', '23', '24', '25', '31', '33','34','35','36', '38', '39', '43', '44', '65', '73', '74', '99')
			and
		((hin.hin_endd is null
		and (hin.hin_typy in ('1','3','4')
		or hin.hin_typy is null))
			or
		(hin.hin_endd is null
		and hin.hin_typy ='2'
		and hin.hin_nota is null))
		or ((to_date(hin.hin_endd, 'DD-MON-YY')-to_date(hin.hin_comd,'DD-MON-YY'))>14
		and (hin.hin_load >'0'
		or hin.hin_load is not null
		or hcd.hcd_sceq = '01'))
		then (case
				when (hcs.hcs_gcqa like 'P%'
				or hcs.hcs_gcqa like 'Q%'
				or hcs.hcs_gcqa like 'R%'
				or hcs.hcs_gcqa like 'S%'
				or hcs.hcs_gcqa like 'X%')
					then '(0.25) HESA SR FE Population (Calculated)'
				when (hcs.hcs_gcqa like 'D%'
				or hcs.hcs_gcqa like 'E%'
				or hcs.hcs_gcqa like 'L%'
				or hcs.hcs_gcqa like 'M%'
				or hcs.hcs_gcqa like 'H%'
				or hcs.hcs_gcqa like 'I%'
				or hcs.hcs_gcqa like 'J%'
				or hcs.hcs_gcqa like 'C%')
					then '(0.15) HESA SR HE Population (Calculated)'
						else '(0.35) HESA Non-SR Population (Calculated)'
				end)
when (hcs.hcs_ttci in ('0', '1', '2', '5', '9', 'D', 'Q')
		or hcs.hcs_ttci is null)
			and
	(hin.hin_locn in ('6', '9', 'C', 'D', 'E', 'H', 'J', 'K', 'T', 'U', 'Z')
		or hin.hin_locn is null)
			and
	 (hin.hin_exch in ('N','Y','Z')
		or hin.hin_exch is null)
			and
	 hin.hin_mode in ('01', '02', '12', '13', '14', '23', '24', '25', '31', '33','34','35','36', '38', '39', '43', '44', '65', '73', '74', '99')
			and
		(to_date(hin.hin_endd, 'DD-MON-YY')-to_date(hin.hin_comd,'DD-MON-YY')>379)
			or
		(to_number(to_date(hin.hin_endd, 'DD-MON-YY')-to_date(hin.hin_comd,'DD-MON-YY'))<=379
		and ((hin.hin_ulen = '3'
		and hin.hin_elen in ('1','2'))
		or
		(hin.hin_ulen = '4'
		and hin.hin_elen in ('1' , '2' , '3' , '4' , '5' , '6' , '7' , '8' , '9' , '10' , '11' , '12' , '13' , '14'))
		or
		(hin.hin_ulen = '5'
		and hin.hin_elen in ('1' , '2' , '3' , '4' , '5' , '6' , '7' , '8' , '9' , '10' , '11' , '12' , '13' , '14' , '15' , '16' , '17' , '18' , '19' , '20' , '21' , '22' , '23' , '24' , '25' , '26' , '27' , '28' , '29' , '30' , '31' , '32' , '33' , '34' , '35' , '36' , '37' , '38' , '39' , '40' , '41' , '42'))
		))
		or ((to_date(hin.hin_endd, 'DD-MON-YY')-to_date(hin.hin_comd,'DD-MON-YY'))>14
		and (hin.hin_load >'0'
		or hin.hin_load is not null
		or hcd.hcd_sceq = '01'))
		then
		(case
				when (hcs.hcs_gcqa like 'P%'
				or hcs.hcs_gcqa like 'Q%'
				or hcs.hcs_gcqa like 'R%'
				or hcs.hcs_gcqa like 'S%'
				or hcs.hcs_gcqa like 'X%')
					then '(0.25) HESA SR FE Population (Calculated)'
				when (hcs.hcs_gcqa like 'D%'
				or hcs.hcs_gcqa like 'E%'
				or hcs.hcs_gcqa like 'L%'
				or hcs.hcs_gcqa like 'M%'
				or hcs.hcs_gcqa like 'H%'
				or hcs.hcs_gcqa like 'I%'
				or hcs.hcs_gcqa like 'J%'
				or hcs.hcs_gcqa like 'C%')
					then '(0.15) HESA SR HE Population (Calculated)'
						else '(0.35) HESA Non-SR Population (Calculated)'
				end)
when hin.hin_scjc is null 
	then '(99) Not yet assigned to HESA population'
else '###ERROR###'
end "HESA Populations INTERNAL",


/*testing the adding of some HESA fields to support a request
hsb.hsb_jacs,
hsb.hsb_perc,
hhs.hhs_hecs,
hhs.hhs_perc
*/



---------------HIN Table---------------
--hin.hin_hcic "HIN - HCS",
--hin.hin_load "HIN - Student FTE", --is in the SCE table section beside SCE FTE
hin.hin_locn "HIN - Location of Study",
hin.hin_mstf "HIN - Major Source of Funding",
hin.hin_elen "HIN - Expected Length of Study",


---------------HCD Table---------------
case
when hcd.hcd_lev5 = '1'
	then '(01) - Postgraduate (research)'
when hcd.hcd_lev5 = '2'
	then '(02) - Postgraduate (taught)'
when hcd.hcd_lev5 = '3'
	then '(03) - First degree'
when hcd.hcd_lev5 = '4'
	then '(04) - Other undergraduate'
when hcd.hcd_lev5 = '5'
	then '(05) - Further education'
else '(99) Not recorded'
end "XLEV501 (HCD)",


case
when eqa2.eqa_hesa in ('D00', 'D90', 'L00', 'L80', 'L90', 'L91', 'L99') 
    then '(01) - Postgraduate (research)'
when eqa2.eqa_hesa in ('E00', 'E13', 'E40', 'E43', 'E90', 'M00', 'M01', 'M02', 'M10', 'M11', 'M13', 'M16', 'M40', 'M41', 'M42', 'M43', 'M44', 'M45', 'M50', 'M70', 'M71', 'M72', 'M73', 'M76', 'M78', 'M79', 'M80', 'M86', 'M88', 'M90', 'M91', 'M99') 
    then '(02) - Postgraduate (taught)'
when eqa2.eqa_hesa in ('M22', 'M26', 'M28', 'H00', 'H11', 'H12', 'H16', 'H18', 'H22', 'H23', 'H50', 'I00', 'I11', 'I12', 'I16')
    then '(03) - First degree'
when eqa2.eqa_hesa in ('H13', 'H41', 'H42', 'H43', 'H60', 'H61', 'H62', 'H70', 'H71', 'H72', 'H76', 'H78', 'H79', 'H80', 'H81', 'H88', 'H90', 'H91', 'H99', 'I60', 'I61', 'I70', 'I71', 'I72', 'I73', 'I74', 'I76', 'I78', 'I79', 'I80', 'I81', 'I90', 'I91', 'I99', 'J10', 'J13', 'J16', 'J20', 'J26', 'J30', 'J41', 'J42', 'J43', 'J45', 'J76', 'J80', 'J90', 'J99', 'C13', 'C20', 'C30', 'C41', 'C42', 'C43', 'C77', 'C78', 'C80', 'C90', 'C99')
	then '(04) - Other undergraduate'
when eqa2.eqa_hesa in ('P41', 'P42', 'P43', 'P45', 'P50', 'P55', 'P56', 'P70', 'P77', 'P78', 'P80', 'P85', 'P90', 'Q41', 'Q42', 'Q43', 'Q45', 'Q50', 'Q56', 'Q57', 'Q70', 'Q80', 'Q90', 'R42', 'R43', 'R45', 'R50', 'R56', 'R57', 'R70', 'R80', 'R90', 'S42', 'S57', 'S80', 'S90', 'X00', 'X01', 'X99')
    then '(05) - Further education'
else '(99) Not recorded'
end "XLEV501 (calc)",

case
when hcd.hcd_lev6 = '1'
	then '(01) - Higher Degree (research)'
when hcd.hcd_lev6 = '2'
	then '(02) - Higher Degree (taught)'
when hcd.hcd_lev6 = '3'
	then '(03) - Other postgraduate'
when hcd.hcd_lev6 = '4'
	then '(04) - First Degree'
when hcd.hcd_lev6 = '5'
	then '(05) - Other undergraduate'
when hcd.hcd_lev6 = '6'
	then '(05) - Further Education'
else '(99) Not recorded'
end "XLEV601",

case
when hcd.hcd_lql6 = '1'
	then '(01) - Higher Degree (research)'
when hcd.hcd_lql6 = '2'
	then '(02) - Higher Degree (taught)'
when hcd.hcd_lql6 = '3'
	then '(03) - Other postgraduate'
when hcd.hcd_lql6 = '4'
	then '(04) - First Degree'
when hcd.hcd_lql6 = '5'
	then '(05) - Other undergraduate'
when hcd.hcd_lql6 = '6'
	then '(05) - Further Education'
else '(99) Not recorded'
end "XQLEV601",


case
when hcd.hcd_srp1 = '1'
	then '(01) First Years'
when hcd.hcd_srp1 = '2'
	then '(02) Other Years'
else '(99) Not applicable'
end "XFYRS01",
cdd3.cdd_name "XDOMGR01",
case
when hcd.hcd_mofs = '1' 
	then '(01) Full-time'
when hcd.hcd_mofs = '2' 
	then '(02) Sandwich'
when hcd.hcd_mofs = '3' 
	then '(03) Part-time'
when hcd.hcd_mofs = '4' 
	then '(04) Writing-up'
when hcd.hcd_mofs = '5' 
	then '(05) Sabbatical'
when hcd.hcd_mofs = '6' 
	then '(06) Dormant'
when hcd.hcd_mofs = '7' 
	then '(07) FE continuous delivery'
when hcd.hcd_mofs = '8' 
	then '(08) FE students in England'
when hcd.hcd_mofs = '9' 
	then '(09) Not applicable'
else '(10) Not recorded'
end "XMODE01",
case
when hcd.hcd_cale = '01' 
	then '(01) Care leaver (16+)'
when hcd.hcd_cale = '02' 
	then '(02) Looked after in Scotland'
when hcd.hcd_cale = '03' 
	then '(03) In care in the rest of UK'
when hcd.hcd_cale = '04' 
	then '(04) UCAS defined care leaver'
when hcd.hcd_cale = '05' 
	then '(05) Not a care leaver'
when hcd.hcd_cale = '98' 
	then '(98) Information refused'
when hcd.hcd_cale = '99' 
	then '(99) Not known'
else '(99) Not recorded'
end "CARELEAVER",
case
when hcd.hcd_disb between 1 and 96
	then 'Disability'
when hcd.hcd_disb = '00'
	then 'No known disability'
when hcd.hcd_disb in ('97','98','99')
	then 'Not Known'
else 'Not in SFC list'
end "DISABLE",
case
when hcd.hcd_ethn between 10 and 19
	then 'White'
when hcd.hcd_ethn between 21 and 80
	then 'BME'
else 'Not recorded'
end "ETHNIC",
hcd.hcd_trpa "HCD - XTPOINTS",
/*hcd.hcd_tagp "HCD - XTARIFFGP",
hcd.hcd_tagr "HCD - XTPOINTSGP", 
case
when hcd.hcd_tagr = '01' 
	and hcd.hcd_Ayrc = '2018/9'
	then '(01) Less than 48 points'
when hcd.hcd_tagr = '02' 
	and hcd.hcd_Ayrc = '2018/9'
	then '(02) 48 - 63 points'
when hcd.hcd_tagr = '03' 	
	and hcd.hcd_Ayrc = '2018/9'
	then '(03) 64 - 79 points'
when hcd.hcd_tagr = '04' 
	and hcd.hcd_Ayrc = '2018/9'
	then '(04) 80 - 95 points'
when hcd.hcd_tagr = '05' 
	and hcd.hcd_Ayrc = '2018/9'
	then '(05) 96 - 111 points'
when hcd.hcd_tagr = '06' 
	and hcd.hcd_Ayrc = '2018/9'
	then '(06) 112 - 127 points'
when hcd.hcd_tagr = '07' 
	and hcd.hcd_Ayrc = '2018/9'
	then '(07) 128 - 143 points'
when hcd.hcd_tagr = '08' 
	and hcd.hcd_Ayrc = '2018/9'
	then '(08) 144 - 159 points'
when hcd.hcd_tagr = '09' 
	and hcd.hcd_Ayrc = '2018/9'
	then '(09) 160 - 175 points'
when hcd.hcd_tagr = '10' 	
	and hcd.hcd_Ayrc = '2018/9'
	then '(10) 176 - 191 points'
when hcd.hcd_tagr = '11' 
	and hcd.hcd_Ayrc = '2018/9'
	then '(11) 192 - 207 points'
when hcd.hcd_tagr = '12' 
	and hcd.hcd_Ayrc = '2018/9'
	then '(12) 208 - 223 points'
when hcd.hcd_tagr = '13' 
	and hcd.hcd_Ayrc = '2018/9'
	then '(13) 224 - 239 points'
when hcd.hcd_tagr = '14' 
	and hcd.hcd_Ayrc = '2018/9'
	then '(14) 240+ points'
when hcd.hcd_tagr = '99' 
	and hcd.hcd_Ayrc = '2018/9'
	then '(99) Zero or unknown tariff points'
when hcd.hcd_tagr = 'NA' 
	and hcd.hcd_Ayrc = '2018/9'
	then '(99) Not in the standard tariff population'
when hcd.hcd_tagr is null
	and hcd.hcd_Ayrc = '2018/9'
	then '(99) No HCD tariff available'
else '###ERROR###'||to_char(hcd.hcd_tagr)||'###ERROR###'
end "HCD - XTPOINTS",
case
when hcd.hcd_tagp ='01' 
	and hcd.hcd_Ayrc <> '2018/9'
		 then '(01) 1 - 79 points'
when hcd.hcd_tagp ='02' 
	and hcd.hcd_Ayrc <> '2018/9'
	then '(02) 80 - 119 points'
when hcd.hcd_tagp ='03' 
	and hcd.hcd_Ayrc <> '2018/9'
	then '(03) 120 - 179 points'
when hcd.hcd_tagp ='04' 
	and hcd.hcd_Ayrc <> '2018/9'
	then '(04) 180 - 239 points'
when hcd.hcd_tagp ='05' 
	and hcd.hcd_Ayrc <> '2018/9'
	then '(05) 240 - 299 points'
when hcd.hcd_tagp ='06' 
	and hcd.hcd_Ayrc <> '2018/9'
	then '(06) 300 - 359 points'
when hcd.hcd_tagp ='07' 
	and hcd.hcd_Ayrc <> '2018/9'
	then '(07) 360 - 419 points'
when hcd.hcd_tagp ='08' 
	and hcd.hcd_Ayrc <> '2018/9'
	then '(08) 420 - 479 points'
when hcd.hcd_tagp ='09' 
	and hcd.hcd_Ayrc <> '2018/9'
	then '(09) 480 - 539 points'
when hcd.hcd_tagp ='10' 
	and hcd.hcd_Ayrc <> '2018/9'
	then '(10) 540+ points'
when hcd.hcd_tagp = '99' 
	and hcd.hcd_Ayrc <> '2018/9'
	then '(99) Zero or unknown tariff points'
when hcd.hcd_tagp = 'NA' 
	and hcd.hcd_Ayrc <> '2018/9'
	then '(99) Not in the standard tariff population'
when hcd.hcd_tagp is null
	and hcd.hcd_Ayrc <> '2018/9'
	then '(99) No HCD tariff available'
else '(99) Exclude'
end "HCD - XTARIFF",*/
case
when hcd.hcd_tagp in ('01','02','03')
	or hcd.hcd_tagr in ('01','02','03','04')
	then '(03) Low tariff'
when hcd.hcd_tagp in ('04','05','06','07')
	or hcd.hcd_tagr in ('05','06','07','08','09','10')
	then '(02) Medium tariff'
when hcd.hcd_tagp in ('08','09','10')
	or hcd.hcd_tagr in ('11','12','13','14')
	then '(01) High tariff'
else '(04) 0 or null'
end "UoD Tariff Banding",
/*case
when hcd.hcd_tqit = '$$$$'
		or hcd.hcd_tqit = '____'
		--or hcd.hcd_tqit is null
		or hcd.hcd_tqit = '0'
		or hcd.hcd_tqit = '0000'
		then to_number('0')
else to_number(nvl(nvl(hcd.hcd_tqit,hcd.hcd_trpa),'0')) 
end "HCD - Tariff Score",
/*case ------This code may be obselete (19.9.19 DE)
when hcd.hcd_hqn3 not like 'P%'
	and hcd.hcd_hqn3 not in ('31A','32','33','34','35','36','37','38','39','40','42','46','47')
		then 'Not Applicable'
when hcd.hcd_hqn3 is null then 'SCJ QUALENT3 is null'
when (case
	when hcd.hcd_tqit = '$$$$'
		or hcd.hcd_tqit = '____'
		--or hcd.hcd_tqit is null
		or hcd.hcd_tqit = '0'
		or hcd.hcd_tqit = '0000'
		then '0'
	when hcd.hcd_tqit is null
		or hcd.hcd_ayrc ='2016/7'
		then to_char(hcd.hcd_trpa)
	when hcd.hcd_hqn3 like 'P%'
		then to_char(ltrim(hcd.hcd_tqit,0))
else '0'
end) between 0 and 50 then 'Band E - 0 to 50'
when (case
	when hcd.hcd_tqit = '$$$$'
		or hcd.hcd_tqit = '____'
		--or hcd.hcd_tqit is null
		or hcd.hcd_tqit = '0'
		or hcd.hcd_tqit = '0000'
		then '0'
	when hcd.hcd_tqit is null
		or hcd.hcd_ayrc ='2016/7'
		then to_char(hcd.hcd_trpa)
	when hcd.hcd_hqn3 like 'P%'
		then to_char(ltrim(hcd.hcd_tqit,0))
else '0'
end) between 50 and 100 then 'Band D - 50 to 100'
when (case
	when hcd.hcd_tqit = '$$$$'
		or hcd.hcd_tqit = '____'
		--or hcd.hcd_tqit is null
		or hcd.hcd_tqit = '0'
		or hcd.hcd_tqit = '0000'
		then '0'
	when hcd.hcd_tqit is null
		or hcd.hcd_ayrc ='2016/7'
		then to_char(hcd.hcd_trpa)
	when hcd.hcd_hqn3 like 'P%'
		then to_char(ltrim(hcd.hcd_tqit,0))
else '0'
end) between 100 and 200 then 'Band C - 100 to 200'
when (case
	when hcd.hcd_tqit = '$$$$'
		or hcd.hcd_tqit = '____'
		--or hcd.hcd_tqit is null
		or hcd.hcd_tqit = '0'
		or hcd.hcd_tqit = '0000'
		then '0'
	when hcd.hcd_tqit is null
		or hcd.hcd_ayrc ='2016/7'
		then to_char(hcd.hcd_trpa)
	when hcd.hcd_hqn3 like 'P%'
		then to_char(ltrim(hcd.hcd_tqit,0))
else '0'
end) between 200 and 300 then 'Band B - 200 to 300'
when (case
	when hcd.hcd_tqit = '$$$$'
		or hcd.hcd_tqit = '____'
		--or hcd.hcd_tqit is null
		or hcd.hcd_tqit = '0'
		or hcd.hcd_tqit = '0000'
		then '0'
	when hcd.hcd_tqit is null
		or hcd.hcd_ayrc ='2016/7'
		then to_char(hcd.hcd_trpa)
	when hcd.hcd_hqn3 like 'P%'
		then to_char(ltrim(hcd.hcd_tqit,0))
else '0'
end) >=200 then 'Band A - < 300'
else (case
	when hcd.hcd_tqit = '$$$$'
		or hcd.hcd_tqit = '____'
		--or hcd.hcd_tqit is null
		or hcd.hcd_tqit = '0'
		or hcd.hcd_tqit = '0000'
		or hcd.hcd_hqn3 not like 'P%'
		then 'Not applicable'
	when hcd.hcd_tqit is null
		or hcd.hcd_ayrc ='2016/7'
		then to_char(hcd.hcd_trpa)
	when hcd.hcd_hqn3 like 'P%'
		then to_char(ltrim(hcd.hcd_tqit,0))	
else 'Band F - > 50'
end) 
end "HCD - Tariff Points",*/


hop.hop_ayrc "HOP - AYR",
hop.hop_scjc "HOP - Student Join Code",
hop.hop_levp "HOP - Level",
hop.hop_typa "HOP - Type of Activity",
hop.hop_cddc "HOP - Country"


from
reporting.ins_stu stu 

left join reporting.srs_scj scj on scj.scj_stuc = stu.stu_code
left join reporting.srs_sce sce on sce.sce_scjc = scj.scj_code 
left join reporting.ins_spr spr on spr.spr_code = scj.scj_sprc

left join reporting.srs_shi shi on shi.shi_stuc = stu.stu_code

left join reporting.ins_stua stua on stua.stua_stuc = stu.stu_code
left join reporting.srs_gen gen on gen.gen_code = stu.stu_gend -- Gender table
left join reporting.srs_eth eth on stu.stu_ethc = eth.eth_code -- ETH table for STU ethnicity
left join reporting.srs_nat nat on stu.stu_natc = nat.nat_code -- NAT table for STU nationality
left join reporting.srs_dsb dsb on dsb.dsb_code = stu.stu_dsbc --added 23/09 to facilitate FOI

--left join sipr.srs_mci mci on mci.mci_mstc = stu.stu_code
left join reporting.men_mre mre on mre.mre_code = stu.stu_code
    and mre.mre_mrcc = 'STU'
left join reporting.srs_mci mci on mci.mci_mstc = mre.mre_mstc
    and mre.mre_mrcc = 'STU'
--I have used the 2 in the name so that it is obvious throughtout the script when MCI is source of data 
left join reporting.srs_clv clv2 on clv2.clv_code = mci.mci_clvc
left join reporting.srs_car car2 on car2.car_code = mci.mci_carc
left join reporting.srs_dep dep2 on dep2.dep_code = mci.mci_depc
left join reporting.srs_nat nat2 on nat2.nat_code = mci.mci_natc
left join reporting.srs_rlg rlg2 on rlg2.rlg_code = mci.mci_rlgc  
left join reporting.srs_eth eth2 on eth2.eth_code = mci.mci_ethc
left join reporting.srs_gid gid2 on gid2.gid_code = mci.mci_gidc
left join reporting.srs_ped ped2 on ped2.ped_code = mci.mci_pedc
left join reporting.srs_sxo sxo2 on sxo2.sxo_code = mci.mci_sxoc 
left join reporting.srs_sec sec2 on sec2.sec_code = mci.mci_secc 
left join reporting.srs_sob sob2 on sob2.sob_code = mci.mci_sobc
left join reporting.srs_svl svl2 on svl2.svl_code = mci.mci_serl
left join reporting.srs_slu slu2 on slu2.slu_code = mci.mci_sluc
left join reporting.srs_etr etr2 on etr2.etr_code = mci.mci_etrc
left join reporting.srs_sca sca2 on sca2.sca_code = mci.mci_scac
left join reporting.srs_trn trn2 on trn2.trn_code = mci.mci_trnc
left join reporting.srs_geg geg2 on geg2.geg_code = nat2.nat_gegc

left join reporting.srs_cod cod3 on cod3.cod_code = stu.stu_codc -- Country of domicile on STU
left join reporting.srs_cdd cdd3 on cdd3.cdd_code = cod3.cod_cddc -- Higher level COD on STU  

left join reporting.men_add add1 on add1.add_adid = stu.stu_code
    and add1.add_actv = 'C'
    and add1.add_atyc = 'H'
    and add1.add_aent = 'STU'
left join reporting.men_add add2 on add2.add_adid = stu.stu_code
    and add2.add_actv = 'C'
    and add2.add_atyc = 'C'
    and add2.add_aent = 'STU'

left join reporting.srs_cod cod4 on cod4.cod_code = add1.add_codc   --Current Home ADD Country code
left join reporting.srs_cdd cdd4 on cdd4.cdd_code = cod4.cod_cddc   --Current Home ADD Country code

left join reporting.srs_cod cod5 on cod5.cod_code = add2.add_codc   --Current Contact ADD Country code 
left join reporting.srs_cdd cdd5 on cdd5.cdd_code = cod5.cod_cddc   --Current Contact ADD Country code

--data about the join
left join reporting.srs_qen qen on qen.qen_code = scj.scj_qenc -- QUALENT3 values
left join reporting.srs_cod cod on scj.scj_codc = cod.cod_code -- Country of domicile on SCJ
left join reporting.srs_cdd cdd on cdd.cdd_code = cod.cod_cddc -- Higher level COD on SCJ
left join reporting.srs_geg geg on cod.cod_gegc = geg.geg_code -- GEG table for country of domicile geographical area
left join reporting.srs_reg reg on cod.cod_regc = reg.reg_code -- REG table added 05/05/21 for Country of Domicile regional grouping
left join reporting.srs_scl scl on scj.scj_sclc = scl.scl_code -- SCL table for SCJ school
left join reporting.ins_ins ins on ins.ins_code = scj.scj_insc -- INS table for SCJ institution
left join reporting.srs_scj scj2 on scj2.scj_stuc = scj.scj_stuc
		and scj2.scj_ayrc <> scj.scj_ayrc
		and scj2.scj_ayrc <> sce.sce_ayrc
		and scj2.scj_crsc in ('ADACSS7','ADACSS8','ADACSS86','AFACSS9') -- for Access students. These courses are hardcoded and may need expanded.

left join reporting.srs_cap cap on scj.scj_code = cap.cap_scjc --CAP to get to AGN table...
        and scj.scj_ayrc = cap.cap_ayrc
left join reporting.srs_agn agn on agn.agn_code = cap.cap_udfj --...to get Partnership involved.
left join reporting.srs_agn agn2 on agn2.agn_code = cap.cap_udf7 --...to get Agent involved
left join reporting.srs_cod cod2 on cod2.cod_code = agn2.agn_codc --Get Partnership COD location
left join reporting.srs_cdd cdd2 on cdd2.cdd_code = cod2.cod_cddc -- Higher level COD on AGN
left join reporting.srs_apf apf on apf.apf_stuc = cap.cap_stuc
    and apf.apf_seqn = cap.cap_apfs    
    
--data about the enrolment
left join reporting.srs_sta sta on sce.sce_stac = sta.sta_code -- STA table for SCE enrolment status
left join reporting.ins_rou rou on sce.sce_rouc = rou.rou_code -- ROU Table
left join reporting.srs_crs crs on sce.sce_crsc = crs.crs_code -- CRS table
left join reporting.srs_qul qul on qul.qul_code = crs.crs_qulc -- CRS > QUL > EQA
left join reporting.ins_eqa eqa2 on eqa2.eqa_code = qul.qul_eqac -- EQA table attached to CRS table
left join reporting.ins_dpt dpt on dpt.dpt_code = rou.rou_udf6 -- Discipline on ROU
left join reporting.srs_fac fac on fac.fac_code = rou.rou_udf5 -- School on ROU
left join reporting.srs_rft rft on rft.rft_code = sce.sce_rftc
left join reporting.srs_rft rft2 on rft2.rft_code = sce.sce_udfj
left join reporting.srs_tti tti on tti.tti_code = crs.crs_ttic
left join reporting.srs_uom uom on uom.uom_code = crs.crs_uomc
left join reporting.ins_awd awd on awd.awd_code = spr.awd_code -- AWD table for intended award
left join reporting.ins_eqa eqa on eqa.eqa_code = awd.awd_eqac -- EQA table attached to AWD table
left join reporting.ins_prg prg on prg.prg_code = sce.sce_prgc
left join reporting.srs_cbo cbo on cbo.cbo_crsc = sce.sce_crsc
    and cbo.cbo_occl = sce.sce_occl
    and cbo.cbo_blok = sce.sce_blok
    and cbo.cbo_ayrc = sce.sce_ayrc
left join reporting.srs_efu efu on efu.efu_code = sce.sce_efid -- EFU table attached to SCE
left join reporting.srs_ini ini1 on ini1.ini_code = sce.sce_ini1 -- INI1 table attached to SCE_INI1
left join reporting.srs_ini ini2 on ini2.ini_code = sce.sce_ini2 -- INI2 table attached to SCE_INI2

--data from legacy HESA Student Return tables
left join reporting.srs_hcd hcd on hcd.hcd_scjc = sce.sce_scjc
		and hcd.hcd_ayrc = sce.sce_ayrc
left join reporting.srs_hin hin on hin.hin_scjc = sce.sce_scjc
		and hin.hin_ayrc = sce.sce_ayrc
left join reporting.srs_hcs hcs on hcs.hcs_hcic = hin.hin_hcic
		and hin.hin_ayrc = hcs.hcs_ayrc      
left join reporting.srs_cdd cdd3 on cdd3.cdd_code = hcd.hcd_domi -- CDD level from HCD table.
left join reporting.srs_hop hop on hop.hop_scjc = sce.sce_scjc
        and hop.hop_ayrc = sce.sce_ayrc




where
stu.stu_udf7 is null -- No test records
and sce.sce_ayrc >= '2018/9'
--and sce.sce_ayrc >= '2004/5'
--and sce.sce_ayrc = '2010/1' this value and earlier won't work in Awards and Classifications Dashboard so was just testing it here 11/03/25