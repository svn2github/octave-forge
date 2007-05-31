/*
 * oplot-gl 
 *
 * Copyright (C) 2007 Michael Goffioul 
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA 
 *
 */

package org.octave.graphics;

import java.awt.Color;
import javax.media.opengl.*;
import javax.media.opengl.glu.*;
import java.nio.ByteBuffer;
import java.util.*;
import java.nio.*;

public class GLRenderer implements Renderer
{
	private int maxLight;
	private GLAutoDrawable d;
	private GL gl;
	private GLU glu;

	private double xmin, xmax;
	private double ymin, ymax;
	private double zmin, zmax;

	private Point3D cameraPos;
	private Point3D cameraDir;
	private TreeMap alphaPrimitives;
	private GLUtessellator tess = null;
	private int lightSideMode = GL.GL_FRONT_AND_BACK;

	public GLRenderer(GLAutoDrawable d)
	{
		this.d = d;
		this.gl = d.getGL();
		this.maxLight = 0;
		this.alphaPrimitives = new TreeMap();
		this.glu = new GLU();
	}

	public GL getGL()
	{
		return gl;
	}

	public void end()
	{
		if (this.alphaPrimitives.size() > 0)
		{
			gl.glEnable(GL.GL_BLEND);
			Iterator it = this.alphaPrimitives.entrySet().iterator();
			while (it.hasNext())
			{
				List l = (List)((Map.Entry)it.next()).getValue();
				Iterator lit = l.iterator();
				while (lit.hasNext())
					((Runnable)lit.next()).run();
			}
			this.alphaPrimitives.clear();
			gl.glDisable(GL.GL_BLEND);
		}
		this.maxLight = 0;
	}

	public void setClipping(boolean flag)
	{
		if (gl.glIsEnabled(GL.GL_CLIP_PLANE0) != flag)
		{
			if (flag)
				for (int i=0; i<6; i++)
					gl.glEnable(GL.GL_CLIP_PLANE0+i);
			else
				for (int i=0; i<6; i++)
					gl.glDisable(GL.GL_CLIP_PLANE0+i);
		}
	}

	public boolean hasClipping()
	{
		return gl.glIsEnabled(GL.GL_CLIP_PLANE0);
	}
	
	public void setClipBox(double xmin, double xmax, double ymin, double ymax, double zmin, double zmax)
	{
		gl.glClipPlane(GL.GL_CLIP_PLANE0, new double[] { -1, 0, 0, xmax }, 0);
		gl.glClipPlane(GL.GL_CLIP_PLANE1, new double[] { 1, 0, 0, -xmin }, 0);
		gl.glClipPlane(GL.GL_CLIP_PLANE2, new double[] { 0, -1, 0, ymax }, 0);
		gl.glClipPlane(GL.GL_CLIP_PLANE3, new double[] { 0, 1, 0, -ymin }, 0);
		gl.glClipPlane(GL.GL_CLIP_PLANE4, new double[] { 0, 0, -1, zmax }, 0);
		gl.glClipPlane(GL.GL_CLIP_PLANE5, new double[] { 0, 0, 1, -zmin }, 0);

		this.xmin = xmin; this.xmax = xmax;
		this.ymin = ymin; this.ymax = ymax;
		this.zmin = zmin; this.zmax = zmax;
	}

	public boolean isClipped(double x, double y, double z)
	{
		return (x < xmin || x > xmax || y < ymin || y > ymax || z < zmin || z > zmax);
	}

	public int clipCode(double x, double y, double z)
	{
		return (
			(x < xmin ? 1 : 0)      |
			(x > xmax ? 1 : 0) << 1 |
			(y < ymin ? 1 : 0) << 2 |
			(y > ymax ? 1 : 0) << 3 |
			(z < zmin ? 1 : 0) << 4 |
			(z > zmax ? 1 : 0) << 5 |
			(isNaN(x, y, z) ? 0 : 1) << 6
		);
	}

	public boolean isNaN(double x, double y, double z)
	{
		return (Double.isNaN(x) || Double.isNaN(y) || Double.isNaN(z));
	}

	public void setCamera(double[] pos, double[] target)
	{
		cameraPos = new Point3D(pos[0], pos[1], pos[2]);
		cameraDir = new Point3D(target[0]-pos[0], target[1]-pos[1], target[2]-pos[2]);
		cameraDir.normalize();
	}

	public void addAlphaPrimitive(double d, Runnable r)
	{
		Double dbl = new Double(d);
		if (alphaPrimitives.containsKey(dbl))
			((List)alphaPrimitives.get(dbl)).add(r);
		else
		{
			List l = new LinkedList();
			l.add(r);
			alphaPrimitives.put(dbl, l);
		}
	}

	private GLUtessellator getTess(boolean fill)
	{
		if (tess == null)
		{
			tess = glu.gluNewTess();
		}
		//glu.gluTessProperty(tess, GLU.GLU_TESS_WINDING_RULE, GLU.GLU_TESS_WINDING_NONZERO);
		glu.gluTessProperty(tess, GLU.GLU_TESS_BOUNDARY_ONLY, (fill ? GL.GL_FALSE : GL.GL_TRUE));
		return tess;
	}

	public void fillPolygon(double[] vIndex, int vmax, double[][] v, double[] c)
	{
		gl.glColor3d(c[0], c[1], c[2]);
		gl.glBegin(GL.GL_POLYGON);
		for (int i=0; i<vmax; i++)
		{
			double[] vertex = v[(int)vIndex[i]-1];
			gl.glVertex3d(vertex[0], vertex[1], vertex[2]);
		}
		gl.glEnd();
	}

	public void fillPolygon(double[] vIndex, int vmax, double[][] v, double[] c,
		double[] n, float as, float ds, float ss, float se)
	{
		gl.glMaterialfv(lightSideMode, GL.GL_SPECULAR,
			new float[] {ss, ss, ss, 1}, 0);
		gl.glMaterialf(lightSideMode, GL.GL_SHININESS, se);
		gl.glMaterialfv(lightSideMode, GL.GL_AMBIENT,
			new float[] {as*(float)c[0], as*(float)c[1], as*(float)c[2], 1}, 0);
		gl.glMaterialfv(lightSideMode, GL.GL_DIFFUSE,
			new float[] {ds*(float)c[0], ds*(float)c[1], ds*(float)c[2], 1}, 0);
		gl.glEnable(GL.GL_LIGHTING);
		gl.glShadeModel(GL.GL_FLAT);
		gl.glNormal3d(n[0], n[1], n[2]);
		fillPolygon(vIndex, vmax, v, c);
		gl.glShadeModel(GL.GL_SMOOTH);
		gl.glDisable(GL.GL_LIGHTING);
	}

	public void fillPolygon(double[] vIndex, int vmax, double[][] v, double[] c,
		double[][] n, float as, float ds, float ss, float se)
	{
		gl.glMaterialfv(lightSideMode, GL.GL_SPECULAR,
			new float[] {ss, ss, ss, 1}, 0);
		gl.glMaterialf(lightSideMode, GL.GL_SHININESS, se);
		gl.glMaterialfv(lightSideMode, GL.GL_AMBIENT,
			new float[] {as*(float)c[0], as*(float)c[1], as*(float)c[2], 1}, 0);
		gl.glMaterialfv(lightSideMode, GL.GL_DIFFUSE,
			new float[] {ds*(float)c[0], ds*(float)c[1], ds*(float)c[2], 1}, 0);
		gl.glEnable(GL.GL_LIGHTING);
		gl.glColor3d(c[0], c[1], c[2]);
		gl.glBegin(GL.GL_POLYGON);
		for (int i=0; i<vmax; i++)
		{
			double[] vertex = v[(int)vIndex[i]-1];
			double[] norm = n[(int)vIndex[i]-1];
			gl.glNormal3d(norm[0], norm[1], norm[2]);
			gl.glVertex3d(vertex[0], vertex[1], vertex[2]);
		}
		gl.glEnd();
		gl.glDisable(GL.GL_LIGHTING);
	}

	public void shadePolygon(double[] vIndex, int vmax, double[][] v, double[][] c)
	{
		gl.glBegin(GL.GL_POLYGON);
		for (int i=0; i<vmax; i++)
		{
			double[] vertex = v[(int)vIndex[i]-1], color = c[(int)vIndex[i]-1];
			gl.glColor3d(color[0], color[1], color[2]);
			gl.glVertex3d(vertex[0], vertex[1], vertex[2]);
		}
		gl.glEnd();
	}

