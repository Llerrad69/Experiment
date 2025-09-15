/*
This file was created on 21 July 2023 by Linda Bathgate, Returns & Data Quality Assistant, Strategic Intelligence Unit, Strategic Planning
Source:     Cognos > Student Awards and Classifications v 5.1 (140921)
            with some data elements/coding coming from Student Numbers Dashboard SQL with MCI and ADD (031022)  
As at:      21/07/23
In the Student Data SQL Files the file name is SRT - Awards and Classifications Dashboard (210723)

--it does NOT include the data developments from 2022 that were discussed with ER-H in QAS - intentionally this is to replicate current cognos output and THEN re-develop the code/external-facing dashboard

Used in
Student Awards and Classifications v6.1 (excel) - which has retained the _ column headers for ease of use (ie not having to re-do filters on pivots etc) even though the dataset column headings do not
Used in:    SIU - Dashboard Data Source (Reporting) (290923) v3.4 > AwardsClassifications > Dashboard Data Source - PPR Awards
12/06/24 - columns added to support RIBA submission of conferred awards - name, DOB - added at end so as not to 'upset' the order of the existing data items
25/11/24 - three further columsn added, Fundability Group, Initiative 1 name, enrolment status group - Claudia Cisneros-Foster had needed the Fundability group, and I added the other 2 as they had been added to SEN underlying data at the same time as fundability was; BSCN and BDS moved from SCQF level 10 to 9; IYR added to MoA

DEV
Course Aim SCQF should be added too, to provide the triangulation of Course Aim, Intended Award and Actual Award SCQF's
*/

select distinct

sce.sce_scjc "Record Count",
case
when saw.cla2_code in ('FC', 'HN', 'MARCHD', 'CM', 'MARCHM', 'US', 'MARCH') --does not yet include MEDS & OD
then 'First or 2:1 (or equivalent)'
when saw.cla2_code in ('LS', 'TC', 'UGDS', 'UNC', 'AG', 'UGM', 'UGME') --does not yet include MEDS <> OD, or DIPHE or CERTHE when classificaiotn is null
then 'Other outcome'
when saw.cla2_code in ('PGDS', 'PGM', 'MT')
then 'No Classification'
else 'No Classification'
end "Classification Group",
-- saw.cla2_code,  --added during script testing
nvl(cla.cla_name,'z_No Classification') "Award Classification",
--spr.awd_code, --added during script testing
awd.awd_name "Intended Award",
awd2.awd_name "Actual Award",
initcap(crs.crs_udf4) "Course Type",

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
rou.rou_name||' ('||rou.rou_code||')' "Programme Name (Route)", --"ROU - Programme Route"
fac.fac_name "School", --"ROU - School"
dpt.dpt_name "Discipline", --"ROU - Discipline"
nvl(gen.gen_name, 'Not recorded') "Gender", -- "STU - Gender"
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
end "Ethnicity Group", --"STU - Ethnic Origin"

case
when mci.mci_ethc is not null then to_char(eth2.eth_name)
when stu.stu_ethc is not null then to_char(eth.eth_name)
else 'Not recorded'
end "Ethnicity",

case
    when stu.stu_dsbc in ('0','N','U','A','99','98','95')    
        then 'No'
     when stu.stu_dsbc is null then 'No'
else 'Yes'
end "Disability", --"STU - Disability"
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
end "Age on Entry", --"SCJ - Age on Entry",

/*
case
when [SFC MD40 Quintile] = 'Q1'
	then 'MD20'
when [SFC MD40 Quintile] in ('Q1','Q2')  
	then 'MD40'
else 'Not MD40'
end
The record will never be allocated to MD40 if are already allocated to MD20 - known issue with this not working - intentionally excluded
*/
case
    when initcap(scj.scj_udf8) in ('Q1','Q2') 
        then 'MD40'
else 'Not MD40'
end "MD40 Status", --"SCJ - MD40 Status"
case
when scj.scj_udf8 is null
	or scj.scj_udf8 = 'Not applicable' or scj.scj_udf8 = 'NA'
	then 'Not applicable'
else upper(to_char(scj.scj_udf8))
end "MD Quintile", --"SCJ - MD Quintile"
scj.scj_ayrc "Academic Year (Entry)", --"SCJ - Join Year"

case
	when sce.sce_2ndr = 'S' and sce.sce_moac = 'FOC' and sce.sce_elsc = '10'        --I have chosen locatoin as opposed to SCE_STYC as ELSC comes from CBO and is therefore not subject to a data quality check for it to exist, whereas STYC is updated and entered manually.
        then 'Overseas Based Student'
    when sce.sce_2ndr = 'S'
		then 'UK Based Student' 
	when sce.sce_2ndr = 'O'
		then 'Overseas Based Student'                               --need to review this for the parternships students overseas, using SCE_ELSC as well? Def needs refined
	else 'Not Yet Categorised/Excluded from HESA'
end "Location of Student",
--updated 16/12/24
/*
case
when [Sce Udf1] = '1'
	then '1_HESA SRPopulation'
when [Sce Udf1]='2' 	
	then '2_HESA FE Population'
when [Sce Udf1]='0' 
	then '3_HESA Non-SRPopulation'
when [Sce Udf1]='AOR'
	then '3_HESA Offshore Population (AOR)'
when [Sce Udf1]='EXL' 
	then '8_Excluded from HESA'
else null
end

once this has been sorted in the stunde numbers dashboard sql re getting rid of annual year-on-year updates; it will need apdating here is part of the more-than-just-a-cognos-replica project
*/     

case
when sce.sce_udf1 = '1' 
    then '1_HESA SRPopulation'
when sce.sce_udf1 = '2' 
    then '2_HESA FE Population'
when sce.sce_udf1 = '0' 
    then '3_HESA Non-SRPopulation'
when sce.sce_udf1 = 'AOR' 
    then '3_HESA Offshore Population (AOR)'
when sce.sce_udf1 = 'EXL' 
    then '8_Excluded from HESA'
else null
end "HESA Population",

/*
intentionally excluding

HESA Population (CAL)
if ([_HESA Population] is not null) THEN ([_HESA Population])
ELSE IF ([_Location of Student]='UK Based Student' AND [_Population - Non Active]='Select All Other Students' AND [_Population - WritingUp]='Select All Other Students' AND [_Population - Visiting]='Select All Other Students' AND [_Population - Non Credit Bearing]='Select All Other Students') THEN ('1_HESA SRPopulation (Cal)')
ELSE IF ([_Location of Student]='Overseas based student') then ('4_HESA OffshorePopulation(AOR)')
ELSE IF ([_Location of Student]='Not Yet Categorized/Excluded from HESA') then ('9_PopulationNotAssigned')
ELSE ('3_HESA Non-SRPopulation (Cal)')

_Population - Non Credit Bearing NIU
_Population - Non Active NIU
_Population - WritingUp NIU
_Population - Associate NIU
_Population - Non Graduating NIU
_Population - Visiting NIU
*/


