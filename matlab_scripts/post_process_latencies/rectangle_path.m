% figure()
% x = [0, 0, 0, 0, 0, 7];
% y = [0, 0, 0, 0, 0, 7];
% counter = 2;
% while true
%     x(counter) = counter;
%     y(counter) = counter;
%     scatter(x,y);
%     pause(1.2);
%     counter = counter + 1;
%     if counter == 6
%         break
%     end
% end
%%
clear

% set p the environment 
x = [0, 50];
y = [0, 50];
figure();
scatter(x,y)

% initialize position
% state = 0;

counter = 2;
step = 0.5;

x_init = 1;
y_init = 40;

rectangle_side = 10;
x_ref = x_init;
y_ref = y_init;
x_ubound = x_init + rectangle_side;
x_lbound = x_init;
y_lbound = y_init - rectangle_side;
y_ubound = y_init;

path_accuracy = 0.00001;

% x_ubound = x_init + rectangle_side;
% x_lbound = x_init;
% y_lbound = y_init;
% y_ubound = y_init + rectangle_side;

% is a vector containing the current state at element 2, and the previous
% state at element 1. state_vector = [previous_state, current_state]
state_vector = [0,0];

while true
    
%     if x_ref == x_lbound && y_ref == y_ubound
%         if state_vector(2) == 7
%             state_vector(1) = 7;
% %             step = step / 2;
%             x = [0, 50];
%             y = [0, 50];
%             counter = 2;
%             scatter(x,y)
%         end
%         state_vector(2) = 1;
%     elseif x_ref == x_ubound && y_ref == y_ubound
%         state_vector(2) = 3;
%         state_vector(1) = 1;
%     elseif x_ref == x_ubound && y_ref == y_lbound
%         state_vector(2) = 5;
%         state_vector(1) = 3;
%     elseif x_ref == x_lbound && y_ref == y_lbound
%         state_vector(2) = 7;
%         state_vector(1) = 5;
%     end

    if abs(x_ref - x_lbound) <= path_accuracy && abs(y_ref - y_ubound) <= path_accuracy
        if state_vector(2) == 7
            state_vector(1) = 7;

            x = [0, 50];
            y = [0, 50];
            counter = 2;
            scatter(x,y)
        end
        state_vector(2) = 1;
    elseif abs(x_ref - x_ubound) <= path_accuracy && abs(y_ref - y_ubound) <= path_accuracy
        state_vector(2) = 3;
        state_vector(1) = 1;
    elseif abs(x_ref - x_ubound) <= path_accuracy && abs(y_ref - y_lbound) <= path_accuracy
        state_vector(2) = 5;
        state_vector(1) = 3;
    elseif abs(x_ref - x_lbound) <= path_accuracy && abs(y_ref - y_lbound) <= path_accuracy
        state_vector(2) = 7;
        state_vector(1) = 5;
    end

    if state_vector(2) == 1 && (state_vector(1) == 7 || ...
            state_vector(1) == 0)
        x_ref = x_ref + step;
    elseif state_vector(2) == 3 && state_vector(1) == 1
        y_ref = y_ref - step;
    elseif state_vector(2) == 5 && state_vector(1) == 3
        x_ref = x_ref - step;
    elseif state_vector(2) == 7 && state_vector(1) == 5
        y_ref = y_ref + step;
    end


   

    counter = counter + 1;
    x(counter) = x_ref;
    y(counter) = y_ref;
    pause(.01);
    scatter(x,y)
    if counter == 1400
        break
    end
end
















%%
% clear
% 
% % set p the environment 
% x = zeros(1, 100);
% y = zeros(1,100);
% x(2) = 100;
% y(2) = 100;
% x(3) = 100;
% y(3) = 0;
% x(4) = 0;
% y(4) = 100;
% figure();
% scatter(x,y)
% 
% % initialize position
% % state = 0;
% x_ref = 2;
% y_ref = 15;
% counter = 2;
% step = 1;
% 
% x_pbound = 80;
% x_mbound = 1;
% y_mbound = 15;
% y_pbound = 80;
% 
% % is a vector containing the current state at element 2, and the previous
% % state at element 1. state_vector = [previous_state, current_state]
% state_vector = [0,0];
% 
% while true
%      % decide state, if you are on a state or bound
%      x_cond = x_ref ~= x_pbound && x_ref ~= x_mbound;
%      y_cond = y_ref ~= y_pbound && y_ref ~= y_mbound;
%     if x_cond % ths means that you either in state 3 or 1
%         if (y_ref > y_mbound) && (y_ref < y_pbound)
%             state_vector(2) = 3;
%         else
%             state_vector(2) = 1;
%         end
%     else % you are on a bound
%         % switch states
%         if state_vector(2) == 1 && state_vector(1) == 4
%             state_vector(2) = 2;
%             state_vector(1) = 1;
%         elseif state_vector(2) == 2 && state_vector(1) == 1
%             
%         end
% %         state_vector = [0,0];
% %         break
%     end
%     
%     if state_vector(2) == 1
%         x_ref = x_ref - step;
%     elseif state_vector(2) == 2
%         y_ref = y_ref - step;
%     elseif state_vector(2) == 3
%         x_ref = x_ref + step;
%     elseif state_vector(2) == 4
%         y_ref = y_ref + step;
%     end
% 
%    
% 
%     counter = counter + 1;
%     x(counter) = x_ref;
%     y(counter) = y_ref;
%     pause(.1);
%     scatter(x,y)
% end




