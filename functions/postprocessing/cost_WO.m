% function cost = cost_WO(x,F,D,W,T)
% This is the cost function based on:
% x the [1 x (phase +1)] matrix with global waveform [1 x phase] and c_w_o [1]
% the only tricky part is setting up Q, as we already have q (F)
% Before linear interpolation, time data will be triplicated so that timeshift can be positive or negative
% Linear Interp Set up:
% time should be [1 x 3*n] with the central time being the normal sampling times
% flow should be [numphase x 3n]
% ntime should be [numphase x n] where each column can have diff times
function cost = cost_WO(x,F,D,W,T)
    numphase=length(T);
    if T(1)==0 %allows for time to start at 0 without errors, flexibility!
        dt=T(2)-T(1);
    else
        dt=0;
    end
    time=[(T-((T(end)+dt))) T (T+(T(end)+dt))]; %center positive and negative time, negative PWV possible
    timeshift=D./x(end); %nx1 time points, need to shift for all sampling times
    timeshift=[repmat(time(21:40),length(D),1)-timeshift]; %This is now [numphase x n] and shifted for all times
    %Last step is to interpolate the global waveform (x(1:(end-1))) to new times
    Q = interp1(time,[x(1:(end-1)) x(1:(end-1)) x(1:(end-1))],timeshift);
    %Make weight matrix span all time points;
    w=repmat(W,1,numphase);
    cost=sum(w.*((F-Q).^2),'all'); %Notation wise in manuscript, F is q.
end