case
when spr.sts_code = 'NC' then 'Completed'
else 'Not Complete'
end "Completion Status",


/*
case
when [Awd Code] in ('DBA','DCE','DCLD','DDSC','DED','DEDPSYCH','DHSCI','DHUM','DLITT','DMAN','DPROF','DSC','DSSCI','DSWO','LLD','MD','PHD')
	then '(12) Doctorates (Research)'
when [Awd Code] in ('LLMR','MACCR','MDSCR','MFMR','MMSCR','MPH(PCR)','MPHILR','MSCR','MSSCR','PGCERTR')
	then '(11) Masters (Research)'
when [Awd Code] in ('DSW','EMBA','INSTCREDPG','LLM','MACC','MARCH','MASG','MBA','MCHORTH','MCN','MDES','MDPH','MDSC','MED','MEDH','MEDO','MFA','MFIN','MFM','MFO','MFT','MLITT','MMAS','MMED','MMSC','MN','MPC','MPH','MPHIL','MRES','MSC','MSCN','MSSC','MSW','PGCE','PGCERT','PGCERTM','PGDE','PGDIP','PGDIPE','PGDIPM','PGDIPR','PGEDIP','PGMA','ROAPG','XLLMMBA','XLLMMSC','XMSCMBA')
	then '(11) Masters (Taught)'
when [Awd Code] in ('BABDES','BACCH','BAH','BAHA','BAHW','BAOA','BARCHH','BDESH','BDS','BEDH','BENGH','BFINH','BIACCH','BIFINH','BMSC','BSCH','BSCM','BSCMSC','BSCN','BSCNH','FDIP','GCERT','GDIP','INSTCREDUG2','LLBH','MAH','MAHDIP','MENGH','MENGO','MMATHH','MMATHO','MSCIH','MSCIO','PROQUAL','REG','UGCERT') 
	then '(10) Honours degree / Graduate Diploma / Certificate'
when [Awd Code] in ('BACCO','BAO','BARCHO','BDESO','BENGO','BFINO','BHS','BIFINO','BM','BM/DIPHE','BN','BN/DIPHE','BNSPQ','BSCA','BSCN(POST)','BSCO','LLBO','MAO','MBCHB')
	then '(09) Ordinary degree/ Graduate Diploma / Certificate'
when [Awd Code] = 'DIPHE'
	then '(08) Higher National Diploma / Diploma in Higher Education / SVQ 4'
when [Awd Code] = 'CERTHE'
	then '(07) Higher National Certificate / Certificate of Higher Education'
when [Awd Code] = 'INSTCREDUG'
	then '(06.5) UG Credits'
when [Awd Code] = 'ROA'
		then '(02) HE Education Access'
when [Awd Code] in ('NOAWARD','NOAWARDPG')
	then '(01) No Award'
else to_char([Awd Code])
end 
*/

case
when spr.awd_code in ('DBA','DCE','DCLD','DDSC','DED','DEDPSYCH','DHSCI','DHUM','DLITT','DMAN','DPROF','DSC','DSSCI','DSWO','LLD','MD','PHD')
    then '(12) Doctorates (Research)' 
when spr.awd_code in ('LLMR','MACCR','MDSCR','MFMR','MMSCR','MPH(PCR)','MPHILR','MSCR','MSSCR','PGCERTR','MDESR','MFAR')
    then '(11) Masters (Research)'
when spr.awd_code in ('DSW','EMBA','INSTCREDPG','LLM','MACC','MARCH','MASG','MBA','MCHORTH','MCN','MDES','MDPH','MDSC','MED','MEDH','MEDO','MFA','MFIN','MFM','MFO','MFT','MLITT','MMAS','MMED','MMSC','MN','MPC','MPH','MPHIL','MRES','MSC','MSCN','MSSC','MSW','PGCE','PGCERT','PGCERTM','PGDE','PGDIP','PGDIPE','PGDIPM','PGDIPR','PGEDIP','PGMA','ROAPG','XLLMMBA','XLLMMSC','XMSCMBA')
	then '(11) Masters (Taught)'
when spr.awd_code in ('BABDES','BACCH','BAH','BAHA','BAHW','BAOA','BARCHH','BDESH','BDS','BEDH','BENGH','BFINH','BIACCH','BIFINH','BMSC','BSCH','BSCM','BSCMSC','BSCNH','FDIP','GCERT','GDIP','INSTCREDUG2','LLBH','MAH','MAHDIP','MENGH','MENGO','MMATHH','MMATHO','MSCIH','MSCIO','PROQUAL','REG','UGCERT') 
	then '(10) Honours degree / Graduate Diploma / Certificate'
when spr.awd_code in ('BACCO','BAO','BARCHO','BDESO','BENGO','BFINO','BHS','BIFINO','BM','BM/DIPHE','BN','BN/DIPHE','BNSPQ','BSCA','BSCN(POST)','BSCO','LLBO','MAO','MBCHB', 'BSCN', 'BDS')
	then '(09) Ordinary degree/ Graduate Diploma / Certificate'
when spr.awd_code = 'DIPHE'
	then '(08) Higher National Diploma / Diploma in Higher Education / SVQ 4'
when spr.awd_code = 'CERTHE'
	then '(07) Higher National Certificate / Certificate of Higher Education'
when spr.awd_code = 'INSTCREDUG'
	then '(06.5) UG Credits'
when spr.awd_code = 'ROA'
		then '(02) HE Education Access'
when spr.awd_code in ('NOAWARD','NOAWARDPG')
	then '(01) No Award'
else to_char(spr.awd_code)
end "SCQF Intended",

