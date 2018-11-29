function subject2 = importfile(workbookFile)
%% Setup the Import Options
opts = spreadsheetImportOptions("NumVariables", 10);

% Specify sheet and range
opts.DataRange = "A" + ":J";

% Specify column names and types
opts.VariableNames = ["timestamp", "steps", "timestamp", "heartrate", "bedtime", "awoketime", "timestamp", "fluid","heacacheStart","heacacheEnd"];
opts.VariableTypes = ["datetime", "double", "datetime", "double", "datetime", "datetime", "datetime", "double","datetime","datetime"];

% Import the data
subject2 = readtable(workbookFile, opts, "UseExcel", false);
end