function [d3_max]...
    = CalculateWaveletFeatures_reduced(data,wave_n,wave_typ)

[c,l] = wavedec(data,wave_n,wave_typ);
reconstruct_3(:,1) = zscore(wrcoef('d',c,l,wave_typ,3));
[d3_max] = max(abs((reconstruct_3)));

