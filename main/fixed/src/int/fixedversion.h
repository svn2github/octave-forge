#define FIXEDVERSION "1.0.0"

#if defined (_MSC_VER)
# if defined (FIXED_DLL)
#  define OCTAVE_FIXED_API __declspec(dllexport)
# else
#  define OCTAVE_FIXED_API __declspec(dllimport)
# endif
#else
# define OCTAVE_FIXED_API
#endif
