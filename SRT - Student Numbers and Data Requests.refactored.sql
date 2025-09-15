-- Refactored: SRT - Student Numbers and Data Requests
-- Purpose: show centralised mapping CTEs and a cleaned base for student demographics and SCE/SCJ joins

WITH

-- Ethnicity grouping CTE (source: reporting.srs_eth)
ethnicity_cte as (
    select
        eth_code,
        eth_name,
        case
            when eth_code in ('10','11','12','13','19','161','164','166','167','168','169','170','179') then 'White'
            when eth_code in ('14','21','22','29','31','32','33','34','39','41','42','43','49','50','80','16','100','101','103','104','119','120','121','139','140','141','142','159','180','899') then 'BAME'
            when eth_code in ('90','98','99','997','998') then 'Not known / Prefer not to say'
            else 'Not recorded'
        end as ethnicity_group,
        case
            when eth_code in ('119','33','100','34','101','31','103','39','32','104') then 'Asian'
            when eth_code in ('139','22','120','121','29','21') then 'Black'
            when eth_code in ('159','140','141','142','49','43','42','41') then 'Mixed'
            when eth_code in ('98','90','997','998','99') then 'Not known / Prefer not to say'
            when eth_code in ('899','50','16','80','14','180') then 'Other'
            when eth_code in ('179','19','11','161','164','166','167','168','169','170') then 'White'
            else null
        end as ethnicity_group_2
    from reporting.srs_eth
),

-- Disability grouping CTE (source: reporting.srs_dsb or use STU_DSBC values)
disability_cte as (
    select
        dsb_code,
        case when dsb_code in ('0','N','U','A','99','98','95') or dsb_code is null then 'No' else 'Yes' end as disability_flag
    from reporting.srs_dsb
),

-- Course level mapping CTE (source: reporting.srs_crs.crs_udf1 values)
course_level_cte as (
    select 'A' as code, '(05) Access' as course_level from dual union all
    select 'R','(03) Research' from dual union all
    select 'T','(02) Taught Postgraduate' from dual union all
    select 'U','(01) Undergraduate' from dual
),

-- Mode of attendance mapping CTE
mode_attendance_cte as (
    select 'BOC' moac, 'Distance Learning' mode_of_attendance from dual union all
    select 'DDL','Distance Learning' from dual union all
    select 'DL','Distance Learning' from dual union all
    select 'DLO','Distance Learning' from dual union all
    select 'WBL','Distance Learning' from dual union all
    select 'FOC','Distance Learning' from dual union all
    select 'CFT','Full-time' from dual union all
    select 'CYR','Full-time' from dual union all
    select 'DFT','Full-time' from dual union all
    select 'FT','Full-time' from dual union all
    select 'FTARCH','Full-time' from dual union all
    select 'FTF','Full-time' from dual union all
    select 'FTIP','Full-time' from dual union all
    select 'FTO','Full-time' from dual union all
    select 'GYR','Full-time' from dual union all
    select 'OYR','Full-time' from dual union all
    select 'SAB','Full-time' from dual union all
    select 'STE','Full-time' from dual union all
    select 'TYR','Full-time' from dual union all
    select 'WFT','Full-time' from dual union all
    select 'IEO','Full-time' from dual union all
    select 'IYR','Full-time' from dual union all
    select 'CPT','Part-time' from dual union all
    select 'DPT','Part-time' from dual union all
    select 'PT','Part-time' from dual union all
    select 'PTO','Part-time' from dual union all
    select 'WPT','Part-time' from dual union all
    select 'WMS','Part-time' from dual
),

