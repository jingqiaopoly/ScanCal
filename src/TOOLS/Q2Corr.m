function [C,qii]=Q2Corr(Q);

% function [C,VF]=Q2Corr(V)
% 
% Calculate correlation matrix from cofactor matrix.
%
% input parameters:
%    V           [nxn] cofactor matrix
%
% output parameters:
%    C           [nxn] correlation matrix
%    VF          [nx1] variance factors (diagonal of V)
% ---------------------------------------------------------------

% Category:    Adjustment
% Description: Compute correlation matrix

% extract non-zero entries from sparse matrix
n=size(Q,1);
[row,col,qrc]=find(Q);

% separate diagonal and non-diagonal elements
j=find(~(row-col));
qii=zeros(n,1);
ii=row(j);
qii(ii)=qrc(j);
row(j)=[];
col(j)=[];
qrc(j)=[];

% calculate correlation coefficient for all
% non diagonal elements
j=1:length(row);
r=qrc(j)./sqrt(qii(row(j)).*qii(col(j)));

% compose correlation matrix
C=sparse([row(:);(1:n)'],[col(:);(1:n)'],[r(:);ones(n,1)]);

% 'desparse' vector of variance factors
qii=reshape(full(qii),[],1);


