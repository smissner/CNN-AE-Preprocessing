function ProjectMain()
    process_datasets(fullfile(pwd,'Datasets'))
end
function process_datasets(root_directory)
    % Define the list of datasets and their corresponding processing functions
    datasets = containers.Map({'Cure-TSR', 'SIDD', 'Set12','Cure-OR'}, ...
                              {@process_TSR_images, @process_SIDD_images, ...
                               @process_Set12_images, @process_OR_images});

    % Iterate over each dataset
    k = 1;
    for i ={'Set12','Cure-TSR','Cure-OR','SIDD'} 
        dataset = i{1};
        process_function = datasets(dataset);

        % Construct the path to the dataset folder
        dataset_folder = fullfile(root_directory, dataset);

        % Call the corresponding processing function with the path to the dataset folder
        process_function(dataset_folder);
        fprintf('%s Finished\n', dataset);
        figure(k)
        plot([1,2,3],[1,2,3])
        k = k+1;
    end
end
function comparison_results_all = compare(reference_image_path, challenge_image_path, Dataset)
    % Read the images
    reference_image = (imread(reference_image_path));
    challenge_image = (imread(challenge_image_path));
  %  if(strcmp(Dataset,'SIDD'))
   %     reference_image = imresize(reference_image,.2);
    %    challenge_image = imresize(challenge_image,.2);
    %end
    if(size(reference_image) ~= size(challenge_image))
        challenge_image = imresize(challenge_image,size(reference_image));
    end
    if(ndims(reference_image)<3)
        temp = zeros(size(reference_image,1),size(reference_image,2),3);
        temp(:,:,1) = reference_image;
        temp(:,:,2) = temp(:,:,1);
        temp(:,:,3) = temp(:,:,1);
        reference_image = temp;
        temp(:,:,1) = challenge_image;
        temp(:,:,2) = temp(:,:,1);
        temp(:,:,3) = temp(:,:,1);
        challenge_image = temp;
    end
    

    reference_image = im2double(reference_image);
    challenge_image = im2double(challenge_image); 
    % Apply transformations to the challenge image
    challenge_image_transformation1 = transformation1(challenge_image);
    challenge_image_transformation2 = transformation2(challenge_image);

    % Define the list of images to compare
    images_to_compare = {
        challenge_image, '_noTransform';
        challenge_image_transformation1, '_Transformation1';
        challenge_image_transformation2, '_Transformation2'
    };

    % Define the list of comparison functions
    comparison_functions = {@psnr, @ssim, @SUMMER, @csv, @mslUNIQUE, @mslMSUNIQUE,@cwssim_index};

    % Initialize a global dictionary to store the comparison results
    comparison_results_all = {};

    % Iterate over each image to compare
    for i = 1:size(images_to_compare, 1)
        % Initialize a dictionary to store the comparison results
        comparison_results = struct('name', strcat(Dataset, challenge_image_path, images_to_compare{i, 2}));

        % Apply each comparison function to the reference image and the current image
        for j = 1:length(comparison_functions)
            
                try
                    if(strcmp(func2str(comparison_functions{j}),'cwssim_index'))
                        comparison_results.(func2str(comparison_functions{j})) = comparison_functions{j}(im2gray(reference_image), im2gray(images_to_compare{i, 1}),1,1,0,0);
                    else
                        if(strcmp(func2str(comparison_functions{j}),'psnr') ||strcmp(func2str(comparison_functions{j}),'ssim'))
                        comparison_results.(func2str(comparison_functions{j})) = comparison_functions{j}(images_to_compare{i, 1}, reference_image);
                        else
                        comparison_results.(func2str(comparison_functions{j})) = comparison_functions{j}(reference_image, images_to_compare{i, 1});
                            % Add the comparison results to the global dictionary
                        end
                    end
                catch exc
                    %disp(getReport(exc))
                    continue
                end
        end
        comparison_results_all = [comparison_results_all comparison_results];
    end
end
function process_SIDD_images(directory)
    % Get all subfolders and files in the directory
        files = dir(fullfile(directory,'**', '*.png'));
        % Collect each "GT"/"NOISY" image pair as a filepath
        comparison_results_all = {};
        parfor j = 1:length(files)
            file = fullfile(files(j).folder,files(j).name);
            if contains(file, '_GT_')
                NOISYimage = strrep(file, '_GT_', '_NOISY_');
                % Put their file paths into a function called compare
                comparison_result = compare(file, NOISYimage, 'SIDD');
                comparison_results_all = [comparison_results_all comparison_result];

            end
        end
        save SIDD_Data.mat comparison_results_all
