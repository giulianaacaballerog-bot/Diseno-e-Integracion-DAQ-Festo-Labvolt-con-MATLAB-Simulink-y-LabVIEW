function GUI_Principal

    fig = figure('Name','Sistema LabVolt - Panel General',...
        'NumberTitle','off',...
        'Position',[500 300 450 350],...
        'Color', [0.94 0.94 0.94]);

    % Texto estado
    txt_estado = uicontrol('Style','text',...
        'Position',[20 310 250 25],...
        'String','Estado: Desconectado',...
        'FontSize', 10, 'FontWeight', 'bold',...
        'ForegroundColor',[0.8 0 0], 'HorizontalAlignment', 'left');

    % Lista de módulos
    modulos = {
        'Modulo de Tiristores (LabVolt 9063)'
        'Modulo DC (LabVolt 9043)'
        'Modulo AC (LabVolt 9053)'
        'Modulo de Control (LabVolt 9060)'
        };
    
    uicontrol('Style','text','Position',[20 270 200 20],...
        'String','Seleccione un módulo:', 'HorizontalAlignment', 'left');
        
    lista_modulos = uicontrol('Style','listbox',...
        'Position',[20 80 220 180],...
        'String',modulos, 'FontSize', 9);

    % Botón abrir módulo
    uicontrol('Style','pushbutton',...
        'String','Abrir Modulo',...
        'Position',[270 190 140 45],...
        'BackgroundColor', [0.8 0.9 1],...
        'Callback', @abrir_modulo);

    % Botón configurar comunicación
    uicontrol('Style','pushbutton',...
        'String','Configurar COM',...
        'Position',[270 130 140 45],...
        'Callback', @configurar_com);

    %Navegacion
    function configurar_com(~,~)
        puerto = inputdlg('Puerto COM (ej: COM3)', 'Configuración');
        if ~isempty(puerto)
            % Simulación de conexión exitosa
            set(txt_estado,'String','Estado: Conectado (Simulado)',...
                'ForegroundColor',[0 0.5 0]);
            msgbox(['Conectado exitosamente al puerto ' puerto{1}]);
        end
    end

    function abrir_modulo(~,~)
        indice = get(lista_modulos,'Value');
        switch indice
            case 1, GUI_Tiristores();
            case 2, GUI_DC();
            case 3, GUI_AC();
            case 4, GUI_Control();
        end
    
end


end