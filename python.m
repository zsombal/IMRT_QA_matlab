function [result status] = python(varargin)
%Python Execute Python command and return the result.
%   Python(PythonFILE) calls Python script specified by the file PythonFILE
%   using appropriate python executable.
%
%   Python(PythonFILE,ARG1,ARG2,...) passes the arguments ARG1,ARG2,...
%   to the python script file PythonFILE, and calls it by using appropriate
%   python executable.
%
%   RESULT=Python(...) outputs the result of attempted python call.  If the
%   exit status of python is not zero, an error will be returned.
%
%   [RESULT,STATUS] = Python(...) outputs the result of the python call, and
%   also saves its exit status into variable STATUS.
%
%   If the Python executable is not available, it can be downloaded from:
%     http://www.cpan.org
%
%   See also SYSTEM, JAVA, MEX.

%   Copyright 1990-2007 The MathWorks, Inc.
%   $Revision: 1.1.4.11 $
    
cmdString = '';

% Add input to arguments to operating system command to be executed.
% (If an argument refers to a file on the MATLAB path, use full file path.)
for i = 1:nargin
    thisArg = varargin{i};
    if ~ischar(thisArg)
        error(message('MATLAB:python:InputsMustBeStrings'));
    end
    if i==1
        if exist(thisArg, 'file')==2
            % This is a valid file on the MATLAB path
            if isempty(dir(thisArg))
                % Not complete file specification
                % - file is not in current directory
                % - OR filename specified without extension
                % ==> get full file path
                thisArg = which(thisArg);
            end
        else
            % First input argument is PythonFile - it must be a valid file
            error(message('MATLAB:python:FileNotFound', thisArg));
        end
    end

    % Wrap thisArg in double quotes if it contains spaces
    if isempty(thisArg) || any(thisArg == ' ')
        thisArg = ['"', thisArg, '"']; %#ok<AGROW>
    end

    % Add argument to command string
    cmdString = [cmdString, ' ', thisArg]; %#ok<AGROW>
end

% Execute Python script
if isempty(cmdString)
    error(message('MATLAB:python:NoPythonCommand'));
elseif ispc
    % PC
    pythonCmd = fullfile(matlabroot, 'sys\python\win32\bin\');
    cmdString = ['python' cmdString];
    pythonCmd = ['set PATH=',pythonCmd, ';%PATH%&' cmdString];
    [status, result] = dos(pythonCmd);
else
    % UNIX
    [status ignore] = unix('which python'); %#ok
    if (status == 0)
        cmdString = ['python', cmdString];
        [status, result] = unix(cmdString);
    else
        error(message('MATLAB:python:NoExecutable'));
    end
end

% Check for errors in shell command
if nargout < 2 && status~=0
    error(message('MATLAB:python:ExecutionError', result, cmdString));
end