end
%{
function comparison_results_all = process_OR_images(directory_path)
    % Get all .jpg files in the directory and its subdirectories
    files = dir(fullfile(directory_path, '**', '*.jpg'));
    % Get all reference images
    ref_path = fullfile(directory_path, '10_grayscale_no_challenge');
    ref_files = dir(fullfile(ref_path,'**', '*.jpg'));
    % Initialize the comparison_results_all cell array
    comparison_results_all = {};
    % Loop throua a =aaaaabifejkgnjsdjkfsedjkfnwdgh each file
    for i = 1:length(files)
        % Check if the file is a challenge image
        if contains(files(i).name, '_')
            % Get the reference image path
            ref_image_name = [files(i).name(1:strfind(files(i).name, '_objectID_')+8), '10_0.jpg'];
            ref_image_path = fullfile(ref_files.folder, ref_image_name);
            % Get the challenge image path
            challenge_image_path = fullfile(files(i).folder, files(i).name);
            % Call the compare function
            comparison_result = compare(ref_image_path, challenge_image_path, 'OR');
            % Append the comparison_result to the comparison_results_all cell array
            comparison_results_all = [comparison_results_all comparison_result];
        end
    end
end 
%}
function process_OR_images(root_folder)
    challenge_free_folder = fullfile(root_folder, '10_grayscale_no_challenge');
    other_folders = dir(root_folder);
    other_folders = other_folders([other_folders.isdir]);
    other_folders = other_folders(~ismember({other_folders.name},{'.','..','10_grayscale_no_challenge'}));
    other_folders = {other_folders.name};

    % Initialize an empty struct to store the comparison results
    comparison_results_all = {};

    % Loop over each folder in the root folder
    parfor i = 1:numel(other_folders)
        folder = fullfile(root_folder, other_folders{i});
        files = dir(fullfile(folder,'**', '*.jpg'));
        n = numel(files);
        for j = 1:20:n
            filename = files(j).name;
            index = strsplit(filename, '_');
            index = [index{1} '_' index{2} '_' index{3} '_' index{4}];
            challenge_free_file = dir(fullfile(challenge_free_folder, '**',[index '_*']));
            if ~isempty(challenge_free_file)
                % Call the compare function and store the result in the struct
                comparison_result = compare(fullfile(challenge_free_file.folder, challenge_free_file.name), fullfile(files(j).folder, filename), 'Cure_OR');
                comparison_results_all = [comparison_results_all comparison_result];
            end
            disp(j/n)
        end
        disp(i)
    end
    save OR_Data.mat comparison_results_all

end
function process_Set12_images(root_folder)
    files = dir(fullfile(root_folder,'*.png'));
    compResultsall = {};
    for i = 1:numel(files)
        filename = files(i).name;
        compans = compare(fullfile(root_folder, filename), fullfile(root_folder, filename), 'Set12');
        compResultsall = [compResultsall compans];
    end
    save set12_Data.mat compResultsall
    disp('Set 12 Finished');
end
function process_TSR_images(root_folder)
    challenge_free_folder = fullfile(root_folder, 'ChallengeFree');
    other_folders = dir(root_folder);
    other_folders = other_folders([other_folders.isdir]);
    other_folders = other_folders(~ismember({other_folders.name},{'.','..','ChallengeFree'}));
    other_folders = {other_folders.name};

    % Initialize an empty struct to store the comparison results
    comparison_results_all = {};

    % Loop over each folder in the root folder
    parfor i = 1:numel(other_folders)
        folder = fullfile(root_folder, other_folders{i});
        files = dir(fullfile(folder, '*.bmp'));
        n = numel(files);
        for j = 1:n
            filename = files(j).name;
            index = strsplit(filename, '_');
            index = index{end};
            challenge_free_file = dir(fullfile(challenge_free_folder, ['*_' index]));
            if ~isempty(challenge_free_file)
                challenge_free_file = challenge_free_file.name;
                % Call the compare function and store the result in the struct
                comparison_result = compare(fullfile(challenge_free_folder, challenge_free_file), fullfile(folder, filename), 'Cure_TSR');
                comparison_results_all = [comparison_results_all comparison_result];
            end
            disp(j/n)
        end
        disp(i)
    end
    save TSR_Data.mat comparison_results_all
end
function out = transformation1(image)
    image = medfilt3(image,[3,3,1]);
    order = 1-log(mean(image(:))/median(image(:)));
    out = ctrHarmFilt(image,[3,3],order);
end
function out = transformation2(image)
    out = ctrHarmFilt(image,[3,3],-1.5);
    out = ctrHarmFilt(out,[3,3],1.5);
end