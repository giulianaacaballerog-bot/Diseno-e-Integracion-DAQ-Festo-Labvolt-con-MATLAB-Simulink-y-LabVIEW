function [E1,E2,I1,I2] = LV9063Backend(command,varargin)

% ==============================================================
%                    LV9063 BACKEND
% ==============================================================
%
% UN SOLO CLIENTE PARA EL LV9063
%
% ENTRADAS DIGITALES:
%   DO0
%   DO1
%
% SALIDAS ANALOGICAS:
%   E1
%   E2
%   I1
%   I2
%
% Fs = 20000 Hz
%
% command:
%
%   0 = Inicializar
%   1 = Adquirir + actualizar digitales
%   2 = Cerrar
%
% ==============================================================


persistent dac
persistent buffer

persistent frameE1
persistent frameE2
persistent frameI1
persistent frameI2

persistent sampleIndex
persistent initialized


% ==============================================================
% VALORES DE SALIDA
% ==============================================================

E1 = single(0);
E2 = single(0);
I1 = single(0);
I2 = single(0);


% ==============================================================
% ESTADO INICIAL
% ==============================================================

if isempty(initialized)

    initialized = false;

end


% ==============================================================
% ASEGURAR ENTRADAS DIGITALES
% ==============================================================

DO0 = false;
DO1 = false;


if nargin >= 2

    if ~isempty(varargin{1})

        DO0 = logical(varargin{1});

    end

end


if nargin >= 3

    if ~isempty(varargin{2})

        DO1 = logical(varargin{2});

    end

end


% ==============================================================
% COMANDO
% ==============================================================