	public void draw(LineObject line)
	{
		double[] x = line.XData.getArray();
		double[] y = line.YData.getArray();
		double[] z = line.ZData.getArray();
		int n = Math.min(Math.min(x.length, y.length), (z.length == 0 ? Integer.MAX_VALUE : z.length));
		int[] clip = new int[n];

		if (z.length == 0)
		{
			double zmid = (zmin+zmax)/2;
			for (int i=0; i<n; i++)
				clip[i] = clipCode(x[i], y[i], zmid);
		}
		else
			for (int i=0; i<n; i++)
				clip[i] = clipCode(x[i], y[i], z[i]);

		if (line.LineStyle.isSet())
		{
			line.LineColor.setup(gl);
			line.LineStyle.setup(gl);
			if (!line.LineStyle.is("-"))
				gl.glEnable(GL.GL_LINE_STIPPLE);
			gl.glLineWidth(line.LineWidth.floatValue());
			
			if (z.length == 0)
			{
				boolean flag = false;
				for (int i=1; i<n; i++)
				{
					if ((clip[i-1] & clip[i]) == 64)
					{
						if (!flag)
						{
							flag = true;
							gl.glBegin(GL.GL_LINE_STRIP);
							gl.glVertex2d(x[i-1], y[i-1]);
						}
						gl.glVertex2d(x[i], y[i]);
					}
					else if (flag)
					{
						gl.glEnd();
						flag = false;
					}
				}
				if (flag)
					gl.glEnd();
			}
			else
			{
				boolean flag = false;
				for (int i=1; i<n; i++)
				{
					if ((clip[i-1] & clip[i]) == 64)
					{
						if (!flag)
						{
							flag = true;
							gl.glBegin(GL.GL_LINE_STRIP);
							gl.glVertex3d(x[i-1], y[i-1], z[i-1]);
						}
						gl.glVertex3d(x[i], y[i], z[i]);
					}
					else if (flag)
					{
						gl.glEnd();
						flag = false;
					}
				}
				if (flag)
					gl.glEnd();
			}

			gl.glDisable(GL.GL_LINE_STIPPLE);
			gl.glLineWidth(1.0f);
			gl.glLineStipple(1, (short)0xFFFF);
		}

		if (line.Marker.isSet())
		{
			MarkerProperty.Marker m = line.Marker.makeMarker(line.MarkerSize.doubleValue(), line.LineWidth.doubleValue()); 
			int w = m.w, h = m.h, xhot = m.xhot, yhot = m.yhot;
			byte[] data = m.data;

			gl.glPixelStorei(GL.GL_UNPACK_ALIGNMENT, 1);
			line.LineColor.setup(gl);
			if (z.length == 0)
			{
				for (int i=0; i<n; i++)
				{
					if (clip[i] == 64)
					{
						gl.glRasterPos2d(x[i], y[i]);
						gl.glBitmap(0, 0, 0, 0, -xhot, -yhot, null, 0);
						gl.glBitmap(w, h, 0, 0, 0, 0, data, 0);
					}
				}
			}
			else
			{
				for (int i=0; i<n; i++)
				{
					if (clip[i] == 64)
					{
						gl.glRasterPos3d(x[i], y[i], z[i]);
						gl.glBitmap(0, 0, 0, 0, -xhot, -yhot, null, 0);
						gl.glBitmap(w, h, 0, 0, 0, 0, data, 0);
					}
				}
			}
			gl.glPixelStorei(GL.GL_UNPACK_ALIGNMENT, 4);
		}
	}
	
	public void draw(LightObject light)
	{
		Color c = light.LightColor.getColor();
		double[] pos = light.Position.getArray();
		boolean isLocal = light.Style.is("local");
		float[] cp = new float[] {c.getRed()/255.0f, c.getGreen()/255.0f, c.getBlue()/255.0f, 1.0f};

		gl.glLightfv(GL.GL_LIGHT0+maxLight, GL.GL_DIFFUSE, cp, 0);
		gl.glLightfv(GL.GL_LIGHT0+maxLight, GL.GL_SPECULAR, cp, 0);
		gl.glLightfv(GL.GL_LIGHT0+maxLight, GL.GL_AMBIENT, new float[] {1,1,1,1}, 0);
		gl.glLightfv(GL.GL_LIGHT0+maxLight, GL.GL_POSITION,
			new float[] {(float)pos[0], (float)pos[1], (float)pos[2], (isLocal ? 1.0f : 0.0f)}, 0);
		gl.glEnable(GL.GL_LIGHT0+maxLight);
		maxLight++;
	}

	public void draw(ByteBuffer data, int w, int h, double[] pos,
		int xOffset, int yOffset, boolean useClipping, boolean useZBuffer)
	{
		boolean hasClip = hasClipping();

		if (hasClip != useClipping)
			setClipping(useClipping);
		if (!useZBuffer)
			gl.glDisable(GL.GL_DEPTH_TEST);
		gl.glEnable(GL.GL_ALPHA_TEST);
		gl.glAlphaFunc(GL.GL_GREATER, 0.0f);
		gl.glRasterPos3d(pos[0], pos[1], pos[2]);
		gl.glBitmap(0, 0, 0, 0, -xOffset, -yOffset, null, 0);
		gl.glDrawPixels(w, h, GL.GL_ABGR_EXT, GL.GL_UNSIGNED_BYTE, data);
		gl.glDisable(GL.GL_ALPHA_TEST);
		if (!useZBuffer)
			gl.glEnable(GL.GL_DEPTH_TEST);
		if (hasClip != useClipping)
			setClipping(!useClipping);
	}

	private class VertexData
	{
		double[] coords;
		double[] color;
		double alpha;
		double[] normal;
		float ambient;
		float diffuse;
		float specular;
		float specularExp;

		VertexData(double[] coords, double[] color, double alpha,
			double[] normal, float ambient, float diffuse, float specular, float specularExp)
		{
			this.coords = coords;
			this.color = color;
			this.alpha = alpha;
			this.normal = normal;
			this.ambient = ambient;
			this.diffuse = diffuse;
			this.specular = specular;
			this.specularExp = specularExp;
		}
	}

	private class PatchTessellator extends GLUtessellatorCallbackAdapter
	{
		private int colorMode; // 0: uni,  1: flat, 2: interp
		private int lightMode; // 0: none, 1: flat, 2: gouraud
		private boolean firstVertex;
		private GL gl;
		private VertexData v0;
		private boolean fill;

		public PatchTessellator(GL gl, int colorMode, int lightMode)
		{
			this.gl = gl;
			this.colorMode = colorMode;
			this.lightMode = lightMode;
		}

		public void beginData(int mode, Object pData)
		{
			firstVertex = true;
			v0 = (VertexData)pData;
			if (colorMode == 2 || lightMode == 2)
				gl.glShadeModel(GL.GL_SMOOTH);
			else
				gl.glShadeModel(GL.GL_FLAT);
			if (mode != GL.GL_LINE_LOOP)
			{
				gl.glEnable(GL.GL_POLYGON_OFFSET_FILL);
				fill = true;
			}
			else
				fill = false;
			gl.glBegin(mode);
		}

		public void end()
		{
			gl.glEnd();
			gl.glDisable(GL.GL_POLYGON_OFFSET_FILL);
		}

		public void vertex(Object vData)
		{
			VertexData v = (VertexData)vData;
			if (colorMode > 0 && (firstVertex || colorMode == 2 || !fill))
			{
				double[] color = ((colorMode == 2 || !fill) ? v.color : v0.color);
				gl.glColor3d(color[0], color[1], color[2]);
				if (lightMode > 0)
				{
					gl.glMaterialfv(lightSideMode, GL.GL_AMBIENT,
						new float[] {v.ambient*(float)color[0], v.ambient*(float)color[1], v.ambient*(float)color[2], 1}, 0);
					gl.glMaterialfv(lightSideMode, GL.GL_DIFFUSE,
						new float[] {v.diffuse*(float)color[0], v.diffuse*(float)color[1], v.diffuse*(float)color[2], 1}, 0);
				}
			}
			if (lightMode > 0 && (firstVertex || lightMode == 2))
				gl.glNormal3d(v.normal[0], v.normal[1], v.normal[2]);
			gl.glVertex3d(v.coords[0], v.coords[1], v.coords[2]);
			firstVertex = false;
		}

