/*
 * jhandles 
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

import java.awt.*;

public class SurfaceObject extends GraphicObject
{
	private boolean callListValid;
	private boolean useCallList;

	/* Properties */
	DoubleMatrixProperty XData;
	DoubleMatrixProperty YData;
	DoubleMatrixProperty ZData;
	DoubleMatrixProperty CData;
	RadioProperty CDataMapping;
	ColorProperty EdgeColor;
	ColorProperty FaceColor;
	DoubleProperty AmbientStrength;
	DoubleProperty DiffuseStrength;
	DoubleProperty SpecularStrength;
	DoubleProperty SpecularExponent;
	RadioProperty EdgeLighting;
	RadioProperty FaceLighting;
	DoubleRadioProperty FaceAlpha;
	DoubleRadioProperty EdgeAlpha;
	DoubleMatrixProperty VertexNormals;
	MatrixProperty AlphaData;
	RadioProperty AlphaDataMapping;

	public SurfaceObject(HandleObject parent, double[][] xdata, double[][] ydata, double[][] zdata)
	{
		super(parent, "surface");
		callListValid = false;
		useCallList = false;

		XData = new DoubleMatrixProperty(this, "XData", xdata);
		YData = new DoubleMatrixProperty(this, "YData", ydata);
		ZData = new DoubleMatrixProperty(this, "ZData", zdata);
		CData = new DoubleMatrixProperty(this, "CData", zdata);
		CDataMapping = new RadioProperty(this, "CDataMapping", new String[] {"direct", "scaled"}, "scaled");
		EdgeColor = new ColorProperty(this, "EdgeColor", Color.black, new String[] {"none", "flat", "interp"}, null);
		FaceColor = new ColorProperty(this, "FaceColor", null, new String[] {"none", "flat", "interp"}, "flat");
		AmbientStrength = new DoubleProperty(this, "AmbientStrength", 0.3);
		DiffuseStrength = new DoubleProperty(this, "DiffuseStrength", 0.6);
		SpecularStrength = new DoubleProperty(this, "SpecularStrength", 0.9);
		SpecularExponent = new DoubleProperty(this, "SpecularExponent", 10);
		EdgeLighting = new RadioProperty(this, "EdgeLighting", new String[] {"none", "flat", "gouraud", "phong"}, "none");
		FaceLighting = new RadioProperty(this, "FaceLighting", new String[] {"none", "flat", "gouraud", "phong"}, "none");
		FaceAlpha = new DoubleRadioProperty(this, "FaceAlpha", 1.0, new String[] {"flat", "interp"}, null);
		EdgeAlpha = new DoubleRadioProperty(this, "EdgeAlpha", 1.0, new String[] {"flat", "interp"}, null);
		VertexNormals = new DoubleMatrixProperty(this, "VertexNormals", null);
		AlphaData = new MatrixProperty(this, "AlphaData", null);
		AlphaDataMapping = new RadioProperty(this, "AlphaDataMapping", new String[] {"none", "scaled", "direct"}, "scaled");

		ZLimInclude.reset(new Boolean(true));
		CLimInclude.reset(new Boolean(true));
		ALimInclude.reset(new Boolean(true));

		listen(XData);
		listen(YData);
		listen(ZData);
		listen(CData);
	}

	public void validate()
	{
		updateMinMax();
		updateColorMinMax();
		VertexNormals.reset(computeNormals());
		super.validate();
	}

	private void updateMinMax()
	{
		double xmin, xmax, ymin, ymax, zmin, zmax;
		double xmin2, xmax2, ymin2, ymax2, zmin2, zmax2;

		double[][] x = XData.getMatrix();
		double[][] y = YData.getMatrix();
		double[][] z = ZData.getMatrix();

		int m = Math.min(Math.min(x.length, y.length), z.length);
		int n = (m > 0 ? Math.min(Math.min(x[0].length, y[0].length), z[0].length) : 0);

		xmin = ymin = zmin = Double.POSITIVE_INFINITY;
		xmax = ymax = zmax = Double.NEGATIVE_INFINITY;
		xmin2 = ymin2 = zmin2 = Double.POSITIVE_INFINITY;
		xmax2 = ymax2 = zmax2 = Double.MIN_VALUE;

		for (int i=0; i<m; i++)
			for (int j=0; j<n; j++)
			{
				if (x[i][j] < xmin) xmin = x[i][j];
				else if (x[i][j] > xmax) xmax = x[i][j];
				if (x[i][j] > 0)
				{
					if (x[i][j] < xmin2) xmin2 = x[i][j];
					else if (x[i][j] > xmax2) xmax2 = x[i][j];
				}
				if (y[i][j] < ymin) ymin = y[i][j];
				else if (y[i][j] > ymax) ymax = y[i][j];
				if (y[i][j] > 0)
				{
					if (y[i][j] < ymin2) ymin2 = y[i][j];
					else if (y[i][j] > ymax2) ymax2 = y[i][j];
				}
				if (z[i][j] < zmin) zmin = z[i][j];
				else if (z[i][j] > zmax) zmax = z[i][j];
				if (z[i][j] > 0)
				{
					if (z[i][j] < zmin2) zmin2 = z[i][j];
					else if (z[i][j] > zmax2) zmax2 = z[i][j];
				}
			}

		XLim.set(new double[] {xmin, xmax, xmin2, xmax2}, true);
		YLim.set(new double[] {ymin, ymax, ymin2, ymax2}, true);
		ZLim.set(new double[] {zmin, zmax, zmin2, zmax2}, true);
	}

	private void updateColorMinMax()
	{
		if (CData.getNDims() == 2)
		{
			double cmin, cmax;
			double[][] c = CData.getMatrix();

			cmin = c[0][0]; cmax = c[0][0];
			for (int i=0; i<c.length; i++)
				for (int j=0; j<c[i].length; j++)
					if (c[i][j] < cmin) cmin = c[i][j];
					else if (c[i][j] > cmax) cmax = c[i][j];

			CLim.set(new double[] {cmin, cmax}, true);
		}
		else
			CLim.set(new double[] {Double.POSITIVE_INFINITY, Double.NEGATIVE_INFINITY}, true);
	}

	double[][][] getVertexNormals()
	{
		double[][][] n = VertexNormals.getMatrix3();

		if (n == null)
		{
			n = computeNormals();
			VertexNormals.reset(n);
		}
		return n;
	}

	double[][][] computeNormals()
	{
		double[][] x = XData.getMatrix();
		double[][] y = YData.getMatrix();
		double[][] z = ZData.getMatrix();
		double[][][] n = new double[z.length][z[0].length][3];

		// TODO: normal computation at boundaries
		for (int i=1; i<z.length-1; i++)
		{
			for (int j=1; j<z[i].length-1; j++)
			{
				n[i][j][0] = n[i][j][1] = n[i][j][2] = 0;
				Utils.crossProduct(
					x[i][j+1]-x[i][j], y[i][j+1]-y[i][j], z[i][j+1]-z[i][j],
					x[i+1][j]-x[i][j], y[i+1][j]-y[i][j], z[i+1][j]-z[i][j],
					n[i][j]);
				Utils.crossProduct(
					x[i-1][j]-x[i][j], y[i-1][j]-y[i][j], z[i-1][j]-z[i][j],
					x[i][j+1]-x[i][j], y[i][j+1]-y[i][j], z[i][j+1]-z[i][j],
					n[i][j]);
				Utils.crossProduct(
					x[i][j-1]-x[i][j], y[i][j-1]-y[i][j], z[i][j-1]-z[i][j],
					x[i-1][j]-x[i][j], y[i-1][j]-y[i][j], z[i-1][j]-z[i][j],
					n[i][j]);
				Utils.crossProduct(
					x[i+1][j]-x[i][j], y[i+1][j]-y[i][j], z[i+1][j]-z[i][j],
					x[i][j-1]-x[i][j], y[i][j-1]-y[i][j], z[i][j-1]-z[i][j],
					n[i][j]);
				n[i][j][0] /= 4;
				n[i][j][1] /= 4;
				n[i][j][2] /= 4;
				double d = Math.sqrt(n[i][j][0]*n[i][j][0]+n[i][j][1]*n[i][j][1]+n[i][j][2]*n[i][j][2]);
				n[i][j][0] /= d;
				n[i][j][1] /= d;
				n[i][j][2] /= d;
			}
		}

		return n;
	}

	/* TODO: remove
	private void drawSurface2(GL gl, double[][] x, double[][] y, double[][] z, double[][][] n, double[][] c,
		ColorProperty color, int shadeModel, boolean useLight, boolean useFlatLight,
		float as, float ds, float alpha)
	{
		if (useLight)
			getAxes().setLight(gl, true);
		if (alpha < 1.0f)
			gl.glEnable(GL.GL_BLEND);
		if (color != null)
			if (useLight)
			{
				Color C = color.getColor();
				gl.glMaterialfv(GL.GL_FRONT_AND_BACK, GL.GL_AMBIENT, 
						new float[] {(as*C.getRed())/255, (as*C.getGreen())/255, (as*C.getBlue())/255, 1}, 0);
				gl.glMaterialfv(GL.GL_FRONT_AND_BACK, GL.GL_DIFFUSE, 
						new float[] {(ds*C.getRed())/255, (ds*C.getGreen())/255, (ds*C.getBlue())/255, alpha}, 0);
			}
			else
				color.setup(gl, alpha);
		else
		{
			if (useLight)
			{
				gl.glMaterialfv(GL.GL_FRONT_AND_BACK, GL.GL_AMBIENT, new float[] {as, as, as, 1}, 0);
				gl.glMaterialfv(GL.GL_FRONT_AND_BACK, GL.GL_DIFFUSE, new float[] {ds, ds, ds, alpha}, 0);
			}
			else
				gl.glColor4f(1, 1, 1, alpha);
			gl.glEnable(GL.GL_TEXTURE_1D);
		}
		gl.glShadeModel(shadeModel);
		gl.glBegin(GL.GL_QUADS);
		for (int i=1; i<x.length; i++)
		{
			for (int j=1; j<x[i].length; j++)
			{
				if (useFlatLight)
				{
					double nx = n[i-1][j-1][0]+n[i-1][j][0]+n[i][j-1][0]+n[i][j][0];
					double ny = n[i-1][j-1][1]+n[i-1][j][1]+n[i][j-1][0]+n[i][j][1];
					double nz = n[i-1][j-1][2]+n[i-1][j][2]+n[i][j-1][0]+n[i][j][2];
					double nd = Math.sqrt(nx*nx+ny*ny+nz*nz);
					gl.glNormal3d(nx/nd, ny/nd, nz/nd);
				}
				else
					gl.glNormal3d(n[i-1][j-1][0], n[i-1][j-1][1], n[i-1][j-1][2]);
				if (color == null)
					gl.glTexCoord1d(c[i-1][j-1]);
				gl.glVertex3d(x[i-1][j-1], y[i-1][j-1], z[i-1][j-1]);

				if (!useFlatLight)
					gl.glNormal3d(n[i][j-1][0], n[i][j-1][1], n[i][j-1][2]);
				if (color == null)
					gl.glTexCoord1d(c[i][j-1]);
				gl.glVertex3d(x[i][j-1], y[i][j-1], z[i][j-1]);

				if (!useFlatLight)
					gl.glNormal3d(n[i][j][0], n[i][j][1], n[i][j][2]);
				if (color == null)
					gl.glTexCoord1d(c[i][j]);
				gl.glVertex3d(x[i][j], y[i][j], z[i][j]);

				if (!useFlatLight)
					gl.glNormal3d(n[i-1][j][0], n[i-1][j][1], n[i-1][j][2]);
				if (color == null)
					gl.glTexCoord1d(c[i-1][j]);
				gl.glVertex3d(x[i-1][j], y[i-1][j], z[i-1][j]);
			}
		}
		gl.glEnd();
		gl.glDisable(GL.GL_TEXTURE_1D);
		gl.glDisable(GL.GL_BLEND);
		if (useLight)
			getAxes().setLight(gl, false);
	}

	private void drawSurface(GL gl, double[][] x, double[][] y, double[][] z, double[][][] n, double[][][] c,
		ColorProperty color, int shadeModel, boolean useLight, boolean useFlatLight,
		float as, float ds, float alpha)
	{
		if (useLight)
			getAxes().setLight(gl, true);
		if (alpha < 1.0f)
			gl.glEnable(GL.GL_BLEND);
		if (color != null)
			if (useLight)
			{
				Color C = color.getColor();
				gl.glMaterialfv(GL.GL_FRONT_AND_BACK, GL.GL_AMBIENT, 
						new float[] {(as*C.getRed())/255, (as*C.getGreen())/255, (as*C.getBlue())/255, 1}, 0);
				gl.glMaterialfv(GL.GL_FRONT_AND_BACK, GL.GL_DIFFUSE, 
						new float[] {(ds*C.getRed())/255, (ds*C.getGreen())/255, (ds*C.getBlue())/255, alpha}, 0);
			}
			else
				color.setup(gl, alpha);
		gl.glShadeModel(shadeModel);
		gl.glBegin(GL.GL_QUADS);
		for (int i=1; i<x.length; i++)
		{
			for (int j=1; j<x[i].length; j++)
			{
				if (useFlatLight)
				{
					double nx = n[i-1][j-1][0]+n[i-1][j][0]+n[i][j-1][0]+n[i][j][0];
					double ny = n[i-1][j-1][1]+n[i-1][j][1]+n[i][j-1][0]+n[i][j][1];
					double nz = n[i-1][j-1][2]+n[i-1][j][2]+n[i][j-1][0]+n[i][j][2];
					double nd = Math.sqrt(nx*nx+ny*ny+nz*nz);
					gl.glNormal3d(nx/nd, ny/nd, nz/nd);
				}
				else if (useLight)
					gl.glNormal3d(n[i-1][j-1][0], n[i-1][j-1][1], n[i-1][j-1][2]);
				if (color == null)
					if (useLight)
					{
						gl.glMaterialfv(GL.GL_FRONT_AND_BACK, GL.GL_AMBIENT,
							new float[] {as*(float)c[i-1][j-1][0], as*(float)c[i-1][j-1][1], as*(float)c[i-1][j-1][2], 1}, 0);
						gl.glMaterialfv(GL.GL_FRONT_AND_BACK, GL.GL_DIFFUSE,
							new float[] {ds*(float)c[i-1][j-1][0], ds*(float)c[i-1][j-1][1], ds*(float)c[i-1][j-1][2], alpha}, 0);
					}
					else
						gl.glColor4d(c[i-1][j-1][0], c[i-1][j-1][1], c[i-1][j-1][2], alpha);
				gl.glVertex3d(x[i-1][j-1], y[i-1][j-1], z[i-1][j-1]);

				if (useLight && !useFlatLight)
					gl.glNormal3d(n[i][j-1][0], n[i][j-1][1], n[i][j-1][2]);
				if (color == null)
					if (useLight)
					{
						gl.glMaterialfv(GL.GL_FRONT_AND_BACK, GL.GL_AMBIENT,
							new float[] {as*(float)c[i][j-1][0], as*(float)c[i][j-1][1], as*(float)c[i][j-1][2], 1}, 0);
						gl.glMaterialfv(GL.GL_FRONT_AND_BACK, GL.GL_DIFFUSE,
							new float[] {ds*(float)c[i][j-1][0], ds*(float)c[i][j-1][1], ds*(float)c[i][j-1][2], alpha}, 0);
					}
					else
						gl.glColor4d(c[i][j-1][0], c[i][j-1][1], c[i][j-1][2], alpha);
				gl.glVertex3d(x[i][j-1], y[i][j-1], z[i][j-1]);

				if (useLight && !useFlatLight)
					gl.glNormal3d(n[i][j][0], n[i][j][1], n[i][j][2]);
				if (color == null)
					if (useLight)
					{
						gl.glMaterialfv(GL.GL_FRONT_AND_BACK, GL.GL_AMBIENT,
							new float[] {as*(float)c[i][j][0], as*(float)c[i][j][1], as*(float)c[i][j][2], 1}, 0);
						gl.glMaterialfv(GL.GL_FRONT_AND_BACK, GL.GL_DIFFUSE,
							new float[] {ds*(float)c[i][j][0], ds*(float)c[i][j][1], ds*(float)c[i][j][2], alpha}, 0);
					}
					else
						gl.glColor4d(c[i][j][0], c[i][j][1], c[i][j][2], alpha);
				gl.glVertex3d(x[i][j], y[i][j], z[i][j]);

				if (useLight && !useFlatLight)
					gl.glNormal3d(n[i-1][j][0], n[i-1][j][1], n[i-1][j][2]);
				if (color == null)
					if (useLight)
					{
						gl.glMaterialfv(GL.GL_FRONT_AND_BACK, GL.GL_AMBIENT,
							new float[] {as*(float)c[i-1][j][0], as*(float)c[i-1][j][1], as*(float)c[i-1][j][2], 1}, 0);
						gl.glMaterialfv(GL.GL_FRONT_AND_BACK, GL.GL_DIFFUSE,
							new float[] {ds*(float)c[i-1][j][0], ds*(float)c[i-1][j][1], ds*(float)c[i-1][j][2], alpha}, 0);
					}
					else
						gl.glColor4d(c[i-1][j][0], c[i-1][j][1], c[i-1][j][2], alpha);
				gl.glVertex3d(x[i-1][j], y[i-1][j], z[i-1][j]);
			}
		}
		gl.glEnd();
		gl.glDisable(GL.GL_BLEND);
		if (useLight)
			getAxes().setLight(gl, false);
	}
	*/

	double[][][] getCData()
	{
		return getAxes().convertCData(CData.getMatrix(), CDataMapping.getValue());
	}

	double[][] getAlphaData()
	{
		if (AlphaData.getNDims() != 2)
			return null;

		if (AlphaData.getComponentType().equals(Double.TYPE))
		{
			double[][] aa = (double[][])AlphaData.getObject();

			if (AlphaDataMapping.is("none"))
				return aa;
			else if (AlphaDataMapping.is("scaled"))
			{
				double[][] res = new double[aa.length][aa[0].length];
				double[] amap = getAxes().getFigure().Alphamap.getArray();
				double[] alim = getAxes().ALim.getArray();

				for (int i=0; i<res.length; i++)
					for (int j=0; j<res[i].length; j++)
					{
						int s = (int)Math.round((amap.length-1)*(aa[i][j]-alim[0])/(alim[1]-alim[0]));
						s = Math.min(Math.max(0, s), amap.length-1);
						res[i][j] = amap[s];
					}
				return res;
			}
			else if (AlphaDataMapping.is("direct"))
			{
				double[][] res = new double[aa.length][aa[0].length];
				double[] amap = getAxes().getFigure().Alphamap.getArray();
				
				for (int i=0; i<res.length; i++)
					for (int j=0; j<res[i].length; j++)
					{
						int s = (int)Math.round(aa[i][j])-1;
						s = Math.min(Math.max(0, s), amap.length-1);
						res[i][j] = amap[s];
					}
				return res;
			}
		}

		return null;
	}

	/* TODO: remove
	public void draw(GL gl)
	{
		if (callListValid && useCallList)
		{
			gl.glCallList(glID);
			return;
		}

		double[][] x = XData.getMatrix();
		double[][] y = YData.getMatrix();
		double[][] z = ZData.getMatrix();
		double[][][] n = getVertexNormals();

		double[][][] c = null;
		double[][] ci = null;

		float as = AmbientStrength.floatValue(), ds = DiffuseStrength.floatValue(), ss = SpecularStrength.floatValue();

		if ((!EdgeColor.isSet() && !EdgeColor.is("none")) || (!FaceColor.isSet() && !FaceColor.is("none")))
		{
			c = getAxes().convertCData(CData.getMatrix());
			ci = getAxes().convertCDataToIndex(CData.getMatrix());
		}

		if (useCallList)
			gl.glNewList(glID, GL.GL_COMPILE_AND_EXECUTE);

		gl.glMaterialfv(GL.GL_FRONT_AND_BACK, GL.GL_SPECULAR, new float[] {ss, ss, ss, 1}, 0);
		gl.glMaterialf(GL.GL_FRONT_AND_BACK, GL.GL_SHININESS, SpecularExponent.floatValue());

		// Faces

		if (!FaceColor.is("none"))
		{
			boolean useLight = (getAxes().hasLight() && !FaceLighting.is("none")), useFlatLight = (useLight && FaceLighting.is("flat"));
			
			gl.glPolygonOffset(1.0f, 1.0f);
			gl.glEnable(GL.GL_POLYGON_OFFSET_FILL);
			drawSurface(gl, x, y, z, n, c,
				(FaceColor.isSet() ? FaceColor : null), (FaceColor.is("flat") ? GL.GL_FLAT : GL.GL_SMOOTH), useLight, useFlatLight,
				as, ds, FaceAlpha.floatValue());
			//drawSurface2(gl, x, y, z, n, ci,
			//	(FaceColor.isSet() ? FaceColor : null), (FaceColor.is("flat") ? GL.GL_FLAT : GL.GL_SMOOTH), useLight, useFlatLight,
			//	as, ds, FaceAlpha.floatValue());
			gl.glDisable(GL.GL_POLYGON_OFFSET_FILL);
		}

		// Edges

		if (!EdgeColor.is("none"))
		{
			boolean useLight = (getAxes().hasLight() && !EdgeLighting.is("none")), useFlatLight = (useLight && EdgeLighting.is("flat"));

			gl.glPolygonMode(GL.GL_FRONT_AND_BACK, GL.GL_LINE);
			drawSurface(gl, x, y, z, n, c,
				(EdgeColor.isSet() ? EdgeColor : null), (EdgeColor.is("flat") ? GL.GL_FLAT : GL.GL_SMOOTH), useLight, useFlatLight,
				as, ds, EdgeAlpha.floatValue());
			gl.glPolygonMode(GL.GL_FRONT_AND_BACK, GL.GL_FILL);
		}

		if (useCallList)
		{
			callListValid = true;
			gl.glEndList();
		}
	}
	*/

	public void draw(Renderer r)
	{
		r.draw(this);
	}

	/* TODO: remove
	private void invalidateCallList()
	{
		if (useCallList)
		{
			GLCanvas canvas = getAxes().getCanvas();
			boolean isCurrent = (canvas.getContext() == GLContext.getCurrent());

			if (!isCurrent)
				canvas.getContext().makeCurrent();
			canvas.getGL().glDeleteLists(glID, 1);
			callListValid = false;
			if (!isCurrent)
				canvas.getContext().release();
		}
	}
	*/

	public void propertyChanged(Property p) throws PropertyException
	{
		if (p == XData || p == YData || p == ZData)
		{
			VertexNormals.reset(null);
			updateMinMax();
		}
		else if (p == CData)
			updateColorMinMax();
	}
}