switch double(command)


    % ==========================================================
    % COMANDO 0
    % INICIALIZAR
    % ==========================================================

    case 0


        % ------------------------------------------------------
        % SI YA ESTA INICIALIZADO NO VOLVER A CREAR EL OBJETO
        % ------------------------------------------------------

        if initialized && ~isempty(dac)

            return

        end


        % ======================================================
        % RUTA DE LA DLL
        % ======================================================

        dllPath = [ ...
            'C:\Program Files (x86)\Festo Didactic\', ...
            'LVDAC-EMS\SDK\9063\DLL\LV9063SDK.DLL'];


        % ======================================================
        % CARGAR DLL
        % ======================================================

        try

            NET.addAssembly(dllPath);

        catch

            % La DLL probablemente ya esta cargada.

        end


        % ======================================================
        % CREAR OBJETO
        % ======================================================

        dac = LV9063DLL.LV9063EntryPoint();


        % ======================================================
        % INICIALIZAR DISPOSITIVO
        % ======================================================

        ret = dac.InitDevice(0);


        if ret ~= LV9063DLL.ErrorCode.None

            dac = [];

            initialized = false;

            error('No se pudo inicializar el LV9063.');

        end


        % ======================================================
        % CONFIGURAR RANGOS
        % ======================================================

        ranges = NET.createArray( ...
            'LV9063DLL.InputRange',8);


        % ------------------------------------------------------
        % E1
        % ------------------------------------------------------

        ranges.Set( ...
            0, ...
            LV9063DLL.InputRange.Low);


        % ------------------------------------------------------
        % I1
        %
        % Rango LOW = +/-4 A
        % ------------------------------------------------------

        ranges.Set( ...
            1, ...
            LV9063DLL.InputRange.Low);


        % ------------------------------------------------------
        % E2
        % ------------------------------------------------------

        ranges.Set( ...
            2, ...
            LV9063DLL.InputRange.Low);


        % ------------------------------------------------------
        % I2
        %
        % Rango LOW = +/-4 A
        % ------------------------------------------------------

        ranges.Set( ...
            3, ...
            LV9063DLL.InputRange.Low);


        % ------------------------------------------------------
        % E3
        % ------------------------------------------------------

        ranges.Set( ...
            4, ...
            LV9063DLL.InputRange.Low);


        % ------------------------------------------------------
        % I3
        % ------------------------------------------------------

        ranges.Set( ...
            5, ...
            LV9063DLL.InputRange.High);


        % ------------------------------------------------------
        % E4
        % ------------------------------------------------------

        ranges.Set( ...
            6, ...
            LV9063DLL.InputRange.Low);


        % ------------------------------------------------------
        % I4
        % ------------------------------------------------------

        ranges.Set( ...
            7, ...
            LV9063DLL.InputRange.High);


        % ======================================================
        % ENVIAR RANGOS
        % ======================================================

        ret = dac.SetAllInputsRange(ranges);


        if ret ~= LV9063DLL.ErrorCode.None

            error('Error configurando los rangos de entrada.');

        end


        ret = dac.SendRelayTable();


        if ret ~= LV9063DLL.ErrorCode.None

            error('Error enviando RelayTable.');

        end


        % ======================================================
        % CONFIGURAR ENTRADAS
        %
        % E1
        % I1
        % E2
        % I2
        % ======================================================

        inputs = NET.createArray( ...
            'LV9063DLL.Input',4);


        inputs.Set( ...
            0, ...
            LV9063DLL.Input.E1);


        inputs.Set( ...
            1, ...
            LV9063DLL.Input.I1);


        inputs.Set( ...
            2, ...
            LV9063DLL.Input.E2);


        inputs.Set( ...
            3, ...
            LV9063DLL.Input.I2);


        % ======================================================
        % FRECUENCIA DE MUESTREO
        % ======================================================

        samplingFreq = single(20000);


        % ======================================================
        % NUMERO DE PAQUETES
        %
        % 8 paquetes x 256 muestras / 4 canales
        % = 512 muestras por canal
        % ======================================================

        nbPackets = int32(8);


        % ======================================================
        % CONFIGURAR ADQUISICION
        % ======================================================

        ret = dac.SetAcqTable( ...
            samplingFreq, ...
            inputs, ...
            nbPackets);


        if ret ~= LV9063DLL.ErrorCode.None

            error('Error configurando la adquisicion.');

        end


        % ======================================================
        % ENVIAR TABLA DE ADQUISICION
        % ======================================================

        ret = dac.SendAcqTable();


        if ret ~= LV9063DLL.ErrorCode.None

            error('Error enviando la tabla de adquisicion.');

        end


        % ======================================================
        % CREAR BUFFER
        %
        % 4 canales x 512 muestras
        % = 2048 valores
        % ======================================================

        buffer = NET.createArray( ...
            'System.Single', ...
            2048);


        % ======================================================
        % CREAR FRAMES
        % ======================================================

        frameE1 = zeros(512,1,'single');

        frameE2 = zeros(512,1,'single');

        frameI1 = zeros(512,1,'single');

        frameI2 = zeros(512,1,'single');


        % ======================================================
        % FORZAR PRIMERA ADQUISICION
        % ======================================================

        sampleIndex = 513;


        % ======================================================
        % ESTADO
        % ======================================================

        initialized = true;


        % ======================================================
        % APAGAR SALIDAS DIGITALES AL INICIAR
        % ======================================================

        dac.SetDigitalOutputState( ...
            0, ...
            false);


        dac.SetDigitalOutputState( ...
            1, ...
            false);


        dac.SendDigitalOutputsTable();


        % ======================================================
        % MENSAJES
        % ======================================================

        disp(' ');
        disp('==========================================');
        disp('           LV9063 INICIALIZADO');
        disp('==========================================');
        disp(' ');
        disp('Fs = 20000 Hz');
        disp('E1 = Voltaje');
        disp('E2 = Voltaje');
        disp('I1 = Corriente');
        disp('I2 = Corriente');
        disp('DO0 = Digital');
        disp('DO1 = Digital');
        disp(' ');
        disp('==========================================');


    % ==========================================================
    % COMANDO 1
    % ADQUISICION + DIGITALES
    % ==========================================================

    case 1


        % ------------------------------------------------------
        % COMPROBAR INICIALIZACION
        % ------------------------------------------------------

        if ~initialized || isempty(dac)

            error('LV9063 no esta inicializado.');

        end


        % ======================================================
        % ACTUALIZAR SALIDA DIGITAL DO0
        % ======================================================

        ret = dac.SetDigitalOutputState( ...
            0, ...
            DO0);


        if ret ~= LV9063DLL.ErrorCode.None

            error('Error configurando DO0.');

        end


        % ======================================================
        % ACTUALIZAR SALIDA DIGITAL DO1
        % ======================================================

        ret = dac.SetDigitalOutputState( ...
            1, ...
            DO1);


        if ret ~= LV9063DLL.ErrorCode.None

            error('Error configurando DO1.');

        end


        % ======================================================
        % ENVIAR TABLA DIGITAL
        % ======================================================

        ret = dac.SendDigitalOutputsTable();


        if ret ~= LV9063DLL.ErrorCode.None

            error('Error enviando salidas digitales.');

        end


        % ======================================================
        % COMPROBAR SI NECESITAMOS UN NUEVO BLOQUE
        % ======================================================

        if sampleIndex > 512


            % ==================================================
            % ADQUIRIR 512 MUESTRAS POR CANAL
            % ==================================================

            ret = dac.AcquireData( ...
                buffer, ...
                true);


            if ret ~= LV9063DLL.ErrorCode.None

                error('Error durante AcquireData.');

            end


            % ==================================================
            % COPIAR BUFFER .NET -> MATLAB
            % ==================================================

            rawData = zeros(2048,1,'single');


            for k = 1:2048

                rawData(k) = single(buffer(k));

            end


            % ==================================================
            % ORGANIZAR DATOS
            %
            % ORDEN:
            %
            % E1 I1 E2 I2
            %
            % ==================================================

            datos = reshape( ...
                rawData, ...
                [4 512])';


            % ==================================================
            % SEPARAR CANALES
            % ==================================================

            frameE1 = datos(:,1);

            frameI1 = datos(:,2);

            frameE2 = datos(:,3);

            frameI2 = datos(:,4);


            % ==================================================
            % REINICIAR INDICE
            % ==================================================

            sampleIndex = 1;


        end


        % ======================================================
        % ENTREGAR UNA MUESTRA
        % ======================================================

        E1 = frameE1(sampleIndex);

        I1 = frameI1(sampleIndex);

        E2 = frameE2(sampleIndex);

        I2 = frameI2(sampleIndex);


        % ======================================================
        % SIGUIENTE MUESTRA
        % ======================================================

        sampleIndex = sampleIndex + 1;


    % ==========================================================
    % COMANDO 2
    % CERRAR
    % ==========================================================

    case 2


        % ======================================================
        % APAGAR SALIDAS
        % ======================================================

        if ~isempty(dac)


            try

                dac.SetDigitalOutputState( ...
                    0, ...
                    false);

                dac.SetDigitalOutputState( ...
                    1, ...
                    false);

                dac.SendDigitalOutputsTable();

            catch

            end


            % ==================================================
            % CERRAR DISPOSITIVO
            % ==================================================

            try

                dac.CloseDevice();

            catch

            end


        end


        % ======================================================
        % LIMPIAR VARIABLES PERSISTENTES
        % ======================================================

        dac = [];

        buffer = [];

        frameE1 = [];

        frameE2 = [];

        frameI1 = [];

        frameI2 = [];

        sampleIndex = [];

        initialized = false;


        % ======================================================
        % MENSAJE
        % ======================================================

        disp(' ');
        disp('==========================================');
        disp('           LV9063 CERRADO');
        disp('==========================================');
        disp(' ');


end

end