		public void combine(double[] coords, Object[] d, float[] w, Object[] outData)
		{
			VertexData v0 = (VertexData)d[0], v1 = (VertexData)d[1], v2 = (VertexData)d[2], v3 = (VertexData)d[3];
			System.out.println(v0);
			System.out.println(v1);
			System.out.println(v2);
			System.out.println(v3);
			if (v0 == null || v1 == null || v2 == null || v3 == null)
				return;
			outData[0] = new VertexData(
				coords,
				(v0.color != null && v1.color != null && v2.color != null && v3.color != null ?
					new double[] {
						w[0]*v0.color[0]+w[1]*v1.color[0]+w[2]*v2.color[0]+w[3]*v3.color[0],
						w[0]*v0.color[1]+w[1]*v1.color[1]+w[2]*v2.color[1]+w[3]*v3.color[1],
						w[0]*v0.color[2]+w[1]*v1.color[2]+w[2]*v2.color[2]+w[3]*v3.color[2]} :
					null),
				w[0]*v0.alpha+w[1]*v1.alpha+w[2]*v2.alpha+w[3]*v3.alpha,
				new double[] {
					w[0]*v0.normal[0]+w[1]*v1.normal[0]+w[2]*v2.normal[0]+w[3]*v3.normal[0],
					w[0]*v0.normal[1]+w[1]*v1.normal[1]+w[2]*v2.normal[1]+w[3]*v3.normal[1],
					w[0]*v0.normal[2]+w[1]*v1.normal[2]+w[2]*v2.normal[2]+w[3]*v3.normal[2]},
				v0.ambient, v0.diffuse, v0.specular, v0.specularExp);
		}
	}
	
	private class PatchTessellatorAlpha extends GLUtessellatorCallbackAdapter
	{
		private int colorMode; // 0: uni,  1: flat, 2: interp
		private int lightMode; // 0: none, 1: flat, 2: gouraud
		private int alphaMode; // 0: uni,  1: flat, 2: interp
		private boolean firstVertex;
		private GLRenderer r;
		private VertexData v0;
		private VertexData[] v;
		private int vCounter;
		private boolean fill;
		private double[] globalColor;
		private double globalAlpha;

		PatchTessellatorAlpha(GLRenderer r, int colorMode, int lightMode, int alphaMode,
			double[] globalColor, double globalAlpha)
		{
			this.r = r;
			this.colorMode = colorMode;
			this.lightMode = lightMode;
			this.alphaMode = alphaMode;
			this.v = new VertexData[3];
			this.globalColor = globalColor;
			this.globalAlpha = globalAlpha;
		}

		public void beginData(int mode, Object pData)
		{
			vCounter = 0;
			v0 = (VertexData)pData;
			fill = (mode != GL.GL_LINE_LOOP);
		}

		public void end()
		{
			if (!fill)
			{
				v[1] = v0;
				addLinePrimitive();
			}
		}

		private void addLinePrimitive()
		{
			Point3D p = new Point3D(0, 0, 0);
			final VertexData[] v = (VertexData[])this.v.clone();
			final VertexData v0 = (VertexData)this.v0;

			p.add(v[0].coords);
			p.add(v[1].coords);
			p.scale(1/2.0);
			p.sub(r.cameraPos);

			r.addAlphaPrimitive(
				-p.dot(r.cameraDir),
				new Runnable() {
					public void run()
					{
						if (lightMode > 0)
						{
							gl.glMaterialfv(lightSideMode, GL.GL_SPECULAR,
								new float[] {v0.specular, v0.specular, v0.specular, 1}, 0);
							gl.glMaterialf(lightSideMode, GL.GL_SHININESS, v0.specularExp);
							gl.glEnable(GL.GL_LIGHTING);
						}
						if (colorMode < 2 && alphaMode < 2)
						{
							double[] color = (colorMode == 0 ? globalColor : v[1].color);
							double alpha = (alphaMode == 0 ? globalAlpha : v[1].alpha);
							gl.glColor4d(color[0], color[1], color[2], alpha);
							if (lightMode > 0)
							{
								gl.glMaterialfv(lightSideMode, GL.GL_AMBIENT,
									new float[] {v0.ambient*(float)color[0], v0.ambient*(float)color[1],
										v0.ambient*(float)color[2], 1}, 0);
								gl.glMaterialfv(lightSideMode, GL.GL_DIFFUSE,
									new float[] {v0.diffuse*(float)color[0], v0.diffuse*(float)color[1],
										v0.diffuse*(float)color[2], (float)alpha}, 0);
							}
						}
						if (lightMode == 1)
							gl.glNormal3d(v[1].normal[0], v[1].normal[1], v[1].normal[2]);
						if (colorMode == 2 || lightMode == 2 || alphaMode == 2)
							gl.glShadeModel(GL.GL_SMOOTH);
						else
							gl.glShadeModel(GL.GL_FLAT);
						gl.glBegin(GL.GL_LINES);
						for (int i=0; i<2; i++)
						{
							if (colorMode == 2 || alphaMode == 2)
							{
								double[] color = (colorMode == 2 ? v[i].color : (colorMode == 1 ? v[1].color : globalColor));
								double alpha = (alphaMode == 2 ? v[i].alpha : (alphaMode == 1 ? v[1].alpha : globalAlpha));
								gl.glColor4d(color[0], color[1], color[2], alpha);
								if (lightMode > 0)
								{
									gl.glMaterialfv(lightSideMode, GL.GL_AMBIENT,
										new float[] {v0.ambient*(float)color[0], v0.ambient*(float)color[1],
											v0.ambient*(float)color[2], 1}, 0);
									gl.glMaterialfv(lightSideMode, GL.GL_DIFFUSE,
										new float[] {v0.diffuse*(float)color[0], v0.diffuse*(float)color[1],
											v0.diffuse*(float)color[2], (float)alpha}, 0);
								}
							}
							if (lightMode == 2)
								gl.glNormal3d(v[i].normal[0], v[i].normal[1], v[i].normal[2]);
							gl.glVertex3d(v[i].coords[0], v[i].coords[1], v[i].coords[2]);
						}
						gl.glEnd();
						if (lightMode > 0)
							gl.glDisable(GL.GL_LIGHTING);
					}
				});
		}

		public void vertex(Object vData)
		{
			if (fill)
			{
				v[vCounter%3] = (VertexData)vData;
				vCounter++;

				if ((vCounter%3) == 0)
				{
					Point3D p = new Point3D(0, 0, 0);
					final VertexData[] v = (VertexData[])this.v.clone();
					final VertexData v0 = (VertexData)this.v0;

					for (int i=0; i<3; i++)
						p.add(v[i].coords);
					p.scale(1/3.0);
					p.sub(r.cameraPos);

					r.addAlphaPrimitive(
							-p.dot(r.cameraDir),
							new Runnable() {
								public void run()
								{
									if (lightMode > 0)
									{
										gl.glMaterialfv(lightSideMode, GL.GL_SPECULAR,
											new float[] {v0.specular, v0.specular, v0.specular, 1}, 0);
										gl.glMaterialf(lightSideMode, GL.GL_SHININESS, v0.specularExp);
										gl.glEnable(GL.GL_LIGHTING);
									}
									if (colorMode < 2 && alphaMode < 2)
									{
										double[] color = (colorMode == 0 ? globalColor : v0.color);
										double alpha = (alphaMode == 0 ? globalAlpha : v0.alpha);
										gl.glColor4d(color[0], color[1], color[2], alpha);
										if (lightMode > 0)
										{
											gl.glMaterialfv(lightSideMode, GL.GL_AMBIENT,
												new float[] {v0.ambient*(float)color[0], v0.ambient*(float)color[1],
													v0.ambient*(float)color[2], 1}, 0);
											gl.glMaterialfv(lightSideMode, GL.GL_DIFFUSE,
													new float[] {v0.diffuse*(float)color[0], v0.diffuse*(float)color[1],
														v0.diffuse*(float)color[2], (float)alpha}, 0);
										}
									}
									if (lightMode == 1)
										gl.glNormal3d(v0.normal[0], v0.normal[1], v0.normal[2]);
									if (colorMode == 2 || lightMode == 2 || alphaMode == 2)
										gl.glShadeModel(GL.GL_SMOOTH);
									else
										gl.glShadeModel(GL.GL_FLAT);
									gl.glEnable(GL.GL_POLYGON_OFFSET_FILL);
									gl.glBegin(GL.GL_TRIANGLES);
									for (int i=0; i<3; i++)
									{
										if (colorMode == 2 || alphaMode == 2)
										{
											double[] color = (colorMode == 2 ? v[i].color : (colorMode == 1 ? v0.color : globalColor));
											double alpha = (alphaMode == 2 ? v[i].alpha : (alphaMode == 1 ? v0.alpha : globalAlpha));
											gl.glColor4d(color[0], color[1], color[2], alpha);
											if (lightMode > 0)
											{
												gl.glMaterialfv(lightSideMode, GL.GL_AMBIENT,
														new float[] {v0.ambient*(float)color[0], v0.ambient*(float)color[1],
															v0.ambient*(float)color[2], 1}, 0);
												gl.glMaterialfv(lightSideMode, GL.GL_DIFFUSE,
														new float[] {v0.diffuse*(float)color[0], v0.diffuse*(float)color[1],
															v0.diffuse*(float)color[2], (float)alpha}, 0);
											}
										}
										if (lightMode == 2)
											gl.glNormal3d(v[i].normal[0], v[i].normal[1], v[i].normal[2]);
										gl.glVertex3d(v[i].coords[0], v[i].coords[1], v[i].coords[2]);
									}
									gl.glEnd();
									gl.glDisable(GL.GL_POLYGON_OFFSET_FILL);
									if (lightMode > 0)
										gl.glDisable(GL.GL_LIGHTING);
								}
							});
				}
			}
			else
			{
				v[vCounter] = (VertexData)vData;
				if (vCounter == 0)
				{
					v0 = v[vCounter];
					vCounter++;
				}
				else
				{
					addLinePrimitive();
					v[0] = v[1];
				}
			}
		}
		