/*
case
when [Awd Code] in ('DBA','DCE','DCLD','DDSC','DED','DEDPSYCH','DHSCI','DHUM','DLITT','DMAN','DPROF','DSC','DSSCI','DSWO','LLD','MD','PHD')
	then '(12) Doctorates (Research)'
when [Awd Code] in ('LLMR','MACCR','MDSCR','MFMR','MMSCR','MPH(PCR)','MPHILR','MSCR','MSSCR','PGCERTR')
	then '(11) Masters (Research)'
when [Awd Code] in ('DSW','EMBA','INSTCREDPG','LLM','MACC','MARCH','MASG','MBA','MCHORTH','MCN','MDES','MDPH','MDSC','MED','MEDH','MEDO','MFA','MFIN','MFM','MFO','MFT','MLITT','MMAS','MMED','MMSC','MN','MPC','MPH','MPHIL','MRES','MSC','MSCN','MSSC','MSW','PGCE','PGCERT','PGCERTM','PGDE','PGDIP','PGDIPE','PGDIPM','PGDIPR','PGEDIP','PGMA','ROAPG','XLLMMBA','XLLMMSC','XMSCMBA')
	then '(11) Masters (Taught)'
when [Awd Code] in ('BABDES','BACCH','BAH','BAHA','BAHW','BAOA','BARCHH','BDESH','BDS','BEDH','BENGH','BFINH','BIACCH','BIFINH','BMSC','BSCH','BSCM','BSCMSC','BSCN','BSCNH','FDIP','GCERT','GDIP','INSTCREDUG2','LLBH','MAH','MAHDIP','MENGH','MENGO','MMATHH','MMATHO','MSCIH','MSCIO','PROQUAL','REG','UGCERT') 
	then '(10) Honours degree / Graduate Diploma / Certificate'
when [Awd Code] in ('BACCO','BAO','BARCHO','BDESO','BENGO','BFINO','BHS','BIFINO','BM','BM/DIPHE','BN','BN/DIPHE','BNSPQ','BSCA','BSCN(POST)','BSCO','LLBO','MAO','MBCHB')
	then '(09) Ordinary degree/ Graduate Diploma / Certificate'
when [Awd Code] = 'DIPHE'
	then '(08) Higher National Diploma / Diploma in Higher Education / SVQ 4'
when [Awd Code] = 'CERTHE'
	then '(07) Higher National Certificate / Certificate of Higher Education'
when [Awd Code] = 'INSTCREDUG'
	then '(06.5) UG Credits'
when [Awd Code] = 'ROA'
		then '(02) HE Education Access'
when [Awd Code] in ('NOAWARD','NOAWARDPG')
	then '(01) No Award'
else to_char([Awd Code])
end
*/
case
when saw.awd_code in ('DBA','DCE','DCLD','DDSC','DED','DEDPSYCH','DHSCI','DHUM','DLITT','DMAN','DPROF','DSC','DSSCI','DSWO','LLD','MD','PHD')
	then '(12) Doctorates (Research)'
when saw.awd_code in ('LLMR','MACCR','MDSCR','MFMR','MMSCR','MPH(PCR)','MPHILR','MSCR','MSSCR','PGCERTR','MDESR', 'MFAR')
	then '(11) Masters (Research)'
when saw.awd_code in ('DSW','EMBA','INSTCREDPG','LLM','MACC','MARCH','MASG','MBA','MCHORTH','MCN','MDES','MDPH','MDSC','MED','MEDH','MEDO','MFA','MFIN','MFM','MFO','MFT','MLITT','MMAS','MMED','MMSC','MN','MPC','MPH','MPHIL','MRES','MSC','MSCN','MSSC','MSW','PGCE','PGCERT','PGCERTM','PGDE','PGDIP','PGDIPE','PGDIPM','PGDIPR','PGEDIP','PGMA','ROAPG','XLLMMBA','XLLMMSC','XMSCMBA')
	then '(11) Masters (Taught)'
when saw.awd_code in ('BABDES','BACCH','BAH','BAHA','BAHW','BAOA','BARCHH','BDESH','BEDH','BENGH','BFINH','BIACCH','BIFINH','BMSC','BSCH','BSCM','BSCMSC','BSCNH','FDIP','GCERT','GDIP','INSTCREDUG2','LLBH','MAH','MAHDIP','MENGH','MENGO','MMATHH','MMATHO','MSCIH','MSCIO','PROQUAL','REG','UGCERT') 
	then '(10) Honours degree / Graduate Diploma / Certificate'
when saw.awd_code in ('BACCO','BAO','BARCHO','BDESO','BENGO','BFINO','BHS','BIFINO','BM','BM/DIPHE','BN','BN/DIPHE','BNSPQ','BSCA','BSCN(POST)','BSCO','LLBO','MAO','MBCHB','BSCN','BDS')
	then '(09) Ordinary degree/ Graduate Diploma / Certificate'
when saw.awd_code = 'DIPHE'
	then '(08) Higher National Diploma / Diploma in Higher Education / SVQ 4'
when saw.awd_code = 'CERTHE'
	then '(07) Higher National Certificate / Certificate of Higher Education'
when saw.awd_code = 'INSTCREDUG'
	then '(06.5) UG Credits'
when saw.awd_code = 'ROA'
		then '(02) HE Education Access'
when saw.awd_code in ('NOAWARD','NOAWARDPG')
	then '(01) No Award'
else to_char(saw.awd_code)
end "SCQF Award Level",

saw.ayr_code "Academic Year of Award",

/*
case
when [Sce Moac] in ('BOC','DDL','DL','DLO','WBL','FOC','FOCF','FOCP')
	then 'Distance Learning'
when [Sce Moac] in ('CFT','CYR','DFT','EYR','FT','FTARCH','FTF','FTIP','FTO','GYRY','OYR','SAB','STE','TYR','WFT')
	then 'Full-time'
when [Sce Moac] in ('CPT','DPT','PT','PTO','WPT','WMS')
	then 'Part-time'
when [Sce Moac] = 'AS' then 'Associate Student'
when [Sce Moac] = 'DOR' then 'Dormant'
else 'z_Not recorded'
end
*/
case
when sce.sce_moac in ('BOC','DDL','DL','DLO','WBL','FOC','FOCF','FOCP','DLF')
	then 'Distance Learning'
when sce.sce_moac in ('CFT','CYR','DFT','EYR','FT','FTARCH','FTF','FTIP','FTO','GYRY','OYR','SAB','STE','TYR','WFT','IEO','IYR')
	then 'Full-time'
when sce.sce_moac in ('CPT','DPT','PT','PTO','WPT','WMS')
	then 'Part-time'
when sce.sce_moac = 'AS' then 'Associate Student'
when sce.sce_moac = 'DOR' then 'Dormant'
else 'z_Not recorded'
end "Mode of Attendance",

/*
case
when [Sce Fstc] in ('CIOMC','H','HC','HEU','HFP','HFW','HH','HHC','HNF','HNFS','HNI','HNIC','HNIPR','HSEU','HTH')
	then 'HomeEU'
when [Sce Fstc] = 'HS'
	then 'HomeScottish'
when [Sce Fstc] like 'O%'
	then' Overseas'
when [Sce Fstc] in ('CIOM','CIOMF','CIOMN','HRUK','HRUKF','HRUKN','HRUK1','RUK')
	then 'RUK'
else 'z_Not recorded'
end
*/
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
end "Student Fee Status",

case
when mci.mci_natc is not null then to_char(nat2.nat_name)
when stu.stu_natc is not null then to_char(nat.nat_name)
else 'Not recorded'
end "Nationality",

