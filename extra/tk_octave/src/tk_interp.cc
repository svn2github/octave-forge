
/* 

This code is in the public domain. Use, modify, redistribute with or
without modification, or license it as you see fit.

*/

#include <octave/config.h>
#include <octave/oct-obj.h>
#include <octave/parse.h>
#include <octave/defun-dld.h>
#include <octave/error.h>
#include <octave/variables.h>
#include <octave/sighandlers.h>
#include <octave/mx-base.h>
#include <octave/help.h>

#include <tk.h>
#ifndef CONST84
#define CONST84
#endif

// I have attempted to block all access to octave variables from the tcl
// thread while octave is running, but I didn't do it correctly and it
// leads to deadlocks.  Since the window on the race condition is very
// small, and can be avoided completely with careful programming, I haven't
// yet debugged this. Set SAFE_VAR to 1 to include what I have done so far.

#define SAFE_VAR 0

#ifndef HAVE_BLT
#define HAVE_BLT 0
#endif

#if HAVE_BLT

#include <blt.h>
#include <bltVector.h>

#endif /* !HAVE_BLT */

#define _VERSION(a,b,c) (((a) << 16) + ((b) << 8) + (c))
#define TCL_VERSION_NUMBER _VERSION(TCL_MAJOR_VERSION, TCL_MINOR_VERSION, TCL_RELEASE_SERIAL)
#define TK_VERSION_NUMBER _VERSION(TK_MAJOR_VERSION, TK_MINOR_VERSION, TK_RELEASE_SERIAL)

#ifndef HAVE_VTK
#define HAVE_VTK 0
#endif

#if HAVE_VTK
#include <vtk/vtkRenderer.h>
#include <vtk/vtkRenderWindow.h>
#include <vtk/vtkRenderWindowInteractor.h>
#include <vtk/vtkPlaneSource.h>
#include <vtk/vtkTransform.h>
#include <vtk/vtkTransformPolyDataFilter.h>
#include <vtk/vtkPoints.h>
#include <vtk/vtkWarpScalar.h>
#include <vtk/vtkDataSetMapper.h>
#include <vtk/vtkPolyData.h>
#include <vtk/vtkActor.h>
#include <vtk/vtkTclUtil.h>
#endif /* HAVE_VTK */

#include <string>
#include <iostream>
#include <pthread.h>

#define TRUE  1
#define FALSE 0

#define ID "$Id$"

static Tcl_Interp *interp = NULL;

static char *command_to_do  = NULL;
static const char *command_result = NULL;

static pthread_t       tk_thread = 0;
static pthread_cond_t  tk_cond   = PTHREAD_COND_INITIALIZER;
static pthread_mutex_t tk_mutex  = PTHREAD_MUTEX_INITIALIZER;

#if SAVE_VAR
static pthread_mutex_t oct_mutex = PTHREAD_MUTEX_INITIALIZER;
#endif

static int continue_running;

class fifo
{
   struct fifo_element
   {
      char *cmd;
      struct fifo_element *next;
   } *front;
public:
   fifo(void) { front = NULL; }   /* Initialize the FIFO. */
   void push(char *cmd)   /* Add command to back of the fifo. */
   {
      fifo_element *push_me = front;
      if(push_me)
      {
         while(push_me->next) push_me = push_me->next;
         push_me->next = new fifo_element;
         push_me = push_me->next;
      }
      else
      {
         push_me = new fifo_element;
         front = push_me;
      }
      push_me->cmd = new char[strlen(cmd)+1];
      strcpy(push_me->cmd, cmd);
      push_me->next = NULL;
   }
   void pop(void)   /* Remove the command at the front of the fifo. */
   {
      if(front)
      {
         fifo_element *pop_me = front;
         front = front->next;
         delete[] pop_me->cmd;
         delete pop_me;
      }
   }
   char *peek(void)   /* Return the command at the front of the fifo. */
   {
      if(front) return front->cmd;
      else return NULL;
   }
} tk_fifo;