-- Award SCQF mapping (full lists consolidated from scripts)
award_scqf_cte AS (
    select 'DBA' awd_code, '(12) Doctorates (Research)' scqf_award_level from dual union all
    select 'DCE','(12) Doctorates (Research)' from dual union all
    select 'DCLD','(12) Doctorates (Research)' from dual union all
    select 'DDSC','(12) Doctorates (Research)' from dual union all
    select 'DED','(12) Doctorates (Research)' from dual union all
    select 'DEDPSYCH','(12) Doctorates (Research)' from dual union all
    select 'DHSCI','(12) Doctorates (Research)' from dual union all
    select 'DHUM','(12) Doctorates (Research)' from dual union all
    select 'DLITT','(12) Doctorates (Research)' from dual union all
    select 'DMAN','(12) Doctorates (Research)' from dual union all
    select 'DPROF','(12) Doctorates (Research)' from dual union all
    select 'DSC','(12) Doctorates (Research)' from dual union all
    select 'DSSCI','(12) Doctorates (Research)' from dual union all
    select 'DSWO','(12) Doctorates (Research)' from dual union all
    select 'LLD','(12) Doctorates (Research)' from dual union all
    select 'MD','(12) Doctorates (Research)' from dual union all
    select 'PHD','(12) Doctorates (Research)' from dual union all

    select 'LLMR' awd_code, '(11) Masters (Research)' scqf_award_level from dual union all
    select 'MACCR','(11) Masters (Research)' from dual union all
    select 'MDSCR','(11) Masters (Research)' from dual union all
    select 'MFMR','(11) Masters (Research)' from dual union all
    select 'MMSCR','(11) Masters (Research)' from dual union all
    select 'MPH(PCR)','(11) Masters (Research)' from dual union all
    select 'MPHILR','(11) Masters (Research)' from dual union all
    select 'MSCR','(11) Masters (Research)' from dual union all
    select 'MSSCR','(11) Masters (Research)' from dual union all
    select 'PGCERTR','(11) Masters (Research)' from dual union all
    select 'MDESR','(11) Masters (Research)' from dual union all
    select 'MFAR','(11) Masters (Research)' from dual union all

    select 'DSW' awd_code, '(11) Masters (Taught)' scqf_award_level from dual union all
    select 'EMBA','(11) Masters (Taught)' from dual union all
    select 'INSTCREDPG','(11) Masters (Taught)' from dual union all
    select 'LLM','(11) Masters (Taught)' from dual union all
    select 'MACC','(11) Masters (Taught)' from dual union all
    select 'MARCH','(11) Masters (Taught)' from dual union all
    select 'MASG','(11) Masters (Taught)' from dual union all
    select 'MBA','(11) Masters (Taught)' from dual union all
    select 'MCHORTH','(11) Masters (Taught)' from dual union all
    select 'MCN','(11) Masters (Taught)' from dual union all
    select 'MDES','(11) Masters (Taught)' from dual union all
    select 'MDPH','(11) Masters (Taught)' from dual union all
    select 'MDSC','(11) Masters (Taught)' from dual union all
    select 'MED','(11) Masters (Taught)' from dual union all
    select 'MEDH','(11) Masters (Taught)' from dual union all
    select 'MEDO','(11) Masters (Taught)' from dual union all
    select 'MFA','(11) Masters (Taught)' from dual union all
    select 'MFIN','(11) Masters (Taught)' from dual union all
    select 'MFM','(11) Masters (Taught)' from dual union all
    select 'MFO','(11) Masters (Taught)' from dual union all
    select 'MFT','(11) Masters (Taught)' from dual union all
    select 'MLITT','(11) Masters (Taught)' from dual union all
    select 'MMAS','(11) Masters (Taught)' from dual union all
    select 'MMED','(11) Masters (Taught)' from dual union all
    select 'MMSC','(11) Masters (Taught)' from dual union all
    select 'MN','(11) Masters (Taught)' from dual union all
    select 'MPC','(11) Masters (Taught)' from dual union all
    select 'MPH','(11) Masters (Taught)' from dual union all
    select 'MPHIL','(11) Masters (Taught)' from dual union all
    select 'MRES','(11) Masters (Taught)' from dual union all
    select 'MSC','(11) Masters (Taught)' from dual union all
    select 'MSCN','(11) Masters (Taught)' from dual union all
    select 'MSSC','(11) Masters (Taught)' from dual union all
    select 'MSW','(11) Masters (Taught)' from dual union all
    select 'PGCE','(11) Masters (Taught)' from dual union all
    select 'PGCERT','(11) Masters (Taught)' from dual union all
    select 'PGCERTM','(11) Masters (Taught)' from dual union all
    select 'PGDE','(11) Masters (Taught)' from dual union all
    select 'PGDIP','(11) Masters (Taught)' from dual union all
    select 'PGDIPE','(11) Masters (Taught)' from dual union all
    select 'PGDIPM','(11) Masters (Taught)' from dual union all
    select 'PGDIPR','(11) Masters (Taught)' from dual union all
    select 'PGEDIP','(11) Masters (Taught)' from dual union all
    select 'PGMA','(11) Masters (Taught)' from dual union all
    select 'ROAPG','(11) Masters (Taught)' from dual union all
    select 'XLLMMBA','(11) Masters (Taught)' from dual union all
    select 'XLLMMSC','(11) Masters (Taught)' from dual union all
    select 'XMSCMBA','(11) Masters (Taught)' from dual union all

    select 'BABDES' awd_code, '(10) Honours degree / Graduate Diploma / Certificate' scqf_award_level from dual union all
    select 'BACCH','(10) Honours degree / Graduate Diploma / Certificate' from dual union all
    select 'BAH','(10) Honours degree / Graduate Diploma / Certificate' from dual union all
    select 'BAHA','(10) Honours degree / Graduate Diploma / Certificate' from dual union all
    select 'BAHW','(10) Honours degree / Graduate Diploma / Certificate' from dual union all
    select 'BAOA','(10) Honours degree / Graduate Diploma / Certificate' from dual union all
    select 'BARCHH','(10) Honours degree / Graduate Diploma / Certificate' from dual union all
    select 'BDESH','(10) Honours degree / Graduate Diploma / Certificate' from dual union all
    select 'BDS','(10) Honours degree / Graduate Diploma / Certificate' from dual union all
    select 'BEDH','(10) Honours degree / Graduate Diploma / Certificate' from dual union all
    select 'BENGH','(10) Honours degree / Graduate Diploma / Certificate' from dual union all
    select 'BFINH','(10) Honours degree / Graduate Diploma / Certificate' from dual union all
    select 'BIACCH','(10) Honours degree / Graduate Diploma / Certificate' from dual union all
    select 'BIFINH','(10) Honours degree / Graduate Diploma / Certificate' from dual union all
    select 'BMSC','(10) Honours degree / Graduate Diploma / Certificate' from dual union all
    select 'BSCH','(10) Honours degree / Graduate Diploma / Certificate' from dual union all
    select 'BSCM','(10) Honours degree / Graduate Diploma / Certificate' from dual union all
    select 'BSCMSC','(10) Honours degree / Graduate Diploma / Certificate' from dual union all
    select 'BSCNH','(10) Honours degree / Graduate Diploma / Certificate' from dual union all
    select 'FDIP','(10) Honours degree / Graduate Diploma / Certificate' from dual union all
    select 'GCERT','(10) Honours degree / Graduate Diploma / Certificate' from dual union all
    select 'GDIP','(10) Honours degree / Graduate Diploma / Certificate' from dual union all
    select 'INSTCREDUG2','(10) Honours degree / Graduate Diploma / Certificate' from dual union all
    select 'LLBH','(10) Honours degree / Graduate Diploma / Certificate' from dual union all
    select 'MAH','(10) Honours degree / Graduate Diploma / Certificate' from dual union all
    select 'MAHDIP','(10) Honours degree / Graduate Diploma / Certificate' from dual union all
    select 'MENGH','(10) Honours degree / Graduate Diploma / Certificate' from dual union all
    select 'MENGO','(10) Honours degree / Graduate Diploma / Certificate' from dual union all
    select 'MMATHH','(10) Honours degree / Graduate Diploma / Certificate' from dual union all
    select 'MMATHO','(10) Honours degree / Graduate Diploma / Certificate' from dual union all
    select 'MSCIH','(10) Honours degree / Graduate Diploma / Certificate' from dual union all
    select 'MSCIO','(10) Honours degree / Graduate Diploma / Certificate' from dual union all
    select 'PROQUAL','(10) Honours degree / Graduate Diploma / Certificate' from dual union all
    select 'REG','(10) Honours degree / Graduate Diploma / Certificate' from dual union all
    select 'UGCERT','(10) Honours degree / Graduate Diploma / Certificate' from dual union all

    select 'BACCO' awd_code, '(09) Ordinary degree/ Graduate Diploma / Certificate' scqf_award_level from dual union all
    select 'BAO','(09) Ordinary degree/ Graduate Diploma / Certificate' from dual union all
    select 'BARCHO','(09) Ordinary degree/ Graduate Diploma / Certificate' from dual union all
    select 'BDESO','(09) Ordinary degree/ Graduate Diploma / Certificate' from dual union all
    select 'BENGO','(09) Ordinary degree/ Graduate Diploma / Certificate' from dual union all
    select 'BFINO','(09) Ordinary degree/ Graduate Diploma / Certificate' from dual union all
    select 'BHS','(09) Ordinary degree/ Graduate Diploma / Certificate' from dual union all
    select 'BIFINO','(09) Ordinary degree/ Graduate Diploma / Certificate' from dual union all
    select 'BM','(09) Ordinary degree/ Graduate Diploma / Certificate' from dual union all
    select 'BM/DIPHE','(09) Ordinary degree/ Graduate Diploma / Certificate' from dual union all
    select 'BN','(09) Ordinary degree/ Graduate Diploma / Certificate' from dual union all
    select 'BN/DIPHE','(09) Ordinary degree/ Graduate Diploma / Certificate' from dual union all
    select 'BNSPQ','(09) Ordinary degree/ Graduate Diploma / Certificate' from dual union all
    select 'BSCA','(09) Ordinary degree/ Graduate Diploma / Certificate' from dual union all
    select 'BSCN(POST)','(09) Ordinary degree/ Graduate Diploma / Certificate' from dual union all
    select 'BSCO','(09) Ordinary degree/ Graduate Diploma / Certificate' from dual union all
    select 'LLBO','(09) Ordinary degree/ Graduate Diploma / Certificate' from dual union all
    select 'MAO','(09) Ordinary degree/ Graduate Diploma / Certificate' from dual union all
    select 'MBCHB','(09) Ordinary degree/ Graduate Diploma / Certificate' from dual union all
    select 'BSCN','(09) Ordinary degree/ Graduate Diploma / Certificate' from dual union all
    select 'BDS','(09) Ordinary degree/ Graduate Diploma / Certificate' from dual union all

    select 'DIPHE' awd_code, '(08) Higher National Diploma / Diploma in Higher Education / SVQ 4' scqf_award_level from dual union all
    select 'CERTHE','(07) Higher National Certificate / Certificate of Higher Education' from dual union all
    select 'INSTCREDUG','(06.5) UG Credits' from dual union all
    select 'ROA','(02) HE Education Access' from dual union all
    select 'NOAWARD','(01) No Award' from dual
),