case 
    when mci.mci_natc ='7826' 
        then '(02) Other'
    when mci.mci_natc in ('000','2826','3826','5826','593','594','595','6826','999','4826') 
        then '(03) UK'
    when mci.mci_natc ='8826' 
        then '(04) Northern Ireland'
    when mci.mci_natc ='676' 
        then '(06) Ireland'
    when mci.mci_natc in ('638','653','656','661','670','727','751','849','882','883','XE') 
        then '(07) European Union (exc. EIRE) - Area 1'
    when mci.mci_natc in ('621','700','733','831','832','833','834','835','850') 
        then '(08) European Union (exc. EIRE) - Area 2'
    when mci.mci_natc in ('610','614','641','651','678','693','710','728','755','853','878') 
        then '(09) European Union (exc. EIRE) - Area 3'
    when mci.mci_natc in ('637','659','711','821','822','828','865') 
        then '(11) European Overseas Territories'
    when mci.mci_natc in ('626','771','873')
        then '(12) Overseas - Area 0'
    when mci.mci_natc in ('612','628','631','669','672','683','684','686','698','708','717','721','731','743','746','764','766','774','779','839') 
        then '(13) Overseas - Area 1'
    when mci.mci_natc in ('652','673','681','697','718','760','772','787','842','845') 
        then '(14) Overseas - Area 2'
    when mci.mci_natc in ('1780','601','604','609','618','620','630','658','671','677','692','694','702','703','706','714','750','756','759','765','767','768','773','780','793','825','826','827','840','841','843','844','846','847','880','881','898','997') 
        then '(15) Overseas - Area 3'
    when mci.mci_natc in ('807','602','603','605','606','607','608','611','613','616','617','619','622','623','624','625','627','629','632','633','634','635','636','640','642','643','645','646','647','648','650','654','655','660','662','663','664','665','666','667','668','674','675','679','680','682','685','687','688','689','690','691','695','696','699','701','704','707','709','712','713','715','716','722','723','724','725','726','730','732','734','736','737','738','739','741','742','744','745','747','748','749','752','753','754','757','761','762','763','769','770','775','777','778','781','782','783','784','785','786','788','789','790','791','792','794','795','796','797','798','800','802','803','804','805','836','837','838','848','851','852','854','860','861','862','863','864','870','874','884','998','XN')
        then '(16) Overseas - Area 4'
    when mci.mci_natc in ('615','649','705','735','776','799','801','823','824','829','830')
        then '(17) British Overseas Territories'
    when mci.mci_natc in ('780X','BNO') then
        'Area Not coded'
    when stu.stu_natc ='7826' 
        then '(02) Other'
    when stu.stu_natc in ('000','2826','3826','5826','593','594','595','6826','999','4826') 
        then '(03) UK'
    when stu.stu_natc ='8826' 
        then '(04) Northern Ireland'
    when stu.stu_natc ='676' 
        then '(06) Ireland'
    when stu.stu_natc in ('638','653','656','661','670','727','751','849','882','883','XE') 
        then '(07) European Union (exc. EIRE) - Area 1'
    when stu.stu_natc in ('621','700','733','831','832','833','834','835','850') 
        then '(08) European Union (exc. EIRE) - Area 2'
    when stu.stu_natc in ('610','614','641','651','678','693','710','728','755','853','878') 
        then '(09) European Union (exc. EIRE) - Area 3'
    when stu.stu_natc in ('637','659','711','821','822','828','865') 
        then '(11) European Overseas Territories'
    when stu.stu_natc in ('626','771','873')
        then '(12) Overseas - Area 0'
    when stu.stu_natc in ('612','628','631','669','672','683','684','686','698','708','717','721','731','743','746','764','766','774','779','839') 
        then '(13) Overseas - Area 1'
    when stu.stu_natc in ('652','673','681','697','718','760','772','787','842','845') 
        then '(14) Overseas - Area 2'
    when stu.stu_natc in ('1780','601','604','609','618','620','630','658','671','677','692','694','702','703','706','714','750','756','759','765','767','768','773','780','793','825','826','827','840','841','843','844','846','847','880','881','898','997') 
        then '(15) Overseas - Area 3'
    when stu.stu_natc in ('807','602','603','605','606','607','608','611','613','616','617','619','622','623','624','625','627','629','632','633','634','635','636','640','642','643','645','646','647','648','650','654','655','660','662','663','664','665','666','667','668','674','675','679','680','682','685','687','688','689','690','691','695','696','699','701','704','707','709','712','713','715','716','722','723','724','725','726','730','732','734','736','737','738','739','741','742','744','745','747','748','749','752','753','754','757','761','762','763','769','770','775','777','778','781','782','783','784','785','786','788','789','790','791','792','794','795','796','797','798','800','802','803','804','805','836','837','838','848','851','852','854','860','861','862','863','864','870','874','884','998','XN')
        then '(16) Overseas - Area 4'
    when stu.stu_natc in ('615','649','705','735','776','799','801','823','824','829','830')
        then '(17) British Overseas Territories'
    when stu.stu_natc in ('780X','BNO') then
        'Area Not coded'
	when stu.stu_natc is null 
		then 'Not recorded'
else '###ERROR###'
end "Nationality Area",
nvl(cdd.cdd_name,'Not recorded') "Country of Domicile",
nvl(geg.geg_name,'Not recorded') "Country of Domicile Area",
sce.sce_blok "Year of Course", --"SCE - Year of Study"
awd3.awd_name "Calculated Award",

