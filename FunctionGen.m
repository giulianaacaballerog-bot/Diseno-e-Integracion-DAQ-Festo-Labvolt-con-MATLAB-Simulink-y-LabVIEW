function FunctionGen

%Note: Monitor the Analog Output 1 of 9063 to see the sine wave which lasts 10s after the execution of the example

%Before executing function, check if the following path for LV9063SDK.DLL is valid.
%Depending of version of the operating system (32 bits or 64 bits) and its language,
%the path may have to be modified to execute properly.
%Troubleshoot: To see if LV9063SDK.DLL load correctly after executing once the command
%NET.addAssembly, execute ListAssemblies.m to see which assemblies is visible to Matlab.
try
    if (~IsAssemblyAdded('LV9063SDK'))
        NET.addAssembly('C:\Program Files (x86)\Festo Didactic\LVDAC-EMS\SDK\9063\DLL\LV9063SDK.DLL');
    end

    dll9063 = LV9063DLL.LV9063EntryPoint();
    e = dll9063.InitDevice(0);
    if (e == LV9063DLL.ErrorCode.None)
        %3rd parameter = peak amplitude in Volt, 4th parameter = frequency in Hz
        dll9063.SetFunctionGenerator(dll9063.AO1, LV9063DLL.Waveform.Sine, 15.0, 1.0);
        dll9063.SetAnalogOutputStartStop(dll9063.AO1, dll9063.START);
        err = dll9063.SendAnalogOutputsTable();
        if (err == LV9063DLL.ErrorCode.Communication)
            errmsg = sprintf('\nCommunication failed!');
            disp(errmsg);
        else
            %Timer of 10s to show the sinewave on analog output
            i = 60;
            while (i >= 0)
                pause(1);
                cntdown = sprintf('\nAnalog Output 1 Enable Countdown: %d s', i);
                disp(cntdown);
                i = i - 1;
            end
        end
    end
    e = dll9063.CloseDevice();  %Which set the analog output to 0V

catch e
    e.message
    if(isa(e,'NET.NetException'))
        e.ExceptionObject
    end
end

end

function loaded = IsAssemblyAdded( AsmName )

asm = System.AppDomain.CurrentDomain.GetAssemblies;
loaded = false;
j = 0;
while (j < asm.Length && ~loaded)
    loaded = strcmp(char(asm.Get(j).GetName.Name), AsmName);
    j = j + 1;
end

end