		public void combine(double[] coords, Object[] d, float[] w, Object[] outData)
		{
			VertexData v0 = (VertexData)d[0], v1 = (VertexData)d[1], v2 = (VertexData)d[2], v3 = (VertexData)d[3];
			if (v0 == null || v1 == null || v2 == null || v3 == null)
				return;
			outData[0] = new VertexData(
				coords,
				(v0.color != null && v1.color != null && v2.color != null && v3.color != null ?
					new double[] {
						w[0]*v0.color[0]+w[1]*v1.color[0]+w[2]*v2.color[0]+w[3]*v3.color[0],
						w[0]*v0.color[1]+w[1]*v1.color[1]+w[2]*v2.color[1]+w[3]*v3.color[1],
						w[0]*v0.color[2]+w[1]*v1.color[2]+w[2]*v2.color[2]+w[3]*v3.color[2]} :
					null),
				w[0]*v0.alpha+w[1]*v1.alpha+w[2]*v2.alpha+w[3]*v3.alpha,
				new double[] {
					w[0]*v0.normal[0]+w[1]*v1.normal[0]+w[2]*v2.normal[0]+w[3]*v3.normal[0],
					w[0]*v0.normal[1]+w[1]*v1.normal[1]+w[2]*v2.normal[1]+w[3]*v3.normal[1],
					w[0]*v0.normal[2]+w[1]*v1.normal[2]+w[2]*v2.normal[2]+w[3]*v3.normal[2]},
				v0.ambient, v0.diffuse, v0.specular, v0.specularExp);
		}
	}

	public void draw(PatchObject patch)
	{
		double[][] f = patch.Faces.getMatrix();
		double[][] v = patch.Vertices.getMatrix();
		double[][] c = null;
		double[][] n = patch.VertexNormals.getMatrix();
		double[] a = null;
		int[] faceCount = patch.getFaceCount();

		boolean hasFaceColor = false;
		boolean hasFaceAlpha = false;
		int faceColorMode = (patch.FaceColor.isSet() ? 0 : (patch.FaceColor.is("flat") ? 1 : 2));
		int faceLightMode = (patch.FaceLighting.is("none") ? 0 : (patch.FaceLighting.is("flat") ? 1 : 2));
		int faceAlphaMode = (patch.FaceAlpha.isDouble() ? 0 : (patch.FaceAlpha.is("flat") ? 1 : 2));
		int edgeColorMode = (patch.EdgeColor.isSet() ? 0 : (patch.EdgeColor.is("flat") ? 1 : 2));
		int edgeLightMode = (patch.EdgeLighting.is("none") ? 0 : (patch.EdgeLighting.is("flat") ? 1 : 2));
		int edgeAlphaMode = (patch.EdgeAlpha.isDouble() ? 0 : (patch.EdgeAlpha.is("flat") ? 1 : 2));

		double[] fcolor = patch.FaceColor.getArray();
		double[] ecolor = patch.EdgeColor.getArray();

		float as = patch.AmbientStrength.floatValue();
		float ds = patch.DiffuseStrength.floatValue();
		float ss = patch.SpecularStrength.floatValue();
		float se = patch.SpecularExponent.floatValue();

		if (!patch.FaceColor.isSet() || !patch.EdgeColor.isSet())
		{
			c = patch.getCData();
			hasFaceColor = (c != null && c.length == f.length);
		}

		if (faceAlphaMode > 0 || edgeAlphaMode > 0)
		{
			a = patch.getAlphaData();
			hasFaceAlpha = (a != null && a.length == f.length);
		}

		VertexData[][] vData = new VertexData[f.length][];
		for (int i=0; i<f.length; i++)
		{
			vData[i] = new VertexData[faceCount[i]];
			for (int j=0; j<faceCount[i]; j++)
			{
				int k = (int)f[i][j]-1;
				vData[i][j] = new VertexData(
					v[k],
					(c == null ? null : (hasFaceColor ? c[i] : c[k])),
					(a == null ? 1.0 : (hasFaceAlpha ? a[i] : a[k])),
					n[k],
					as, ds, ss, se);
			}
		}

		if (faceLightMode > 0 || edgeLightMode > 0)
		{
			gl.glMaterialfv(lightSideMode, GL.GL_SPECULAR,
				new float[] {ss, ss, ss, 1}, 0);
			gl.glMaterialf(lightSideMode, GL.GL_SHININESS, se);
		}

		if (!patch.FaceColor.is("none"))
		{
			if (patch.FaceAlpha.isDouble() && patch.FaceAlpha.doubleValue() == 1)
			{
				if (faceColorMode == 0)
				{
					gl.glColor3d(fcolor[0], fcolor[1], fcolor[2]);
					if (faceLightMode > 0)
					{
						gl.glMaterialfv(lightSideMode, GL.GL_AMBIENT,
							new float[] {as*(float)fcolor[0], as*(float)fcolor[1], as*(float)fcolor[2], 1}, 0); 
						gl.glMaterialfv(lightSideMode, GL.GL_DIFFUSE,
							new float[] {ds*(float)fcolor[0], ds*(float)fcolor[1], ds*(float)fcolor[2], 1}, 0); 
					}
				}

				if (faceLightMode > 0)
					gl.glEnable(GL.GL_LIGHTING);

				GLUtessellator tess = getTess(true);
				GLUtessellatorCallback cb = new PatchTessellator(gl, faceColorMode, faceLightMode);
						
				glu.gluTessCallback(tess, GLU.GLU_TESS_BEGIN_DATA,  cb);
				glu.gluTessCallback(tess, GLU.GLU_TESS_END,  cb);
				glu.gluTessCallback(tess, GLU.GLU_TESS_COMBINE,  cb);
				glu.gluTessCallback(tess, GLU.GLU_TESS_VERTEX,  cb);
				glu.gluTessCallback(tess, GLU.GLU_TESS_EDGE_FLAG,  null);
						
				for (int i=0; i<f.length; i++)
				{
					glu.gluTessBeginPolygon(tess, vData[i][0]);
					glu.gluTessBeginContour(tess);
					for (int j=0; j<faceCount[i]; j++)
					{
						int index = (int)f[i][j]-1;
						glu.gluTessVertex(tess, v[index], 0, vData[i][j]);
					}
					glu.gluTessEndContour(tess);
					glu.gluTessEndPolygon(tess);
				}

				if (faceLightMode > 0)
					gl.glDisable(GL.GL_LIGHTING);
			}
			else
			{
				GLUtessellator tess = getTess(true);
				GLUtessellatorCallback cb = new PatchTessellatorAlpha(this, faceColorMode, faceLightMode, faceAlphaMode,
								fcolor, (faceAlphaMode == 0 ? patch.FaceAlpha.doubleValue() : 1.0));
				
				glu.gluTessCallback(tess, GLU.GLU_TESS_BEGIN_DATA,  cb);
				glu.gluTessCallback(tess, GLU.GLU_TESS_END,  cb);
				glu.gluTessCallback(tess, GLU.GLU_TESS_COMBINE,  cb);
				glu.gluTessCallback(tess, GLU.GLU_TESS_VERTEX,  cb);
				glu.gluTessCallback(tess, GLU.GLU_TESS_EDGE_FLAG,  cb);
						
				for (int i=0; i<f.length; i++)
				{
					glu.gluTessBeginPolygon(tess, vData[i][0]);
					glu.gluTessBeginContour(tess);
					for (int j=0; j<faceCount[i]; j++)
					{
						int index = (int)f[i][j]-1;
						glu.gluTessVertex(tess, v[index], 0, vData[i][j]);
					}
					glu.gluTessEndContour(tess);
					glu.gluTessEndPolygon(tess);
				}
			}
		}
		
		if (!patch.EdgeColor.is("none"))
		{
			if (patch.EdgeAlpha.isDouble() && patch.EdgeAlpha.doubleValue() == 1)
			{
				if (edgeColorMode == 0)
				{
					gl.glColor3d(ecolor[0], ecolor[1], ecolor[2]);
					if (edgeLightMode > 0)
					{
						gl.glMaterialfv(lightSideMode, GL.GL_AMBIENT,
							new float[] {as*(float)ecolor[0], as*(float)ecolor[1], as*(float)ecolor[2], 1}, 0); 
						gl.glMaterialfv(lightSideMode, GL.GL_DIFFUSE,
							new float[] {ds*(float)ecolor[0], ds*(float)ecolor[1], ds*(float)ecolor[2], 1}, 0); 
					}
				}

				if (edgeLightMode > 0)
					gl.glEnable(GL.GL_LIGHTING);

				GLUtessellator tess = getTess(false);
				GLUtessellatorCallback cb = new PatchTessellator(gl, edgeColorMode, edgeLightMode);
						
				glu.gluTessCallback(tess, GLU.GLU_TESS_BEGIN_DATA,  cb);
				glu.gluTessCallback(tess, GLU.GLU_TESS_END,  cb);
				glu.gluTessCallback(tess, GLU.GLU_TESS_COMBINE,  cb);
				glu.gluTessCallback(tess, GLU.GLU_TESS_VERTEX,  cb);
				glu.gluTessCallback(tess, GLU.GLU_TESS_EDGE_FLAG,  null);
						
				for (int i=0; i<f.length; i++)
				{
					glu.gluTessBeginPolygon(tess, vData[i][0]);
					glu.gluTessBeginContour(tess);
					for (int j=0; j<faceCount[i]; j++)
					{
						int index = (int)f[i][j]-1;
						glu.gluTessVertex(tess, v[index], 0, vData[i][j]);
					}
					glu.gluTessEndContour(tess);
					glu.gluTessEndPolygon(tess);
				}

				if (edgeLightMode > 0)
					gl.glDisable(GL.GL_LIGHTING);
			}
			else
			{
				GLUtessellator tess = getTess(false);
				GLUtessellatorCallback cb = new PatchTessellatorAlpha(this, edgeColorMode, edgeLightMode, edgeAlphaMode,
								ecolor, (edgeAlphaMode == 0 ? patch.EdgeAlpha.doubleValue() : 1.0));
				
				glu.gluTessCallback(tess, GLU.GLU_TESS_BEGIN_DATA,  cb);
				glu.gluTessCallback(tess, GLU.GLU_TESS_END,  cb);
				glu.gluTessCallback(tess, GLU.GLU_TESS_COMBINE,  cb);
				glu.gluTessCallback(tess, GLU.GLU_TESS_VERTEX,  cb);
				glu.gluTessCallback(tess, GLU.GLU_TESS_EDGE_FLAG,  null);

				for (int i=0; i<f.length; i++)
				{
					glu.gluTessBeginPolygon(tess, vData[i][0]);
					glu.gluTessBeginContour(tess);
					for (int j=0; j<faceCount[i]; j++)
					{
						int index = (int)f[i][j]-1;
						glu.gluTessVertex(tess, v[index], 0, vData[i][j]);
					}
					glu.gluTessEndContour(tess);
					glu.gluTessEndPolygon(tess);
				}
			}
		}

	}