-- Module grade mappings and aggregation scale
grade_map_cte AS (
    select 'A1' code, 'A' grade from dual union all
    select 'A2','A' from dual union all
    select 'A3','A' from dual union all
    select 'A4','A' from dual union all
    select 'A5','A' from dual union all
    select 'B1','B' from dual union all
    select 'B2','B' from dual union all
    select 'B3','B' from dual union all
    select 'C1','C' from dual union all
    select 'C2','C' from dual union all
    select 'C3','C' from dual union all
    select 'D1','D' from dual union all
    select 'D2','D' from dual union all
    select 'D3','D' from dual union all
    select 'M1','MF' from dual union all
    select 'M2','MF' from dual union all
    select 'M3','MF' from dual union all
    select 'CF','CF' from dual union all
    select 'BF','BF' from dual union all
    select 'QF','QF' from dual union all
    select 'F','F' from dual union all
    select 'AB','F' from dual union all
    select 'ST','F' from dual union all
    select 'MF','F' from dual union all
    select 'NM','No Mark Awarded' from dual union all
    select 'CA','Absent' from dual union all
    select 'MC','Absent' from dual
),

aggregation_scale_cte AS (
    select 'A1' code, 23 val from dual union all
    select 'A2',22 from dual union all
    select 'A3',21 from dual union all
    select 'A4',20 from dual union all
    select 'A5',19 from dual union all
    select 'M1',9 from dual union all
    select 'M2',8 from dual union all
    select 'M3',7 from dual union all
    select 'CF',5 from dual union all
    select 'BF',2 from dual union all
    select 'QF',0 from dual union all
    select 'B1',18 from dual union all
    select 'B2',17 from dual union all
    select 'B3',16 from dual union all
    select 'C1',15 from dual union all
    select 'C2',14 from dual union all
    select 'C3',13 from dual union all
    select 'D1',12 from dual union all
    select 'D2',11 from dual union all
    select 'D3',10 from dual
),

