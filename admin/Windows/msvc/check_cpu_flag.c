#include <string.h>
#include <windows.h>

int WinMain (HINSTANCE hInst, HINSTANCE hPrevInst, LPSTR cmdLine, int nShow)
{
  int d, c, i, verbose = 0;
  int dm, cm;
  int result, argc;
  LPWSTR *argv;

  argv = CommandLineToArgvW (GetCommandLineW (), &argc);

  if (argv == NULL)
    {
      MessageBox (NULL, "Cannot parse command arguments", "Error", MB_OK|MB_ICONSTOP);
      return -1;
    }

  if (argc < 2)
    {
      MessageBox (NULL, "Missing argument", "Error", MB_OK|MB_ICONSTOP);
      return -1;
    }

  __asm {
      mov eax, 0x00000001
      cpuid
      mov d, edx
      mov c, ecx
  }

  dm = cm = 0;

  for (i = 1; i < argc; i++)
    if (wcsicmp (argv[i], L"mmx") == 0)
      dm |= (1 << 23);
    else if (wcsicmp (argv[i], L"sse") == 0
	     || wcsicmp (argv[i], L"sse1") == 0)
      dm |= (1 << 25);
    else if (wcsicmp (argv[i], L"sse2") == 0)
      dm |= (1 << 26);
    else if (wcsicmp (argv[i], L"sse3") == 0)
      cm |= (1 << 0);
    else if (wcscmp (argv[i], L"-v") == 0)
      verbose = 1;
    else
      MessageBoxW (NULL, argv[i], L"Error", MB_OK|MB_ICONSTOP);

  result = ((d & dm) | (c & cm));
  if (verbose)
    MessageBox (NULL, (result ? "Features supported" : "Features not supported"), "CPU check", MB_OK|MB_ICONINFORMATION);

  return (result ? 0 : 1);
}