/************************************************************

   Get an octave value from Octave's global symbol table

   If the symbol does not exist, or the value is undefined, 
   return a value for which value.is_undefined() is true.


************************************************************/
static octave_value get_octave_value(const char *name)
{
  octave_value def;

  // Copy variable from octave
#if SAFE_VAR
  pthread_mutex_lock(&oct_mutex);
#endif
  symbol_record *sr;
  if (!strncmp(name, "global::", 8))
    sr = global_sym_tab->lookup (name+8);
  else if (!strncmp(name, "top::", 5))
    sr = top_level_sym_tab->lookup (name+5);
  else if (!strncmp(name, "current::", 9))
    sr = curr_sym_tab->lookup (name+9);
  else
    sr = top_level_sym_tab->lookup (name);
  if (sr) def = sr->def();
#if SAFE_VAR
  pthread_mutex_unlock(&oct_mutex);
#endif

  return def;
}


/************************************************************

   Tk Photo Image Format for an Octave matrix:

   The following procedures and data structures are used to
   establish a photo image format within Tk that allows an
   Octave matrix to be represented as an image.

************************************************************/

static int
StringMatchOctaveMatrix(Tcl_Obj *, Tcl_Obj *, int *, int *, Tcl_Interp *);

static int
StringReadOctaveMatrix(Tcl_Interp *, Tcl_Obj *, Tcl_Obj *, Tk_PhotoHandle,
int, int, int, int, int, int);

Tk_PhotoImageFormat tkImgFmtOctaveMatrix =
{
   "OctaveMatrix",            // name
   NULL,                      // fileMatchProc
   StringMatchOctaveMatrix,   // stringMatchProc
   NULL,                      // fileReadProc
   StringReadOctaveMatrix,    // stringReadProc
   NULL,                      // fileWriteProc
   NULL                       // stringWriteProc
};

#define DEFAULT_COLORMAP_LENGTH 41

unsigned char *make_grayscale_colormap(int length)
{
  unsigned char *colormap = (unsigned char *) malloc (3*length);
  float incr = 255.0 / (length - 1);
  float rgb_val = 0.0;
  for(int i = 0; i < length; i++)
    {
      colormap[3*i] = colormap[3*i+1] = colormap[3*i+2] 
	= (unsigned char)rgb_val;
      rgb_val += incr;
    }
  return colormap;
}

unsigned char *make_custom_colormap(Matrix m)
{
  int length = m.rows();
  unsigned char *colormap = (unsigned char *) malloc (3*length);
  for(int i = 0; i < length; i++)
    {
      colormap[3*i] = (unsigned char)(255.0*m.elem(i, 0));
      colormap[3*i+1] = (unsigned char)(255.0*m.elem(i, 1));
      colormap[3*i+2] = (unsigned char)(255.0*m.elem(i, 2));
   }
   return colormap;
}

static int
myStringMatchOctaveMatrix 
(int argc, CONST84 char **argv, int *widthP, int *heightP, Tcl_Interp *interp)
{
  if (argc < 1) return FALSE;

  octave_value def = get_octave_value(argv[0]);
  if(!def.is_defined() || !def.is_real_matrix()) 
    return FALSE;   // See if the arg is a matrix
  Matrix m = def.matrix_value();

  // We don't check any of the arguments here since
  // this will be done in StringReadOctaveMatrix below.
  *heightP = m.rows();
  *widthP = m.cols();
  return TRUE;
}

static int
StringMatchOctaveMatrix
(Tcl_Obj *str, Tcl_Obj *format, int *widthP, int *heightP, Tcl_Interp *interp)
{
   int argc;
   CONST84 char **argv;
   if (Tcl_SplitList(interp, (char *)str, &argc, &argv) != TCL_OK)
     return FALSE;

   int ret = myStringMatchOctaveMatrix(argc, argv, widthP, heightP, interp);
   Tcl_Free ((char *)argv);
   return ret;
}

