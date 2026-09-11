function Scope_I1

clc
clear
close all

try

    %% ==========================================
    %% Cargar DLL
    %% ==========================================

    if ~IsAssemblyAdded('LV9063SDK')
        NET.addAssembly('C:\Program Files (x86)\Festo Didactic\LVDAC-EMS\SDK\9063\DLL\LV9063SDK.DLL');
    end

    %% Crear objeto

    dll9063 = LV9063DLL.LV9063EntryPoint();

    %% Inicializar dispositivo

    e = dll9063.InitDevice(0);

    if e ~= LV9063DLL.ErrorCode.None
        error('No se pudo inicializar el 9063');
    end

    disp('Dispositivo inicializado correctamente');

    %% ==========================================
    %% Configurar rangos de entrada
    %% ==========================================

    ranges = NET.createArray('LV9063DLL.InputRange',8);

    % E1
    ranges.Set(0,LV9063DLL.InputRange.Low);

    % I1
    ranges.Set(1,LV9063DLL.InputRange.High);

    % E2
    ranges.Set(2,LV9063DLL.InputRange.Low);

    % I2
    ranges.Set(3,LV9063DLL.InputRange.High);

    % E3
    ranges.Set(4,LV9063DLL.InputRange.Low);

    % I3
    ranges.Set(5,LV9063DLL.InputRange.High);

    % E4
    ranges.Set(6,LV9063DLL.InputRange.Low);

    % I4
    ranges.Set(7,LV9063DLL.InputRange.High);

    dll9063.SetAllInputsRange(ranges);
    dll9063.SendRelayTable();

    %% ==========================================
    %% Configuración de adquisición
    %% ==========================================

    samplingFreq = single(20000);
    nbPackets = int32(4);

    inputs = NET.createArray('LV9063DLL.Input',2);

    inputs.Set(0,LV9063DLL.Input.E1);
    inputs.Set(1,LV9063DLL.Input.I1);

    dll9063.SetAcqTable(samplingFreq,inputs,nbPackets);

    dll9063.SendAcqTable();

    %% ==========================================
    %% Buffer
    %% ==========================================

    buffer = NET.createArray('System.Single',1024);

    figure

    while true

        e = dll9063.AcquireData(buffer,true);

        if e ~= LV9063DLL.ErrorCode.None
            break
        end

        datos = reshape(single(buffer),[2 512])';

        E1 = datos(:,1);
        I1 = datos(:,2);

        %% ==========================================
        %% Vector de tiempo
        %% ==========================================

        Fs = double(samplingFreq);   % Frecuencia de muestreo (Hz)
        N = length(E1);              % Número de muestras
        t = (0:N-1)/Fs;               % Tiempo en segundos

        %% ==========================================
        %% Convertir a arreglos .NET
        %% ==========================================

        dataE = NET.createArray('System.Single',512);
        dataI = NET.createArray('System.Single',512);

        for k = 1:512

            dataE(k) = single(E1(k));
            dataI(k) = single(I1(k));

        end

        %% RMS

        Vrms = dll9063.GetRMSValue(dataE);
        Irms = dll9063.GetRMSValue(dataI);

        %% ==========================================
        %% Factor de potencia
        %% ==========================================

        try
            PF = dll9063.GetPowerFactorValue(LV9063DLL.PFMode.Total,dataE,dataI);
        catch
            PF = NaN;
        end

        %% ==========================================
        %% Armónico 3
        %% ==========================================

        try
            H3 = dll9063.GetHarmonicValue(LV9063DLL.Harmonic.H3,dataE);
        catch
            H3 = NaN;
        end

        %% ==========================================
        %% Gráfica: Voltaje y Corriente juntos
        %% ==========================================

        clf

        plot(t,E1,'b','LineWidth',1.5)
        hold on

        plot(t,100*I1,'r','LineWidth',1.5)

        hold off

        grid on
        xlabel('Tiempo (s)')
        ylabel('Amplitud')
        title('Voltaje y Corriente')

        legend('Voltaje (E1)','Corriente (I1)','Location','best')

        %% ==========================================
        %% Mostrar resultados
        %% ==========================================

        clc

        fprintf('=====================================\n');
        fprintf('            LABVOLT 9063\n');
        fprintf('=====================================\n\n');

        fprintf('Voltaje RMS   : %8.3f V\n',Vrms);
        fprintf('Corriente RMS : %8.3f A\n',Irms);
        % fprintf('PF            : %8.3f\n',PF);
        % fprintf('H3            : %8.3f %%\n',H3);

        fprintf('\n=====================================\n');

        drawnow

        pause(0.5)

    end

    dll9063.CloseDevice();

catch err

    disp(err.message)

    if isa(err,'NET.NetException')
        disp(err.ExceptionObject)
    end

end

end

function loaded = IsAssemblyAdded(AsmName)

asm = System.AppDomain.CurrentDomain.GetAssemblies;

loaded = false;

j = 0;

while (j < asm.Length && ~loaded)

    loaded = strcmp(char(asm.Get(j).GetName.Name),AsmName);

    j = j + 1;

end

end
