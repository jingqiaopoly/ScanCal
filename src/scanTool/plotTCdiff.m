% Plot TC difference
index_r = [];%[2 8];
valueBar = [];
load('J:\Bonn\Faro\Targets\Calibration\s12345678Cali\TC56.mat');% J:\Bonn\ZF\Export_SOCS\targets\setFace34\PP  J:\Bonn\RTC360\RAW\Targets\setFace56\TC.mat
dRHV(2:3,:) = rad2sec(dRHV(2:3,:));
dRHV = abs(dRHV);
dRHV(:,index_r) =NaN;
offset = vecnorm(dXYZ,1);
offset(index_r) =NaN;
valueBar = [valueBar; dRHV];

x= [1:14];
% x(index_r) =NaN;
figure(1); clf;
subplot(1,3,1);
plot(x,dRHV(1,:),'rx-')
subplot(1,3,2);
plot(x,dRHV(2,:),'rx-')
subplot(1,3,3);
plot(x,dRHV(3,:),'rx-')
figure(2);clf;
plot(x,offset,'ro-');


load('J:\Bonn\Faro\Targets\Calibration\s12345678Cali\PP56.mat');
dRHV(2:3,:) = rad2sec(dRHV(2:3,:));
dRHV = abs(dRHV);
dRHV(:,index_r) =NaN;
offset = vecnorm(dXYZ,1);
offset(index_r) =NaN;
valueBar = [valueBar; dRHV];
figure(1);
subplot(1,3,1);
hold on
plot(x,dRHV(1,:),'g*-')
subplot(1,3,2);
hold on
plot(x,dRHV(2,:),'g*-')
subplot(1,3,3);
hold on
plot(x,dRHV(3,:),'g*-')
figure(2); 
hold on
plot(x,offset,'g*-');

load('J:\Bonn\ZF\Export_SOCS\targets\setFace34\PP.mat');
dRHV(2:3,:) = rad2sec(dRHV(2:3,:));
dRHV = abs(dRHV);
dRHV(:,index_r) =NaN;
offset = vecnorm(dXYZ,1);
offset(index_r) =NaN;
valueBar = [valueBar; dRHV];
figure(1);
subplot(1,3,1);
hold on
plot(x,dRHV(1,:),'bs-')
ylim([0 0.2])
subplot(1,3,2);
ylim([0 150])
hold on
plot(x,dRHV(2,:),'bs-')
subplot(1,3,3);
ylim([0 150])
hold on
plot(x,dRHV(3,:),'bs-')
figure(2); 
hold on
plot(x,offset,'bs-');

% Bar plot
figure(3); clf
Rbar = [valueBar(1,:);valueBar(4,:);valueBar(7,:)]';
Hbar = [valueBar(2,:);valueBar(5,:);valueBar(8,:)]';
Vbar = [valueBar(3,:);valueBar(6,:);valueBar(9,:)]';
subplot(1,3,1)
b= bar(Rbar);
n = size(Rbar,1);
b(1).FaceColor = 'r'; b(1).EdgeColor = 'r';
b(2).FaceColor = 'g'; b(2).EdgeColor = 'g';
b(3).FaceColor = 'b'; b(3).EdgeColor = 'b';
xlabel('target ID');
ylabel('dRang (mm)')
% ylim([0 0.2])
subplot(1,3,2)
b= bar(Hbar);
b(1).FaceColor = 'r'; b(1).EdgeColor = 'r';
b(2).FaceColor = 'g'; b(2).EdgeColor = 'g';
b(3).FaceColor = 'b'; b(3).EdgeColor = 'b';
xlabel('target ID');
ylabel('dAZ ('''')')
% ylim([0 20])
subplot(1,3,3)
b= bar(Vbar);
b(1).FaceColor = 'r'; b(1).EdgeColor = 'r';
b(2).FaceColor = 'g'; b(2).EdgeColor = 'g';
b(3).FaceColor = 'b'; b(3).EdgeColor = 'b';
xlabel('target ID');
ylabel('dEL ('''')')
% ylim([0 20])
legend('Target','Feature','Plane')





load('J:\Bonn\RTC360\RAW\Targets\setFace56\Raw.mat');
dRHV(2:3,:) = rad2sec(dRHV(2:3,:));
dRHV = abs(dRHV);
dRHV(:,index_r) =NaN;
offset = vecnorm(dXYZ,1);
offset(index_r) =NaN;
figure(1);clf;
subplot(1,3,1);
hold on
plot(x,dRHV(1,:),'mo-')
ylim([0 0.2])
subplot(1,3,2);
ylim([0 150])
hold on
plot(x,dRHV(2,:),'mo-')
subplot(1,3,3);
ylim([0 150])
hold on
plot(x,dRHV(3,:),'mo-')
figure(2); 
hold on
plot(x,offset,'mo-');