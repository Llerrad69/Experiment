Power Query mapping lookups

Quick usage

- Paste the contents of `Award_SCQF.m` into Power Query Advanced Editor, then call:

  - `fnAward_SCQF("PHD")`

- Paste the contents of `Grade_Map.m` into Power Query Advanced Editor, then call:

  - `fnGradeMap("A1")`

- Paste the contents of `Nationality_Area.m` into Power Query Advanced Editor, then call:

  - `fnNationalityArea("8826")`

Notes

- Each file exports a record with both the mapping table and a single convenience function: `fnAward_SCQF`, `fnGradeMap`, `fnNationalityArea`.
- Functions accept `nullable text`. They trim whitespace and perform case-insensitive matching; if the code isn't found they return `null`.
- To use the lookup inside a query column transform, call the function from a custom column, e.g.:

  - `= fnAward_SCQF([AwardCode])`

- For production use, consider moving these mappings into a persisted table (CSV or database) and loading that table in Power Query for easier updates.

Step-by-step: Load into Power BI

1. In Power BI Desktop create a Blank Query: `Home > Get Data > Blank Query` and open `Advanced Editor`.
2. Paste the full contents of one mapping file (for example `Award_SCQF.m`) into the editor and click `Done`. Rename the query to `Award_SCQF`.
3. Repeat for `Grade_Map.m` and `Nationality_Area.m`, naming queries `Grade_Map` and `Nationality_Area` respectively.
4. Each query returns a record exposing both the mapping table and a convenience function (for example `fnAward_SCQF`). To use a lookup in another query, add a Custom Column or create a new Blank Query and call the function, e.g.:

   - `= fnAward_SCQF([AwardCode])`

5. Optional: disable load for the mapping queries (right-click the query -> `Enable Load`) so the mapping queries don't load into the data model but the functions remain available for transformations.

Quick checks

- After pasting, ensure the exported function name matches the example (`fnAward_SCQF`, `fnGradeMap`, `fnNationalityArea`).
- If you want the mappings editable, store them in a CSV or a database table and `Get Data` from that source instead of embedding inline.