static int
myStringReadOctaveMatrix
(Tcl_Interp *interp, int argc, CONST84 char **argv, Tk_PhotoHandle imageHandle,
int destX, int destY, int width, int height, int srcX, int srcY)
{
  // find matrix containing octave image
  octave_value def = get_octave_value(argv[0]);
  if(!def.is_defined() ||     // See if the arg is defined
     !def.is_real_matrix())   // See if the arg is a matrix
    {
      Tcl_AppendResult(interp, "No such Octave matrix defined.", NULL);
      return TCL_ERROR;
    }
  Matrix m = def.matrix_value();

  // interpret image format info
  int indexed = FALSE;
  const char *colormap = "global::__current_color_map__";
  while(--argc)
    {
      argv++;
      if(!strcmp(argv[0], "-indexed"))
	indexed = TRUE;
      else if(!strcmp(argv[0], "-colormap"))
      {
	if (argc == 0 || argv[1][0] == '-')
	  {
	    Tcl_AppendResult(interp,
			     "-colormap needs the name of the colormap", NULL);
	    return TCL_ERROR;
	  }
	--argc, ++argv;
	      
	colormap = argv[0];
      }
      else
	{
	  Tcl_AppendResult(interp, "unknown octave image option ", argv[0],NULL);
	  return TCL_ERROR;
	}
    }

  // Grab colormap from octave
  unsigned char *colormap_data = NULL;
  int colormap_length = DEFAULT_COLORMAP_LENGTH;
  def = get_octave_value(colormap);
  if (!def.is_defined())
    {
      colormap_length = DEFAULT_COLORMAP_LENGTH;
      colormap_data = make_grayscale_colormap(colormap_length);
    }
  else if (!def.is_real_matrix() || def.columns() != 3)
    {
      Tcl_AppendResult(interp, colormap,
		       " is not a valid colormap");
      return TCL_ERROR;
    }
  else
    {
      Matrix m(def.matrix_value());
      colormap_data = make_custom_colormap(m);
      colormap_length = m.rows();
    }


  // determine the range of values in the image in case the image is
  // not indexed, but instead needs to be shifted and scaled to the 
  // full range of valid colormap indices.
  float min=0.0, max=0.0;
  if (!indexed)
    {
      min = max = m.elem(0, 0);
      for(int i = 0; i < height; i++)
	{
	  for(int j = 0; j < width; j++)
	    {
	      float cur = m.elem(i, j);
	      if(cur < min) min = cur;
	      if(cur > max) max = cur;
	    }
	}
      if(min == max) max=max+1.0;;
    }

  // Build the TK photo image from the octave image and the colormap.
  Tk_PhotoImageBlock block;
  block.pixelSize = 3;
  block.offset[0] = 0;
  block.offset[1] = 1;
  block.offset[2] = 2;
  block.width = width;
  block.height = height;
  block.pitch = block.pixelSize * width;
  block.pixelPtr = (unsigned char *) calloc(height, block.pitch);
  Tk_PhotoSetSize(imageHandle, width, height);
  for(int i = 0; i < height; i++)
    {
      for(int j = 0; j < width; j++)
	{
	  int pixel_index = (height-(i+1)) * block.pitch + j * block.pixelSize;
	  int color_index;

	  if (indexed)
	    {
	      color_index = (int) floor(m.elem(i,j)) - 1;
	      if (color_index < 0) 
		color_index = 0;
	      else if (color_index >= colormap_length) 
		color_index = colormap_length - 1;
	    }
	  else
	    {
	      float color = (m.elem(i,j) - min) / (max-min) * 0.999;
	      color_index = (int)rint(color * (colormap_length-1));
	    }
	  block.pixelPtr[pixel_index] = colormap_data[3*color_index];
	  block.pixelPtr[pixel_index+1] = colormap_data[3*color_index+1];
	  block.pixelPtr[pixel_index+2] = colormap_data[3*color_index+2];
	}
    }
#if TK_VERSION_NUMBER >= _VERSION(8,4,0)
  Tk_PhotoPutBlock(imageHandle, &block, destX, destY, width, height, 
	TK_PHOTO_COMPOSITE_SET);
#else
  Tk_PhotoPutBlock(imageHandle, &block, destX, destY, width, height);
#endif
  free((void *) block.pixelPtr);
  free((void *) colormap_data);
  
  return TCL_OK;
}

static int
StringReadOctaveMatrix
(Tcl_Interp *interp, Tcl_Obj *str, Tcl_Obj *format, Tk_PhotoHandle imageHandle,
int destX, int destY, int width, int height, int srcX, int srcY)
{
   int argc;
   CONST84 char **argv;

   if (Tcl_SplitList(interp, (char *) str, &argc, &argv) != TCL_OK)
     return FALSE;

   int ret = myStringReadOctaveMatrix(interp, argc, argv, imageHandle,
				      destX, destY, width, height, srcX, srcY);

   Tcl_Free ((char *)argv);
   return ret;
}