-- Progression code mapping (condensed but includes main codes)
progression_cte AS (
    select '1' code, '(01-01) PP - Pass Proceed' label from dual union all
    select 'NFY','(01-01) PP - Pass Proceed' from dual union all
    select 'PP','(01-01) PP - Pass Proceed' from dual union all
    select 'PR','(01-04) PR - Pass but has resits' from dual union all
    select 'PRF','(01-04) PR - Pass but has resits' from dual union all
    select 'PC','(01-03) PC - Pass Carrying Module(s)' from dual union all
    select 'RC','(01-05) RC - Pass at Resit Carrying Module(s)' from dual union all
    select 'RP','(01-02) RP - Pass after Resits' from dual union all
    select 'D','(02-01) D - Year Discounted' from dual union all
    select 'RY','(02-03) RY - Repeat year of course' from dual union all
    select 'SB','(02-04) SB - Study Break' from dual union all
    select 'LST','(02-02) LST - Liable Studies Terminated following yr' from dual union all
    select 'LAE','(03-01) LAE - Lesser Award Early Exit' from dual union all
    select 'ST','(02-05) ST - Studies Terminated' from dual union all
    select 'W','(02-06) W - Withdrawn' from dual union all
    select 'FA','(01-06) FA - Student obtained Full Award' from dual union all
    select 'AWD','(01-06) FA - Student obtained Full Award' from dual union all
    select 'NC','(01-06) FA - Student obtained Full Award' from dual union all
    select 'LT','(05-01) LT - Liable for Termination' from dual union all
    select 'IT','(01-07) IT - Internal Transfer' from dual union all
    select 'FR','(02-07) FR - Fail with Resit' from dual union all
    select 'LA','(04-01) LA - Lesser Award' from dual union all
    select 'N','(05-01) N - Awaiting Results' from dual union all
    select 'STP','(02-05) STP - Studies Terminated (from previous year)' from dual union all
    select 'NS','(05-04) NS - Never Started' from dual union all
    select 'GA','(05-02) GA - Graduate Apprentice - progression not known' from dual union all
    select 'ICD','(05-03) ICD - ICD' from dual union all
    select null code, '(99) Progression Code not present' from dual
),

