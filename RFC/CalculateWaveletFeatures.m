function [d1_max,d2_max,d3_max,d4_max,idx_max_var]...
    = CalculateWaveletFeatures(data,wave_n,wave_typ)

[c,l] = wavedec(data,wave_n,wave_typ);

reconstruct_1(:,1) = zscore(wrcoef('d',c,l,wave_typ,1));
reconstruct_2(:,1) = zscore(wrcoef('d',c,l,wave_typ,2));
reconstruct_3(:,1) = zscore(wrcoef('d',c,l,wave_typ,3));
reconstruct_4(:,1) = zscore(wrcoef('d',c,l,wave_typ,4));

% detail coefficients
% d1_max = max(abs(reconstruct_1)); 
% [~,d1_max_idx] = max((reconstruct_1)); 
% [~,d1_min_idx] = min((reconstruct_1)); 
% d1_std = std(reconstruct_1);
% d1_mean = mean(reconstruct_1);
% d2_max = max(abs(reconstruct_2)); 
% [~,d2_max_idx] = max((reconstruct_2)); 
% [~,d2_min_idx] = min((reconstruct_2)); 
% d2_std = std(reconstruct_2);
% d2_mean = mean(reconstruct_2);
% d3_max = max(abs(reconstruct_3)); 
% [~,d3_max_idx] = max((reconstruct_3));  
% [~,d3_min_idx] = min((reconstruct_3)); 
% d3_std = std(reconstruct_3);
% d3_mean = mean(reconstruct_3);
% d4_max = max(abs(reconstruct_4));
% [~,d4_max_idx] = max((reconstruct_4)); 
% [~,d4_min_idx] = min((reconstruct_4)); 
% d4_std = std(reconstruct_4);
% d4_mean = mean(reconstruct_4);


[d1_max,d1_max_idx] = max(abs((reconstruct_1)));
[d2_max,d2_max_idx] = max(abs((reconstruct_2)));
[d3_max,d3_max_idx] = max(abs((reconstruct_3)));
[d4_max,d4_max_idx] = max(abs((reconstruct_4)));
idx_max_var = std([d1_max_idx,d2_max_idx,d3_max_idx,d4_max_idx])/128;
