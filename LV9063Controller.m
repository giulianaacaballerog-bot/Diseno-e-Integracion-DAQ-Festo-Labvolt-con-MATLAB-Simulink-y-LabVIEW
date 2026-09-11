classdef LV9063Controller < matlab.System
    % ==============================================================
    % LV9063Controller
    %
    % System object combinado para el LV9063 (Festo Didactic).
    % A diferencia de LV9063AnalogInput (solo entradas analogicas)
    % y de LV9063Digital (solo salidas digitales), esta clase
    % gestiona ambos grupos de senales usando un unico cliente del
    % backend (LV9063Backend), tal como lo exige el hardware real.
    %
    % ENTRADAS (Simulink):
    %   DO0
    %   DO1
    %
    % SALIDAS (Simulink):
    %   E1  Voltaje 1
    %   E2  Voltaje 2
    %   I1  Corriente 1
    %   I2  Corriente 2
    %
    % Fs = 20000 Hz
    %
    % NOTA: Esta clase reemplaza a la version anterior del
    % controlador, que se habia corrompido por una traduccion
    % automatica de las palabras clave de MATLAB (function ->
    % funcion, end -> fin, etc.) y ya no era ejecutable.
    % ==============================================================

    methods (Access = protected)

        % ==========================================================
        % CONFIGURACION
        % ==========================================================

        function setupImpl(~)

            coder.extrinsic('LV9063Backend');

            disp(' ');
            disp('==========================================');
            disp('        INICIALIZANDO LV9063');
            disp('==========================================');
            disp(' ');

            % ------------------------------------------------------
            % INICIALIZAR (comando 0)
            % ------------------------------------------------------

            LV9063Backend( ...
                uint8(0), ...
                false, ...
                false);

            disp(' ');
            disp('==========================================');
            disp('           LV9063 LISTA');
            disp('==========================================');
            disp(' ');
            disp('DO0 = BAJO');
            disp('DO1 = BAJO');
            disp('E1 / E2 / I1 / I2 activos.');
            disp(' ');

        end


        % ==========================================================
        % PASO
        % ==========================================================

        function [E1,E2,I1,I2] = stepImpl(~,DO0,DO1)

            coder.extrinsic('LV9063Backend');

            % ------------------------------------------------------
            % VALORES INICIALES (obligatorio para Simulink/coder)
            % ------------------------------------------------------

            E1 = single(0);
            E2 = single(0);
            I1 = single(0);
            I2 = single(0);

            % ------------------------------------------------------
            % ASEGURAR VALORES VALIDOS
            % ------------------------------------------------------

            if isempty(DO0)
                DO0 = false;
            end

            if isempty(DO1)
                DO1 = false;
            end

            DO0 = logical(DO0);
            DO1 = logical(DO1);

            % ------------------------------------------------------
            % ADQUIRIR + ACTUALIZAR DIGITALES (comando 1)
            % ------------------------------------------------------

            [E1,E2,I1,I2] = LV9063Backend( ...
                uint8(1), ...
                DO0, ...
                DO1);

        end


        % ==========================================================
        % NUMERO DE ENTRADAS / SALIDAS
        % ==========================================================

        function numberInputs = getNumInputsImpl(~)
            numberInputs = 2;
        end

        function numberOutputs = getNumOutputsImpl(~)
            numberOutputs = 4;
        end


        % ==========================================================
        % TAMANO DE ENTRADAS
        % ==========================================================

        function [size1,size2] = getInputSizeImpl(~)
            size1 = [1 1];
            size2 = [1 1];
        end


        % ==========================================================
        % TIPO DE ENTRADAS
        % ==========================================================

        function [type1,type2] = getInputDataTypeImpl(~)
            type1 = 'double';
            type2 = 'double';
        end


        % ==========================================================
        % COMPLEJIDAD DE ENTRADAS
        % ==========================================================

        function [complex1,complex2] = isInputComplexImpl(~)
            complex1 = false;
            complex2 = false;
        end


        % ==========================================================
        % TAMANO DE SALIDAS
        % ==========================================================

        function [size1,size2,size3,size4] = getOutputSizeImpl(~)
            size1 = [1 1];
            size2 = [1 1];
            size3 = [1 1];
            size4 = [1 1];
        end


        % ==========================================================
        % TIPO DE SALIDAS
        % ==========================================================

        function [type1,type2,type3,type4] = getOutputDataTypeImpl(~)
            type1 = 'single';
            type2 = 'single';
            type3 = 'single';
            type4 = 'single';
        end


        % ==========================================================
        % COMPLEJIDAD DE SALIDAS
        % ==========================================================

        function [complex1,complex2,complex3,complex4] = isOutputComplexImpl(~)
            complex1 = false;
            complex2 = false;
            complex3 = false;
            complex4 = false;
        end


        % ==========================================================
        % TAMANO FIJO
        % ==========================================================

        function [fixed1,fixed2,fixed3,fixed4] = isOutputFixedSizeImpl(~)
            fixed1 = true;
            fixed2 = true;
            fixed3 = true;
            fixed4 = true;
        end


        % ==========================================================
        % TIEMPO DE MUESTREO
        % ==========================================================

        function sampleTime = getSampleTimeImpl(obj)

            samplingFrequency = 20000;
            samplingPeriod = 1 / samplingFrequency;

            sampleTime = createSampleTime( ...
                obj, ...
                'Type','Discrete', ...
                'SampleTime',samplingPeriod);

        end


        % ==========================================================
        % LIBERAR
        % ==========================================================

        function releaseImpl(~)

            coder.extrinsic('LV9063Backend');

            disp(' ');
            disp('==========================================');
            disp('          CERRANDO LV9063');
            disp('==========================================');
            disp(' ');

            LV9063Backend( ...
                uint8(2), ...
                false, ...
                false);

            disp('Dispositivo cerrado correctamente.');
            disp(' ');

        end

    end

end
