#if !defined (__RSOCT_H__)
#define __RSOCT_H__

#include <octave/oct.h>

extern "C" {
#include "rs.h"
#include "int.h"    // We really shouldn't be using this header as it 
                    // gives access to private structures of the RS.
                    // But I don't see how else to do it.
}

#define _RS_Tab_Size   15    /* Number of Elements in the above tabel */

/* Type of messages */
typedef enum {MSG_TYPE_BINARY = 0, MSG_TYPE_DECIMAL, MSG_TYPE_POWER} MsgType;

struct {
  int symsize;
  int genpoly;
} _RS_Tab[] = {
  {2, 0x7    },
  {3, 0xb    },
  {4, 0x13   },
  {5, 0x25   },
  {6, 0x43   },
  {7, 0x89   },
  {8, 0x11d  },
  {9, 0x211  },
  {10,0x409  },
  {11,0x805  },
  {12,0x1053 },
  {13,0x201b },
  {14,0x4443 },
  {15,0x8003 },
  {16,0x1100b},
};

int find_table_index(int M) 
{
  for (int i=0; i<_RS_Tab_Size; i++)
    if (_RS_Tab[i].symsize == M) return i;
  return -1;
}

#endif /* __RSOCT_H__ */

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
