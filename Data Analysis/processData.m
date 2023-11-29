%This code isn't great, but is a nice Hackey solution to organize my data
function processData()
    exp1Data = {};
    exp2Data = {};
    load TSR_Dataexp1.mat
    exp1Data = [exp1Data comparison_results_all];
    load TSR_Dataexp2.mat
    exp2Data = [exp2Data comparison_results_all];
    load OR_Dataexp1.mat
    exp1Data = [exp1Data comparison_results_all];
    load OR_Dataexp2.mat
    exp2Data=[exp2Data comparison_results_all];
    load Set12_Dataexp1.mat
    exp1Data = [exp1Data compResultsall];
    load Set12_Dataexp2.mat
    exp2Data = [exp2Data compResultsall];
    load SIDD_Dataexp1.mat
    exp1Data = [exp1Data comparison_results_all];
    load SIDD_Dataexp2.mat
    exp2Data = [exp2Data comparison_results_all];
    disp('Converting Dataset 1 to table')
    [T11,T12,T13] = data2table(exp1Data);
    disp('Converting Dataset 2 to table')
    [T21,T22,T23] = data2table(exp2Data);
    createFigures(exp1Data,exp2Data);
end
function [T1, T2, T3] = data2table(data)
% Create tables from the data cell array
T1 = table();
T2 = table();
T3 = table();
n = length(data);
for i = 1:n
    % Get the name category from the name field
    name = data{i}.name;
    if contains(name, 'Set12')
        name = name(6:end);%Need to do this for each category to fix a mistake that is too late to fix now
        category = 'Set12';
    elseif contains(name, 'SIDD')
        name = name(5:end);
        category = 'SIDD';
    elseif contains(name, 'Cure-OR')
        % Get the category field from the name field
        name = name(8:end);
        category_field = split(name, '\');
        category_field = category_field{find(contains(category_field, 'Cure-OR')) + 1};
        category = ['Cure-OR-' category_field(14:end)];
    elseif contains(name, 'Cure-TSR')
        name = name(9:end);
        % Get the category field from the name field
        category_field = split(name, '\');
        category_field = category_field{find(contains(category_field, 'Cure-TSR')) + 1};
        category = ['Cure-TSR-' category_field(1:end-2)];
    else
        disp('Invalid name field')
    end
    
    % Add the data to the table
    try
        T = table(string(category), data{i}.ssim, data{i}.SUMMER, data{i}.psnr, data{i}.csv, data{i}.mslUNIQUE, data{i}.mslMSUNIQUE, data{i}.cwssim_index);
    catch
        T = slowTable(category,data{i});
    end
    T.Properties.VariableNames = {'Category', 'SSIM', 'SUMMER', 'PSNR', 'CSV', 'MSLUNIQUE', 'MSLMSUNIQUE', 'CWSSIM'};
    if contains(name, 'noTransform')
        T1 = [T1;T];
    elseif contains(name, 'Transformation1')
        T2 = [T2;T];
    elseif contains(name, 'Transformation2')
        T3 = [T3;T];

    end
    disp(i/n)
end

% Group the tables by category and calculate the average of each numeric field
T1 = varfun(@specMean, T1, 'GroupingVariables', 'Category');
T2 = varfun(@specMean, T2, 'GroupingVariables', 'Category');
T3 = varfun(@specMean, T3, 'GroupingVariables', 'Category');
end
function avg =  specMean(A)
avg =  mean(A(isfinite(A)),'omitnan');
end
function t = slowTable(cat,data)
    vals = {cat};
    for l = {'ssim','SUMMER','psnr','csv','mslUNIQUE','mslMSUNIQUE','cwssim_index'}
        try
            vals = [vals,data.(l{1})];
        catch
            vals = [vals,nan];

        end
    end
    t = cell2table(vals);
end