%
% (c) 2017 Alexei A. Morozov
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
% inImageCorners
% m-by-2, double matrix containing the x- and y-coordinates
% of defining points in physical space (in meters).
% outImageCorners
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
% inImageCorners=  [0,  6.715; 11.16, 6.70; 15.45, 1.90; 0,  0];
% outImageCorners= [64, 88;    211,   40;   349,   184;  39, 187];
%
inImageCorners=  [ 0,  0; 0.56,  0; 0.56, 0.30;  0, 0.30];
outImageCorners= [66, 98;  598, 64;  617,  418; 59,  426];
%
disp('X,Y co-ordinates of defining points in meters:');
disp(num2str(inImageCorners,' %0.4f'));
disp('X,Y co-ordinates of defining points in pixels:');
disp(num2str(outImageCorners,' %0.4f'));
%
hgte1= vision.GeometricTransformEstimator(...
	'Transform','Projective',...
	'AlgebraicDistanceThreshold',1,...
	'ExcludeOutliers',true);
	... 'ExcludeOutliers',false);
T= step(hgte1,inImageCorners,outImageCorners);
%
% Warning: The Computer Vision System Toolbox
% coordinate system changed. You invoked a
% function, System object, or block affected by the
% change. See R2011b Release Notes for details.
% > In cvstGetCoordsChoice at 64
%
disp('Projective transformation matrix:');
disp(num2str(T,' %0.4f'));
%
M= inv(T);
M= M ./ M(3,3);
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
	u= outImageCorners(n,1);
	v= outImageCorners(n,2);
	disp(['Expected: u=',num2str(u),' v=',num2str(v)]);
	x= inImageCorners(n,1);
	y= inImageCorners(n,2);
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
	x= inImageCorners(n,1);
	y= inImageCorners(n,2);
	disp(['Expected: x=',num2str(x),' y=',num2str(y)]);
	u= outImageCorners(n,1);
	v= outImageCorners(n,2);
	Q= M'*[u;v;1];
	Q= Q / Q(3);
	x= Q(1);
	y= Q(2);
	disp(['Obtained: x=',num2str(x),' y=',num2str(y)]);
end;
