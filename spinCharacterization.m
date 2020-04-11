function wmaxmat = spinCharacterization(fileName)
% measure rotational velocity from optical intensity reading

radd = 45; % rad to the filter, in mm
expTime = 1/(637/0.105); % imaging exp time
rawdata = readtable(fileName,'Delimiter','\t');
rawdataMat = table2array(rawdata(:,2));
%% preprocess raw data
pdata = rawdataMat > 1000;
xdata = [1:numel(pdata)]*expTime;
%% peak detection
[pks,locs] = findpeaks(double(pdata));
%% find peaks and measure the speed
spinTime = locs(1:1:end-1)*expTime;
spinDuration = diff(spinTime);
% 1.12  x  R  x  (RPM/1000)©÷
rpmm = (1./spinDuration)*60;
angularVelocity= rpmm.*(2*pi)/60; 
wmaxmat(bidx) = max(angularVelocity);