	public void draw(SurfaceObject surf)
	{
		double[][] x = surf.XData.getMatrix();
		double[][] y = surf.YData.getMatrix();
		double[][] z = surf.ZData.getMatrix();
		double[][][] c = null;
		double[][][] n = surf.VertexNormals.getMatrix3();
		double[][] a = null;
		
		final int faceColorMode = (surf.FaceColor.isSet() ? 0 : (surf.FaceColor.is("flat") ? 1 : (surf.FaceColor.is("interp") ? 2 : -1)));
		final int faceLightMode = (surf.FaceLighting.is("none") ? 0 : (surf.FaceLighting.is("flat") ? 1 : 2));
		final int faceAlphaMode = (surf.FaceAlpha.isDouble() ? 0 : (surf.FaceAlpha.is("flat") ? 1 : 2));
		final int edgeColorMode = (surf.EdgeColor.isSet() ? 0 : (surf.EdgeColor.is("flat") ? 1 : (surf.EdgeColor.is("interp") ? 2 : -1)));
		final int edgeLightMode = (surf.EdgeLighting.is("none") ? 0 : (surf.EdgeLighting.is("flat") ? 1 : 2));
		final int edgeAlphaMode = (surf.EdgeAlpha.isDouble() ? 0 : (surf.EdgeAlpha.is("flat") ? 1 : 2));

		final double[] fcolor = surf.FaceColor.getArray();
		final double[] ecolor = surf.EdgeColor.getArray();

		final float as = surf.AmbientStrength.floatValue();
		final float ds = surf.DiffuseStrength.floatValue();
		final float ss = surf.SpecularStrength.floatValue();
		final float se = surf.SpecularExponent.floatValue();

		if (faceColorMode > 0 || edgeColorMode > 0)
		{
			c = surf.getCData();
		}

		if (faceAlphaMode > 0 || edgeAlphaMode > 0)
		{
			a = surf.getAlphaData();
		}

		if (faceLightMode > 0 || edgeLightMode > 0)
		{
			gl.glMaterialfv(lightSideMode, GL.GL_SPECULAR,
				new float[] {ss, ss, ss, 1}, 0);
			gl.glMaterialf(lightSideMode, GL.GL_SHININESS, se);
		}

		if (!surf.FaceColor.is("none"))
		{
			if (surf.FaceAlpha.isDouble() && surf.FaceAlpha.doubleValue() == 1)
			{
				if (faceColorMode == 0)
				{
					gl.glColor3d(fcolor[0], fcolor[1], fcolor[2]);
					if (faceLightMode > 0)
					{
						gl.glMaterialfv(lightSideMode, GL.GL_AMBIENT,
							new float[] {as*(float)fcolor[0], as*(float)fcolor[1], as*(float)fcolor[2], 1}, 0); 
						gl.glMaterialfv(lightSideMode, GL.GL_DIFFUSE,
							new float[] {ds*(float)fcolor[0], ds*(float)fcolor[1], ds*(float)fcolor[2], 1}, 0); 
					}
				}

				if (faceLightMode > 0)
					gl.glEnable(GL.GL_LIGHTING);
				gl.glShadeModel((faceColorMode == 2 || faceLightMode == 2) ? GL.GL_SMOOTH : GL.GL_FLAT);
				gl.glEnable(GL.GL_POLYGON_OFFSET_FILL);

				// TODO: remove
				//System.out.println("GL_LIGHT0 is " + gl.glIsEnabled(GL.GL_LIGHT0));
				//System.out.println("GL_LIGHTING is " + gl.glIsEnabled(GL.GL_LIGHTING));
				//System.out.println("GL_CULL_FACE is " + gl.glIsEnabled(GL.GL_CULL_FACE));
				//System.out.println("GL_NORMALIZE is " + gl.glIsEnabled(GL.GL_NORMALIZE));

				for (int i=1; i<x.length; i++)
					for (int j=1; j<x[i].length; j++)
					{
						gl.glBegin(GL.GL_QUADS);

						// Vertex 1
						if (faceColorMode > 0)
						{
							double[] C = c[i-1][j-1];
							gl.glColor3d(C[0], C[1], C[2]);
							if (faceLightMode > 0)
							{
								gl.glMaterialfv(lightSideMode, GL.GL_AMBIENT,
										new float[] {as*(float)C[0], as*(float)C[1], as*(float)C[2], 1}, 0);
								gl.glMaterialfv(lightSideMode, GL.GL_DIFFUSE,
										new float[] {ds*(float)C[0], ds*(float)C[1], ds*(float)C[2], 1}, 0);
							}
						}
						if (faceLightMode > 0)
							gl.glNormal3d(n[i-1][j-1][0], n[i-1][j-1][1], n[i-1][j-1][2]);
						gl.glVertex3d(x[i-1][j-1], y[i-1][j-1], z[i-1][j-1]);

						// Vertex 2
						if (faceColorMode == 2)
						{
							double[] C = c[i][j-1];
							gl.glColor3d(C[0], C[1], C[2]);
							if (faceLightMode > 0)
							{
								gl.glMaterialfv(lightSideMode, GL.GL_AMBIENT,
										new float[] {as*(float)C[0], as*(float)C[1], as*(float)C[2], 1}, 0);
								gl.glMaterialfv(lightSideMode, GL.GL_DIFFUSE,
										new float[] {ds*(float)C[0], ds*(float)C[1], ds*(float)C[2], 1}, 0);
							}
						}
						if (faceLightMode == 2)
							gl.glNormal3d(n[i][j-1][0], n[i][j-1][1], n[i][j-1][2]);
						gl.glVertex3d(x[i][j-1], y[i][j-1], z[i][j-1]);

						// Vertex 3
						if (faceColorMode == 2)
						{
							double[] C = c[i][j];
							gl.glColor3d(C[0], C[1], C[2]);
							if (faceLightMode > 0)
							{
								gl.glMaterialfv(lightSideMode, GL.GL_AMBIENT,
										new float[] {as*(float)C[0], as*(float)C[1], as*(float)C[2], 1}, 0);
								gl.glMaterialfv(lightSideMode, GL.GL_DIFFUSE,
										new float[] {ds*(float)C[0], ds*(float)C[1], ds*(float)C[2], 1}, 0);
							}
						}
						if (faceLightMode == 2)
							gl.glNormal3d(n[i][j][0], n[i][j][1], n[i][j][2]);
						gl.glVertex3d(x[i][j], y[i][j], z[i][j]);

						// Vertex 4
						if (faceColorMode == 2)
						{
							double[] C = c[i-1][j];
							gl.glColor3d(C[0], C[1], C[2]);
							if (faceLightMode > 0)
							{
								gl.glMaterialfv(lightSideMode, GL.GL_AMBIENT,
										new float[] {as*(float)C[0], as*(float)C[1], as*(float)C[2], 1}, 0);
								gl.glMaterialfv(lightSideMode, GL.GL_DIFFUSE,
										new float[] {ds*(float)C[0], ds*(float)C[1], ds*(float)C[2], 1}, 0);
							}
						}
						if (faceLightMode == 2)
							gl.glNormal3d(n[i-1][j][0], n[i-1][j][1], n[i-1][j][2]);
						gl.glVertex3d(x[i-1][j], y[i-1][j], z[i-1][j]);

						gl.glEnd();
					}

				gl.glDisable(GL.GL_POLYGON_OFFSET_FILL);

				if (faceLightMode > 0)
					gl.glDisable(GL.GL_LIGHTING);
			}
			else
			{
				final double falpha = surf.FaceAlpha.doubleValue();

				for (int i=1; i<x.length; i++)
					for (int j=1; j<x[i].length; j++)
					{
						final double[] xx = new double[] {x[i-1][j-1], x[i][j-1], x[i][j], x[i-1][j]};
						final double[] yy = new double[] {y[i-1][j-1], y[i][j-1], y[i][j], y[i-1][j]};
						final double[] zz = new double[] {z[i-1][j-1], z[i][j-1], z[i][j], z[i-1][j]};
						final double[][] nn = new double[][] {n[i-1][j-1], n[i][j-1], n[i][j], n[i-1][j]};
						final double[][] cc = (c != null ? new double[][] {c[i-1][j-1], c[i][j-1], c[i][j], c[i-1][j]} : null);
						final double[] aa = (a != null ? new double[] {a[i-1][j-1], a[i][j-1], a[i][j], a[i-1][j]} : null);

						Point3D center = new Point3D(
							(xx[0]+xx[1]+xx[2]+xx[3])/4,
							(yy[0]+yy[1]+yy[2]+yy[3])/4,
							(zz[0]+zz[1]+zz[2]+zz[3])/4);
						center.sub(cameraPos);

						addAlphaPrimitive(
							-center.dot(cameraDir),
							new Runnable() {
								public void run()
								{
									if (faceLightMode > 0)
									{
										gl.glMaterialfv(lightSideMode, GL.GL_SPECULAR,
											new float[] {ss, ss, ss, 1}, 0);
										gl.glMaterialf(lightSideMode, GL.GL_SHININESS, se);
										gl.glEnable(GL.GL_LIGHTING);
									}
									if (faceColorMode < 2 && faceAlphaMode < 2)
									{
										double[] C = (faceColorMode == 0 ? fcolor : cc[0]);
										double a = (faceAlphaMode == 0 ? falpha : aa[0]);
										gl.glColor4d(C[0], C[1], C[2], a);
										if (faceLightMode > 0)
										{
											gl.glMaterialfv(lightSideMode, GL.GL_AMBIENT,
												new float[] {as*(float)C[0], as*(float)C[1], as*(float)C[2], 1}, 0);
											gl.glMaterialfv(lightSideMode, GL.GL_DIFFUSE,
												new float[] {ds*(float)C[0], ds*(float)C[1], ds*(float)C[2], (float)a}, 0);
										}
									}
									if (faceLightMode == 1)
										gl.glNormal3d(nn[0][0], nn[0][1], nn[0][2]);
									if (faceColorMode == 2 || faceLightMode == 2 || faceAlphaMode == 2)
										gl.glShadeModel(GL.GL_SMOOTH);
									else
										gl.glShadeModel(GL.GL_FLAT);
									gl.glEnable(GL.GL_POLYGON_OFFSET_FILL);
									gl.glBegin(GL.GL_QUADS);
									for (int i=0; i<4; i++)
									{
										if (faceColorMode == 2 || faceAlphaMode == 2)
										{
											double[] C = (faceColorMode == 2 ? cc[i] : (faceColorMode == 1 ? cc[0] : fcolor));
											double a = (faceAlphaMode == 2 ? aa[i] : (faceAlphaMode == 1 ? aa[0] : falpha));
											gl.glColor4d(C[0], C[1], C[2], a);
											if (faceLightMode > 0)
											{
												gl.glMaterialfv(lightSideMode, GL.GL_AMBIENT,
													new float[] {as*(float)C[0], as*(float)C[1], as*(float)C[2], 1}, 0);
												gl.glMaterialfv(lightSideMode, GL.GL_DIFFUSE,
													new float[] {ds*(float)C[0], ds*(float)C[1], ds*(float)C[2], (float)a}, 0);
											}
										}
										if (faceLightMode == 2)
											gl.glNormal3d(nn[i][0], nn[i][1], nn[i][2]);
										gl.glVertex3d(xx[i], yy[i], zz[i]);
									}
									gl.glEnd();
									gl.glDisable(GL.GL_POLYGON_OFFSET_FILL);
									if (faceLightMode > 0)
										gl.glDisable(GL.GL_LIGHTING);
								}
							});
					}
			}
		}

		if (!surf.EdgeColor.is("none"))
		{
			if (surf.EdgeAlpha.isDouble() && surf.EdgeAlpha.doubleValue() == 1)
			{
				if (edgeColorMode == 0)
				{
					gl.glColor3d(ecolor[0], ecolor[1], ecolor[2]);
					if (edgeLightMode > 0)
					{
						gl.glMaterialfv(lightSideMode, GL.GL_AMBIENT,
							new float[] {as*(float)ecolor[0], as*(float)ecolor[1], as*(float)ecolor[2], 1}, 0); 
						gl.glMaterialfv(lightSideMode, GL.GL_DIFFUSE,
							new float[] {ds*(float)ecolor[0], ds*(float)ecolor[1], ds*(float)ecolor[2], 1}, 0); 
					}
				}

				if (edgeLightMode > 0)
					gl.glEnable(GL.GL_LIGHTING);
				gl.glShadeModel((edgeColorMode == 2 || edgeLightMode == 2) ? GL.GL_SMOOTH : GL.GL_FLAT);

				for (int i=0; i<x.length; i++)
				{
					for (int j=1; j<x[i].length; j++)
					{
						gl.glBegin(GL.GL_LINES);

						// Vertex 1
						if (edgeColorMode > 0)
						{
							double[] C = c[i][j-1];
							gl.glColor3d(C[0], C[1], C[2]);
							if (edgeLightMode > 0)
							{
								gl.glMaterialfv(lightSideMode, GL.GL_AMBIENT,
										new float[] {as*(float)C[0], as*(float)C[1], as*(float)C[2], 1}, 0);
								gl.glMaterialfv(lightSideMode, GL.GL_DIFFUSE,
										new float[] {ds*(float)C[0], ds*(float)C[1], ds*(float)C[2], 1}, 0);
							}
						}
						if (edgeLightMode > 0)
							gl.glNormal3d(n[i][j-1][0], n[i][j-1][1], n[i][j-1][2]);
						gl.glVertex3d(x[i][j-1], y[i][j-1], z[i][j-1]);

						// Vertex 2
						if (edgeColorMode == 2)
						{
							double[] C = c[i][j];
							gl.glColor3d(C[0], C[1], C[2]);
							if (edgeLightMode > 0)
							{
								gl.glMaterialfv(lightSideMode, GL.GL_AMBIENT,
										new float[] {as*(float)C[0], as*(float)C[1], as*(float)C[2], 1}, 0);
								gl.glMaterialfv(lightSideMode, GL.GL_DIFFUSE,
										new float[] {ds*(float)C[0], ds*(float)C[1], ds*(float)C[2], 1}, 0);
							}
						}
						if (edgeLightMode == 2)
							gl.glNormal3d(n[i][j][0], n[i][j][1], n[i][j][2]);
						gl.glVertex3d(x[i][j], y[i][j], z[i][j]);

						gl.glEnd();
					}
				}
				
				for (int j=0; j<y.length; j++)
				{
					for (int i=1; i<y[j].length; i++)
					{
						gl.glBegin(GL.GL_LINES);

						// Vertex 1
						if (edgeColorMode > 0)
						{
							double[] C = c[i-1][j];
							gl.glColor3d(C[0], C[1], C[2]);
							if (edgeLightMode > 0)
							{
								gl.glMaterialfv(lightSideMode, GL.GL_AMBIENT,
										new float[] {as*(float)C[0], as*(float)C[1], as*(float)C[2], 1}, 0);
								gl.glMaterialfv(lightSideMode, GL.GL_DIFFUSE,
										new float[] {ds*(float)C[0], ds*(float)C[1], ds*(float)C[2], 1}, 0);
							}
						}
						if (edgeLightMode > 0)
							gl.glNormal3d(n[i-1][j][0], n[i-1][j][1], n[i-1][j][2]);
						gl.glVertex3d(x[i-1][j], y[i-1][j], z[i-1][j]);

						// Vertex 2
						if (edgeColorMode == 2)
						{
							double[] C = c[i][j];
							gl.glColor3d(C[0], C[1], C[2]);
							if (edgeLightMode > 0)
							{
								gl.glMaterialfv(lightSideMode, GL.GL_AMBIENT,
										new float[] {as*(float)C[0], as*(float)C[1], as*(float)C[2], 1}, 0);
								gl.glMaterialfv(lightSideMode, GL.GL_DIFFUSE,
										new float[] {ds*(float)C[0], ds*(float)C[1], ds*(float)C[2], 1}, 0);
							}
						}
						if (edgeLightMode == 2)
							gl.glNormal3d(n[i][j][0], n[i][j][1], n[i][j][2]);
						gl.glVertex3d(x[i][j], y[i][j], z[i][j]);

						gl.glEnd();
					}
				}

				if (edgeLightMode > 0)
					gl.glDisable(GL.GL_LIGHTING);
			}
			else
			{
				final double ealpha = surf.EdgeAlpha.doubleValue();

				for (int i=0; i<x.length; i++)
				{
					for (int j=1; j<x[i].length; j++)
					{
						final double[] xx = new double[] {x[i][j-1], x[i][j]};
						final double[] yy = new double[] {y[i][j-1], y[i][j]};
						final double[] zz = new double[] {z[i][j-1], z[i][j]};
						final double[][] nn = new double[][] {n[i][j-1], n[i][j]};
						final double[][] cc = (c != null ? new double[][] {c[i][j-1], c[i][j]} : null);
						final double[] aa = (a != null ? new double[] {a[i][j-1], a[i][j]} : null);

						Point3D center = new Point3D(
							(xx[0]+xx[1])/2,
							(yy[0]+yy[1])/2,
							(zz[0]+zz[1])/2);
						center.sub(cameraPos);

						addAlphaPrimitive(
							-center.dot(cameraDir),
							new Runnable() {
								public void run()
								{
									if (edgeLightMode > 0)
									{
										gl.glMaterialfv(lightSideMode, GL.GL_SPECULAR,
											new float[] {ss, ss, ss, 1}, 0);
										gl.glMaterialf(lightSideMode, GL.GL_SHININESS, se);
										gl.glEnable(GL.GL_LIGHTING);
									}
									if (edgeColorMode < 2 && edgeAlphaMode < 2)
									{
										double[] C = (edgeColorMode == 0 ? ecolor : cc[0]);
										double a = (edgeAlphaMode == 0 ? ealpha : aa[0]);
										gl.glColor4d(C[0], C[1], C[2], a);
										if (edgeLightMode > 0)
										{
											gl.glMaterialfv(lightSideMode, GL.GL_AMBIENT,
												new float[] {as*(float)C[0], as*(float)C[1], as*(float)C[2], 1}, 0);
											gl.glMaterialfv(lightSideMode, GL.GL_DIFFUSE,
												new float[] {ds*(float)C[0], ds*(float)C[1], ds*(float)C[2], (float)a}, 0);
										}
									}
									if (edgeLightMode == 1)
										gl.glNormal3d(nn[0][0], nn[0][1], nn[0][2]);
									if (edgeColorMode == 2 || edgeLightMode == 2 || edgeAlphaMode == 2)
										gl.glShadeModel(GL.GL_SMOOTH);
									else
										gl.glShadeModel(GL.GL_FLAT);
									gl.glBegin(GL.GL_LINES);
									for (int i=0; i<2; i++)
									{
										if (edgeColorMode == 2 || edgeAlphaMode == 2)
										{
											double[] C = (edgeColorMode == 2 ? cc[i] : (edgeColorMode == 1 ? cc[0] : ecolor));
											double a = (edgeAlphaMode == 2 ? aa[i] : (edgeAlphaMode == 1 ? aa[0] : ealpha));
											gl.glColor4d(C[0], C[1], C[2], a);
											if (edgeLightMode > 0)
											{
												gl.glMaterialfv(lightSideMode, GL.GL_AMBIENT,
													new float[] {as*(float)C[0], as*(float)C[1], as*(float)C[2], 1}, 0);
												gl.glMaterialfv(lightSideMode, GL.GL_DIFFUSE,
													new float[] {ds*(float)C[0], ds*(float)C[1], ds*(float)C[2], (float)a}, 0);
											}
										}
										if (edgeLightMode == 2)
											gl.glNormal3d(nn[i][0], nn[i][1], nn[i][2]);
										gl.glVertex3d(xx[i], yy[i], zz[i]);
									}
									gl.glEnd();
									if (edgeLightMode > 0)
										gl.glDisable(GL.GL_LIGHTING);
								}
							});
					}
				}
				
				for (int j=0; j<y.length; j++)
				{
					for (int i=1; i<y[j].length; i++)
					{
						final double[] xx = new double[] {x[i-1][j], x[i][j]};
						final double[] yy = new double[] {y[i-1][j], y[i][j]};
						final double[] zz = new double[] {z[i-1][j], z[i][j]};
						final double[][] nn = new double[][] {n[i-1][j], n[i][j]};
						final double[][] cc = (c != null ? new double[][] {c[i-1][j], c[i][j]} : null);
						final double[] aa = (a != null ? new double[] {a[i-1][j], a[i][j]} : null);

						Point3D center = new Point3D(
							(xx[0]+xx[1])/2,
							(yy[0]+yy[1])/2,
							(zz[0]+zz[1])/2);
						center.sub(cameraPos);

						addAlphaPrimitive(
							-center.dot(cameraDir),
							new Runnable() {
								public void run()
								{
									if (edgeLightMode > 0)
									{
										gl.glMaterialfv(lightSideMode, GL.GL_SPECULAR,
											new float[] {ss, ss, ss, 1}, 0);
										gl.glMaterialf(lightSideMode, GL.GL_SHININESS, se);
										gl.glEnable(GL.GL_LIGHTING);
									}
									if (edgeColorMode < 2 && edgeAlphaMode < 2)
									{
										double[] C = (edgeColorMode == 0 ? ecolor : cc[0]);
										double a = (edgeAlphaMode == 0 ? ealpha : aa[0]);
										gl.glColor4d(C[0], C[1], C[2], a);
										if (edgeLightMode > 0)
										{
											gl.glMaterialfv(lightSideMode, GL.GL_AMBIENT,
												new float[] {as*(float)C[0], as*(float)C[1], as*(float)C[2], 1}, 0);
											gl.glMaterialfv(lightSideMode, GL.GL_DIFFUSE,
												new float[] {ds*(float)C[0], ds*(float)C[1], ds*(float)C[2], (float)a}, 0);
										}
									}
									if (edgeLightMode == 1)
										gl.glNormal3d(nn[0][0], nn[0][1], nn[0][2]);
									if (edgeColorMode == 2 || edgeLightMode == 2 || edgeAlphaMode == 2)
										gl.glShadeModel(GL.GL_SMOOTH);
									else
										gl.glShadeModel(GL.GL_FLAT);
									gl.glBegin(GL.GL_LINES);
									for (int i=0; i<2; i++)
									{
										if (edgeColorMode == 2 || edgeAlphaMode == 2)
										{
											double[] C = (edgeColorMode == 2 ? cc[i] : (edgeColorMode == 1 ? cc[0] : ecolor));
											double a = (edgeAlphaMode == 2 ? aa[i] : (edgeAlphaMode == 1 ? aa[0] : ealpha));
											gl.glColor4d(C[0], C[1], C[2], a);
											if (edgeLightMode > 0)
											{
												gl.glMaterialfv(lightSideMode, GL.GL_AMBIENT,
													new float[] {as*(float)C[0], as*(float)C[1], as*(float)C[2], 1}, 0);
												gl.glMaterialfv(lightSideMode, GL.GL_DIFFUSE,
													new float[] {ds*(float)C[0], ds*(float)C[1], ds*(float)C[2], (float)a}, 0);
											}
										}
										if (edgeLightMode == 2)
											gl.glNormal3d(nn[i][0], nn[i][1], nn[i][2]);
										gl.glVertex3d(xx[i], yy[i], zz[i]);
									}
									gl.glEnd();
									if (edgeLightMode > 0)
										gl.glDisable(GL.GL_LIGHTING);
								}
							});
					}
				}
			}
		}
	}