/************************************************************

   Procedure:  oct_string

   Routine for interrogating an Octave string within Tk.

************************************************************/

int oct_string(ClientData clientData, Tcl_Interp *interp, int argc, CONST84 char **argv)
{
  if (argc < 2)
    {
      Tcl_AppendResult(interp, "wrong # args: should be \"oct_string \
stringName options\"", NULL);
      return TCL_ERROR;
    }

   octave_value def = get_octave_value(argv[1]);
   bool exists = def.is_defined() && def.is_string();
   if (!strcmp(argv[2], "exists"))
     {
       Tcl_AppendResult(interp, exists ? "1":"0", NULL);
       return TCL_OK;
     }
   if(!exists)
   {
      Tcl_AppendResult(interp, "No such Octave string \"",
         argv[1], "\" defined.", NULL);
      return TCL_ERROR;
   }
   std::string s = def.string_value();
   Tcl_AppendResult(interp, s.c_str(), NULL);
   return TCL_OK;
}


/************************************************************

   Procedure:  oct_matrix

   Routine for interrogating an Octave matrix within Tk.

************************************************************/

int oct_matrix(ClientData clientData, Tcl_Interp *interp, int argc, CONST84 char **argv)
{
   if(argc < 3) 
   {
      Tcl_AppendResult(interp, "wrong # args: should be \"oct_matrix \
matrixName option\"", NULL);
      return TCL_ERROR;
   }

   octave_value def = get_octave_value(argv[1]);
   bool exists = def.is_defined() && def.is_real_matrix();
   if (!strcmp(argv[2], "exists"))
     {
       Tcl_AppendResult(interp, exists ? "1":"0", NULL);
       return TCL_OK;
     }
   if(!exists)
   {
      Tcl_AppendResult(interp, "No such Octave matrix \"",
         argv[1], "\" defined.", NULL);
      return TCL_ERROR;
   }
   Matrix m = def.matrix_value();
   if(!strcmp(argv[2], "rows"))
   {
      char buf[20];
      sprintf(buf, "%d", m.rows());
      Tcl_AppendResult(interp, buf, NULL);
      return TCL_OK;
   }
   if(!strcmp(argv[2], "columns") || !strcmp(argv[2], "cols"))
   {
      char buf[20];
      sprintf(buf, "%d", m.cols());
      Tcl_AppendResult(interp, buf, NULL);
      return TCL_OK;
   }
   if(!strcmp(argv[2], "min"))
   {
      double min = m.elem(0, 0);
      for(int i = 0; i < m.rows(); i++)
      {
         for(int j = 0; j < m.cols(); j++)
         {
            if(m.elem(i, j) < min) min = m.elem(i, j);
         }
      }
      char buf[20];
      sprintf(buf, "%f", min);
      Tcl_AppendResult(interp, buf, NULL);
      return TCL_OK;
   }
   if(!strcmp(argv[2], "max"))
   {
      double max = m.elem(0, 0);
      for(int i = 0; i < m.rows(); i++)
      {
         for(int j = 0; j < m.cols(); j++)
         {
            if(m.elem(i, j) > max) max = m.elem(i, j);
         }
      }
      char buf[20];
      sprintf(buf, "%f", max);
      Tcl_AppendResult(interp, buf, NULL);
      return TCL_OK;
   }
   if(!strcmp(argv[2], "element") || !strcmp(argv[2], "elem"))
   {
      if(argc != 5)
      {
         Tcl_AppendResult(interp, "wrong # args: should be \"oct_matrix \
matrixName element row column\"", NULL);
         return TCL_ERROR;
      }
      int row = atoi(argv[3]);
      int col = atoi(argv[4]);
      double elem = m.elem(row, col);
      char buf[20];
      sprintf(buf, "%f", elem);
      Tcl_AppendResult(interp, buf, NULL);
      return TCL_OK;
   }
   Tcl_AppendResult(interp, "bad option \"",
      argv[2], "\": must be exists, rows, col[umn]s, min, max or elem[ent]", NULL);
   return TCL_ERROR;
}

