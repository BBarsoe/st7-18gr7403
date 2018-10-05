function fluidjacob = importFluidData(workbookFile, sheetName, startRow, endRow)
%IMPORTFILE1 Import data from a spreadsheet
%  FLUIDJACOB = IMPORTFILE1(FILE) reads data from the first worksheet in
%  the Microsoft Excel spreadsheet file named FILE.  Returns the data as
%  a table.
%
%  FLUIDJACOB = IMPORTFILE1(FILE, SHEET) reads from the specified
%  worksheet.
%
%  FLUIDJACOB = IMPORTFILE1(FILE, SHEET, STARTROW, ENDROW) reads from
%  the specified worksheet for the specified row interval(s). Specify
%  STARTROW and ENDROW as a pair of scalars or vectors of matching size
%  for dis-contiguous row intervals.
%
%  Example:
%  fluidjacob = importfile1("C:\Users\Admin\Documents\Git\st7-18gr7403\patterne-recognition-tests\fluid_jacob.xlsx", "Ark1", 2, 85);
%
%  See also READTABLE.
%
% Auto-generated by MATLAB on 04-Oct-2018 13:47:31

%% Input handling

% If no sheet is specified, read first sheet
if nargin == 1 || isempty(sheetName)
    sheetName = 1;
end

% If row start and end points are not specified, define defaults
if nargin <= 3
    startRow = 2;
    endRow = 85;
end

%% Setup the Import Options
opts = spreadsheetImportOptions("NumVariables", 3);

% Specify sheet and range
opts.Sheet = sheetName;
opts.DataRange = "A" + startRow(1) + ":C" + endRow(1);

% Specify column names and types
opts.VariableNames = ["Date", "Amountml", "Type"];
opts.VariableTypes = ["datetime", "double", "categorical"];
opts = setvaropts(opts, 3, "EmptyFieldRule", "auto");

% Import the data
fluidjacob = readtable(workbookFile, opts, "UseExcel", false);

for idx = 2:length(startRow)
    opts.DataRange = "A" + startRow(idx) + ":C" + endRow(idx);
    tb = readtable(workbookFile, opts, "UseExcel", false);
    fluidjacob = [fluidjacob; tb]; %#ok<AGROW>
end

end