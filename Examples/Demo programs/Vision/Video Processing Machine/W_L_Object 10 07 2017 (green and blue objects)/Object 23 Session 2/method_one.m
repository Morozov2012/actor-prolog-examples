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
% L1 - this is a matrix containing X,Y co-ordinates of
%      selected defining points in physical space (in meters).
% L2 - this matrix contains X,Y co-ordinates of the same
%      defining points in the video (in pixels).
%
%      For instance:
%          Point (Col,Row) (pixels)  (X,Y) (meters)
%              1 (64,88)             (0,6.715)
%              2 (211,40)            (11.16,6.70)
%              3 (349,184)           (15.45,1.90)
%              4 (39,187)            (0,0)
%
% L1= [0,  6.715, 1; 11.16, 6.70, 1; 15.45, 1.90, 1; 0,  0,   1];
% L2= [64, 88,    1; 211,   40,   1; 349,   184,  1; 39, 187, 1];
%
L1= [ 0,  0; 0.56,  0; 0.56, 0.30;  0, 0.30];
L2= [56, 84;  589, 85;  597,  434; 46,  418];
%
disp('X,Y co-ordinates of defining points in meters:');
disp(num2str(L1,' %0.4f'));
disp('X,Y co-ordinates of defining points in pixels:');
disp(num2str(L2,' %0.4f'));
%
% u = (Ax + By + C)/(Gx + Hy + I)
% v = (Dx + Ey + F)/(Gx + Hy + I)
%
% Assume I = 1, multiply both equations, by denominator:
%
% u = [x y 1 0 0 0 -ux -uy] * [A B C D E F G H]'
% v = [0 0 0 x y 1 -vx -vy] * [A B C D E F G H]'
%
% With 4 or more correspondence points we can combine the u equations and
% the v equations for one linear system to solve for [A B C D E F G H]:
%
x1= L1(1,1);
x2= L1(2,1);
x3= L1(3,1);
x4= L1(4,1);
%
y1= L1(1,2);
y2= L1(2,2);
y3= L1(3,2);
y4= L1(4,2);
%
u1= L2(1,1);
u2= L2(2,1);
u3= L2(3,1);
u4= L2(4,1);
%
v1= L2(1,2);
v2= L2(2,2);
v3= L2(3,2);
v4= L2(4,2);
%
% [ u1  ] = [ x1  y1  1  0   0   0  -u1*x1  -u1*y1 ] * [A]
% [ u2  ] = [ x2  y2  1  0   0   0  -u2*x2  -u2*y2 ]   [B]
% [ u3  ] = [ x3  y3  1  0   0   0  -u3*x3  -u3*y3 ]   [C]
% [ u1  ] = [ x4  y4  1  0   0   0  -u4*x4  -u4*y4 ]   [D]
% [ ... ]   [ ...                                  ]   [E]
% [ un  ] = [ xn  yn  1  0   0   0  -un*xn  -un*yn ]   [F]
% [ v1  ] = [ 0   0   0  x1  y1  1  -v1*x1  -v1*y1 ]   [G]
% [ v2  ] = [ 0   0   0  x2  y2  1  -v2*x2  -v2*y2 ]   [H]
% [ v3  ] = [ 0   0   0  x3  y3  1  -v3*x3  -v3*y3 ]
% [ v4  ] = [ 0   0   0  x4  y4  1  -v4*x4  -v4*y4 ]
% [ ... ]   [ ...                                  ]
% [ vn  ] = [ 0   0   0  xn  yn  1  -vn*xn  -vn*yn ]
%
% Or rewriting the above matrix equation:
% U = X * Tvec, where Tvec = [A B C D E F G H]'
% so Tvec = X\U.
%
U= [u1;u2;u3;u4;v1;v2;v3;v4];
X= [	[ x1,  y1,  1,   0,   0,  0,  -u1*x1,  -u1*y1 ];
	[ x2,  y2,  1,   0,   0,  0,  -u2*x2,  -u2*y2 ];
	[ x3,  y3,  1,   0,   0,  0,  -u3*x3,  -u3*y3 ];
	[ x4,  y4,  1,   0,   0,  0,  -u4*x4,  -u4*y4 ];
	[  0,   0,  0,  x1,  y1,  1,  -v1*x1,  -v1*y1 ];
	[  0,   0,  0,  x2,  y2,  1,  -v2*x2,  -v2*y2 ];
	[  0,   0,  0,  x3,  y3,  1,  -v3*x3,  -v3*y3 ];
	[  0,   0,  0,  x4,  y4,  1,  -v4*x4,  -v4*y4 ]	];
%
Tvec= X \ U;
%
A= Tvec(1);
B= Tvec(2);
C= Tvec(3);
D= Tvec(4);
E= Tvec(5);
F= Tvec(6);
G= Tvec(7);
H= Tvec(8);
%
I= 1;
%
T= [	[ A, D, G ];
	[ B, E, H ];
	[ C, F, I ]	];
%
disp('Projective transformation matrix:');
disp(num2str(T,' %0.4f'));
%
M= inv(T);
%
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
	u= L2(n,1);
	v= L2(n,2);
	disp(['Expected: u=',num2str(u),' v=',num2str(v)]);
	x= L1(n,1);
	y= L1(n,2);
	u= (A*x + B*y + C) / (G*x + H*y + I);
	v= (D*x + E*y + F) / (G*x + H*y + I);
	disp(['Obtained: u=',num2str(u),' v=',num2str(v)]);
end;
%
disp('=======================================');
disp('Self-check (2): Image -> Physical space');
disp('=======================================');
%
for n=1:4,
	u= L2(n,1);
	v= L2(n,2);
	disp(['Expected: u=',num2str(u),' v=',num2str(v)]);
	x= L1(n,1);
	y= L1(n,2);
	Q= T'*[x;y;1];
	Q= Q / Q(3);
	u= Q(1);
	v= Q(2);
	disp(['Obtained: u=',num2str(u),' v=',num2str(v)]);
end;
%
disp('=======================================');
disp('Self-check (3): Physical space -> Image');
disp('=======================================');
%
for n=1:4,
	x= L1(n,1);
	y= L1(n,2);
	disp(['Expected: x=',num2str(x),' y=',num2str(y)]);
	u= L2(n,1);
	v= L2(n,2);
	Q= M'*[u;v;1];
	Q= Q / Q(3);
	x= Q(1);
	y= Q(2);
	disp(['Obtained: x=',num2str(x),' y=',num2str(y)]);
end;