#if HAVE_BLT
/************************************************************

   Procedure:  oct_mtov

   Slices an Octave matrix into a BLT vector.

************************************************************/

int oct_mtov(ClientData clientData, Tcl_Interp *interp, int argc, CONST84 char **argv)
{
   if(argc != 7)
   {
      Tcl_AppendResult(interp, "wrong # args: should be \"oct_mtov \
matrixName vectorName startX startY sizeX sizeY\"", NULL);
      return TCL_ERROR;
   }

   octave_value def = get_octave_value(argv[1]);
   bool exists = def.is_defined() && def.is_real_matrix();
   if(!exists)
   {
      Tcl_AppendResult(interp, "No such Octave matrix \"",
         argv[1], "\" defined.", NULL);
      return TCL_ERROR;
   }
   Matrix m = def.matrix_value();
   int startX = atoi(argv[3]);
   if((startX < 0) || (startX >= m.cols()))
   {
      Tcl_AppendResult(interp, "startX value is out of bounds.", NULL);
      return TCL_ERROR;
   }
   int startY = atoi(argv[4]);
   if((startY < 0) || (startY >= m.rows()))
   {
      Tcl_AppendResult(interp, "startY value is out of bounds.", NULL);
      return TCL_ERROR;
   }
   int sizeX  = atoi(argv[5]);
   if((sizeX < 1) || (sizeX > (m.cols() - startX)))
   {
      Tcl_AppendResult(interp, "sizeX value is out of bounds.", NULL);
      return TCL_ERROR;
   }
   int sizeY  = atoi(argv[6]);
   if((sizeY < 1) || (sizeY > (m.rows() - startY)))
   {
      Tcl_AppendResult(interp, "sizeY value is out of bounds.", NULL);
      return TCL_ERROR;
   }
   Blt_Vector *v;
   if(Blt_VectorExists(interp, (char *)argv[2]))
   {
      if(Blt_GetVector(interp, (char *)argv[2], &v) != TCL_OK)
      {
         Tcl_AppendResult(interp, "Unable to get pointer to BLT vector \"",
            argv[2], "\".", NULL);
         return TCL_ERROR;
      }
      if(Blt_ResizeVector(v, (sizeX * sizeY)) != TCL_OK)
      {
         Tcl_AppendResult(interp, "Unable to resize BLT vector \"",
            argv[2], "\".", NULL);
         return TCL_ERROR;
      }
   }
   else
   {
      if(Blt_CreateVector(interp, (char *)argv[2], (sizeX * sizeY), &v) != TCL_OK)
      {
         Tcl_AppendResult(interp, "Unable to create BLT vector \"",
            argv[2], "\".", NULL);
         return TCL_ERROR;
      }
   }
   double *elemPtr = v->valueArr;
   for(int i = startY; i < (startY + sizeY); i++)
   {
      for(int j = startX; j < (startX + sizeX); j++)
      {
         *elemPtr++ = m.elem(i, j);
      }
   }
   Blt_ResetVector(v, v->valueArr, v->numValues, v->arraySize, NULL);
   return TCL_OK;
}
#endif /* HAVE_BLT */

#if HAVE_VTK
/************************************************************

   Procedure:  oct_mtovtk

   Routine to transform an Octave matrix into a VTK surface

************************************************************/