-- Student fee status mapping
fee_status_cte AS (
    select 'HS' code, 'HomeScottish' label from dual union all
    select 'CIOMC','HomeEU' from dual union all
    select 'H','HomeEU' from dual union all
    select 'HC','HomeEU' from dual union all
    select 'HEU','HomeEU' from dual union all
    select 'HFP','HomeEU' from dual union all
    select 'HFW','HomeEU' from dual union all
    select 'HH','HomeEU' from dual union all
    select 'HHC','HomeEU' from dual union all
    select 'HNF','HomeEU' from dual union all
    select 'HNFS','HomeEU' from dual union all
    select 'HNI','HomeEU' from dual union all
    select 'HNIC','HomeEU' from dual union all
    select 'HNIPR','HomeEU' from dual union all
    select 'HSEU','HomeEU' from dual union all
    select 'HTH','HomeEU' from dual union all
    select 'CIOM','RUK' from dual union all
    select 'CIOMF','RUK' from dual union all
    select 'CIOMN','RUK' from dual union all
    select 'HRUK','RUK' from dual union all
    select 'HRUKF','RUK' from dual union all
    select 'HRUKN','RUK' from dual union all
    select 'HRUK1','RUK' from dual union all
    select 'RUK','RUK' from dual union all
    select 'O%','Overseas' from dual
),