	private int nextPowerOf2(int n)
	{
		int m = 1;
		while (m < n)
			m *= 2;
		return m;
	}

	private Buffer makeTexture2D(byte[][][] data, int[] dims, int[] realDims)
	{
		int m = nextPowerOf2(data.length);
		int n = nextPowerOf2(data[0].length);
		ByteBuffer buf = ByteBuffer.allocate(m*n*4);

		for (int i=0; i<data.length; i++)
		{
			buf.position(i*n*4);
			for (int j=0; j<data[0].length; j++)
			{
				buf.put(data[i][j], 0, 3);
				buf.put((byte)-127);
			}
		}
		dims[0] = m;
		dims[1] = n;
		realDims[0] = data.length;
		realDims[1] = data[0].length;
		buf.rewind();

		return buf;
	}

	private Buffer makeTexture2D(double[][][] data, int[] dims, int[] realDims)
	{
		int m = nextPowerOf2(data.length);
		int n = nextPowerOf2(data[0].length);
		FloatBuffer buf = FloatBuffer.allocate(m*n*4);

		for (int i=0; i<data.length; i++)
		{
			buf.position(i*n*4);
			for (int j=0; j<data[0].length; j++)
			{
				buf.put((float)data[i][j][0]);
				buf.put((float)data[i][j][1]);
				buf.put((float)data[i][j][2]);
				buf.put(1.0f);
			}
		}
		dims[0] = m;
		dims[1] = n;
		realDims[0] = data.length;
		realDims[1] = data[0].length;
		buf.rewind();

		return buf;
	}