/*
case
when [Folders].[Cam Saw].[Saw Udf5] is null then
	(case
	when [Folders].[Cam Saw].[Cla2 Code] = 'AG' then 'Aegrotat (Unclassified Honours)'
	when [Folders].[Cam Saw].[Cla2 Code] = 'CM' then 'Commendation'
	when [Folders].[Cam Saw].[Cla2 Code] = 'FC' then 'First Class Honours'
	when [Folders].[Cam Saw].[Cla2 Code] = 'FCP' then 'First Class (Provisional)'
	when [Folders].[Cam Saw].[Cla2 Code] = 'HN' then 'Honours'
	when [Folders].[Cam Saw].[Cla2 Code] = 'LS' then 'Lower Second Class Honours'
	when [Folders].[Cam Saw].[Cla2 Code] = 'LSP' then 'Lower Second Class Honours (Provisional)'
	when [Folders].[Cam Saw].[Cla2 Code] = 'MARCH' then 'Master of Architecture'
	when [Folders].[Cam Saw].[Cla2 Code] = 'MARCHD' then 'Master of Architecture with Distinction'
	when [Folders].[Cam Saw].[Cla2 Code] = 'MARCHM' then 'Master of Architecture with Merit'
	when [Folders].[Cam Saw].[Cla2 Code] = 'MT' then 'Merit in Teaching'
	when [Folders].[Cam Saw].[Cla2 Code] = 'OD' then 'Ordinary Degree'
	when [Folders].[Cam Saw].[Cla2 Code] = 'PGDS' then 'Distinction'
	when [Folders].[Cam Saw].[Cla2 Code] = 'PGM' then 'Merit'
	when [Folders].[Cam Saw].[Cla2 Code] = 'TC' then 'Third Class Honours'
	when [Folders].[Cam Saw].[Cla2 Code] = 'TCP' then 'Third Class Honours (Provisional)'
	when [Folders].[Cam Saw].[Cla2 Code] = 'UGDS' then 'Ordinary Degree with Distinction'
	when [Folders].[Cam Saw].[Cla2 Code] = 'UGME' then 'Ordinary Degree with Merit'
	when [Folders].[Cam Saw].[Cla2 Code] = 'UNC' then 'Unclassified Honours'
	when [Folders].[Cam Saw].[Cla2 Code] = 'US' then 'Upper Second Class Honours'
	when [Folders].[Cam Saw].[Cla2 Code] = 'USP' then 'Upper Second Class Honours (Provisional)'
	when [Folders].[Cam Saw].[Cla2 Code] = 'UGM' then 'Certificate of Higher Education with Merit'
	else 'z_No Classification'
	end)
when [Folders].[Cam Saw].[Saw Udf5] is not null then 
(case 
	when (Case 
			when [Folders].[Cam Saw].[Saw Udf5] in ('FC','MARCHD') then '1'
			when [Folders].[Cam Saw].[Saw Udf5] in ('US','MARCHM') then '2'
			when [Folders].[Cam Saw].[Saw Udf5] in ('LS','MARCH') then '3'
			when [Folders].[Cam Saw].[Saw Udf5]= 'TC' then '5'
			when [Folders].[Cam Saw].[Saw Udf5]= 'HN' then '7'
			when [Folders].[Cam Saw].[Saw Udf5]= 'AG' then '8'
			when [Folders].[Cam Saw].[Saw Udf5]= 'UGDS' then '9'
			when [Folders].[Cam Saw].[Saw Udf5] in ('UGME','OD','CM') then '10'
			when [Folders].[Cam Saw].[Saw Udf5]= 'UGM' then '11'
			else null
			end)
>
	(Case 
			when [Folders].[Cam Saw].[Cla2 Code] in ('FC','MARCHD') then '1'
			when [Folders].[Cam Saw].[Cla2 Code] in ('US','MARCHM') then '2'
			when [Folders].[Cam Saw].[Cla2 Code] in ('LS','MARCH') then '3'
			when [Folders].[Cam Saw].[Cla2 Code] = 'TC' then '5'
			when [Folders].[Cam Saw].[Cla2 Code] = 'HN' then '7'
			when [Folders].[Cam Saw].[Cla2 Code] = 'AG' then '8'
			when [Folders].[Cam Saw].[Cla2 Code] = 'UGDS' then '9'
			when [Folders].[Cam Saw].[Cla2 Code] in ('UGME','OD','CM') then '10'
			when [Folders].[Cam Saw].[Cla2 Code] = 'UGM' then '11'
			else null
			end)
then (case
		when [Folders].[Cam Saw].[Cla2 Code] = 'AG' then 'Aegrotat (Unclassified Honours)'
		when [Folders].[Cam Saw].[Cla2 Code] = 'CM' then 'Commendation'
		when [Folders].[Cam Saw].[Cla2 Code] = 'FC' then 'First Class Honours'
		when [Folders].[Cam Saw].[Cla2 Code] = 'FCP' then 'First Class (Provisional)'
		when [Folders].[Cam Saw].[Cla2 Code] = 'HN' then 'Honours'
		when [Folders].[Cam Saw].[Cla2 Code] = 'LS' then 'Lower Second Class Honours'
		when [Folders].[Cam Saw].[Cla2 Code] = 'LSP' then 'Lower Second Class Honours (Provisional)'
		when [Folders].[Cam Saw].[Cla2 Code] = 'MARCH' then 'Master of Architecture'
		when [Folders].[Cam Saw].[Cla2 Code] = 'MARCHD' then 'Master of Architecture with Distinction'
		when [Folders].[Cam Saw].[Cla2 Code] = 'MARCHM' then 'Master of Architecture with Merit'
		when [Folders].[Cam Saw].[Cla2 Code] = 'MT' then 'Merit in Teaching'
		when [Folders].[Cam Saw].[Cla2 Code] = 'OD' then 'Ordinary Degree'
		when [Folders].[Cam Saw].[Cla2 Code] = 'PGDS' then 'Distinction'
		when [Folders].[Cam Saw].[Cla2 Code] = 'PGM' then 'Merit'
		when [Folders].[Cam Saw].[Cla2 Code] = 'TC' then 'Third Class Honours'
		when [Folders].[Cam Saw].[Cla2 Code] = 'TCP' then 'Third Class Honours (Provisional)'
		when [Folders].[Cam Saw].[Cla2 Code] = 'UGDS' then 'Ordinary Degree with Distinction'
		when [Folders].[Cam Saw].[Cla2 Code] = 'UGME' then 'Ordinary Degree with Merit'
		when [Folders].[Cam Saw].[Cla2 Code] = 'UNC' then 'Unclassified Honours'
		when [Folders].[Cam Saw].[Cla2 Code] = 'US' then 'Upper Second Class Honours'
		when [Folders].[Cam Saw].[Cla2 Code] = 'USP' then 'Upper Second Class Honours (Provisional)'
		when [Folders].[Cam Saw].[Cla2 Code] = 'UGM' then 'Certificate of Higher Education with Merit'
		else 'z_No Classification'
		end)
else (case
when [Folders].[Cam Saw].[Saw Udf5]= 'AG' then 'Aegrotat (Unclassified Honours)'
when [Folders].[Cam Saw].[Saw Udf5]= 'CM' then 'Commendation'
when [Folders].[Cam Saw].[Saw Udf5]= 'FC' then 'First Class Honours'
when [Folders].[Cam Saw].[Saw Udf5]= 'FCP' then 'First Class (Provisional)'
when [Folders].[Cam Saw].[Saw Udf5]= 'HN' then 'Honours'
when [Folders].[Cam Saw].[Saw Udf5]= 'LS' then 'Lower Second Class Honours'
when [Folders].[Cam Saw].[Saw Udf5]= 'LSP' then 'Lower Second Class Honours (Provisional)'
when [Folders].[Cam Saw].[Saw Udf5]= 'MARCH' then 'Master of Architecture'
when [Folders].[Cam Saw].[Saw Udf5]= 'MARCHD' then 'Master of Architecture with Distinction'
when [Folders].[Cam Saw].[Saw Udf5]= 'MARCHM' then 'Master of Architecture with Merit'
when [Folders].[Cam Saw].[Saw Udf5]= 'MT' then 'Merit in Teaching'
when [Folders].[Cam Saw].[Saw Udf5]= 'OD' then 'Ordinary Degree'
when [Folders].[Cam Saw].[Saw Udf5]= 'PGDS' then 'Distinction'
when [Folders].[Cam Saw].[Saw Udf5]= 'PGM' then 'Merit'
when [Folders].[Cam Saw].[Saw Udf5]= 'TC' then 'Third Class Honours'
when [Folders].[Cam Saw].[Saw Udf5]= 'TCP' then 'Third Class Honours (Provisional)'
when [Folders].[Cam Saw].[Saw Udf5]= 'UGDS' then 'Ordinary Degree with Distinction'
when [Folders].[Cam Saw].[Saw Udf5]= 'UGME' then 'Ordinary Degree with Merit'
when [Folders].[Cam Saw].[Saw Udf5]= 'UNC' then 'Unclassified Honours'
when [Folders].[Cam Saw].[Saw Udf5]= 'US' then 'Upper Second Class Honours'
when [Folders].[Cam Saw].[Saw Udf5]= 'USP' then 'Upper Second Class Honours (Provisional)'
when [Folders].[Cam Saw].[Saw Udf5]= 'UGM' then 'Certificate of Higher Education with Merit'
else 'z_No Classification'
end)
end)
else null
end
*/