-- Nationality area mapping (condensed, use the full lists from original script if needed)
nationality_area_cte AS (
    select '7826' code, '(02) Other' label from dual union all
    select '000','(03) UK' from dual union all
    select '2826','(03) UK' from dual union all
    select '3826','(03) UK' from dual union all
    select '5826','(03) UK' from dual union all
    select '593','(03) UK' from dual union all
    select '594','(03) UK' from dual union all
    select '595','(03) UK' from dual union all
    select '6826','(03) UK' from dual union all
    select '999','(03) UK' from dual union all
    select '4826','(03) UK' from dual union all
    select '8826','(04) Northern Ireland' from dual union all
    select '676','(06) Ireland' from dual union all
    select '638','(07) European Union (exc. EIRE) - Area 1' from dual union all
    select '653','(07) European Union (exc. EIRE) - Area 1' from dual union all
    select '656','(07) European Union (exc. EIRE) - Area 1' from dual union all
    select '661','(07) European Union (exc. EIRE) - Area 1' from dual union all
    select '670','(07) European Union (exc. EIRE) - Area 1' from dual union all
    select '727','(07) European Union (exc. EIRE) - Area 1' from dual union all
    select '751','(07) European Union (exc. EIRE) - Area 1' from dual union all
    select '849','(07) European Union (exc. EIRE) - Area 1' from dual union all
    select '882','(07) European Union (exc. EIRE) - Area 1' from dual union all
    select '883','(07) European Union (exc. EIRE) - Area 1' from dual union all
    select 'XE','(07) European Union (exc. EIRE) - Area 1' from dual union all
    select '621','(08) European Union (exc. EIRE) - Area 2' from dual union all
    select '700','(08) European Union (exc. EIRE) - Area 2' from dual union all
    select '733','(08) European Union (exc. EIRE) - Area 2' from dual union all
    select '831','(08) European Union (exc. EIRE) - Area 2' from dual union all
    select '832','(08) European Union (exc. EIRE) - Area 2' from dual union all
    select '833','(08) European Union (exc. EIRE) - Area 2' from dual union all
    select '834','(08) European Union (exc. EIRE) - Area 2' from dual union all
    select '835','(08) European Union (exc. EIRE) - Area 2' from dual union all
    select '850','(08) European Union (exc. EIRE) - Area 2' from dual union all
    select '610','(09) European Union (exc. EIRE) - Area 3' from dual union all
    select '614','(09) European Union (exc. EIRE) - Area 3' from dual union all
    select '641','(09) European Union (exc. EIRE) - Area 3' from dual union all
    select '651','(09) European Union (exc. EIRE) - Area 3' from dual union all
    select '678','(09) European Union (exc. EIRE) - Area 3' from dual union all
    select '693','(09) European Union (exc. EIRE) - Area 3' from dual union all
    select '710','(09) European Union (exc. EIRE) - Area 3' from dual union all
    select '728','(09) European Union (exc. EIRE) - Area 3' from dual union all
    select '755','(09) European Union (exc. EIRE) - Area 3' from dual union all
    select '853','(09) European Union (exc. EIRE) - Area 3' from dual union all
    select '878','(09) European Union (exc. EIRE) - Area 3' from dual union all
    select '637','(11) European Overseas Territories' from dual union all
    select '659','(11) European Overseas Territories' from dual union all
    select '711','(11) European Overseas Territories' from dual union all
    select '821','(11) European Overseas Territories' from dual union all
    select '822','(11) European Overseas Territories' from dual union all
    select '828','(11) European Overseas Territories' from dual union all
    select '865','(11) European Overseas Territories' from dual union all
    select '626','(12) Overseas - Area 0' from dual union all
    select '771','(12) Overseas - Area 0' from dual union all
    select '873','(12) Overseas - Area 0' from dual union all
    select '612','(13) Overseas - Area 1' from dual union all
    select '628','(13) Overseas - Area 1' from dual union all
    select '631','(13) Overseas - Area 1' from dual union all
    select '669','(13) Overseas - Area 1' from dual union all
    select '672','(13) Overseas - Area 1' from dual union all
    select '683','(13) Overseas - Area 1' from dual union all
    select '684','(13) Overseas - Area 1' from dual union all
    select '686','(13) Overseas - Area 1' from dual union all
    select '698','(13) Overseas - Area 1' from dual union all
    select '708','(13) Overseas - Area 1' from dual union all
    select '717','(13) Overseas - Area 1' from dual union all
    select '721','(13) Overseas - Area 1' from dual union all
    select '731','(13) Overseas - Area 1' from dual union all
    select '743','(13) Overseas - Area 1' from dual union all
    select '746','(13) Overseas - Area 1' from dual union all
    select '764','(13) Overseas - Area 1' from dual union all
    select '766','(13) Overseas - Area 1' from dual union all
    select '774','(13) Overseas - Area 1' from dual union all
    select '779','(13) Overseas - Area 1' from dual union all
    select '839','(13) Overseas - Area 1' from dual union all
    select '652','(14) Overseas - Area 2' from dual union all
    select '673','(14) Overseas - Area 2' from dual union all
    select '681','(14) Overseas - Area 2' from dual union all
    select '697','(14) Overseas - Area 2' from dual union all
    select '718','(14) Overseas - Area 2' from dual union all
    select '760','(14) Overseas - Area 2' from dual union all
    select '772','(14) Overseas - Area 2' from dual union all
    select '787','(14) Overseas - Area 2' from dual union all
    select '842','(14) Overseas - Area 2' from dual union all
    select '845','(14) Overseas - Area 2' from dual union all
    select '1780','(15) Overseas - Area 3' from dual union all
    select '601','(15) Overseas - Area 3' from dual union all
    select '604','(15) Overseas - Area 3' from dual union all
    select '609','(15) Overseas - Area 3' from dual union all
    select '618','(15) Overseas - Area 3' from dual union all
    select '620','(15) Overseas - Area 3' from dual union all
    select '630','(15) Overseas - Area 3' from dual union all
    select '658','(15) Overseas - Area 3' from dual union all
    select '671','(15) Overseas - Area 3' from dual union all
    select '677','(15) Overseas - Area 3' from dual union all
    select '692','(15) Overseas - Area 3' from dual union all
    select '694','(15) Overseas - Area 3' from dual union all
    select '702','(15) Overseas - Area 3' from dual union all
    select '703','(15) Overseas - Area 3' from dual union all
    select '706','(15) Overseas - Area 3' from dual union all
    select '714','(15) Overseas - Area 3' from dual union all
    select '750','(15) Overseas - Area 3' from dual union all
    select '756','(15) Overseas - Area 3' from dual union all
    select '759','(15) Overseas - Area 3' from dual union all
    select '765','(15) Overseas - Area 3' from dual union all
    select '767','(15) Overseas - Area 3' from dual union all
    select '768','(15) Overseas - Area 3' from dual union all
    select '773','(15) Overseas - Area 3' from dual union all
    select '780','(15) Overseas - Area 3' from dual union all
    select '793','(15) Overseas - Area 3' from dual union all
    select '825','(15) Overseas - Area 3' from dual union all
    select '826','(15) Overseas - Area 3' from dual union all
    select '827','(15) Overseas - Area 3' from dual union all
    select '840','(15) Overseas - Area 3' from dual union all
    select '841','(15) Overseas - Area 3' from dual union all
    select '843','(15) Overseas - Area 3' from dual union all
    select '844','(15) Overseas - Area 3' from dual union all
    select '846','(15) Overseas - Area 3' from dual union all
    select '847','(15) Overseas - Area 3' from dual union all
    select '880','(15) Overseas - Area 3' from dual union all
    select '881','(15) Overseas - Area 3' from dual union all
    select '898','(15) Overseas - Area 3' from dual union all
    select '997','(15) Overseas - Area 3' from dual union all
    select '807','(16) Overseas - Area 4' from dual union all
    select '602','(16) Overseas - Area 4' from dual union all
    select '603','(16) Overseas - Area 4' from dual union all
    select '605','(16) Overseas - Area 4' from dual union all
    select '606','(16) Overseas - Area 4' from dual union all
    select '607','(16) Overseas - Area 4' from dual union all
    select '608','(16) Overseas - Area 4' from dual union all
    select '611','(16) Overseas - Area 4' from dual union all
    select '613','(16) Overseas - Area 4' from dual union all
    select '616','(16) Overseas - Area 4' from dual union all
    select '617','(16) Overseas - Area 4' from dual union all
    select '619','(16) Overseas - Area 4' from dual union all
    select '622','(16) Overseas - Area 4' from dual union all
    select '623','(16) Overseas - Area 4' from dual union all
    select '624','(16) Overseas - Area 4' from dual union all
    select '625','(16) Overseas - Area 4' from dual union all
    select '627','(16) Overseas - Area 4' from dual union all
    select '629','(16) Overseas - Area 4' from dual union all
    select '632','(16) Overseas - Area 4' from dual union all
    select '633','(16) Overseas - Area 4' from dual union all
    select '634','(16) Overseas - Area 4' from dual union all
    select '635','(16) Overseas - Area 4' from dual union all
    select '636','(16) Overseas - Area 4' from dual union all
    select '640','(16) Overseas - Area 4' from dual union all
    select '642','(16) Overseas - Area 4' from dual union all
    select '643','(16) Overseas - Area 4' from dual union all
    select '645','(16) Overseas - Area 4' from dual union all
    select '646','(16) Overseas - Area 4' from dual union all
    select '647','(16) Overseas - Area 4' from dual union all
    select '648','(16) Overseas - Area 4' from dual union all
    select '650','(16) Overseas - Area 4' from dual union all
    select '654','(16) Overseas - Area 4' from dual union all
    select '655','(16) Overseas - Area 4' from dual union all
    select '660','(16) Overseas - Area 4' from dual union all
    select '662','(16) Overseas - Area 4' from dual union all
    select '663','(16) Overseas - Area 4' from dual union all
    select '664','(16) Overseas - Area 4' from dual union all
    select '665','(16) Overseas - Area 4' from dual union all
    select '666','(16) Overseas - Area 4' from dual union all
    select '667','(16) Overseas - Area 4' from dual union all
    select '668','(16) Overseas - Area 4' from dual union all
    select '674','(16) Overseas - Area 4' from dual union all
    select '675','(16) Overseas - Area 4' from dual union all
    select '679','(16) Overseas - Area 4' from dual union all
    select '680','(16) Overseas - Area 4' from dual union all
    select '682','(16) Overseas - Area 4' from dual union all
    select '685','(16) Overseas - Area 4' from dual union all
    select '687','(16) Overseas - Area 4' from dual union all
    select '688','(16) Overseas - Area 4' from dual union all
    select '689','(16) Overseas - Area 4' from dual union all
    select '690','(16) Overseas - Area 4' from dual union all
    select '691','(16) Overseas - Area 4' from dual union all
    select '695','(16) Overseas - Area 4' from dual union all
    select '696','(16) Overseas - Area 4' from dual union all
    select '699','(16) Overseas - Area 4' from dual union all
    select '701','(16) Overseas - Area 4' from dual union all
    select '704','(16) Overseas - Area 4' from dual union all
    select '707','(16) Overseas - Area 4' from dual union all
    select '709','(16) Overseas - Area 4' from dual union all
    select '712','(16) Overseas - Area 4' from dual union all
    select '713','(16) Overseas - Area 4' from dual union all
    select '715','(16) Overseas - Area 4' from dual union all
    select '716','(16) Overseas - Area 4' from dual union all
    select '722','(16) Overseas - Area 4' from dual union all
    select '723','(16) Overseas - Area 4' from dual union all
    select '724','(16) Overseas - Area 4' from dual union all
    select '725','(16) Overseas - Area 4' from dual union all
    select '726','(16) Overseas - Area 4' from dual union all
    select '730','(16) Overseas - Area 4' from dual union all
    select '732','(16) Overseas - Area 4' from dual union all
    select '734','(16) Overseas - Area 4' from dual union all
    select '736','(16) Overseas - Area 4' from dual union all
    select '737','(16) Overseas - Area 4' from dual union all
    select '738','(16) Overseas - Area 4' from dual union all
    select '739','(16) Overseas - Area 4' from dual union all
    select '741','(16) Overseas - Area 4' from dual union all
    select '742','(16) Overseas - Area 4' from dual union all
    select '744','(16) Overseas - Area 4' from dual union all
    select '745','(16) Overseas - Area 4' from dual union all
    select '747','(16) Overseas - Area 4' from dual union all
    select '748','(16) Overseas - Area 4' from dual union all
    select '749','(16) Overseas - Area 4' from dual union all
    select '752','(16) Overseas - Area 4' from dual union all
    select '753','(16) Overseas - Area 4' from dual union all
    select '754','(16) Overseas - Area 4' from dual union all
    select '757','(16) Overseas - Area 4' from dual union all
    select '761','(16) Overseas - Area 4' from dual union all
    select '762','(16) Overseas - Area 4' from dual union all
    select '763','(16) Overseas - Area 4' from dual union all
    select '769','(16) Overseas - Area 4' from dual union all
    select '770','(16) Overseas - Area 4' from dual union all
    select '775','(16) Overseas - Area 4' from dual union all
    select '777','(16) Overseas - Area 4' from dual union all
    select '778','(16) Overseas - Area 4' from dual union all
    select '781','(16) Overseas - Area 4' from dual union all
    select '782','(16) Overseas - Area 4' from dual union all
    select '783','(16) Overseas - Area 4' from dual union all
    select '784','(16) Overseas - Area 4' from dual union all
    select '785','(16) Overseas - Area 4' from dual union all
    select '786','(16) Overseas - Area 4' from dual union all
    select '788','(16) Overseas - Area 4' from dual union all
    select '789','(16) Overseas - Area 4' from dual union all
    select '790','(16) Overseas - Area 4' from dual union all
    select '791','(16) Overseas - Area 4' from dual union all
    select '792','(16) Overseas - Area 4' from dual union all
    select '794','(16) Overseas - Area 4' from dual union all
    select '795','(16) Overseas - Area 4' from dual union all
    select '796','(16) Overseas - Area 4' from dual union all
    select '797','(16) Overseas - Area 4' from dual union all
    select '798','(16) Overseas - Area 4' from dual union all
    select '800','(16) Overseas - Area 4' from dual union all
    select '802','(16) Overseas - Area 4' from dual union all
    select '803','(16) Overseas - Area 4' from dual union all
    select '804','(16) Overseas - Area 4' from dual union all
    select '805','(16) Overseas - Area 4' from dual union all
    select '836','(16) Overseas - Area 4' from dual union all
    select '837','(16) Overseas - Area 4' from dual union all
    select '838','(16) Overseas - Area 4' from dual union all
    select '848','(16) Overseas - Area 4' from dual union all
    select '851','(16) Overseas - Area 4' from dual union all
    select '852','(16) Overseas - Area 4' from dual union all
    select '854','(16) Overseas - Area 4' from dual union all
    select '860','(16) Overseas - Area 4' from dual union all
    select '861','(16) Overseas - Area 4' from dual union all
    select '862','(16) Overseas - Area 4' from dual union all
    select '863','(16) Overseas - Area 4' from dual union all
    select '864','(16) Overseas - Area 4' from dual union all
    select '870','(16) Overseas - Area 4' from dual union all
    select '874','(16) Overseas - Area 4' from dual union all
    select '884','(16) Overseas - Area 4' from dual union all
    select '998','(16) Overseas - Area 4' from dual union all
    select 'XN','(16) Overseas - Area 4' from dual union all
    select '615','(17) British Overseas Territories' from dual union all
    select '649','(17) British Overseas Territories' from dual union all
    select '705','(17) British Overseas Territories' from dual union all
    select '735','(17) British Overseas Territories' from dual union all
    select '776','(17) British Overseas Territories' from dual union all
    select '799','(17) British Overseas Territories' from dual union all
    select '801','(17) British Overseas Territories' from dual union all
    select '823','(17) British Overseas Territories' from dual union all
    select '824','(17) British Overseas Territories' from dual union all
    select '829','(17) British Overseas Territories' from dual union all
    select '830','(17) British Overseas Territories' from dual
),

