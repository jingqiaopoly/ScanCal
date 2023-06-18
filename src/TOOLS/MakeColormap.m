function C = MakeColormap( W );

% C = MakeColormap( W )
%
% W = [w1 R1 G1 B1;w2 R2 G2 B2; ...; wn Rn Gn Bn];
%
% Berechnet eine Lookup Tabelle, die eine Farbverlauf
% von (R1,G1,B1) über (R2,G2,B2), ... bis (Rn,Gn,Bn),
% so codiert, daß das Werteintervall [w1,wn] farbcodiert
% dargestellt werden kann, wobei bei den angegebenen
% Werten wi genau die Farben (Ri,Gi,Bi) auftreten.
%
% C enthält 256 Einträge
% ----------------------------------------------------------------

% Category:    Plotten
% Description: Erzeugen einer Lookup-Tabelle mit Farbverlauf, die 
% Description: bestimmten Funktionswerten betimmte Farben zuordnet.



% --------------> Übergebene Matrix prüfen:
I = size(W);

if I(1,2) ~= 4
   error 'Übergebene Matrix muß zeilenweise die Werte, sowie R,G und B enthalten!'
end
if I(1,1) < 1
   error 'Es muß eine Matrix übergeben werden, die zeilenweise die Werte, sowie R,G und B enthält!'
end

if or(max(max(W(:,2:4))) > 1.0, min(min(W(:,2:4))) < 0.0)
   error 'Die RGB-Werte müssen aus dem Intervall [0,1] sein!'
end
% <-------------- Matrix ist in Ordnung

I = size(W);
I = I(1,1);

% --------------> falls nur ein Wert übergeben wurde, Farbe einsetzen
if I == 1
   C = [W(1,2)*ones(256,1) W(1,3)*ones(256,1) W(1,4)*ones(256,1)];
   return
end

% Werte aufsteigend sortieren
W = sortrows(W,1);

% gesamten Wertebereich ermitteln:
f1 = W(1,1);
fn = W(I,1);
df = fn-f1;
dg = df/255;

% --------------> ersten Eintrag machen
J = 0;
C = [W(1,2) W(1,3) W(1,4)];

% --------------> Intervalle bearbeiten
for i=2:I
	g1 = J;
	g2 = floor((W(i,1)-f1)/dg);
	n = g2-g1;

	R1 = W(i-1,2);
	G1 = W(i-1,3);
	B1 = W(i-1,4);
	R2 = W(i,2);
	G2 = W(i,3);
	B2 = W(i,4);

	dR = (R2-R1)/n;
	dG = (G2-G1)/n;
	dB = (B2-B1)/n;

	if dR ~= 0 
	   R = ((R1+dR):dR:R2)';
	else
	   R = R1*ones(n,1);
	end
	if dG ~= 0 
	   G = ((G1+dG):dG:G2)';
	else
	   G = G1*ones(n,1);
	end
	if dB ~= 0 
   	B = ((B1+dB):dB:B2)';
	else
   	B = B1*ones(n,1);
	end

	C = [C;R G B];
	J = J + n;
end