	public class ImageData implements Renderer.CachedData
	{
		int texID;
		int texW, texH;
		int w, h;
		GLContext context;

		public ImageData(int ID, int texW, int texH, int w, int h)
		{
			this.texID = ID;
			this.texW = texW;
			this.texH = texH;
			this.w = w;
			this.h = h;
			this.context = GLContext.getCurrent();
		}

		public void dispose()
		{
			boolean isCurrent = (GLContext.getCurrent() == context);

			if (!isCurrent)
				context.makeCurrent();
			context.getGL().glDeleteTextures(1, new int[] {texID}, 0);
			if (!isCurrent)
				context.release();
		}
	}

	public void draw(ImageObject image)
	{
		double[] x = image.XData.getArray();
		double[] y = image.YData.getArray();
		ImageData d = (ImageData)image.getCachedData();

		if (d == null)
		{
			Buffer texData = null;
			int[] texDims = new int[2], dims = new int[2];
			int format = GL.GL_UNSIGNED_BYTE;

			if (image.CData.getComponentType().equals(Byte.TYPE))
			{
				texData = makeTexture2D((byte[][][])image.CData.getObject(), texDims, dims);
				format = GL.GL_UNSIGNED_BYTE;
			}
			if (image.CData.getComponentType().equals(Double.TYPE))
			{
				texData = makeTexture2D((double[][][])image.CData.getObject(), texDims, dims);
				format = GL.GL_FLOAT;
			}

			int[] t = new int[1];
			gl.glGenTextures(1, t, 0);
			gl.glBindTexture(GL.GL_TEXTURE_2D, t[0]);
			gl.glTexImage2D(GL.GL_TEXTURE_2D, 0, 4,
					texDims[1], texDims[0], 0, GL.GL_RGBA, format, texData);
			gl.glTexParameteri(GL.GL_TEXTURE_2D, GL.GL_TEXTURE_MIN_FILTER, GL.GL_NEAREST);
			gl.glTexParameteri(GL.GL_TEXTURE_2D, GL.GL_TEXTURE_MAG_FILTER, GL.GL_NEAREST);
			//gl.glTexParameteri(GL.GL_TEXTURE_2D, GL.GL_TEXTURE_WRAP_S, GL.GL_CLAMP_TO_EDGE);
			//gl.glTexParameteri(GL.GL_TEXTURE_2D, GL.GL_TEXTURE_WRAP_T, GL.GL_CLAMP_TO_EDGE);
			d = new ImageData(t[0], texDims[1], texDims[0], dims[1], dims[0]);
			image.setCachedData(d);
		}
		else
			gl.glBindTexture(GL.GL_TEXTURE_2D, d.texID);

		double tx = ((double)d.w)/d.texW;
		double ty = ((double)d.h)/d.texH;
		double px = (x[1]-x[0])/(d.w-1);
		double py = (y[1]-y[0])/(d.h-1);

		gl.glEnable(GL.GL_TEXTURE_2D);
		gl.glColor3d(1, 1, 1);
		gl.glBegin(GL.GL_QUADS);
		gl.glTexCoord2d(0, 0); gl.glVertex3d(x[0]-px/2, y[0]-py/2, (zmin+zmax)/2);
		gl.glTexCoord2d(tx, 0); gl.glVertex3d(x[1]+px/2, y[0]-py/2, (zmin+zmax)/2);
		gl.glTexCoord2d(tx, ty); gl.glVertex3d(x[1]+px/2, y[1]+py/2, (zmin+zmax)/2);
		gl.glTexCoord2d(0, ty); gl.glVertex3d(x[0]-px/2, y[1]+py/2, (zmin+zmax)/2);
		gl.glEnd();
		gl.glDisable(GL.GL_TEXTURE_2D);
	}

