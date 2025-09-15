// Grade_Map.m
// Power Query M: Grade map lookup table + function
// Usage: paste into Power Query Advanced Editor and call fnGradeMap("A1")

let
    GradeMapTable = Table.FromRecords({
        [code = "A1", grade = "A"],
        [code = "A2", grade = "A"],
        [code = "A3", grade = "A"],
        [code = "A4", grade = "A"],
        [code = "A5", grade = "A"],
        [code = "B1", grade = "B"],
        [code = "B2", grade = "B"],
        [code = "B3", grade = "B"],
        [code = "C1", grade = "C"],
        [code = "C2", grade = "C"],
        [code = "C3", grade = "C"],
        [code = "D1", grade = "D"],
        [code = "D2", grade = "D"],
        [code = "D3", grade = "D"],
        [code = "M1", grade = "MF"],
        [code = "M2", grade = "MF"],
        [code = "M3", grade = "MF"],
        [code = "CF", grade = "CF"],
        [code = "BF", grade = "BF"],
        [code = "QF", grade = "QF"],
        [code = "F", grade = "F"],
        [code = "AB", grade = "F"],
        [code = "ST", grade = "F"],
        [code = "MF", grade = "F"],
        [code = "NM", grade = "No Mark Awarded"],
        [code = "CA", grade = "Absent"],
        [code = "MC", grade = "Absent"],
        [code = "DC", grade = "Module Discounted"],
        [code = "P", grade = "P"],
        [code = "DS", grade = "P"],
        [code = "ME", grade = "P"],
        [code = "WD", grade = "WD"],
        [code = null, grade = null]
    }),

    fnGradeMap = (code as nullable text) as nullable text =>
        let
            input = if code = null then null else Text.Trim(Text.Upper(code)),
            found = if input = null then null else Table.SelectRows(GradeMapTable, each Text.Upper(Text.From([code])) = input),
            result = if input = null then null else if Table.RowCount(found) = 0 then null else Record.Field(Table.First(found), "grade")
        in
            result
in
    [ GradeMapTable = GradeMapTable, fnGradeMap = fnGradeMap ]
