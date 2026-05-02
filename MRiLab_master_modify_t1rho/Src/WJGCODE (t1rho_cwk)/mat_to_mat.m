VObj_reshape=VObj;
VObj_reshape.T2Star=VObj_reshape.T2Star*0.1;
VObj_reshape.T2=VObj_reshape.T2*0.1;
%VObj_reshape.WJG_ADC=VObj_reshape.WJG_ADC*0.001;
outputdir='/data3/cwk/ADC_template/ADC_template_test/';
filename=[outputdir,'7.mat'];
save(filename,'VObj_reshape');