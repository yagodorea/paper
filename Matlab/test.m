figure(1);
hold on;

for i = 1:000;
  
   plot(time(1:i));
   drawnow;
   pause(0.01);
end;
