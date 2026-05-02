%% read rf file from varian

filename = '/data3/wj/MRiLab/MRiLab_master_2019.10.19_degub_1/Src/WJGCODE/interface_varian/shapelib/SGLsinc.RF';
content = textread(filename,'%s','delimiter','\n');
for loopi = 1:length(content)
    temp_text = content{loopi};
    if findstr(temp_text,'STEPS')
        steps = str2num(temp_text(isstrprop(temp_text,'digit')))
    end    
end
dt = (tEnd-tStart)/steps;

start_idx = length(content)-steps;
rfAmp = zeros(length(content)-start_idx+1,1);
for loopi = start_idx:length(content)
    temp_rf  = str2num(content{loopi});
    temp_amp = temp_rf(2).*cos(temp_rf(1)/180*pi);
    rfAmp(loopi-start_idx+1) = temp_amp;    
end