case
when saw.saw_udf5 is null then
	(case
	when saw.cla2_code = 'AG' then 'Aegrotat (Unclassified Honours)'
	when saw.cla2_code = 'CM' then 'Commendation'
	when saw.cla2_code = 'FC' then 'First Class Honours'
	when saw.cla2_code = 'FCP' then 'First Class (Provisional)'
	when saw.cla2_code = 'HN' then 'Honours'
	when saw.cla2_code = 'LS' then 'Lower Second Class Honours'
	when saw.cla2_code = 'LSP' then 'Lower Second Class Honours (Provisional)'
	when saw.cla2_code = 'MARCH' then 'Master of Architecture'
	when saw.cla2_code = 'MARCHD' then 'Master of Architecture with Distinction'
	when saw.cla2_code = 'MARCHM' then 'Master of Architecture with Merit'
	when saw.cla2_code = 'MT' then 'Merit in Teaching'
	when saw.cla2_code = 'OD' then 'Ordinary Degree'
	when saw.cla2_code = 'PGDS' then 'Distinction'
	when saw.cla2_code = 'PGM' then 'Merit'
	when saw.cla2_code = 'TC' then 'Third Class Honours'
	when saw.cla2_code = 'TCP' then 'Third Class Honours (Provisional)'
    when saw.cla2_code = 'UGDS' then 'Ordinary Degree with Distinction'
	when saw.cla2_code = 'UGME' then 'Ordinary Degree with Merit'
	when saw.cla2_code = 'UNC' then 'Unclassified Honours'
	when saw.cla2_code = 'US' then 'Upper Second Class Honours'
	when saw.cla2_code = 'USP' then 'Upper Second Class Honours (Provisional)'
	when saw.cla2_code = 'UGM' then 'Certificate of Higher Education with Merit'
	else 'z_No Classification'
	end)
when saw.saw_udf5 is not null then 
(case 
	when (Case 
			when saw.saw_udf5 in ('FC','MARCHD') then '1'
			when saw.saw_udf5 in ('US','MARCHM') then '2'
			when saw.saw_udf5 in ('LS','MARCH') then '3'
			when saw.saw_udf5 = 'TC' then '5'
			when saw.saw_udf5 = 'HN' then '7'
			when saw.saw_udf5 = 'AG' then '8'
			when saw.saw_udf5 = 'UGDS' then '9'
			when saw.saw_udf5 in ('UGME','OD','CM') then '10'
			when saw.saw_udf5 = 'UGM' then '11'
			else null
			end)
>
	(Case 
			when saw.cla2_code in ('FC','MARCHD') then '1'
			when saw.cla2_code in ('US','MARCHM') then '2'
			when saw.cla2_code in ('LS','MARCH') then '3'
			when saw.cla2_code = 'TC' then '5'
			when saw.cla2_code = 'HN' then '7'
			when saw.cla2_code = 'AG' then '8'
			when saw.cla2_code = 'UGDS' then '9'
			when saw.cla2_code in ('UGME','OD','CM') then '10'
			when saw.cla2_code = 'UGM' then '11'
			else null
			end)
then (case
		when saw.cla2_code = 'AG' then 'Aegrotat (Unclassified Honours)'
		when saw.cla2_code = 'CM' then 'Commendation'
		when saw.cla2_code = 'FC' then 'First Class Honours'
		when saw.cla2_code = 'FCP' then 'First Class (Provisional)'
		when saw.cla2_code = 'HN' then 'Honours'
		when saw.cla2_code = 'LS' then 'Lower Second Class Honours'
		when saw.cla2_code = 'LSP' then 'Lower Second Class Honours (Provisional)'
		when saw.cla2_code = 'MARCH' then 'Master of Architecture'
		when saw.cla2_code = 'MARCHD' then 'Master of Architecture with Distinction'
		when saw.cla2_code = 'MARCHM' then 'Master of Architecture with Merit'
		when saw.cla2_code = 'MT' then 'Merit in Teaching'
		when saw.cla2_code = 'OD' then 'Ordinary Degree'
		when saw.cla2_code = 'PGDS' then 'Distinction'
		when saw.cla2_code = 'PGM' then 'Merit'
		when saw.cla2_code = 'TC' then 'Third Class Honours'
		when saw.cla2_code = 'TCP' then 'Third Class Honours (Provisional)'
		when saw.cla2_code = 'UGDS' then 'Ordinary Degree with Distinction'
		when saw.cla2_code = 'UGME' then 'Ordinary Degree with Merit'
		when saw.cla2_code = 'UNC' then 'Unclassified Honours'
		when saw.cla2_code = 'US' then 'Upper Second Class Honours'
		when saw.cla2_code = 'USP' then 'Upper Second Class Honours (Provisional)'
		when saw.cla2_code = 'UGM' then 'Certificate of Higher Education with Merit'
		else 'z_No Classification'
		end)
else (case
when saw.saw_udf5 = 'AG' then 'Aegrotat (Unclassified Honours)'
when saw.saw_udf5 = 'CM' then 'Commendation'
when saw.saw_udf5 = 'FC' then 'First Class Honours'
when saw.saw_udf5 = 'FCP' then 'First Class (Provisional)'
when saw.saw_udf5 = 'HN' then 'Honours'
when saw.saw_udf5 = 'LS' then 'Lower Second Class Honours'
when saw.saw_udf5 = 'LSP' then 'Lower Second Class Honours (Provisional)'
when saw.saw_udf5 = 'MARCH' then 'Master of Architecture'
when saw.saw_udf5 = 'MARCHD' then 'Master of Architecture with Distinction'
when saw.saw_udf5 = 'MARCHM' then 'Master of Architecture with Merit'
when saw.saw_udf5 = 'MT' then 'Merit in Teaching'
when saw.saw_udf5 = 'OD' then 'Ordinary Degree'
when saw.saw_udf5 = 'PGDS' then 'Distinction'
when saw.saw_udf5 = 'PGM' then 'Merit'
when saw.saw_udf5 = 'TC' then 'Third Class Honours'
when saw.saw_udf5 = 'TCP' then 'Third Class Honours (Provisional)'
when saw.saw_udf5 = 'UGDS' then 'Ordinary Degree with Distinction'
when saw.saw_udf5 = 'UGME' then 'Ordinary Degree with Merit'
when saw.saw_udf5 = 'UNC' then 'Unclassified Honours'
when saw.saw_udf5 = 'US' then 'Upper Second Class Honours'
when saw.saw_udf5 = 'USP' then 'Upper Second Class Honours (Provisional)'
when saw.saw_udf5 = 'UGM' then 'Certificate of Higher Education with Merit'
else 'z_No Classification'
end)
end)
else null
end "Calculated Classification",


