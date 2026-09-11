classdef LV9063AnalogInput < matlab.System
    % ==============================================================
    % LV9063AnalogInput
    %
    % Entradas analógicas del DAQ Festo Didactic LV9063
    %
    % CANALES:
    %
    %   E1 = Voltaje 1
    %   E2 = Voltaje 2
    %   I1 = Corriente 1
    %   I2 = Corriente 2
    %
    % Frecuencia de adquisición:
    %
    %   Fs = 20000 Hz
    %
    % Periodo:
    %
    %   Ts = 50 us
    %
    % Compatible con MATLAB R2014b 32 bits
    % ==============================================================


    methods (Access = protected)


        %% =========================================================
        % SETUP
        %% =========================================================

        function setupImpl(~)

            coder.extrinsic('LV9063Backend');

            disp(' ');
            disp('==========================================');
            disp('     INICIALIZANDO DAQ LV9063');
            disp('==========================================');

            % Comando 0 = inicializar
            LV9063Backend(uint8(0));

            disp(' ');
            disp('LV9063 inicializado correctamente.');
            disp(' ');

        end


        %% =========================================================
        % STEP
        %% =========================================================

        function [E1,E2,I1,I2] = stepImpl(~)

            % ------------------------------------------------------
            % PREINICIALIZAR LAS SALIDAS
            % ------------------------------------------------------
            %
            % Esto es importante para MATLAB R2014b y Simulink.
            %

            E1 = single(0);
            E2 = single(0);
            I1 = single(0);
            I2 = single(0);


            coder.extrinsic('LV9063Backend');


            % ------------------------------------------------------
            % ADQUIRIR UNA MUESTRA
            % ------------------------------------------------------
            %
            % El backend se encarga internamente de:
            %
            %   - adquirir paquetes de 512 muestras
            %   - almacenar el paquete
            %   - entregar una muestra por llamada
            %
            % ------------------------------------------------------

            [E1,E2,I1,I2] = LV9063Backend(uint8(1));


        end


        %% =========================================================
        % NUMERO DE SALIDAS
        %% =========================================================

        function numberOutputs = getNumOutputsImpl(~)

            numberOutputs = 4;

        end


        %% =========================================================
        % TAMAÑO DE LAS SALIDAS
        %% =========================================================

        function [size1,size2,size3,size4] = ...
                getOutputSizeImpl(~)

            size1 = [1 1];
            size2 = [1 1];
            size3 = [1 1];
            size4 = [1 1];

        end


        %% =========================================================
        % TIPO DE DATOS
        %% =========================================================

        function [type1,type2,type3,type4] = ...
                getOutputDataTypeImpl(~)

            type1 = 'single';
            type2 = 'single';
            type3 = 'single';
            type4 = 'single';

        end


        %% =========================================================
        % COMPLEJIDAD
        %% =========================================================

        function [complex1,complex2,complex3,complex4] = ...
                isOutputComplexImpl(~)

            complex1 = false;
            complex2 = false;
            complex3 = false;
            complex4 = false;

        end


        %% =========================================================
        % TAMAÑO FIJO
        %% =========================================================

        function [fixed1,fixed2,fixed3,fixed4] = ...
                isOutputFixedSizeImpl(~)

            fixed1 = true;
            fixed2 = true;
            fixed3 = true;
            fixed4 = true;

        end


        %% =========================================================
        % TIEMPO DE MUESTREO
        %% =========================================================

        function sampleTime = getSampleTimeImpl(obj)

            samplingFrequency = 20000;

            samplingPeriod = 1 / samplingFrequency;

            sampleTime = createSampleTime( ...
                obj, ...
                'Type','Discrete', ...
                'SampleTime',samplingPeriod);

        end


        %% =========================================================
        % RELEASE
        %% =========================================================

        function releaseImpl(~)

            coder.extrinsic('LV9063Backend');

            disp(' ');
            disp('Cerrando dispositivo LV9063...');

            % Comando 2 = cerrar
            LV9063Backend(uint8(2));

            disp('Dispositivo LV9063 cerrado.');

        end


    end

end
