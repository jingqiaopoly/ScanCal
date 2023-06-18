% merge the TC from the 4 target and the one on the wall

nT1=1;
nT2=4;
nScan = size(TCEall,2)/nT2;
TCEmerge = [];
for i=1:nScan
    TCEmerge = [TCEmerge TCEall(i*4-3:i*4)];
    TCEmerge = [TCEmerge TCEall1(i)];
end