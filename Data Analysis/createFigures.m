function createFigures(exp1,exp2)
control = exp1{1};
ex1 = exp1{2};
ex2 = exp1{3};
ex3 = exp2{2};
ex4 = exp2{3};
figure(1) 
control_set12 = control(strcmp(control.Category, "Set12"), :);
ex1_set12 = ex1(strcmp(ex1.Category, "Set12"), :);
ex2_set12 = ex2(strcmp(ex2.Category, "Set12"), :);
ex3_set12 = ex3(strcmp(ex3.Category, "Set12"), :);
ex4_set12 = ex4(strcmp(ex4.Category, "Set12"), :);


control_metrics = table2array(control_set12(:, 2:end));
ex1_metrics = table2array(ex1_set12(:, 2:end));
ex2_metrics = table2array(ex2_set12(:, 2:end));
ex3_metrics = table2array(ex3_set12(:, 2:end));
ex4_metrics = table2array(ex4_set12(:, 2:end));

control_metrics(:,3) = [];
ex1_metrics(:,3) = [];
ex2_metrics(:,3) = [];
ex3_metrics(:,3) = [];
ex4_metrics(:,3) = [];

bar(abs([control_metrics; ex1_metrics; ex2_metrics; ex3_metrics; ex4_metrics]), 'grouped');
xticklabels({'Control', 'Experiment 1', 'Experiment 2', 'Experiment 3', 'Experiment 4'});
legend({'SSIM', 'SUMMER', 'CSV', 'UNIQUE', 'MSUNIQUE', 'CWSSIM'},'Location','eastoutside');
ylabel('Metric Value');
title('Set12 Category Metrics');
figure(2)
control_sidd = control(strcmp(control.Category, "SIDD"), :);
    ex1_sidd = ex1(strcmp(ex1.Category, "SIDD"), :);
    ex2_sidd = ex2(strcmp(ex2.Category, "SIDD"), :);
    ex3_sidd = ex3(strcmp(ex3.Category, "SIDD"), :);
    ex4_sidd = ex4(strcmp(ex4.Category, "SIDD"), :);


    control_metrics = table2array(control_sidd(:, 2:end));
    ex1_metrics = table2array(ex1_sidd(:, 2:end));
    ex2_metrics = table2array(ex2_sidd(:, 2:end));
    ex3_metrics = table2array(ex3_sidd(:, 2:end));
    ex4_metrics = table2array(ex4_sidd(:, 2:end));


    bar(abs([control_metrics; ex1_metrics; ex2_metrics; ex3_metrics; ex4_metrics]'), 'grouped');
    legend({'SSIM', 'SUMMER', 'PSNR', 'CSV', 'UNIQUE', 'MSUNIQUE', 'CWSSIM'}, 'Location', 'northeast');
    xticklabels({'Control', 'Experiment 1', 'Experiment 2', 'Experiment 3', 'Experiment 4'});
    ylabel('Metric Value');
    title('SIDD Category Metrics');
    figure(3)
   control_cure_or = control(startsWith(control.Category, "Cure-OR") & ~contains(control.Category, "saltpepper"), :);
    ex1_cure_or = ex1(startsWith(ex1.Category, "Cure-OR") & ~contains(ex1.Category, "saltpepper"), :);
    ex2_cure_or = ex2(startsWith(ex2.Category, "Cure-OR") & ~contains(ex2.Category, "saltpepper"), :);
    ex3_cure_or = ex3(startsWith(ex3.Category, "Cure-OR") & ~contains(ex3.Category, "saltpepper"), :);
    ex4_cure_or = ex4(startsWith(ex4.Category, "Cure-OR") & ~contains(ex4.Category, "saltpepper"), :);


    control_ssim = table2array(control_cure_or(:, 2));
    ex1_ssim = table2array(ex1_cure_or(:, 2));
    ex2_ssim = table2array(ex2_cure_or(:, 2));
    ex3_ssim = table2array(ex3_cure_or(:, 2));
    ex4_ssim = table2array(ex4_cure_or(:, 2));


    subcategories = erase(string(control_cure_or.Category), "Cure-OR-");

    bar([control_ssim ex1_ssim ex2_ssim ex3_ssim ex4_ssim], 'grouped');
    legend({'Control', 'Experiment 1', 'Experiment 2', 'Experiment 3', 'Experiment 4'}, 'Location', 'north');
    xticklabels(subcategories);
    ylabel('SSIM Value');
    title('Cure-OR Subcategory Metrics');
    figure(4)
    control_cure_tsr = control(startsWith(control.Category, "Cure-TSR"), :);
    ex1_cure_tsr = ex1(startsWith(ex1.Category, "Cure-TSR"), :);
    ex2_cure_tsr = ex2(startsWith(ex2.Category, "Cure-TSR"), :);
    ex3_cure_tsr = ex3(startsWith(ex3.Category, "Cure-TSR"), :);
    ex4_cure_tsr = ex4(startsWith(ex4.Category, "Cure-TSR"), :);

    control_ssim = table2array(control_cure_tsr(:, 2));
    ex1_ssim = table2array(ex1_cure_tsr(:, 2));
    ex2_ssim = table2array(ex2_cure_tsr(:, 2));
    ex3_ssim = table2array(ex3_cure_tsr(:, 2));
    ex4_ssim = table2array(ex4_cure_tsr(:, 2));

    subcategories = erase(string(control_cure_tsr.Category), "Cure-TSR-");

    bar([control_ssim ex1_ssim ex2_ssim ex3_ssim ex4_ssim], 'grouped');
    legend({'Control', 'Experiment 1', 'Experiment 2', 'Experiment 3', 'Experiment 4'}, 'Location', 'north');
    xticklabels(subcategories);
    ylabel('SSIM Value');
    title('Cure-TSR Subcategory Metrics');
end

