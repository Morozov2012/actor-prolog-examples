%
% (c) 2016 Alexei A. Morozov
%
% This Matlab script creates the inverse matrix of
% projective transformation and reconstructs source
% image of given scene.
%
clc;
close('all');
clear('all');
%
InputImage= '00000001.png';
%
disp(['Input image: ',InputImage]);
%
% Input data:
%
% input_points
% m-by-2, double matrix containing the x- and y-coordinates
% of defining points in physical space (in meters).
% base_points
% m-by-2, double matrix containing the x- and y-coordinates
% of defining points in the video (in pixels).
%
%      For instance:
%          Point (Col,Row) (pixels)  (X,Y) (meters)
%              1 (64,88)             (0,6.715)
%              2 (211,40)            (11.16,6.70)
%              3 (349,184)           (15.45,1.90)
%              4 (39,187)            (0,0)
%
% input_points= [0,  6.715; 11.16, 6.70; 15.45, 1.90; 0,  0];
% base_points=  [64, 88;    211,   40;   349,   184;  39, 187];
%
unit= 0.60; % [meters]
%
input_points= [...
	0*unit,  0*unit; ...
	0*unit,  2*unit; ...
	1*unit,  2*unit; ...
	2*unit,  5*unit; ...
	3*unit,  5*unit; ...
	2*unit,  1*unit; ...
	3*unit,  2*unit; ...
	4*unit,  1*unit; ...
	3*unit,  0*unit; ...
	3*unit, -1*unit; ...
	2*unit,  0*unit; ...
	1*unit,  0*unit ...
	];
base_points= [...
	133.50,	381.50; ...
	154.00,	292.00; ...
	217.00,	287.00; ...
	252.00,	225.50; ...
	291.50,	223.50; ...
	292.00,	315.00; ...
	335.00,	277.00; ...
	423.50,	302.50; ...
	395.00,	352.00; ...
	443.50,	413.50; ...
	313.00,	362.50; ...
	226.00,	372.00 ...
	];
%
ExpectedMinimalX= -2; % [meters]
ExpectedMaximalX=  3; % [meters]
ExpectedMinimalY= -1; % [meter]
ExpectedMaximalY= 10; % [meters]
%
disp(['Expected minimal X: ',num2str(ExpectedMinimalX),' [m]']);
disp(['Expected maximal X: ',num2str(ExpectedMaximalX),' [m]']);
disp(['Expected minimal Y: ',num2str(ExpectedMinimalY),' [m]']);
disp(['Expected maximal Y: ',num2str(ExpectedMaximalY),' [m]']);
%
disp('X,Y co-ordinates of defining points in meters:');
disp(num2str(input_points,' %0.4f'));
disp('X,Y co-ordinates of defining points in pixels:');
disp(num2str(base_points,' %0.4f'));
%
t_proj= cp2tform(input_points,base_points,'projective');
T= t_proj.tdata.T;
M= t_proj.tdata.Tinv;
%
disp('Projective transformation matrix:');
disp(num2str(T,' %0.4f'));
%
disp('Inverse matrix of projective transformation:');
disp(num2str(M,' %0.4f'));
disp('This matrix is to be used in the demos.');
%
disp('=======================================');
disp('Self-check (1): Image -> Physical space');
disp('=======================================');
%
for n=1:4,
	u= base_points(n,1);
	v= base_points(n,2);
	disp(['Expected: u=',num2str(u),' v=',num2str(v)]);
	x= input_points(n,1);
	y= input_points(n,2);
	Q= T'*[x;y;1];
	Q= Q / Q(3);
	u= Q(1);
	v= Q(2);
	disp(['Obtained: u=',num2str(u),' v=',num2str(v)]);
end;
%
disp('=======================================');
disp('Self-check (2): Physical space -> Image');
disp('=======================================');
%
for n=1:4,
	x= input_points(n,1);
	y= input_points(n,2);
	disp(['Expected: x=',num2str(x),' y=',num2str(y)]);
	u= base_points(n,1);
	v= base_points(n,2);
	Q= M'*[u;v;1];
	Q= Q / Q(3);
	x= Q(1);
	y= Q(2);
	disp(['Obtained: x=',num2str(x),' y=',num2str(y)]);
end;
%
disp('=======================================');
disp('Read and display input image');
disp('=======================================');
%
Iin= imread(InputImage);
%
Fig= 1001;
figure(Fig);
set(figure(Fig),'Color',[1,1,1]);
set(figure(Fig),'NumberTitle','off');
set(figure(Fig),'name',['Transformed image: ',InputImage]);
%
imshow(Iin);
%
title(	['Transformed image: ',InputImage],...
	'FontName','Arial',...
	'FontSize',18,...
	'FontWeight','bold',...
	'interpreter','none');
set(gca,'FontName','Arial');
set(gca,'FontSize',18);
set(gca,'FontWeight','bold');
%
disp('=======================================');
disp('Reconstruct and display source image');
disp('=======================================');
%
Matrix= im2double(Iin);
[Height,Width,N3]= size(Matrix);
%
W= zeros(Height,Width);
H= zeros(Height,Width);
%
for n=1:Width,
	for m=1:Height;
		Vector1= [n;m;1];
		Vector2= M'*Vector1;
		Vector3= Vector2 / Vector2(3);
		W(m,n)= Vector3(1);
		H(m,n)= Vector3(2);
	end;
end;
%
for n=1:Width,
	for m=1:Height;
		V1= W(m,n);
		V2= H(m,n);
		if V1 < ExpectedMinimalX,
			V1= ExpectedMinimalX;
		end;
		if V1 > ExpectedMaximalX,
			V1= ExpectedMaximalX;
		end;
		if V2 < ExpectedMinimalY,
			V2= ExpectedMinimalY;
		end;
		if V2 > ExpectedMaximalY,
			V2= ExpectedMaximalY;
		end;
		W(m,n)= V1;
		H(m,n)= V2;
	end;
end;
%
MinW= min(min(W));
MaxW= max(max(W));
MinH= min(min(H));
MaxH= max(max(H));
%
W= (W - MinW) ./ (MaxW - MinW) * (Width - 1) + 1;
H= (H - MinH) ./ (MaxH - MinH) * (Height - 1) + 1;
%
D= zeros(Height,Width,N3);
%
for n=1:Width,
	for m=1:Height;
		M1= round(H(m,n));
		if M1 < 1 || M1 > Height,
			continue;
		end;
		N1= round(W(m,n));
		if N1 < 1 || N1 > Width,
			continue;
		end;
		D(M1,N1,:)= Matrix(m,n,:);
	end;
end;
%
output= D;
%
Fig= 1002;
figure(Fig);
set(figure(Fig),'Color',[1,1,1]);
set(figure(Fig),'NumberTitle','off');
set(figure(Fig),'name','Reconstructed image');
%
imshow(output);
%
title(	'Reconstructed image',...
	'FontName','Arial',...
	'FontSize',18,...
	'FontWeight','bold',...
	'interpreter','none');
set(gca,'FontName','Arial');
set(gca,'FontSize',18);
set(gca,'FontWeight','bold');
%
imwrite(output,'reconstructed.png','png');