int oct_mtovtk(ClientData clientData, Tcl_Interp *interp, int argc, CONST84 char **argv)
{
   if(argc != 3)
   {
      Tcl_AppendResult(interp,
         "wrong # args: should be \"oct_mtovtk matrixName vtkName\"", NULL);
      return TCL_ERROR;
   }

   octave_value def = get_octave_value(argv[1]);
   bool exists = def.is_defined() && def.is_real_matrix();
   if(!exists)
   {
      Tcl_AppendResult(interp, "No such Octave matrix \"",
         argv[1], "\" defined.", NULL);
      return TCL_ERROR;
   }
   Matrix m = def.matrix_value();

   char buf[128];
   sprintf(buf, "vtkPolyData %s", argv[2]);
   if(Tcl_GlobalEval(interp, buf) != TCL_OK)
   {
      Tcl_AppendResult(interp, "Creation of vtkPolyData \"",
         argv[2], "\" failed.", NULL);
      return TCL_ERROR;
   }
   int error;
   vtkPolyData* surface = (vtkPolyData *)
      vtkTclGetPointerFromObject(argv[2], "vtkPolyData", interp, error);

   // Get min and max of the Octave matrix
   float min, max;
   min = max = m.elem(0, 0);
   for(int i = 0; i < m.rows(); i++)
   {
      for(int j = 0; j < m.cols(); j++)
      {
         float cur = m.elem(i, j);
         if(cur < min) min = cur;
         if(cur > max) max = cur;
      }
   }
   if(min == max) max++;   // Avoid division by zero

   // Create VTK objects
   vtkPlaneSource *plane = vtkPlaneSource::New();
   plane->SetResolution((m.rows() - 1), (m.cols() - 1));
   vtkTransform *transform = vtkTransform::New();
   transform->Scale(1.0, 1.0, 1.0);
   vtkTransformPolyDataFilter *transF = vtkTransformPolyDataFilter::New();
   transF->SetInput(plane->GetOutput());
   transF->SetTransform(transform);
   transF->Update();
   vtkPolyData *input = transF->GetOutput();
   int numPts = input->GetNumberOfPoints();
   vtkPoints *newPts = vtkPoints::New();
   newPts->SetNumberOfPoints(numPts);
   // XXX FIXME XXX color handling has changed
   // vtkScalars *colors = vtkScalars::New();
   // colors->SetNumberOfScalars(numPts);

   // Convert values from Octave matrix and store in VTK object
   double p[3];
   for(int k = 0; k < numPts; k++)
   {
      input->vtkPointSet::GetPoint(k, p);
      int row = int((p[0] + 0.5) * (float) (m.rows() - 1));
      int col = int((p[1] + 0.5) * (float) (m.cols() - 1));
      p[2] = ((m.elem(row, col) - min) / (max - min)) - 0.5;
      newPts->SetPoint(k, p);
      // colors->SetScalar(k, p[2]);
   }   

   surface->CopyStructure(input);
   surface->SetPoints(newPts);
   // surface->GetPointData()->SetScalars(colors);

   // Clean up VTK objects
   plane->Delete();
   transform->Delete();
   transF->Delete();
   newPts->Delete();
   // colors->Delete();

   return TCL_OK;
}
#endif /* HAVE_VTK */

#if 0
/* Don't need get_tk_thread_interp unless other DLD's want to add
 * commands to the tcl interpreter.  In that case, uncomment this
 * function, link the other DLD against tk_interp.oct (by running
 * mkoctfile -v to see what the current link line is, then entering
 * the modified link line by hand since mkoctfile doesn't handle
 * linking one DLD against another), then add the current directory
 * to the LD_LIBRARY_PATH so that the other DLD can find the first
 * when it needs it. */
Tcl_Interp *get_tk_thread_interp(void)
{
   pthread_mutex_lock(&tk_mutex);
   Tcl_Interp *result = (tk_thread ? interp : NULL);
   pthread_mutex_unlock(&tk_mutex);
   return result;
}
#endif

static
int oct_cmd(ClientData clientData, Tcl_Interp *interp, int argc, CONST84 char **argv)
{
   if(argc < 2)
   {
      Tcl_AppendResult(interp,
         "wrong # args: should be \"oct_cmd commandName ?options?\"", NULL);
      return TCL_ERROR;
   }
   int cmd_len = 1;
   char *cmd_str = (char *) malloc(sizeof(char));
   *cmd_str = '\0';
   for(int i = 1; i < argc; i++)
   {
      cmd_len += strlen(argv[i]) + 1;
      cmd_str = (char *) realloc(cmd_str, (cmd_len * sizeof(char)));
      strcat(cmd_str, argv[i]);
      if(i != (argc - 1)) strcat(cmd_str, " ");
      /*      else strcat(cmd_str, ";"); */
   }
   pthread_mutex_lock(&tk_mutex);
   tk_fifo.push(cmd_str);
   pthread_cond_signal(&tk_cond);
   pthread_mutex_unlock(&tk_mutex);
   free(cmd_str);
   return TCL_OK;
}