/*
in WiP - Student Awards and Classifications v5.2 (090622) - TPG-UG issue plus data updates version of the Cognos report but not v5.1---
Sce Prgc
_Advance Standing (SFC)
Awd Code
Cla2 Code
Prg Code
_Actual Award TPG Grouping
Crs Code
Crs Name
*/

sce.sce_prgc,

/*
Case
when ([Folders].[Srs Scj].[Scj Qenc] = 'J30' and [Folders].[Srs Scj].[Scj Blok] >= 2) and ([Scj Arti] in (1,2,3,4)) then ('Advance Standing (HND)')
when ([Folders].[Srs Scj].[Scj Qenc] = 'C30' and [Folders].[Srs Scj].[Scj Blok] >= 2) and ([Scj Arti] in (1,2,3,4)) then ('Advance Standing (HNC)')
Else 'Not Advance Standing'
End
*/

case
when (scj.scj_qenc = 'J30' and scj.scj_blok >= 2 and scj.scj_arti in (1,2,3,4)) then 'Advance Standing (HND)'
when (scj.scj_qenc = 'C30' and scj.scj_blok >= 2 and scj.scj_arti in (1,2,3,4)) then 'Advance Standing (HNC)'
else 'Not Advance Standing'
end "Advance Standing (SFC)",
spr.awd_code "SPR - Award Code",
saw.cla2_code,
saw.prg_code,
--saw.awd_code "SAW - Award Code",

/*
case
when [Awd Desc] = 'Certificate of Higher Education' then 'Certificate of Higher Education'
when [Awd Desc] = 'Diploma of Higher Education' then 'Diploma of Higher Education'
when [Awd Desc] = 'Executive Master of Business Administration' then 'Executive Master of Business Administration'
when [Awd Desc] = 'Graduate Certificate' then 'Graduate Certificate'
when [Awd Desc] = 'Graduate Diploma' then 'Graduate Diploma'
when [Awd Desc] = 'Institutional Credit at PG level' then 'Institutional Credit'
when [Awd Desc] = 'Institutional Credit at U/G Level' then 'Institutional Credit'
when [Awd Desc] = 'Master of Business Administration' then 'Masters'
when [Awd Desc] = 'Master of Dental Public Health' then 'Masters'
when [Awd Desc] = 'Master of Dental Science' then 'Masters'
when [Awd Desc] = 'Master of Design' then 'Masters'
when [Awd Desc] = 'Master of Education' then 'Masters'
when [Awd Desc] = 'Master of Finance' then 'Masters'
when [Awd Desc] = 'Master of Fine Art' then 'Masters'
when [Awd Desc] = 'Master of Forensic Medicine' then 'Masters'
when [Awd Desc] = 'Master of Forensic Odontology (MFOdont)' then 'Masters'
when [Awd Desc] = 'Master of Forensic Toxicology' then 'Masters'
when [Awd Desc] = 'Master of Laws' then 'Masters'
when [Awd Desc] = 'Master of Letters' then 'Masters'
when [Awd Desc] = 'Master of Medical Education' then 'Masters'
when [Awd Desc] = 'Master of Nursing' then 'Masters'
when [Awd Desc] = 'Master of Orthopaedic Surgery (MChOrth)' then 'Masters'
when [Awd Desc] = 'Master of Palliative Care' then 'Masters'
when [Awd Desc] = 'Master of Public Health' then 'Masters'
when [Awd Desc] = 'Master of Public Health (Palliative Care Research)' then 'Masters'
when [Awd Desc] = 'Master of Research' then 'Masters'
when [Awd Desc] = 'Master of Science' then 'Masters'
when [Awd Desc] = 'Master of Science Nursing' then 'Masters'
when [Awd Desc] = 'No Award' then 'No Award'
when [Awd Desc] = 'Postgraduate Certificate' then 'Postgraduate Certificate'
when [Awd Desc] = 'Postgraduate Certificate of Education' then 'Postgraduate Certificate of Education'
when [Awd Desc] = 'Postgraduate Diploma' then 'Postgraduate Diploma'
when [Awd Desc] = 'Postgraduate Diploma in Education' then 'Postgraduate Diploma in Education'
when [Awd Desc] = 'Professional Graduate Diploma' then 'Professional Graduate Diploma'
when [Awd Desc] = 'Undergraduate Certificate' then 'Undergraduate Certificate'
else '###error###'
end
*/
case
when awd2.awd_desc = 'Certificate of Higher Education' then 'Certificate of Higher Education'
when awd2.awd_desc = 'Diploma of Higher Education' then 'Diploma of Higher Education'
when awd2.awd_desc = 'Executive Master of Business Administration' then 'Executive Master of Business Administration'
when awd2.awd_desc = 'Graduate Certificate' then 'Graduate Certificate'
when awd2.awd_desc = 'Graduate Diploma' then 'Graduate Diploma'
when awd2.awd_desc = 'Institutional Credit at PG level' then 'Institutional Credit'
when awd2.awd_desc = 'Institutional Credit at U/G Level' then 'Institutional Credit'
when awd2.awd_desc = 'Master of Business Administration' then 'Masters'
when awd2.awd_desc = 'Master of Dental Public Health' then 'Masters'
when awd2.awd_desc = 'Master of Dental Science' then 'Masters'
when awd2.awd_desc = 'Master of Design' then 'Masters'
when awd2.awd_desc = 'Master of Education' then 'Masters'
when awd2.awd_desc = 'Master of Finance' then 'Masters'
when awd2.awd_desc = 'Master of Fine Art' then 'Masters'
when awd2.awd_desc = 'Master of Forensic Medicine' then 'Masters'
when awd2.awd_desc = 'Master of Forensic Odontology (MFOdont)' then 'Masters'
when awd2.awd_desc = 'Master of Forensic Toxicology' then 'Masters'
when awd2.awd_desc = 'Master of Laws' then 'Masters'
when awd2.awd_desc = 'Master of Letters' then 'Masters'
when awd2.awd_desc = 'Master of Medical Education' then 'Masters'
when awd2.awd_desc = 'Master of Nursing' then 'Masters'
when awd2.awd_desc = 'Master of Orthopaedic Surgery (MChOrth)' then 'Masters'
when awd2.awd_desc = 'Master of Palliative Care' then 'Masters'
when awd2.awd_desc = 'Master of Public Health' then 'Masters'
when awd2.awd_desc = 'Master of Public Health (Palliative Care Research)' then 'Masters'
when awd2.awd_desc = 'Master of Research' then 'Masters'
when awd2.awd_desc = 'Master of Science' then 'Masters'
when awd2.awd_desc = 'Master of Science Nursing' then 'Masters'
when awd2.awd_desc = 'No Award' then 'No Award'
when awd2.awd_desc = 'Postgraduate Certificate' then 'Postgraduate Certificate'
when awd2.awd_desc = 'Postgraduate Certificate of Education' then 'Postgraduate Certificate of Education'
when awd2.awd_desc = 'Postgraduate Diploma' then 'Postgraduate Diploma'
when awd2.awd_desc = 'Postgraduate Diploma in Education' then 'Postgraduate Diploma in Education'
when awd2.awd_desc = 'Professional Graduate Diploma' then 'Professional Graduate Diploma'
when awd2.awd_desc = 'Undergraduate Certificate' then 'Undergraduate Certificate'
else '###error###'
end "Actual Award TPG Grouping",
sce.sce_crsc,
crs.crs_name,
--initcap(stu.stu_fusd) "STU - Known as",       --added for RIBA specific request 12/06/24 and coded out for Awards Dashboard refresh 26/06/24
--initcap(stu.stu_surn) "STU - Surname",        --added for RIBA specific request 12/06/24 and coded out for Awards Dashboard refresh 26/06/24
--initcap(stu.stu_name) "STU - Official name",  --added for RIBA specific request 12/06/24 and coded out for Awards Dashboard refresh 26/06/24
--stu.stu_dob "STU - Date of Birth"             --added for RIBA specific request 12/06/24 and coded out for Awards Dashboard refresh 26/06/24


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

