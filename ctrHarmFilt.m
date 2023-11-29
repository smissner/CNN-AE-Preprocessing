
function [new_image] = ctrHarmFilt(image_matrix, block_size, order)
    switch nargin
        case 1
            block_size = [3,3];
            order = 1-log(mean(image_matrix(:))/median(image_matrix(:)));
        case 2
            order = 1-log(mean(image_matrix(:))/median(image_matrix(:)));


     end
    if(ndims(image_matrix)>2)
        new_image = zeros(size(image_matrix));
        new_image(:,:,1) = ctrHarmFilt(image_matrix(:,:,1),block_size,order);
        new_image(:,:,2) = ctrHarmFilt(image_matrix(:,:,2),block_size,order);
        new_image(:,:,3) = ctrHarmFilt(image_matrix(:,:,3),block_size,order);
    end
    % Create a padded version of the image matrix
    padded_image = im2double(padarray(image_matrix, [block_size(1), block_size(2)], 'replicate'));
    % Create a block filter
    filter = 1/9 * ones(block_size(1), block_size(2));
    % Calculate the sum of surrounding elements to the power of order + 1
    sum_surrounding = convn((padded_image .^ (order + 1)), filter, 'same');
    % Calculate the sum of surrounding elements to the power of order
    sum_surrounding_order = convn(padded_image .^ order, filter, 'same');
    % Replace the value with the ratio of the two sums
    new_image = sum_surrounding ./ (sum_surrounding_order+.00000001);
    % Remove the padding
    new_image = new_image(block_size(1) + 1:end - block_size(1), block_size(2) + 1:end - block_size(2), :);
end