static
int oct_quit(ClientData clientData, Tcl_Interp *interp, int argc, CONST84 char **argv)
{
   if(argc != 1)
   {
      Tcl_AppendResult(interp, "wrong # args: should be \"oct_quit\"", NULL);
      return TCL_ERROR;
   }

   pthread_mutex_lock(&tk_mutex);
   continue_running = FALSE;
   pthread_cond_signal(&tk_cond);
   pthread_mutex_unlock(&tk_mutex);

   return TCL_OK;
}


static void tk_thread_process_start(void)
{
   interp = Tcl_CreateInterp();

   if (Tcl_Init(interp) != TCL_OK)
   {
     error ("Tcl_Init: %s", interp->result);
     return;
   }
   if (Tk_Init(interp) != TCL_OK)
   {
     error ("Tk_Init: %s", interp->result);
     return;
   }

   Tcl_CreateCommand(interp, "oct_cmd",  oct_cmd,  NULL, NULL);
   Tcl_CreateCommand(interp, "oct_quit", oct_quit, NULL, NULL);

   // Set up photo image format for an Octave matrix
   Tk_CreatePhotoImageFormat(&tkImgFmtOctaveMatrix);

   // Create command for interrogating an Octave matrix within Tk
   Tcl_CreateCommand(interp, "oct_matrix", oct_matrix, NULL, NULL);

   // Create command for interrogating an Octave string within Tk
   Tcl_CreateCommand(interp, "oct_string", oct_string, NULL, NULL);

#if HAVE_BLT
   // Create command for slicing an Octave matrix into a BLT vector
   Tcl_CreateCommand(interp, "oct_mtov", oct_mtov, NULL, NULL);
#endif

#if HAVE_VTK
   // Create command to transform Octave matrix to VTK surface
   Tcl_CreateCommand(interp, "oct_mtovtk", oct_mtovtk, NULL, NULL);
#endif


   Tk_Window mainw = Tk_MainWindow(interp);
   const char *name = Tk_SetAppName(mainw, "tk_octave");
   char buf[40];
   sprintf(buf, "wm title . {%s}", name);
   Tcl_Eval(interp, buf);
   Tcl_Eval(interp, "rename exec {}");
   Tcl_Eval(interp, "rename exit {}");

   command_result = name;
}

static void tk_thread_process_end(void *arg)
{
   Tcl_DeleteInterp(interp);
   interp = NULL;

#if SAFE_VAR
   // Let Octave know that the thread has ended
   pthread_mutex_lock(&tk_mutex);
   pthread_cond_signal(&tk_cond);
   pthread_mutex_unlock(&tk_mutex);
#endif
}

static void *tk_thread_process(void *arg)
{
   pthread_mutex_lock(&tk_mutex);
   tk_thread_process_start();
   pthread_cleanup_push(tk_thread_process_end, NULL);
   pthread_cond_signal(&tk_cond);
   pthread_mutex_unlock(&tk_mutex);

   while(1)
   {
      pthread_testcancel();
      if(command_to_do)
      {
         pthread_mutex_lock(&tk_mutex);
	 if (Tcl_Eval(interp, command_to_do) == TCL_ERROR)
	   Tcl_BackgroundError(interp);
         command_to_do = NULL;
         command_result = interp->result;
         pthread_cond_signal(&tk_cond);
         pthread_mutex_unlock(&tk_mutex);
      }
      while(Tcl_DoOneEvent(TCL_ALL_EVENTS | TCL_DONT_WAIT));
   }
   pthread_cleanup_pop(0);
}

DEFUN_DLD (tk_interp, args,, "\
Creates a Tk interpreter within Octave.\n\n\
Usage: retval = tk_interp\n\n\
See also: tk_end, tk_cmd, tk_loop")
{
   octave_value_list ret;

   if(tk_thread)
   {
      error("Error: Tk interpreter is already running.");
      return ret;
   }

   pthread_mutex_lock(&tk_mutex);
   pthread_create(&tk_thread, NULL, tk_thread_process, NULL);
   pthread_cond_wait(&tk_cond, &tk_mutex);
   pthread_mutex_unlock(&tk_mutex);

#if SAFE_VAR
   // Don't grab octave values while octave is running
   pthread_mutex_lock(&oct_mutex);
#endif

   return octave_value(std::string(command_result));
}

