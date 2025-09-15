// Award_SCQF.m
// Power Query M: Award SCQF lookup table + function
// Usage: paste into Power Query Advanced Editor and call fnAward_SCQF("PHD")

let
    // Table: Award SCQF mapping (awd_code -> scqf_award_level)
    AwardSCQFTable = Table.FromRecords({
        [awd_code = "DBA", scqf_award_level = "(12) Doctorates (Research)"],
        [awd_code = "DCE", scqf_award_level = "(12) Doctorates (Research)"],
        [awd_code = "DCLD", scqf_award_level = "(12) Doctorates (Research)"],
        [awd_code = "DDSC", scqf_award_level = "(12) Doctorates (Research)"],
        [awd_code = "DED", scqf_award_level = "(12) Doctorates (Research)"],
        [awd_code = "PHD", scqf_award_level = "(12) Doctorates (Research)"],

        [awd_code = "LLMR", scqf_award_level = "(11) Masters (Research)"],
        [awd_code = "MACCR", scqf_award_level = "(11) Masters (Research)"],

        [awd_code = "DSW", scqf_award_level = "(11) Masters (Taught)"],
        [awd_code = "EMBA", scqf_award_level = "(11) Masters (Taught)"],
        [awd_code = "LLM", scqf_award_level = "(11) Masters (Taught)"],

        [awd_code = "BABDES", scqf_award_level = "(10) Honours degree / Graduate Diploma / Certificate"],
        [awd_code = "BACCH", scqf_award_level = "(10) Honours degree / Graduate Diploma / Certificate"],
        [awd_code = "BAH", scqf_award_level = "(10) Honours degree / Graduate Diploma / Certificate"],

        [awd_code = "BACCO", scqf_award_level = "(09) Ordinary degree/ Graduate Diploma / Certificate"],
        [awd_code = "BAO", scqf_award_level = "(09) Ordinary degree/ Graduate Diploma / Certificate"],

        [awd_code = "DIPHE", scqf_award_level = "(08) Higher National Diploma / Diploma in Higher Education / SVQ 4"],
        [awd_code = "CERTHE", scqf_award_level = "(07) Higher National Certificate / Certificate of Higher Education"],

        [awd_code = "INSTCREDUG", scqf_award_level = "(06.5) UG Credits"],
        [awd_code = "ROA", scqf_award_level = "(02) HE Education Access"],
        [awd_code = "NOAWARD", scqf_award_level = "(01) No Award"],
        [awd_code = null, scqf_award_level = null]
    }),

    // Lookup function: returns scqf_award_level for a given code (null if not found)
    fnAward_SCQF = (code as nullable text) as nullable text =>
        let
            input = if code = null then null else Text.Trim(Text.Upper(code)),
            found = if input = null then null else Table.SelectRows(AwardSCQFTable, each Text.Upper(Text.From([awd_code])) = input),
            result = if input = null then null else if Table.RowCount(found) = 0 then null else Record.Field(Table.First(found), "scqf_award_level")
        in
            result

in
    [ AwardSCQFTable = AwardSCQFTable, fnAward_SCQF = fnAward_SCQF ]
