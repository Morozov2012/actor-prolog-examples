%
% (c) 2014 Alexei A. Morozov
%
% This Matlab script creates the inverse matrix of
% projective transformation to be used in Actor Prolog
% intelligent visual surveillance demos.
%
clc;
clear('all');
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
input_points= [0,  6.715; 11.16, 6.70; 15.45, 1.90; 0,  0];
base_points=  [64, 88;    211,   40;   349,   184;  39, 187];
%
%          Point (Col,Row) (pixels)  (X,Y) (meters)
%              a (453,250)           (9.13,-3.58)
%              b (416,317)           (9.26,-4.54)
%              c (63,327)            (3.48,-8.76)
%              d (44,155)            (-1.48,-2.90)
%              e (125,158)           (0,-2.53)
%              f (259,152)           (3.46,-1.20)
%              g (249,130)           (2.70,0)
%              h (158,113)           (0,0)
%
input_points= [9.13, -3.58; 9.26, -4.54; 3.48, -8.76; -1.48, -2.90; 0,   -2.53; 3.46, -1.20; 2.70, 0;   0,   0];
base_points=  [453,   250;  416,   317;  63,    327;   44,    155;  125,  158;  259,   152;  249,  130; 158, 113];
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