DEFUN_DLD (tk_end, args,, "\
Closes the Tk interpreter created by tk_start.\n\n\
Usage: retval = tk_end\n\n\
See also: tk_start, tk_cmd, tk_loop")
{
   octave_value_list ret;

   if(!tk_thread)
   {
      error("Error: Tk interpreter is not running.");
      return ret;
   }

   pthread_mutex_lock(&tk_mutex);
   pthread_cancel(tk_thread);
   tk_thread = 0;
#if SAFE_VAR
   // Wait for the thread to end, then release the octave value access mutex
   pthread_cond_wait(&tk_cond, &tk_mutex);
   pthread_mutex_unlock(&oct_mutex);
#endif
   pthread_mutex_unlock(&tk_mutex);

   return ret;
}

DEFUN_DLD (tk_cmd, args,, "\
Sends the specified command to the Tk interpreter.\n\n\
Usage: retval = tk_cmd(CMD)\n\n\
   where CMD is a string containing the command to send.\n\n\
See also: tk_start, tk_end, tk_loop")
{
   octave_value_list ret;

   if(!tk_thread)
   {
      error("Error: Tk interpreter is not running.");
      return ret;
   }

   int nargin = args.length();
   if (nargin == 0)
     {
       print_usage ();
       return ret;
     }

   // Concatenate all input arguments into one big string
   std::string cmd = "";
   if (nargin > 0)
     {
       cmd = args(0).string_value();
       if (error_state) return ret;
       for (int i=1; i < nargin; i++)
	 {
	   cmd = cmd + ' ' + args(i).string_value();
	   if (error_state) return ret;
	 }
     }

   if (cmd.length() > 0)
     {
#if SAFE_VAR
       // No longer in octave so it is safe to allow access to octave variables
       pthread_mutex_unlock(&oct_mutex);
#endif

       pthread_mutex_lock(&tk_mutex);
       command_to_do = (char *) cmd.c_str();
       pthread_cond_wait(&tk_cond, &tk_mutex);
       pthread_mutex_unlock(&tk_mutex);

#if SAFE_VAR
       // returning to octave, so block octave variable access
       pthread_mutex_lock(&oct_mutex);
#endif

       ret(0) = octave_value(std::string(command_result));
     }

   return ret;
}

DEFUN_DLD (tk_loop, args,, "\
Makes Octave act as a slave to the Tk command loop.\n\
Processes commands sent to it from the Tk interpreter\n\
until the 'oct_quit' command is called from Tk.\n\n\
Usage: retval = tk_loop\n\n\
See also: tk_start, tk_end, tk_cmd")
{
   octave_value_list ret;

   if(!tk_thread)
   {
      error("Error: Tk interpreter is not running.");
      return ret;
   }

   pthread_mutex_lock(&tk_mutex);
   continue_running = TRUE;
   pthread_mutex_unlock(&tk_mutex);

#if SAFE_VAR
   // No longer running octave, so free the octave mutex
   pthread_mutex_unlock(&oct_mutex);
#endif
   do
   {
      pthread_mutex_lock(&tk_mutex);
      pthread_cond_wait(&tk_cond, &tk_mutex);
      char *command_to_do = tk_fifo.peek();
      pthread_mutex_unlock(&tk_mutex);
      while(command_to_do)
      {
	 std::cout << "Processing command: " << command_to_do << "\n";
         const std::string octave_cmd = std::string(command_to_do);
         int parse_status = 0;
#if SAFE_VAR
	 pthread_mutex_lock(&oct_mutex);
#endif
         eval_string(octave_cmd, (bool) TRUE, parse_status, 0);
#if SAFE_VAR
	 pthread_mutex_unlock(&oct_mutex);
#endif
	 std::cout << "Finished\n";

         pthread_mutex_lock(&tk_mutex);
         tk_fifo.pop();
         command_to_do = tk_fifo.peek();
         pthread_mutex_unlock(&tk_mutex);
      }
   }
   while(continue_running);

#if SAFE_VAR
   pthread_mutex_lock(&oct_mutex);
#endif

   return ret;
}