-- Note: This file is intentionally a "WITH ... SELECT" snippet so it can be validated on its own.
-- To use these CTEs in your scripts, copy the CTE definitions (everything between the initial WITH and the final closing
-- parenthesis) into the top of your query's WITH clause, then reference the CTEs by name (for example, JOIN to ethnicity_cte
-- on eth_code = COALESCE(mci.mci_ethc, stu.stu_ethc)).

base as (
    select
        stu.stu_code,
        stu.stu_name,
        scj.scj_code,
        scj.scj_ayrc,
        scj.scj_agoe,
        sce.sce_scjc,
        sce.sce_ayrc as sce_ayr,
        sce.sce_crsc,
        sce.sce_moac,
        coalesce(mci.mci_ethc, stu.stu_ethc) ethc,
        stu.stu_dsbc,
        sce.sce_efid
    from reporting.ins_stu stu
    left join reporting.srs_scj scj on scj.scj_stuc = stu.stu_code
    left join reporting.srs_sce sce on sce.sce_scjc = scj.scj_code
    left join reporting.men_mre mre on mre.mre_code = stu.stu_code and mre.mre_usrc = 'STU'
    left join reporting.srs_mci mci on mci.mci_mstc = mre.mre_mstc and mre.mre_usrc = 'STU'
),

final as (
    select
        b.stu_code "Student Code",
        b.stu_name "STU Official name",
        b.scj_code "Student Join Code",
        b.scj_ayrc "Academic Year (Entry)",
        case when b.scj_agoe <21 then '20 and under' when b.scj_agoe between 21 and 24 then '21-24' when b.scj_agoe between 25 and 29 then '25-29' when b.scj_agoe >=30 then '30 and over' else 'Not recorded' end "Age on Entry",
        coalesce(e.ethnicity_group,'Not recorded') "Ethnicity",
        case when b.stu_dsbc in ('0','N','U','A','99','98','95') or b.stu_dsbc is null then 'No' else 'Yes' end "Disability",
        coalesce(f.name,'Not recorded') "Fundability Group",
        coalesce(cl.course_level,'###ERROR###') "Course Level"
    from base b
    left join ethnicity_cte e on e.eth_code = b.ethc
    left join fundability_cte f on f.code = b.sce_efid
    left join course_level_cte cl on cl.code = (select crs.crs_udf1 from reporting.srs_crs crs where crs.crs_code = b.sce_crsc)
)

select * from final;

-- To extend: add progression/retention mappings, recruitment pathway, HESA populations and other groups as their own CTEs and join to the base.
