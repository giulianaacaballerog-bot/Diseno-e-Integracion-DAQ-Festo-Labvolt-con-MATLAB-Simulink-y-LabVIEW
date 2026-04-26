function GUI_AC

  fig_ac = figure('Name','Modulo AC',...
        'NumberTitle','off',...
        'Position',[550 350 350 250], 'MenuBar', 'none');
    
    uicontrol('Style','text','Position',[20 210 310 20],...
        'String','Simulación de señal AC', 'FontWeight', 'bold');
    
    uicontrol('Style','text','Position',[20 170 100 20],'String','Amplitud (V):');
    edit_amp = uicontrol('Style','edit','Position',[130 170 60 25],'String','12');
    
    uicontrol('Style','text','Position',[20 130 100 20],'String','Frecuencia (Hz):');
    edit_freq = uicontrol('Style','edit','Position',[130 130 60 25],'String','60');

    uicontrol('Style','pushbutton','Position',[125 40 100 35],...
        'String','Simular AC',...
        'Callback', @(s,e) msgbox(['Señal AC: ' get(edit_amp,'String') 'V / ' get(edit_freq,'String') 'Hz']));
end
