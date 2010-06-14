/* forward.c - executable forwarder
   
   This file is based on forward.c distributed with mingw.org's gcc
   
   This file is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 3, or (at your option)
   any later version.
   
   This file is distributed in the hope that it will be useful, but WITHOUT
   ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
   or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
   License for more details.
   
   You should have received a copy of the GNU General Public License
   along with GAS; see the file COPYING.  If not, write to the Free
   Software Foundation, 51 Franklin Street - Fifth Floor, Boston, MA
   02110-1301, USA.
*/


const char program_name[] = PROGRAM_NAME;

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <windows.h>

// Handle fatal errors.
int error(const char *context)
{
    // Print context.
    fputs(context, stderr);
    fputs(": ", stderr);
    
    // Print message.
    char *message;
    int err = GetLastError();
    DWORD result = FormatMessage(FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS,
    0, err, MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT), &message, 0, 0);
    if (!result)
	fprintf(stderr, "Error %d\n", err);
    else
    {
	fputs(message, stderr);
	putc('\n', stderr);
	LocalFree(message);
    }
    return 1;
}


// Remove trailing file name, but not the backslash.
//   This is similar to PathRemoveFileSpec(), which may not be available if
//   MSIE is not installed.
void 
remove_file_spec(char *path)
{
    // Find trailing slash.
    int l = strlen(path);
    int i = l;
    while (i > 0 && path[i] != '/' && path[i] != '\\')
	--i;

    // Truncate string.
    assert(i > 0);
    assert(i != l);
    ++i;
    path[i] = 0;
}

// Entry point.
//int WINAPI
//WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
int main()
{
    // Get executable path.
    const size_t program_name_len = sizeof(program_name) - 1;
    assert(program_name_len);
    char target_path[strlen(_pgmptr) + program_name_len - 1];
    strcpy(target_path, _pgmptr);

    // Replace file name with new target name.
    remove_file_spec(target_path);
    strcat(target_path, program_name);
    
    // Create process.
    STARTUPINFO start_info;
    GetStartupInfo(&start_info);
    PROCESS_INFORMATION process_info;
    char *full_command_line = GetCommandLine();
    assert(full_command_line);
    BOOL success = CreateProcess(target_path, full_command_line, 0, 0, TRUE, 0,
      0, 0, &start_info, &process_info);
    if (!success)
        return error("CreateProcess()");
    
    // Wait for process to complete.
    DWORD status = WaitForSingleObject(process_info.hProcess, INFINITE);
    if (status == WAIT_FAILED)
        return error("WaitForSingleObject()");
    assert(status == WAIT_OBJECT_0);
    
    // Return.
    DWORD exit_code;
    success = GetExitCodeProcess(process_info.hProcess, &exit_code);
    if (!success)
        return error("GetExitCodeProcess()");
    CloseHandle(process_info.hProcess);
    CloseHandle(process_info.hThread);
    return exit_code;
}
