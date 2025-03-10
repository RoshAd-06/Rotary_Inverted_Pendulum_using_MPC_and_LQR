function inverted_pendulum()
m1 = 0.8; % mass of rod
m2 = 1; % mass of pendulum
m3 = 0.0001; % mass of rotary encoder
g = 9.81;
l1 = 1; % length of rod
l2 = 1; % length of pendulum
y_setpoint = [pi ; 0; 0; 0]; % stable point
y0 = [pi ; 0; pi/6; 0]; % initial point
%y0 = [pi ; 0; pi/6; 0];

% calling functions

%[t,y] = ideal_inverted_pendulum(m1, m2, m3, g, l1, l2, y0);
[t,y] = lqr_inverted_pendulum(m1, m2, m3, g, l1, l2, y_setpoint, y0);

% initialising loop for draw function

for k = 1:length(t) 
    draw(y(k, :));
end


end

function draw(y)
theta1 = y(1);
theta2 = y(3);
l1 = 1;
l2 = 1;

 hold on;
  clf;
  axis equal;
x1_pos = l1*cos(theta1); % positions of the bob as a function of time
y1_pos = l1*sin(theta1);
z1_pos = 0;
x2_pos = l1*cos(theta1) - l2*sin(theta2)*sin(theta1);
y2_pos = l1*sin(theta1) - l2*sin(theta2)*cos(theta1);
z2_pos = l2*cos(theta2);

plot3([0 x1_pos], [-0.25 y1_pos], [0 z1_pos], "linestyle", "-", 'Color','b','MarkerSize',100);
hold on
plot3([x1_pos x2_pos], [y1_pos y2_pos], [z1_pos z2_pos], "linestyle", "-", 'Color', 'g','MarkerSize',100);

  xlim([-2 2]) 
  ylim([-2 2])
  zlim([-2 2])
  drawnow
  hold off

end


   % Lagrangian equations
   
   function dy = inverted_pendulum_dynamics(y, m1, m2, m3, g, l1, l2, u)
    dy(1,1) = y(2);
    dy(3,1) = y(4);
    dy(2,1) = ( (u) + (m2*l1*l2*sin(y(3))*((y(4))^2)) - (2*m1*(l1^2)*y(2)*y(4)*sin(y(3))*cos(y(3))) - (0.5*m2*l1*g*sin(y(3))) - (0.5*m2*l1*l2*sin(y(3))*((cos(y(3)))^2))  )/( (m1*(l1^2)) + (m2*(l2^2)) + (m1*(l1^2)*(sin(y(3))^2)) - (m2*(l1^2)*(cos(y(3))^2)) + (m3*(l1^2)) );
    dy(4,1) = ((0.5*g*sin(y(3)))/(l2)) + (0.5*sin(y(3))*cos(y(3))*((y(2))^2)) - ((l1*cos(y(3))*(dy(2,1)))/(l2));
   end


    function [t,y] = ideal_inverted_pendulum(m1, m2, m3, g, l1, l2, y0)
    u = 0;
    tspan = 0:0.2:10;
    [t,y] = ode45(@(t,y)inverted_pendulum_dynamics(y, m1, m2, m3,  g, l1, l2, u),tspan,y0);
    end

    function [A,B] = inverted_AB_matrix(m1, m2,m3, l1, l2, g)
    A = [0 1 0 0; 0 0   -((g*l1*m2)/2 + (l1*l2*m2)/2)/(l1^2*m1 - l1^2*m2 + l1^2*m3 + l2^2*m2) 0; 0 0 0 1; 0 0 g/(2*l2) + (l1*((g*l1*m2)/2 + (l1*l2*m2)/2))/(l2*(l1^2*m1 - l1^2*m2 + l1^2*m3 + l2^2*m2)) 0];
    B = [0;  1/(l1^2*m1 - l1^2*m2 + l1^2*m3 + l2^2*m2); 0; -l1/(l2*(l1^2*m1 - l1^2*m2 + l1^2*m3 + l2^2*m2))];
    end

    function [t,y] = lqr_inverted_pendulum(m1, m2, m3, g, l1, l2, y_setpoint, y0)
        [A,B] = inverted_AB_matrix(m1, m2, m3, l1, l2, g);
        Q = [1 0 0 0 ; 0 0 0 0 ; 0 0 1 0; 0 0 0 1];
        R = 0.1;
        K = lqr(A,B,Q,R);
        tspan = 0:0.2:10;                 
  [t,y] = ode45(@(t,y)inverted_pendulum_dynamics(y, m1, m2, m3, g, l1, l2, -K*(y - y_setpoint)),tspan,y0);
end