	public void setXForm(AxesObject ax)
	{
		double zmin = ax.x_zmin, zmax = ax.x_zmax;

		gl.glMatrixMode(GL.GL_MODELVIEW);
		gl.glLoadIdentity();
		gl.glScaled(1, 1, -1);
		gl.glMultMatrixd(ax.x_mat1.getData(), 0);
		gl.glMatrixMode(GL.GL_PROJECTION);
		gl.glLoadIdentity();
		gl.glOrtho(0, d.getWidth(), d.getHeight(), 0, zmin-(zmax-zmin)/2, zmax+(zmax-zmin)/2);
		gl.glMultMatrixd(ax.x_mat2.getData(), 0);
		gl.glMatrixMode(GL.GL_MODELVIEW);

		/* assumption: we start a new axes object, reset depth buffer such
		 * that previous drawing are always overdrawn (to implement layering)
		 */
		gl.glClear(GL.GL_DEPTH_BUFFER_BIT);
	}

	public void setViewport(int width, int height)
	{
		gl.glViewport(0, 0, width, height);
	}

	public void clear(Color c)
	{
		gl.glClearColor(c.getRed()/255.0f, c.getGreen()/255.0f, c.getBlue()/255.0f, 1.0f);
		gl.glClear(GL.GL_COLOR_BUFFER_BIT | GL.GL_DEPTH_BUFFER_BIT);
	}

	public void drawRubberBox(int[][] b)
	{
		boolean isCurrent = (d.getContext() == GLContext.getCurrent());

		/* Initialize GL context */
		if (!isCurrent)
			d.getContext().makeCurrent();
		gl.glPushAttrib(GL.GL_COLOR_BUFFER_BIT | GL.GL_DEPTH_BUFFER_BIT);
		if (!isCurrent)
			gl.glDrawBuffer(GL.GL_FRONT);
		gl.glEnable(GL.GL_COLOR_LOGIC_OP);
		gl.glLogicOp(GL.GL_XOR);
		gl.glDisable(GL.GL_DEPTH_TEST);
		gl.glMatrixMode(GL.GL_MODELVIEW);
		gl.glLoadIdentity();
		// TODO: remove (projection should be set correcty anyway)
		gl.glMatrixMode(GL.GL_PROJECTION);
		gl.glLoadIdentity();
		gl.glOrtho(0, d.getWidth(), d.getHeight(), 0, 1, -1);
		gl.glColor3d(0.3, 0.3, 0.3);

		/* Draw rubber box */
		for (int i=0; i<b.length; i++)
		{
			gl.glBegin(GL.GL_LINE_LOOP);
			gl.glVertex3d(b[i][0], b[i][1], 0);
			gl.glVertex3d(b[i][2], b[i][1], 0);
			gl.glVertex3d(b[i][2], b[i][3], 0);
			gl.glVertex3d(b[i][0], b[i][3], 0);
			gl.glEnd();
		}

		/* Restore GL context */
		gl.glFlush();
		gl.glPopAttrib();
		if (!isCurrent)
			d.getContext().release();
	}
}
