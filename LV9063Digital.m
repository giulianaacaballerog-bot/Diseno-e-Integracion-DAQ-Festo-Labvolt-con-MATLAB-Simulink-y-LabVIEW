classdef LV9063Digital < matlab.System

    properties (Access = private)
        dac
    end

    methods (Access = protected)

        %% ==========================================
        %  INICIALIZACION
        %% ==========================================
        function setupImpl(obj)

            disp('======================================');
            disp(' INICIANDO LV9063');
            disp('======================================');

            %% Cargar DLL
            NET.addAssembly( ...
                'C:\Program Files (x86)\Festo Didactic\LVDAC-EMS\SDK\9063\DLL\LV9063SDK.dll');

            disp('DLL cargada correctamente');

            %% Crear objeto
            obj.dac = LV9063DLL.LV9063EntryPoint();

            disp('Objeto LV9063 creado correctamente');

            %% Inicializar dispositivo
            ret = obj.dac.InitDevice(0);

            disp('Resultado InitDevice:');
            disp(ret);

            disp('LV9063 inicializado correctamente');

        end


        %% ==========================================
        %  EJECUCION
        %% ==========================================
        function stepImpl(obj, DO0, DO1)

            %% Convertir entradas a booleano
            estadoDO0 = logical(DO0);
            estadoDO1 = logical(DO1);

            %% Establecer salidas digitales
            obj.dac.SetDigitalOutputState(0, estadoDO0);
            obj.dac.SetDigitalOutputState(1, estadoDO1);

            %% Enviar tabla
            obj.dac.SendDigitalOutputsTable();

            %% Mostrar estados
            disp(['DO0 = ', num2str(DO0)]);
            disp(['DO1 = ', num2str(DO1)]);

        end


        %% ==========================================
        %  CIERRE
        %% ==========================================
        function releaseImpl(obj)

            disp('======================================');
            disp(' CERRANDO LV9063');
            disp('======================================');

            if ~isempty(obj.dac)

                %% Apagar salidas antes de cerrar
                obj.dac.SetDigitalOutputState(0, false);
                obj.dac.SetDigitalOutputState(1, false);

                %% Enviar estado final
                obj.dac.SendDigitalOutputsTable();

                %% Cerrar dispositivo
                obj.dac.CloseDevice();

                disp('Dispositivo cerrado correctamente.');

            end

        end

    end

end
