function subject2 = importfile(workbookFile)
%% Setup the Import Options
opts = spreadsheetImportOptions("NumVariables", 8);

% Specify sheet and range
opts.DataRange = "A" + ":H";

% Specify column names and types
opts.VariableNames = ["timestamp", "steps", "timestamp", "heartrate", "bedtime", "awoketime", "timestamp", "fluid"];
opts.VariableTypes = ["datetime", "double", "datetime", "double", "datetime", "datetime", "datetime", "double"];

% Import the data
subject2 = readtable(workbookFile, opts, "UseExcel", false);
end