nvl(ini1.ini_desc,'Not recorded') "Initiative 1 name",

case
    when sce.sce_stac in ('X','X-BP','X-NC','X-NS','X-W','XB')
        then 'Associate'
    when sce.sce_stac in ('C','CH','CO','CT')
        then 'Current'
    when sce.sce_stac in ('B','BP','BX','CB','DIS','EDP')
        then 'Dormant'
    when sce.sce_stac in ('NC','ST','W')
        then 'Ended studies'
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
end "Progression Code Name" --"SCE - Progression Code"

from reporting.ins_stu stu 

left join reporting.srs_scj scj on scj.scj_stuc = stu.stu_code
left join reporting.srs_sce sce on sce.sce_scjc = scj.scj_code 
left join reporting.ins_spr spr on spr.spr_code = scj.scj_sprc

left join reporting.ins_rou rou on sce.sce_rouc = rou.rou_code -- ROU Table
left join reporting.srs_crs crs on sce.sce_crsc = crs.crs_code -- CRS table
left join reporting.srs_qul qul on qul.qul_code = crs.crs_qulc -- CRS > QUL > EQA
left join reporting.ins_eqa eqa2 on eqa2.eqa_code = qul.qul_eqac -- EQA table attached to CRS table
left join reporting.ins_dpt dpt on dpt.dpt_code = rou.rou_udf6 -- Discipline on ROU
left join reporting.srs_fac fac on fac.fac_code = rou.rou_udf5 -- School on ROU
left join reporting.ins_awd awd on awd.awd_code = spr.awd_code -- AWD table for intended award
left join reporting.ins_eqa eqa on eqa.eqa_code = awd.awd_eqac -- EQA table attached to AWD table for intended award

left join reporting.srs_cod cod on scj.scj_codc = cod.cod_code -- Country of domicile on SCJ
left join reporting.srs_cdd cdd on cdd.cdd_code = cod.cod_cddc -- Higher level COD on SCJ
left join reporting.srs_geg geg on cod.cod_gegc = geg.geg_code -- GEG table for country of domicile geographical area
left join reporting.srs_reg reg on cod.cod_regc = reg.reg_code -- REG table added 05/05/21 for Country of Domicile regional grouping

inner join reporting.cam_saw saw on saw.spr_code = sce.sce_scjc --I only want records that have a SAW
        and saw.ayr_code = sce.sce_ayrc
left join reporting.cam_cla cla on cla.cla_code = saw.cla2_code
inner join reporting.ins_awd awd2 on awd2.awd_code = saw.awd_code -- AWD table for Actual Award

inner join reporting.ins_awd awd3 on awd3.awd_code = saw.saw_cawd -- AWD table for Calculated Award

left join reporting.srs_gen gen on gen.gen_code = stu.stu_gend -- Gender table
left join reporting.srs_eth eth on stu.stu_ethc = eth.eth_code -- ETH table for STU ethnicity
left join reporting.srs_nat nat on stu.stu_natc = nat.nat_code -- NAT table for STU nationality
left join reporting.srs_dsb dsb on dsb.dsb_code = stu.stu_dsbc --added 23/09 to facilitate FOI

left join reporting.men_mre mre on mre.mre_code = stu.stu_code
    and mre.mre_usrc = 'STU'

left join reporting.srs_mci mci on mci.mci_mstc = mre.mre_mstc
    and mre.mre_usrc = 'STU'
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
--left join reporting.srs_sca sca2 on sca2.sca_code = mci.mci_scac
--left join reporting.srs_trn trn2 on trn2.trn_code = mci.mci_trnc
left join reporting.srs_geg geg2 on geg2.geg_code = nat2.nat_gegc

left join reporting.srs_ini ini1 on ini1.ini_code = sce.sce_ini1 -- INI1 table attached to SCE_INI1

where 
stu.stu_udf7 is null -- No test records
and sce.sce_stac not in ('NS', 'P', 'P1')
--and saw.ayr_code = '2010/1'   
--and sce.sce_ayrc = '2010/1' and sce.sce_stac = 'NC'
--11/03/25 - various checks/changes tried; something is different re format of at least one data item, for <=2010/0; error ORA-01722: invalid number

--and saw.ayr_code >= '2019/0'

--and awd.awd_name <> awd2.awd_name -- added for testing purposes only