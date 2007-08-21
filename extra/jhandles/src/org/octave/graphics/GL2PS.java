package org.octave.graphics;

public class GL2PS
{
	static
	{
		System.load(System.getProperty("octave.jhandles.path") + java.io.File.separator +
			System.mapLibraryName("gl2ps_java"));
	}

	final static int GL2PS_MAJOR_VERSION = 1;
	final static int GL2PS_MINOR_VERSION = 3;
	final static int GL2PS_PATCH_VERSION = 2;
	final static String GL2PS_EXTRA_VERSION = "";
	final static double GL2PS_VERSION =
		(GL2PS_MAJOR_VERSION +
		 0.01 * GL2PS_MINOR_VERSION +
		 0.0001 * GL2PS_PATCH_VERSION);
	final static String GL2PS_COPYRIGHT = "(C) 1999-2006 Christophe Geuzaine (geuz@geuz.org)";
	final static int GL2PS_PS = 0;
	final static int GL2PS_EPS = 1;
	final static int GL2PS_TEX = 2;
	final static int GL2PS_PDF = 3;
	final static int GL2PS_SVG = 4;
	final static int GL2PS_PGF = 5;
	final static int GL2PS_NO_SORT = 1;
	final static int GL2PS_SIMPLE_SORT = 2;
	final static int GL2PS_BSP_SORT = 3;
	final static int GL2PS_SUCCESS = 0;
	final static int GL2PS_INFO = 1;
	final static int GL2PS_WARNING = 2;
	final static int GL2PS_ERROR = 3;
	final static int GL2PS_NO_FEEDBACK = 4;
	final static int GL2PS_OVERFLOW = 5;
	final static int GL2PS_UNINITIALIZED = 6;
	final static int GL2PS_NONE = 0;
	final static int GL2PS_DRAW_BACKGROUND = (1<<0);
	final static int GL2PS_SIMPLE_LINE_OFFSET = (1<<1);
	final static int GL2PS_SILENT = (1<<2);
	final static int GL2PS_BEST_ROOT = (1<<3);
	final static int GL2PS_OCCLUSION_CULL = (1<<4);
	final static int GL2PS_NO_TEXT = (1<<5);
	final static int GL2PS_LANDSCAPE = (1<<6);
	final static int GL2PS_NO_PS3_SHADING = (1<<7);
	final static int GL2PS_NO_PIXMAP = (1<<8);
	final static int GL2PS_USE_CURRENT_VIEWPORT = (1<<9);
	final static int GL2PS_COMPRESS = (1<<10);
	final static int GL2PS_NO_BLENDING = (1<<11);
	final static int GL2PS_TIGHT_BOUNDING_BOX = (1<<12);
	final static int GL2PS_POLYGON_OFFSET_FILL = 1;
	final static int GL2PS_POLYGON_BOUNDARY = 2;
	final static int GL2PS_LINE_STIPPLE = 3;
	final static int GL2PS_BLEND = 4;
	final static int GL2PS_TEXT_C = 1;
	final static int GL2PS_TEXT_CL = 2;
	final static int GL2PS_TEXT_CR = 3;
	final static int GL2PS_TEXT_B = 4;
	final static int GL2PS_TEXT_BL = 5;
	final static int GL2PS_TEXT_BR = 6;
	final static int GL2PS_TEXT_T = 7;
	final static int GL2PS_TEXT_TL = 8;
	final static int GL2PS_TEXT_TR = 9;

	public static native int gl2psBeginPage(
		String title, String producer,
		int[] viewport,
		int format, int sort, int options,
		int colormode, int colorsize,
		Object[] colortable,
		int nr, int ng, int nb,
		int buffersize, String outputname,
		String filename);
	public static native int gl2psEndPage();
	public static native int gl2psText(String string, String fontname, int fontsize);
	public static native int gl2psTextOpt(String string, String fontname,
		int fontsize, int align, float angle, float margin);
	public static native int gl2psEnable(int mode);
	public static native int gl2psDisable(int mode);
	public static native int gl2psBeginViewport(int[] viewport);
	public static native int gl2psEndViewport();
	public static native int gl2psLineWidth(float w);
}
