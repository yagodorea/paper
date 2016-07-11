function [s,flag,v] = setupSerial(comPort)

flag = 1;

s = serial(comPort);
set(s,'DataBits',8);
set(s,'StopBits',1);
set(s,'BaudRate',115200);
set(s,'Parity','none');
fclose(s);
fopen(s);

% Code begins here %

% Array with 4000 readings (arbitrary value)
% (about 5 seconds reading)
v = zeros(1,8000);
i = 1;
a = zeros(1,1000);
try
    tic
    while (i < 16)
        % Reads two bytes from buffer and truncates them into one 16-bit
        % integer
        for j = 1:1000
            a(1,j) = fread(s,1,'uint8');
        end
        
        for j = 1:2:999
            b = a(1,j+1) + bitshift(a(1,j),8);
            disp(b);
            v(1,500*(i-1)+(j+1)/2) = b;
        end
        i = i+1;
    end
    toc
catch ERROR
    mbox = msgbox('Error!');
    uiwait(mbox);
    %fclose(s);
    %delete(s);
end

v(1,1) = 0;

mbox = msgbox('Yoshi!');
uiwait(mbox);
fclose(s);
delete(s);
end