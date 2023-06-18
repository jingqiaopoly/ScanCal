% Plot C2M distance
%fileID = fopen('H:\Bonn\Faro\Scan_002_1001.ply','r');
fileID = fopen('H:\Bonn\RTC360\wall\03_S3withS1.ply','r');
limt = 0.004;


C = textscan(fileID, '%f%f%f%f%f', 'MultipleDelimsAsOne',true, 'Delimiter',' ', 'HeaderLines',12);
  %C = textscan(fileID, '%f%f%f%f%f%f%f%f%f', 'MultipleDelimsAsOne',true, 'Delimiter',' ', 'HeaderLines',16);
fclose(fileID);

x = C{1};
y = C{2};
z = C{3};
dis = C{4};
  %dis = C{9};
clear C
dis(dis<-1*limt) = -1*limt;
dis(dis>limt) = limt;

figure;
colormap jet
scatter3(x,y,z,1.5,dis);
clear x y z 
axis equal
view([90 0])
cb = colorbar('southoutside');
a = get(cb);
pos = a.Position;
set(cb,'Position',[pos(1) pos(2)+0.16,pos(3),pos(4)/2])
set(gca,'FontSize',25)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fileID = fopen('I:\Bonn\Faro\Scan_002_1001.ply','r');
limt = 0.006;
C = textscan(fileID, '%f%f%f%f%f', 'MultipleDelimsAsOne',true, 'Delimiter',' ', 'HeaderLines',12);
  %C = textscan(fileID, '%f%f%f%f%f%f%f%f%f', 'MultipleDelimsAsOne',true, 'Delimiter',' ', 'HeaderLines',16);
fclose(fileID);

x = C{1};
y = C{2};
z = C{3};
dis = C{4};
  %dis = C{9};
clear C
dis(dis<-1*limt) = -1*limt;
dis(dis>limt) = limt;

figure;
colormap jet
scatter3(x,y,z,1.5,dis);
clear x y z 
axis equal
view([90 0])
cb = colorbar('southoutside');
a = get(cb);
pos = a.Position;
set(cb,'Position',[pos(1) pos(2)+0.16,pos(3),pos(4)/2])
set(gca,'FontSize',25)