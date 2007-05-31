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

// TODO: remove opengl reference
import javax.media.opengl.*;
import javax.media.opengl.glu.*;
import java.awt.*;
import java.awt.event.*;
import java.util.*;

public class AxesObject extends HandleObject
{
	/*
	private double anglex;
	private double anglez;
	double eyedist;
	double eyeangle;
	*/
	boolean autofit = true;
	private double[] M;
	private double[] P;
	private int[] V;
	private String currentUnits;
	private int maxLight;
	private int axeIndex;
	protected int autoMode = 0;

	RenderCanvas canvas;
	LegendObject legend;
	BaseLineObject baseLine;

	private final int AXE_ANY_DIR = 0;
	private final int AXE_DEPTH_DIR = 1;
	private final int AXE_HORZ_DIR = 2;
	private final int AXE_VERT_DIR = 3;

	private int xstate = 3;
	private int ystate = 3;
	private int zstate = 3;

	private double xticklen;
	private double yticklen;
	private double zticklen;

	private int xPrev, yPrev, xAnchor, yAnchor;
	private boolean zoomBox = false;
	private Stack zoomStack = new Stack();
	private Rectangle boundingBox;
	protected boolean alwaysDrawBox = true;

	/* properties */
	RadioProperty ActivePositionProperty;
	DoubleArrayProperty Position;
	DoubleArrayProperty OuterPosition;
	RadioProperty Units;
	RadioProperty Projection;
	ColorProperty AxesColor;
	ColorProperty XColor;
	ColorProperty YColor;
	ColorProperty ZColor;
	DoubleArrayProperty XLim;
	DoubleArrayProperty YLim;
	DoubleArrayProperty ZLim;
	RadioProperty XLimMode;
	RadioProperty YLimMode;
	RadioProperty ZLimMode;
	BooleanProperty XGrid;
	BooleanProperty YGrid;
	BooleanProperty ZGrid;
	BooleanProperty XMinorGrid;
	BooleanProperty YMinorGrid;
	BooleanProperty ZMinorGrid;
	LineStyleProperty XGridStyle;
	LineStyleProperty YGridStyle;
	LineStyleProperty ZGridStyle;
	DoubleArrayProperty XTick;
	DoubleArrayProperty YTick;
	DoubleArrayProperty ZTick;
	RadioProperty XTickMode;
	RadioProperty YTickMode;
	RadioProperty ZTickMode;
	StringArrayProperty XTickLabel;
	StringArrayProperty YTickLabel;
	StringArrayProperty ZTickLabel;
	RadioProperty XTickLabelMode;
	RadioProperty YTickLabelMode;
	RadioProperty ZTickLabelMode;
	RadioProperty NextPlot;
	BooleanProperty Box;
	RadioProperty TickDir;
	RadioProperty TickDirMode;
	DoubleArrayProperty CameraTarget;
	RadioProperty CameraTargetMode;
	DoubleArrayProperty CameraPosition;
	RadioProperty CameraPositionMode;
	DoubleArrayProperty CameraUpVector;
	RadioProperty CameraUpVectorMode;
	DoubleProperty CameraViewAngle;
	RadioProperty CameraViewAngleMode;
	DoubleArrayProperty DataAspectRatio;
	RadioProperty DataAspectRatioMode;
	DoubleArrayProperty PlotBoxAspectRatio;
	RadioProperty PlotBoxAspectRatioMode;
	DoubleArrayProperty View;
	TextProperty Title;
	TextProperty XLabel;
	TextProperty YLabel;
	TextProperty ZLabel;
	DoubleArrayProperty CLim;
	RadioProperty CLimMode;
	DoubleArrayProperty ALim;
	RadioProperty ALimMode;
	RadioProperty XDir;
	RadioProperty YDir;
	RadioProperty ZDir;
	DoubleArrayProperty x_NormRenderTransform;
	DoubleArrayProperty x_RenderTransform;

	public AxesObject(FigureObject fig, boolean init3D)
	{
		super(fig, "axes");

		double[] angles;
		if (init3D)
			angles = new double[] { -37.5, 30.0 };
		else
			angles = new double[] { 0.0, 90.0 };
		/*
		eyedist = 12.0;
		eyeangle = 10.0;
		*/
		M = new double[16];
		P = new double[16];
		V = new int[4];

		canvas = fig.getCanvas();

		ActivePositionProperty = new RadioProperty(this, "ActivePositionProperty", new String[] {"outerposition", "position"}, "outerposition");
		Position = new DoubleArrayProperty(this, "Position", new double[0], -1);
		OuterPosition = new DoubleArrayProperty(this, "OuterPosition", new double[] {0,0,1,1}, -1);
		Units = new RadioProperty(this, "Units",
			new String[] { "pixels", "normalized" }, "normalized");
		currentUnits = "normalized";
		Projection = new RadioProperty(this, "Projection", new String[] { "orthogonal", "perspective" }, "orthogonal");
		AxesColor = new ColorProperty(this, "Color", Color.white, new String[] {"none"}, null);
		XColor = new ColorProperty(this, "XColor", Color.black);
		YColor = new ColorProperty(this, "YColor", Color.black);
		ZColor = new ColorProperty(this, "ZColor", Color.black);
		XLim = new DoubleArrayProperty(this, "XLim", new double[] {0.0, 1.0}, 2);
		XLimMode = new RadioProperty(this, "XLimMode", new String[] {"auto", "manual"}, "auto");
		YLim = new DoubleArrayProperty(this, "YLim", new double[] {0.0, 1.0}, 2);
		YLimMode = new RadioProperty(this, "YLimMode", new String[] {"auto", "manual"}, "auto");
		ZLim = new DoubleArrayProperty(this, "ZLim", new double[] {-0.5, 0.5}, 2);
		ZLimMode = new RadioProperty(this, "ZLimMode", new String[] {"auto", "manual"}, "auto");
		XGrid = new BooleanProperty(this, "XGrid", false);
		YGrid = new BooleanProperty(this, "YGrid", false);
		ZGrid = new BooleanProperty(this, "ZGrid", false);
		XMinorGrid = new BooleanProperty(this, "XMinorGrid", false);
		YMinorGrid = new BooleanProperty(this, "YMinorGrid", false);
		ZMinorGrid = new BooleanProperty(this, "ZMinorGrid", false);
		XGridStyle = new LineStyleProperty(this, "XGridStyle", ":");
		YGridStyle = new LineStyleProperty(this, "YGridStyle", ":");
		ZGridStyle = new LineStyleProperty(this, "ZGridStyle", ":");
		XTick = new DoubleArrayProperty(this, "XTick", new double[0], -1);
		YTick = new DoubleArrayProperty(this, "YTick", new double[0], -1);
		ZTick = new DoubleArrayProperty(this, "ZTick", new double[0], -1);
		XTickMode = new RadioProperty(this, "XTickMode", new String[] {"auto", "manual"}, "auto");
		YTickMode = new RadioProperty(this, "YTickMode", new String[] {"auto", "manual"}, "auto");
		ZTickMode = new RadioProperty(this, "ZTickMode", new String[] {"auto", "manual"}, "auto");
		XTickLabel = new StringArrayProperty(this, "XTickLabel", new String[0]);
		YTickLabel = new StringArrayProperty(this, "YTickLabel", new String[0]);
		ZTickLabel = new StringArrayProperty(this, "ZTickLabel", new String[0]);
		XTickLabelMode = new RadioProperty(this, "XTickLabelMode", new String[] {"auto", "manual"}, "auto");
		YTickLabelMode = new RadioProperty(this, "YTickLabelMode", new String[] {"auto", "manual"}, "auto");
		ZTickLabelMode = new RadioProperty(this, "ZTickLabelMode", new String[] {"auto", "manual"}, "auto");
		NextPlot = new RadioProperty(this, "NextPlot", new String[] {"replace", "add"}, "replace");
		Box = new BooleanProperty(this, "Box", (init3D ? false : true));
		TickDir = new RadioProperty(this, "TickDir", new String[] {"in", "out"}, (init3D ? "out" : "in"));
		TickDirMode = new RadioProperty(this, "TickDirMode", new String[] {"auto", "manual"}, "auto");
		CameraTarget = new DoubleArrayProperty(this, "CameraTarget", new double[] {0.0,0.0,0.0}, 3);
		CameraTargetMode = new RadioProperty(this, "CameraTargetMode", new String[] {"auto", "manual"}, "auto");
		CameraPosition = new DoubleArrayProperty(this, "CameraPosition", new double[] {0.0,0.0,0.0}, 3);
		CameraPositionMode = new RadioProperty(this, "CameraPositionMode", new String[] {"auto", "manual"}, "auto");
		CameraUpVector = new DoubleArrayProperty(this, "CameraUpVector", new double[] {0,1,0}, 3);
		CameraUpVectorMode = new RadioProperty(this, "CameraUpVectorMode", new String[] {"auto", "manual"}, "auto");
		CameraViewAngle = new DoubleProperty(this, "CameraViewAngle", 10.0);
		CameraViewAngleMode = new RadioProperty(this, "CameraViewAngleMode", new String[] {"auto", "manual"}, "auto");
		DataAspectRatio = new DoubleArrayProperty(this, "DataAspectRatio", new double[] {1,1,1}, 3);
		DataAspectRatioMode = new RadioProperty(this, "DataAspectRatioMode", new String[] {"auto", "manual"}, "auto");
		PlotBoxAspectRatio = new DoubleArrayProperty(this, "PlotBoxAspectRatio", new double[] {1,1,1}, 3);
		PlotBoxAspectRatioMode = new RadioProperty(this, "PlotBoxAspectRatioMode", new String[] {"auto", "manual"}, "auto");
		View = new DoubleArrayProperty(this, "View", angles, 2);
		TextObject titleObj = new TextObject(null, "", new double[] {0,0,0});
		titleObj.HAlign.reset("center");
		titleObj.VAlign.reset("bottom");
		titleObj.Parent.addElement(this);
		titleObj.validate();
		Title = new TextProperty(this, "Title", titleObj);
		TextObject xLabelObj = new TextObject(null, "", new double[] {0,0,0});
		xLabelObj.HAlign.reset(init3D ? "left" : "center");
		xLabelObj.VAlign.reset("top");
		xLabelObj.Parent.addElement(this);
		xLabelObj.validate();
		XLabel = new TextProperty(this, "XLabel", xLabelObj);
		TextObject yLabelObj = new TextObject(null, "", new double[] {0,0,0});
		yLabelObj.HAlign.reset(init3D ? "right" : "center");
		yLabelObj.VAlign.reset(init3D ? "top" : "bottom");
		yLabelObj.Rotation.reset(new Double(init3D ? 0.0 : 90.0));
		yLabelObj.Parent.addElement(this);
		yLabelObj.validate();
		YLabel = new TextProperty(this, "YLabel", yLabelObj);
		TextObject zLabelObj = new TextObject(null, "", new double[] {0,0,0});
		zLabelObj.HAlign.reset(init3D ? "right" : "center");
		zLabelObj.VAlign.reset(init3D ? "top" : "bottom");
		zLabelObj.Rotation.reset(new Double(init3D ? 90.0 : 0.0));
		zLabelObj.Parent.addElement(this);
		zLabelObj.validate();
		ZLabel = new TextProperty(this, "ZLabel", zLabelObj);
		CLim = new DoubleArrayProperty(this, "CLim", new double[] {0, 1}, 2);
		CLimMode = new RadioProperty(this, "CLimMode", new String[] {"auto", "manual"}, "auto");
		ALim = new DoubleArrayProperty(this, "ALim", new double[] {0, 1}, 2);
		ALimMode = new RadioProperty(this, "ALimMode", new String[] {"auto", "manual"}, "auto");
		XDir = new RadioProperty(this, "XDir", new String[] {"normal", "reverse"}, "normal");
		YDir = new RadioProperty(this, "YDir", new String[] {"normal", "reverse"}, "normal");
		ZDir = new RadioProperty(this, "ZDir", new String[] {"normal", "reverse"}, "normal");
		x_NormRenderTransform = new DoubleArrayProperty(this, "x_NormRenderTransform", new double[16], 16);
		x_RenderTransform = new DoubleArrayProperty(this, "x_RenderTransform", new double[16], 16);

		updatePosition();
		autoTick();
		autoAspectRatio();
		autoCamera();

		listen(XLim);
		listen(YLim);
		listen(ZLim);
		listen(XLimMode);
		listen(YLimMode);
		listen(ZLimMode);
		listen(XTick);
		listen(YTick);
		listen(ZTick);
		listen(XTickMode);
		listen(YTickMode);
		listen(ZTickMode);
		listen(XTickLabel);
		listen(YTickLabel);
		listen(ZTickLabel);
		listen(XTickLabelMode);
		listen(YTickLabelMode);
		listen(ZTickLabelMode);
		listen(TickDir);
		listen(TickDirMode);
		listen(CLim);
		listen(CLimMode);
		listen(ALim);
		listen(ALimMode);
		listen(CameraTarget);
		listen(CameraTargetMode);
		listen(CameraPosition);
		listen(CameraPositionMode);
		listen(CameraUpVector);
		listen(CameraUpVectorMode);
		listen(CameraViewAngle);
		listen(CameraViewAngleMode);
		listen(DataAspectRatio);
		listen(DataAspectRatioMode);
		listen(PlotBoxAspectRatio);
		listen(PlotBoxAspectRatioMode);
		listen(View);
		listen(Position);
		listen(OuterPosition);
		listen(Units);
		listen(XDir);
		listen(YDir);
		listen(ZDir);

		legend = null;
		baseLine = null;
	}

	public void reset(String mode)
	{
		super.deleteChildren();

		Projection.reset("orthogonal");
		AxesColor.reset(Color.white);
		XColor.reset(Color.black);
		YColor.reset(Color.black);
		ZColor.reset(Color.black);
		XLim.reset(new double[] {0, 1});
		YLim.reset(new double[] {0, 1});
		ZLim.reset(new double[] {-0.5, 0.5});
		XLimMode.reset("auto");
		YLimMode.reset("auto");
		ZLimMode.reset("auto");
		XGrid.reset(new Boolean(false));
		YGrid.reset(new Boolean(false));
		ZGrid.reset(new Boolean(false));
		XTick.reset(new double[0]);
		YTick.reset(new double[0]);
		ZTick.reset(new double[0]);
		XTickMode.reset("auto");
		YTickMode.reset("auto");
		ZTickMode.reset("auto");
		XTickLabel.reset(new String[0]);
		YTickLabel.reset(new String[0]);
		ZTickLabel.reset(new String[0]);
		XTickLabelMode.reset("auto");
		YTickLabelMode.reset("auto");
		ZTickLabelMode.reset("auto");
		TickDir.reset("in");
		TickDirMode.reset("auto");
		CameraTarget.reset(new double[] {0, 0, 0});
		CameraTargetMode.reset("auto");
		CameraPosition.reset(new double[] {0, 0, 0});
		CameraPositionMode.reset("auto");
		CameraUpVector.reset(new double[] {0, 1, 0});
		CameraUpVectorMode.reset("auto");
		CameraViewAngle.reset(new Double(10));
		CameraViewAngleMode.reset("auto");
		DataAspectRatio.reset(new double[] {1, 1, 1});
		DataAspectRatioMode.reset("auto");
		PlotBoxAspectRatio.reset(new double[] {1, 1, 1});
		PlotBoxAspectRatioMode.reset("auto");
		View.reset(new double[] {0, 90});
		Title.reset("");
		XLabel.reset("");
		YLabel.reset("");
		ZLabel.reset("");
		CLim.reset(new double[] {0, 1});
		CLimMode.reset("auto");
		ALim.reset(new double[] {0, 1});
		ALimMode.reset("auto");
		if (legend != null)
		{
			legend.delete();
			legend = null;
		}
		Box.reset(new Boolean(true));
		XDir.reset("normal");
		YDir.reset("normal");
		ZDir.reset("normal");

		autoTick();
		autoAspectRatio();
		autoCamera();
	}

	public void validate()
	{
		updateActivePosition();
		autoTick();
		autoAspectRatio();
		autoCamera();
		super.validate();
	}

	protected void setInternalPosition(double[] p)
	{
		autoSet(Position, p);
		autoTick();
		autoAspectRatio();
		autoCamera();
	}

	public void deleteChildren()
	{
		super.deleteChildren();
		Title.getText().delete();
		XLabel.getText().delete();
		YLabel.getText().delete();
		ZLabel.getText().delete();
		if (legend != null)
			legend.delete();
	}

	public void removeChild(HandleObject child)
	{
		if (child == baseLine)
			baseLine = null;
		else if (child == legend)
			legend = null;

		super.removeChild(child);

		autoScale();
		autoScaleC();
		autoAspectRatio();
		autoCamera();
	}

	public RenderCanvas getCanvas()
	{
		return canvas;
	}

	public FigureObject getFigure()
	{
		return (FigureObject)Parent.elementAt(0);
	}

	Rectangle getBoundingBox()
	{
		double[] pos = getFigure().convertPosition(Position.getArray(), Units.getValue());
		return new Rectangle((int)pos[0], (int)pos[1], (int)pos[2], (int)pos[3]);
	}

	Rectangle getOuterBoundingBox()
	{
		double[] pos = getFigure().convertPosition(OuterPosition.getArray(), Units.getValue());
		return new Rectangle((int)pos[0], (int)pos[1], (int)pos[2], (int)pos[3]);
	}

	void updatePosition()
	{
		FigureObject fig = getFigure();
		double[] p = fig.convertPosition(OuterPosition.getArray(), Units.getValue());
		FontMetrics fm = canvas.getFontMetrics(canvas.getFont());
		int marginH = 10+fm.stringWidth("0000")+fm.getHeight()+5+7,
			marginV = 10+2*fm.getHeight()+10+7;

		p[0] += marginH;
		p[1] += marginV;
		p[2] -= 2*marginH;
		p[3] -= 2*marginV;
		autoSet(Position, fig.convertPosition(p, "pixels", Units.getValue()));
	}

	void updateOuterPosition()
	{
		FigureObject fig = getFigure();
		double[] p = fig.convertPosition(Position.getArray(), Units.getValue());
		FontMetrics fm = canvas.getFontMetrics(canvas.getFont());
		int marginH = 10+fm.stringWidth("0000")+fm.getHeight()+5+7,
			marginV = 10+2*fm.getHeight()+10+7;
		
		p[0] -= marginH;
		p[1] -= marginV;
		p[2] += 2*marginH;
		p[3] += 2*marginV;
		autoSet(OuterPosition, fig.convertPosition(p, "pixels", Units.getValue()));
	}

	void updateActivePosition()
	{
		if (ActivePositionProperty.is("position"))
			updateOuterPosition();
		else
			updatePosition();
		autoCamera();
	}

	void setAxeIndex(int index)
	{
		axeIndex = index;
	}

	public double[] getM()
	{
		return M;
	}

	public double[] getP()
	{
		return P;
	}

	public int[] getV()
	{
		return V;
	}

	public LegendObject makeLegend(String names[])
	{
		if (legend == null)
		{
			legend = new LegendObject(this, names);
			legend.validate();
		}
		else
			legend.buildLegend(this, names);
		if (legend.size() == 0)
		{
			legend.delete();
			return null;
		}
		else
			return legend;
	}

	public BaseLineObject getBaseLine()
	{
		if (baseLine == null)
		{
			baseLine = new BaseLineObject(this, 0);
			baseLine.LineColor.reset("k");
			baseLine.validate();
		}
		return baseLine;
	}

	private class AxesGeometry
	{
		double dx, dy, dz; // axes span
		double fx, fy, fz; // axes scaling factor
		double az, el;     // axes rotation
		double cx, cy, cz; // axes center location
		double xd, yd, zd; // axes direction (-1: reverse)
	}

	private AxesGeometry getGeometry()
	{
		AxesGeometry g = new AxesGeometry();

		double[] xlim = XLim.getArray(), ylim = YLim.getArray(), zlim = ZLim.getArray();
		double[] angles = View.getArray();

		g.dx = (xlim[1]-xlim[0]);
		g.dy = (ylim[1]-ylim[0]);
		g.dz = (zlim[1]-zlim[0]);
		g.cx = (xlim[0]+xlim[1])/2;
		g.cy = (ylim[0]+ylim[1])/2;
		g.cz = (zlim[0]+zlim[1])/2;
		g.az = angles[0]*Math.PI/180.0;
		g.el = angles[1]*Math.PI/180.0;
		
		double[] daspect = DataAspectRatio.getArray();
		double dmax = Math.max(Math.max(g.dx, g.dy), g.dz);
		double damax = Math.max(Math.max(daspect[0], daspect[1]), daspect[2]);
		
		g.fx = (damax/daspect[0])/dmax;
		g.fy = (damax/daspect[1])/dmax;
		g.fz = (damax/daspect[2])/dmax;
		
		if (!CameraTargetMode.is("auto") || !CameraPositionMode.is("auto") ||
		    !CameraUpVectorMode.is("auto") || !CameraViewAngleMode.is("auto"))
		{
			double maxD = Math.sqrt((g.dx*g.fx)*(g.dx*g.fx)+(g.dy*g.fy)*(g.dy*g.fy)+(g.dz*g.fz)*(g.dz*g.fz));
			g.fx /= maxD;
			g.fy /= maxD;
			g.fz /= maxD;
		}

		g.xd = (XDir.is("reverse") ? -1 : 1);
		g.yd = (YDir.is("reverse") ? -1 : 1);
		g.zd = (ZDir.is("reverse") ? -1 : 1);

		return g;
	}

	private void setupTransformation(GL gl)
	{
		GLU glu = new GLU();
		double[] target = CameraTarget.getArray(), pos = CameraPosition.getArray(), up = CameraUpVector.getArray();
		Rectangle bb = getBoundingBox();
		boolean cameraAuto = (
				CameraTargetMode.is("auto") && CameraPositionMode.is("auto") &&
				CameraUpVectorMode.is("auto") && CameraViewAngleMode.is("auto"));
		boolean aspectAuto = (DataAspectRatioMode.is("auto") && PlotBoxAspectRatioMode.is("auto"));
		AxesGeometry g = getGeometry();
		int scale_mode = 2;
		double fact = 25;

		//System.out.println(g.fx + " " + g.fx*g.dx);
		//System.out.println(g.fy + " " + g.fy*g.dy);
		//System.out.println(g.fz + " " + g.fz*g.dz);

		gl.glMatrixMode(GL.GL_MODELVIEW);
		gl.glLoadIdentity();
		// tryout
		switch (scale_mode)
		{
			case 0:
				gl.glTranslated(-0.5+(bb.width+2*bb.x)/(2.0*canvas.getWidth()), -0.5+(bb.height+2*bb.y)/(2.0*canvas.getHeight()), axeIndex*Math.sqrt(3));
				gl.glScaled((double)bb.width/canvas.getWidth(), (double)bb.height/canvas.getHeight(), 1.0);
				break;
			case 1:
				gl.glTranslated(bb.width/2.0+bb.x, bb.height/2.0+bb.y, axeIndex*Math.sqrt(3));
				gl.glScaled((double)bb.width, (double)bb.height, 1.0);
				break;
			case 2:
				gl.glTranslated(fact*(bb.width/2.0+bb.x)/canvas.getWidth(), fact*(bb.height/2.0+bb.y)/canvas.getHeight(), axeIndex*Math.sqrt(3));
				gl.glScaled(fact*(double)bb.width/canvas.getWidth(), fact*(double)bb.height/canvas.getHeight(), 1);
				break;
		}
		if (!aspectAuto || !cameraAuto)
		{
			if (bb.width > bb.height)
				gl.glScaled((double)bb.height/bb.width, 1.0, 1.0);
			else
				gl.glScaled(1.0, (double)bb.width/bb.height, 1.0);
		}
		//gl.glScaled(0.5/(d*Math.tan(angle*Math.PI/360.0)), 0.5/(d*Math.tan(angle*Math.PI/360.0)), 1.0);
		//gl.glScaled(1/f1, 1/f2, 1.0);
		if (cameraAuto)
		{
			double f1 = Math.abs((g.fx*g.dx)*Math.cos(g.az))+Math.abs((g.fy*g.dy)*Math.sin(g.az));
			double f1b = Math.abs((g.fx*g.dx)*Math.sin(g.az))+Math.abs((g.fy*g.dy)*Math.cos(g.az));
			double f2 = Math.abs((g.fz*g.dz)*Math.cos(g.el))+Math.abs(Math.sin(g.el))*f1b;
			//double f3 = Math.abs((g.fz*g.dz)*Math.sin(g.el))+Math.abs(Math.cos(g.el))*f1b;
			double f3 = 1.0;

			if (aspectAuto)
				gl.glScaled(1/f1, 1/f2, 1/f3);
			else
			{
				double f = Math.max(f1, f2);
				gl.glScaled(1/f, 1/f, 1/f3);
			}
		}
		glu.gluLookAt(
			pos[0]*g.fx, pos[1]*g.fy, pos[2]*g.fz,
			target[0]*g.fx, target[1]*g.fy, target[2]*g.fz,
			up[0]*g.fx, up[1]*g.fy, up[2]*g.fz);
		gl.glScaled(g.fx, g.fy, g.fz);
		gl.glGetDoublev(GL.GL_MODELVIEW_MATRIX, M, 0);
		gl.glMatrixMode(GL.GL_PROJECTION);
		gl.glLoadIdentity();
		// tryout
		switch (scale_mode)
		{
			case 0:
				gl.glOrtho(-0.5, 0.5, -0.5, 0.5, 0, 20);
				break;
			case 1:
				gl.glOrtho(0, canvas.getWidth(), 0, canvas.getHeight(), 0, 20);
				break;
			case 2:
				gl.glOrtho(0, fact, 0, fact, 0, 20);
				break;
		}
		gl.glGetDoublev(GL.GL_PROJECTION_MATRIX, P, 0);
		gl.glMatrixMode(GL.GL_MODELVIEW);
		gl.glGetIntegerv(GL.GL_VIEWPORT, V, 0);
	}

	public void childValidated(HandleObject child)
	{
		autoScale();
		autoScaleC();
		autoAspectRatio();
		autoCamera();

		if (child instanceof GraphicObject)
		{
			GraphicObject go = (GraphicObject)child;
			listen(go.XLim);
			listen(go.YLim);
			listen(go.ZLim);
			listen(go.CLim);
		}
	}

	public void draw(Renderer r)
	{
		// TODO: remove
		GL gl = ((GLRenderer)r).getGL();

		if (false)
			setupTransformation(gl);
		else
		{
			r.setXForm(this);
			gl.glGetDoublev(GL.GL_MODELVIEW_MATRIX, M, 0);
			gl.glGetDoublev(GL.GL_PROJECTION_MATRIX, P, 0);
			gl.glGetIntegerv(GL.GL_VIEWPORT, V, 0);
		}
	
		double xmin = XLim.getArray()[0], xmax = XLim.getArray()[1];
		double ymin = YLim.getArray()[0], ymax = YLim.getArray()[1];
		double zmin = ZLim.getArray()[0], zmax = ZLim.getArray()[1];

		double xd = (XDir.is("normal") ? 1 : -1);
		double yd = (YDir.is("normal") ? 1 : -1);
		double zd = (ZDir.is("normal") ? 1 : -1);

		double[] p1 = new double[3], p2 = new double[3], xv, yv, zv;

		xstate = ystate = zstate = AXE_ANY_DIR;

		x_render.transform(xmin, (ymin+ymax)/2, (zmin+zmax)/2, p1, 0);
		x_render.transform(xmax, (ymin+ymax)/2, (zmin+zmax)/2, p2, 0);
		xv = new double[] {Math.rint(p2[0]-p1[0]), Math.rint(p2[1]-p1[1]), (p2[2]-p1[2])};
		if (xv[0] == 0 && xv[1] == 0)
			xstate = AXE_DEPTH_DIR;
		else if (xv[2] == 0)
		{
			if (xv[0] == 0)
				xstate = AXE_VERT_DIR;
			else if (xv[1] == 0)
				xstate = AXE_HORZ_DIR;
		}
		double xPlane;
		if (xv[2] == 0)
			if (xv[1] == 0)
				xPlane = (xv[0] > 0 ? xmax : xmin);
			else
				xPlane = (xv[1] < 0 ? xmax : xmin);
		else
			xPlane = (xv[2] < 0 ? xmin : xmax);
		double xPlaneN = (xPlane == xmin ? xmax : xmin);
		double fx = (xmax-xmin)/Math.sqrt(xv[0]*xv[0]+xv[1]*xv[1]);

		x_render.transform((xmin+xmax)/2, ymin, (zmin+zmax)/2, p1, 0);
		x_render.transform((xmin+xmax)/2, ymax, (zmin+zmax)/2, p2, 0);
		yv = new double[] {Math.rint(p2[0]-p1[0]), Math.rint(p2[1]-p1[1]), p2[2]-p1[2]};
		if (yv[0] == 0 && yv[1] == 0)
			ystate = AXE_DEPTH_DIR;
		else if (yv[2] == 0)
		{
			if (yv[0] == 0)
				ystate = AXE_VERT_DIR;
			else if (yv[1] == 0)
				ystate = AXE_HORZ_DIR;
		}
		double yPlane;
		if (yv[2] == 0)
			if (yv[1] == 0)
				yPlane = (yv[0] > 0 ? ymax : ymin);
			else
				yPlane = (yv[1] < 0 ? ymax : ymin);
		else
			yPlane = (yv[2] < 0 ? ymin : ymax);
		double yPlaneN = (yPlane == ymin ? ymax : ymin);
		double fy = (ymax-ymin)/Math.sqrt(yv[0]*yv[0]+yv[1]*yv[1]);

		x_render.transform((xmin+xmax)/2, (ymin+ymax)/2, zmin, p1, 0);
		x_render.transform((xmin+xmax)/2, (ymin+ymax)/2, zmax, p2, 0);
		zv = new double[] {Math.rint(p2[0]-p1[0]), Math.rint(p2[1]-p1[1]), p2[2]-p1[2]};
		if (zv[0] == 0 && zv[1] == 0)
			zstate = AXE_DEPTH_DIR;
		else if (zv[2] == 0)
		{
			if (zv[0] == 0)
				zstate = AXE_VERT_DIR;
			else if (zv[1] == 0)
				zstate = AXE_HORZ_DIR;
		}
		double zPlane;
		if (zv[2] == 0)
			if (zv[1] == 0)
				zPlane = (zv[0] > 0 ? zmin : zmax);
			else
				zPlane = (zv[1] < 0 ? zmin : zmax);
		else
			zPlane = (zv[2] < 0 ? zmin : zmax);
		double zPlaneN = (zPlane == zmin ? zmax : zmin);
		double fz = (zmax-zmin)/Math.sqrt(zv[0]*zv[0]+zv[1]*zv[1]);

		boolean mode2d = (((xstate > AXE_DEPTH_DIR ? 1 : 0) +
						   (ystate > AXE_DEPTH_DIR ? 1 : 0) +
						   (zstate > AXE_DEPTH_DIR ? 1 : 0)) == 2);
		if (TickDirMode.is("auto"))
		{
			autoMode++;
			TickDir.set(mode2d ? "in" : "out", true);
			autoMode--;
		}

		xticklen = yticklen = zticklen = 7;

		double xtickoffset = Math.max(1.0, xticklen);
		double ytickoffset = Math.max(1.0, yticklen);
		double ztickoffset = Math.max(1.0, zticklen);
		double tickdir = (TickDir.is("in") ? -1 : 1);

		setLight(gl, false, 8);

		// Axes planes

		if (!AxesColor.is("none"))
		{
			AxesColor.setup(gl);
			gl.glPolygonOffset(2.5f, 2.5f);
			gl.glEnable(GL.GL_POLYGON_OFFSET_FILL);

			gl.glBegin(GL.GL_QUADS);
			gl.glVertex3d(xmin, ymin, zPlane);
			gl.glVertex3d(xmax, ymin, zPlane);
			gl.glVertex3d(xmax, ymax, zPlane);
			gl.glVertex3d(xmin, ymax, zPlane);
			gl.glEnd();

			gl.glBegin(GL.GL_QUADS);
			gl.glVertex3d(xPlane, ymin, zmin);
			gl.glVertex3d(xPlane, ymax, zmin);
			gl.glVertex3d(xPlane, ymax, zmax);
			gl.glVertex3d(xPlane, ymin, zmax);
			gl.glEnd();

			gl.glBegin(GL.GL_QUADS);
			gl.glVertex3d(xmin, yPlane, zmin);
			gl.glVertex3d(xmax, yPlane, zmin);
			gl.glVertex3d(xmax, yPlane, zmax);
			gl.glVertex3d(xmin, yPlane, zmax);
			gl.glEnd();

			gl.glDisable(GL.GL_POLYGON_OFFSET_FILL);
		}
		
		gl.glPolygonOffset(1.0f, 1.0f);
		gl.glEnable(GL.GL_LINE_STIPPLE);

		boolean xySym = (xd*yd*(xPlane-xPlaneN)*(yPlane-yPlaneN) > 0);
		boolean boxSet = Box.isSet();

		// Box

		LineStyleProperty.setupSolid(gl);
		if (boxSet || alwaysDrawBox)
		{
			gl.glBegin(GL.GL_LINES);
			XColor.setup(gl);
			gl.glVertex3d(xPlaneN, yPlaneN, zPlane); gl.glVertex3d(xPlane, yPlaneN, zPlane);
			if (Box.isSet())
			{
				gl.glVertex3d(xPlaneN, yPlane, zPlane); gl.glVertex3d(xPlane, yPlane, zPlane);
				gl.glVertex3d(xPlaneN, yPlane, zPlaneN); gl.glVertex3d(xPlane, yPlane, zPlaneN);
				gl.glVertex3d(xPlaneN, yPlaneN, zPlaneN); gl.glVertex3d(xPlane, yPlaneN, zPlaneN);
			}
			YColor.setup(gl);
			gl.glVertex3d(xPlaneN, yPlaneN, zPlane); gl.glVertex3d(xPlaneN, yPlane, zPlane);
			if (Box.isSet())
			{
				gl.glVertex3d(xPlane, yPlaneN, zPlane); gl.glVertex3d(xPlane, yPlane, zPlane);
				gl.glVertex3d(xPlane, yPlaneN, zPlaneN); gl.glVertex3d(xPlane, yPlane, zPlaneN);
				gl.glVertex3d(xPlaneN, yPlaneN, zPlaneN); gl.glVertex3d(xPlaneN, yPlane, zPlaneN);
			}
			ZColor.setup(gl);
			if (xySym /*xv[2]*yv[2] >= 0*/)
			{ gl.glVertex3d(xPlaneN, yPlane, zPlaneN); gl.glVertex3d(xPlaneN, yPlane, zPlane); }
			else
			{ gl.glVertex3d(xPlane, yPlaneN, zPlaneN); gl.glVertex3d(xPlane, yPlaneN, zPlane); }
			if (Box.isSet())
			{
				gl.glVertex3d(xPlane, yPlane, zPlaneN); gl.glVertex3d(xPlane, yPlane, zPlane);
				if (xySym /*xv[2]*yv[2] >= 0*/)
				{ gl.glVertex3d(xPlane, yPlaneN, zPlaneN); gl.glVertex3d(xPlane, yPlaneN, zPlane); }
				else
				{ gl.glVertex3d(xPlaneN, yPlane, zPlaneN); gl.glVertex3d(xPlaneN, yPlane, zPlane); }
				gl.glVertex3d(xPlaneN, yPlaneN, zPlaneN); gl.glVertex3d(xPlaneN, yPlaneN, zPlane);
			}
			gl.glEnd();
		}

		//gl.glEnable(GL.GL_LINE_STIPPLE);

		// X Grid

		if (xstate != AXE_DEPTH_DIR)
		{
			boolean doXGrid = XGrid.isSet() && !XGridStyle.is("none");
			double[] xticks = XTick.getArray();
			String[] xticklabels = XTickLabel.getArray();
			int wmax = 0, hmax = 0;
			boolean tickAlongZ = Double.isInfinite(fy);
			XColor.setup(gl);
			for (int i=0; i<xticks.length; i++)
			{
				double xf = xticks[i];

				// grid line
				if (doXGrid)
				{
					XGridStyle.setup(gl);
					gl.glBegin(GL.GL_LINES);
					gl.glVertex3d(xf, yPlaneN, zPlane);
					gl.glVertex3d(xf, yPlane, zPlane);
					gl.glVertex3d(xf, yPlane, zPlaneN);
					gl.glVertex3d(xf, yPlane, zPlane);
					gl.glEnd();
					LineStyleProperty.setupSolid(gl);
				}

				// tick mark
				if (tickAlongZ)
				{
					gl.glBegin(GL.GL_LINES);
					gl.glVertex3d(xf, yPlaneN, zPlane);
					gl.glVertex3d(xf, yPlaneN, zPlane+Math.signum(zPlane-zPlaneN)*fz*xticklen*tickdir);
					if (Box.isSet() && xstate != AXE_ANY_DIR)
					{
						gl.glVertex3d(xf, yPlaneN, zPlaneN);
						gl.glVertex3d(xf, yPlaneN, zPlaneN+Math.signum(zPlaneN-zPlane)*fz*xticklen*tickdir);
					}
					gl.glEnd();
					gl.glRasterPos3d(xf, yPlaneN, zPlane+Math.signum(zPlane-zPlaneN)*fz*xtickoffset);
				}
				else
				{
					gl.glBegin(GL.GL_LINES);
					gl.glVertex3d(xf, yPlaneN, zPlane);
					gl.glVertex3d(xf, yPlaneN+Math.signum(yPlaneN-yPlane)*fy*xticklen*tickdir, zPlane);
					if (Box.isSet() && xstate != AXE_ANY_DIR)
					{
						gl.glVertex3d(xf, yPlane, zPlane);
						gl.glVertex3d(xf, yPlane+Math.signum(yPlane-yPlaneN)*fy*xticklen*tickdir, zPlane);
					}
					gl.glEnd();
					gl.glRasterPos3d(xf, yPlaneN+Math.signum(yPlaneN-yPlane)*fy*xtickoffset, zPlane);
				}

				// tick text
				if (i < xticklabels.length)
				{
					Dimension d = GLTextRenderer.draw(canvas, gl, xticklabels[i],
										(xstate == AXE_HORZ_DIR ? 1 : (/*xv[2]*yv[2] >= 0*/ xySym ? 0 : 2)),
										(xstate == AXE_VERT_DIR ? 1 : (zd*zv[2] <= 0 ? 2 : 0)));
					if (d.width > wmax) wmax = d.width;
					if (d.height > hmax) hmax = d.height;
				}
			}

			// label
			if (!XLabel.isEmpty())
			{
				TextObject xLabObj = XLabel.getText();
				if (xLabObj.PositionMode.isSet())
				{
					xLabObj.HAlign.reset(xstate > AXE_DEPTH_DIR ? "center" : (xySym ? "left" : "right"));
					xLabObj.VAlign.reset(xstate == AXE_VERT_DIR ? "bottom" : (zd*zv[2] <= 0 ? "top" : "bottom"));

					double angle = 0;
					double[] p = new double[] {(xmin+xmax)/2, yPlaneN, zPlane};
					if (tickAlongZ)
						p[2] += (Math.signum(zPlane-zPlaneN)*fz*xtickoffset);
					else
						p[1] += (Math.signum(yPlaneN-yPlane)*fy*xtickoffset);
					x_render.transform(p[0], p[1], p[2], p, 0);
					switch (xstate)
					{
						case AXE_ANY_DIR:
							p[0] += (xySym ? wmax : -wmax);
							p[1] += (zd*zv[2] <= 0 ? hmax : -hmax);
							break;
						case AXE_VERT_DIR:
							p[0] -= wmax;
							angle = 90;
							break;
						case AXE_HORZ_DIR:
							p[1] += hmax;
							break;
					}
					x_renderInv.transform(p[0], p[1], p[2], p, 0);
					xLabObj.Position.reset(new double[] {p[0], p[1], p[2]});
					if (xLabObj.Rotation.doubleValue() != angle)
						try { xLabObj.Rotation.set(new Double(angle)); }
						catch (PropertyException e) {}
				}
				xLabObj.draw(r);
			}
		}

		// Y Grid

		if (ystate != AXE_DEPTH_DIR)
		{
			boolean doYGrid = YGrid.isSet() && !YGridStyle.is("none");
			double[] yticks = YTick.getArray();
			String[] yticklabels = YTickLabel.getArray();
			int wmax = 0, hmax = 0;
			boolean tickAlongZ = Double.isInfinite(fx);
			YColor.setup(gl);
			for (int i=0; i<yticks.length; i++)
			{
				double yf = yticks[i];

				// grid line
				if (doYGrid)
				{
					YGridStyle.setup(gl);
					gl.glBegin(GL.GL_LINES);
					gl.glVertex3d(xPlaneN, yf,zPlane);
					gl.glVertex3d(xPlane, yf, zPlane);
					gl.glVertex3d(xPlane, yf, zPlaneN);
					gl.glVertex3d(xPlane, yf, zPlane);
					gl.glEnd();
					LineStyleProperty.setupSolid(gl);
				}

				// tick mark
				if (tickAlongZ)
				{
					gl.glBegin(GL.GL_LINES);
					gl.glVertex3d(xPlaneN, yf, zPlane);
					gl.glVertex3d(xPlaneN, yf, zPlane+Math.signum(zPlane-zPlaneN)*fz*yticklen*tickdir);
					if (Box.isSet() && ystate != AXE_ANY_DIR)
					{
						gl.glVertex3d(xPlaneN, yf, zPlaneN);
						gl.glVertex3d(xPlaneN, yf, zPlaneN+Math.signum(zPlaneN-zPlane)*fz*yticklen*tickdir);
					}
					gl.glEnd();
					gl.glRasterPos3d(xPlaneN, yf, zPlane+Math.signum(zPlane-zPlaneN)*fz*ytickoffset);
				}
				else
				{
					gl.glBegin(GL.GL_LINES);
					gl.glVertex3d(xPlaneN, yf, zPlane);
					gl.glVertex3d(xPlaneN+Math.signum(xPlaneN-xPlane)*fx*yticklen*tickdir, yf, zPlane);
					if (Box.isSet() && ystate != AXE_ANY_DIR)
					{
						gl.glVertex3d(xPlane, yf, zPlane);
						gl.glVertex3d(xPlane+Math.signum(xPlane-xPlaneN)*fx*yticklen*tickdir, yf, zPlane);
					}
					gl.glEnd();
					gl.glRasterPos3d(xPlaneN+Math.signum(xPlaneN-xPlane)*fx*ytickoffset, yf, zPlane);
				}

				// tick text
				if (i < yticklabels.length)
				{
					Dimension d = GLTextRenderer.draw(canvas, gl, yticklabels[i],
										(ystate == AXE_HORZ_DIR ? 1 : (/*xv[2]*yv[2] < 0*/ !xySym ? 0 : 2)),
										(ystate == AXE_VERT_DIR ? 1 : (zd*zv[2] <= 0 ? 2 : 0)));
					if (d.width > wmax) wmax = d.width;
					if (d.height > hmax) hmax = d.height;
				}
			}

			// label
			if (!YLabel.isEmpty())
			{
				TextObject yLabObj = YLabel.getText();
				if (yLabObj.PositionMode.isSet())
				{
					yLabObj.HAlign.reset(ystate > AXE_DEPTH_DIR ? "center" : (!xySym ? "left" : "right"));
					yLabObj.VAlign.reset(ystate == AXE_VERT_DIR ? "bottom" : (zd*zv[2] <= 0 ? "top" : "bottom"));
				
					double angle = 0;
					double[] p = new double[] {xPlaneN, (ymin+ymax)/2, zPlane};
					if (tickAlongZ)
						p[2] += (Math.signum(zPlane-zPlaneN)*fz*ytickoffset);
					else
						p[0] += (Math.signum(xPlaneN-xPlane)*fx*ytickoffset);
					x_render.transform(p[0], p[1], p[2], p, 0);
					switch (ystate)
					{
						case AXE_ANY_DIR:
							p[0] += (!xySym ? wmax : -wmax);
							p[1] += (zd*zv[2] <= 0 ? hmax : -hmax);
							break;
						case AXE_VERT_DIR:
							p[0] -= wmax;
							angle = 90;
							break;
						case AXE_HORZ_DIR:
							p[1] += hmax;
							break;
					}
					x_renderInv.transform(p[0], p[1], p[2], p, 0);
					yLabObj.Position.reset(new double[] {p[0], p[1], p[2]});
					if (yLabObj.Rotation.doubleValue() != angle)
						try { yLabObj.Rotation.set(new Double(angle)); }
						catch (PropertyException e) {}
				}
				yLabObj.draw(r);
			}
		}
		
		// Z Grid

		if (zstate != AXE_DEPTH_DIR)
		{
			boolean doZGrid = ZGrid.isSet() && !ZGridStyle.is("none");
			double[] zticks = ZTick.getArray();
			int wmax = 0, hmax = 0;
			String[] zticklabels = ZTickLabel.getArray();
			ZColor.setup(gl);
			for (int i=0; i<zticks.length; i++)
			{
				double zf = zticks[i];

				// grid line
				if (doZGrid)
				{
					ZGridStyle.setup(gl);
					gl.glBegin(GL.GL_LINES);
					gl.glVertex3d(xPlaneN, yPlane, zf);
					gl.glVertex3d(xPlane, yPlane, zf);
					gl.glVertex3d(xPlane, yPlaneN, zf);
					gl.glVertex3d(xPlane, yPlane, zf);
					gl.glEnd();
					LineStyleProperty.setupSolid(gl);
				}

				// tick mark
				if (/*xv[2]*yv[2] >= 0*/ xySym)
				{
					if (Double.isInfinite(fy))
					{
						gl.glBegin(GL.GL_LINES);
						gl.glVertex3d(xPlaneN, yPlane, zf);
						gl.glVertex3d(xPlaneN+Math.signum(xPlaneN-xPlane)*fx*zticklen*tickdir, yPlane, zf);
						if (Box.isSet() && zstate != AXE_ANY_DIR)
						{
							gl.glVertex3d(xPlane, yPlane, zf);
							gl.glVertex3d(xPlane+Math.signum(xPlane-xPlaneN)*fx*zticklen*tickdir, yPlane, zf);
						}
						gl.glEnd();
						gl.glRasterPos3d(xPlaneN+Math.signum(xPlaneN-xPlane)*fx*ztickoffset, yPlane, zf);
					}
					else
					{
						gl.glBegin(GL.GL_LINES);
						gl.glVertex3d(xPlaneN, yPlane, zf);
						gl.glVertex3d(xPlaneN, yPlane+Math.signum(yPlane-yPlaneN)*fy*zticklen*tickdir, zf);

						gl.glEnd();
						gl.glRasterPos3d(xPlaneN, yPlane+Math.signum(yPlane-yPlaneN)*fy*ztickoffset, zf);
					}
				}
				else
				{
					if (Double.isInfinite(fx))
					{
						gl.glBegin(GL.GL_LINES);
						gl.glVertex3d(xPlane, yPlaneN, zf);
						gl.glVertex3d(xPlane, yPlaneN+Math.signum(yPlaneN-yPlane)*fy*zticklen*tickdir, zf);
						if (Box.isSet() && zstate != AXE_ANY_DIR)
						{
							gl.glVertex3d(xPlane, yPlane, zf);
							gl.glVertex3d(xPlane, yPlane+Math.signum(yPlane-yPlaneN)*fy*zticklen*tickdir, zf);
						}
						gl.glEnd();
						gl.glRasterPos3d(xPlane, yPlaneN+Math.signum(yPlaneN-yPlane)*fy*ztickoffset, zf);
					}
					else
					{
						gl.glBegin(GL.GL_LINES);
						gl.glVertex3d(xPlane, yPlaneN, zf);
						gl.glVertex3d(xPlane+Math.signum(xPlane-xPlaneN)*fx*zticklen*tickdir, yPlaneN, zf);
						gl.glEnd();
						gl.glRasterPos3d(xPlane+Math.signum(xPlane-xPlaneN)*fx*ztickoffset, yPlaneN, zf);
					}
				}

				// tick text
				if (i < zticklabels.length)
				{
					Dimension d = GLTextRenderer.draw(canvas, gl, zticklabels[i],
									2,
									(zstate == AXE_VERT_DIR ? 1 : (zd*zv[2] < 0 ? 0 : 2)));
					if (d.width > wmax) wmax = d.width;
					if (d.height > hmax) hmax = d.height;
				}
			}

			// label
			if (!ZLabel.isEmpty())
			{
				TextObject zLabObj = ZLabel.getText();
				if (zLabObj.PositionMode.isSet())
				{
					zLabObj.HAlign.reset(zstate > AXE_DEPTH_DIR ? "center" : "right");
					zLabObj.VAlign.reset(zstate == AXE_VERT_DIR ? "bottom" : (zd*zv[2] < 0 ? "bottom" : "top"));
				
					double angle = 0;
					double[] p;
					if (xySym)
					{
						p = new double[] {xPlaneN, yPlane, (zmin+zmax)/2};
						if (Double.isInfinite(fy))
							p[0] += (Math.signum(xPlaneN-xPlane)*fx*ztickoffset);
						else
							p[1] += (Math.signum(yPlane-yPlaneN)*fy*ztickoffset);
					}
					else
					{
						p = new double[] {xPlane, yPlaneN, (zmin+zmax)/2};
						if (Double.isInfinite(fx))
							p[1] += (Math.signum(yPlaneN-yPlane)*fy*ztickoffset);
						else
							p[0] += (Math.signum(xPlane-xPlaneN)*fx*ztickoffset);
					}
					x_render.transform(p[0], p[1], p[2], p, 0);
					switch (zstate)
					{
						case AXE_ANY_DIR:
							if (CameraUpVectorMode.is("auto"))
							{
								p[0] -= wmax;
								angle = 90;
							}
							/* TODO: what's the correct offset?
							p[0] += (!xySym ? wmax : -wmax);
							p[1] += (zd*zv[2] <= 0 ? hmax : -hmax);
							*/
							break;
						case AXE_VERT_DIR:
							p[0] -= wmax;
							angle = 90;
							break;
						case AXE_HORZ_DIR:
							p[1] += hmax;
							break;
					}
					x_renderInv.transform(p[0], p[1], p[2], p, 0);
					zLabObj.Position.reset(new double[] {p[0], p[1], p[2]});
					if (zLabObj.Rotation.doubleValue() != angle)
						try { zLabObj.Rotation.set(new Double(angle)); }
						catch (PropertyException e) {}
				}
				zLabObj.draw(r);
			}
		}
		
		gl.glDisable(GL.GL_LINE_STIPPLE);

		// Title

		if (!Title.isEmpty())
		{
			TextObject titleObj = Title.getText();
			if (titleObj.PositionMode.isSet())
			{
				// position title automatically
				Rectangle bb = getBoundingBox();
				double[] p = new double[3];
				x_renderInv.transform(bb.x+bb.width/2, canvas.getHeight()-(bb.y+bb.height+10), (x_zmin+x_zmax)/2, p, 0);
				titleObj.Position.reset(p);
			}
			titleObj.draw(r);
		}

		/*
		if (false)
		{
			// Setup clipping planes

			gl.glClipPlane(GL.GL_CLIP_PLANE0, new double[] { -1, 0, 0, xmax }, 0);
			gl.glClipPlane(GL.GL_CLIP_PLANE1, new double[] { 1, 0, 0, -xmin }, 0);
			gl.glClipPlane(GL.GL_CLIP_PLANE2, new double[] { 0, -1, 0, ymax }, 0);
			gl.glClipPlane(GL.GL_CLIP_PLANE3, new double[] { 0, 1, 0, -ymin }, 0);
			gl.glClipPlane(GL.GL_CLIP_PLANE4, new double[] { 0, 0, -1, zmax }, 0);
			gl.glClipPlane(GL.GL_CLIP_PLANE5, new double[] { 0, 0, 1, -zmin }, 0);

			setClipping(gl, true);
	
			Iterator it;

			// Do lights first
			maxLight = 0;
			it = Children.iterator();
			while (it.hasNext())
			{
				GraphicObject obj = (GraphicObject)it.next();
				if (obj instanceof LightObject)
				{
					gl.glLightfv(GL.GL_LIGHT0+maxLight, GL.GL_AMBIENT, new float[] {1.0f,1.0f,1.0f,1.0f}, 0);
					((LightObject)obj).setLightIndex(maxLight++);
					obj.draw(gl);
				}
			}

			// Do other objects
			it = Children.iterator();
			while (it.hasNext())
			{
				GraphicObject obj = (GraphicObject)it.next();
				if (!(obj instanceof LightObject))
					obj.draw(gl);
			}
			
			setClipping(gl, false);
		}
		else
		{
		*/
			Iterator it;

			// TODO: how to avoid clipping on the clip planes?
			r.setClipBox(
				xmin-0.001*(xmax-xmin), xmax+0.001*(xmax-xmin),
				ymin-0.001*(ymax-ymin), ymax+0.001*(ymax-ymin),
				zmin-0.001*(zmax-zmin), zmax+0.001*(zmax-zmin));
			r.setClipping(true);
			r.setCamera(CameraPosition.getArray(), CameraTarget.getArray());

			// Do lights first
			it = Children.iterator();
			while (it.hasNext())
			{
				GraphicObject obj = (GraphicObject)it.next();
				if (obj.Visible.isSet() && obj instanceof LightObject)
					obj.draw(r);
			}

			// Do other objects
			it = Children.iterator();
			while (it.hasNext())
			{
				GraphicObject obj = (GraphicObject)it.next();
				if (obj.Visible.isSet() && !(obj instanceof LightObject))
					obj.draw(r);
			}

			r.setClipping(false);
		/*
		}
		*/
		
		r.end();
		
		if (zoomBox)
		{
			drawZoomBox(xPrev, yPrev);
		}
	}

	void setClipping(GL gl, boolean flag)
	{
		if (flag)
			for (int i=0; i<6; i++)
				gl.glEnable(GL.GL_CLIP_PLANE0+i);
		else
			for (int i=0; i<6; i++)
				gl.glDisable(GL.GL_CLIP_PLANE0+i);
	}

	boolean getClipping(GL gl)
	{
		return gl.glIsEnabled(GL.GL_CLIP_PLANE0);
	}

	void setLight(GL gl, boolean flag)
	{
		setLight(gl, flag, maxLight);
	}

	void setLight(GL gl, boolean flag, int maxLight)
	{
		if (flag)
		{
			gl.glEnable(GL.GL_LIGHTING);
			for (int i=0; i<maxLight; i++)
				gl.glEnable(GL.GL_LIGHT0+i);
		}
		else
		{
			gl.glDisable(GL.GL_LIGHTING);
			for (int i=0; i<maxLight; i++)
				gl.glDisable(GL.GL_LIGHT0+i);
		}
	}

	void autoSet(Property p, Object value)
	{
		autoMode++;
		p.set(value, true);
		autoMode--;
	}

	boolean isAutoMode()
	{
		return (autoMode > 0);
	}
	
	protected void autoScale()
	{
		autoScaleX();
		autoScaleY();
		autoScaleZ();
	}

	protected void autoScaleX()
	{
		if (XLimMode.is("auto") && Children.size() > 0)
		{
			double[] xlim = { Double.POSITIVE_INFINITY, Double.NEGATIVE_INFINITY };

			for (int i=0; i<Children.size(); i++)
			{
				GraphicObject go = (GraphicObject)Children.elementAt(i);
				if (go.XLimInclude.isSet())
				{
					double[] _xlim = go.XLim.getArray();
					xlim[0] = Math.min(_xlim[0], xlim[0]);
					xlim[1] = Math.max(_xlim[1], xlim[1]);
				}
			}

			if (xlim[0] > xlim[1])
			{
				xlim[0] = 0;
				xlim[1] = 1;
			}
			else if (xlim[0] == xlim[1])
			{
				xlim[0] -= 0.5;
				xlim[1] += 0.5;
			}

			double dx = xlim[1]-xlim[0];
			if (dx > 10)
			{
				xlim[0] = Math.floor(xlim[0]);
				xlim[1] = Math.ceil(xlim[1]);
			}

			autoSet(XLim, xlim);
			autoTickX();
		}
	}

	protected void autoScaleY()
	{
		if (YLimMode.is("auto") && Children.size() > 0)
		{
			double[] ylim = { Double.POSITIVE_INFINITY, Double.NEGATIVE_INFINITY };

			for (int i=0; i<Children.size(); i++)
			{
				GraphicObject go = (GraphicObject)Children.elementAt(i);
				if (go.YLimInclude.isSet())
				{
					double[] _ylim = go.YLim.getArray();
					ylim[0] = Math.min(_ylim[0], ylim[0]);
					ylim[1] = Math.max(_ylim[1], ylim[1]);
				}
			}

			if (ylim[0] > ylim[1])
			{
				ylim[0] = 0;
				ylim[1] = 1;
			}
			else if (ylim[0] == ylim[1])
			{
				ylim[0] -= 0.5;
				ylim[1] += 0.5;
			}

			double dx = ylim[1]-ylim[0];
			if (dx > 10)
			{
				ylim[0] = Math.floor(ylim[0]);
				ylim[1] = Math.ceil(ylim[1]);
			}

			autoSet(YLim, ylim);
			autoTickY();
		}
	}

	protected void autoScaleZ()
	{
		if (ZLimMode.is("auto") && Children.size() > 0)
		{
			double[] zlim = { Double.POSITIVE_INFINITY, Double.NEGATIVE_INFINITY };

			for (int i=0; i<Children.size(); i++)
			{
				GraphicObject go = (GraphicObject)Children.elementAt(i);
				if (go.ZLimInclude.isSet())
				{
					double[] _zlim = go.ZLim.getArray();
					zlim[0] = Math.min(_zlim[0], zlim[0]);
					zlim[1] = Math.max(_zlim[1], zlim[1]);
				}
			}

			if (zlim[0] > zlim[1])
			{
				zlim[0] = -0.5;
				zlim[1] = 0.5;
			}
			else if (zlim[0] == zlim[1])
			{
				zlim[0] -= 0.5;
				zlim[1] += 0.5;
			}

			double dx = zlim[1]-zlim[0];
			if (dx > 10)
			{
				zlim[0] = Math.floor(zlim[0]);
				zlim[1] = Math.ceil(zlim[1]);
			}

			autoSet(ZLim, zlim);
			autoTickZ();
		}
	}

	protected void autoScaleC()
	{
		if (CLimMode.is("auto") && Children.size() > 0)
		{
			double[] clim = { Double.POSITIVE_INFINITY, Double.NEGATIVE_INFINITY };

			for (int i=0; i<Children.size(); i++)
			{
				GraphicObject child = (GraphicObject)Children.elementAt(i);
				String mapping;

				try	{ mapping = (String)child.get("CDataMapping"); }
				catch (PropertyException e) { mapping = ""; }

				if (child.CLimInclude.isSet() && mapping.equals("scaled"))
				{
					double[] _clim = child.CLim.getArray();
					clim[0] = Math.min(clim[0], _clim[0]);
					clim[1] = Math.max(clim[1], _clim[1]);
				}
			}

			if (clim[0] > clim[1])
			{
				clim[0] = 0.0;
				clim[1] = 1.0;
			}

			autoSet(CLim, clim);
		}
	}

	protected void autoScaleA()
	{
	}

	protected void autoTick()
	{
		autoTickX();
		autoTickY();
		autoTickZ();
	}

	protected void autoTickX()
	{
		if (XTickMode.is("auto"))
		{
			double xmin = XLim.getArray()[0], xmax = XLim.getArray()[1];
			double[] ticks = new double[5];
			for (int i=0; i<ticks.length; i++)
				ticks[i] = xmin + i * (xmax - xmin) / (ticks.length - 1);
			autoSet(XTick, ticks);
		}
		autoTickLabelX();
	}

	protected void autoTickY()
	{
		if (YTickMode.is("auto"))
		{
			double ymin = YLim.getArray()[0], ymax = YLim.getArray()[1];
			double[] ticks = new double[5];
			for (int i=0; i<ticks.length; i++)
				ticks[i] = ymin + i * (ymax - ymin) / (ticks.length - 1);
			autoSet(YTick, ticks);
		}
		autoTickLabelY();
	}

	protected void autoTickZ()
	{
		if (ZTickMode.is("auto"))
		{
			double zmin = ZLim.getArray()[0], zmax = ZLim.getArray()[1];
			double[] ticks = new double[5];
			for (int i=0; i<ticks.length; i++)
				ticks[i] = zmin + i * (zmax - zmin) / (ticks.length - 1);
			autoSet(ZTick, ticks);
		}
		autoTickLabelZ();
	}

	protected void autoTickLabel()
	{
		autoTickLabelX();
		autoTickLabelY();
		autoTickLabelZ();
	}

	protected void autoTickLabelX()
	{
		double[] ticks = XTick.getArray();
		String[] labels = new String[ticks.length];
		for (int i=0; i<ticks.length; i++)
		{
			double val = ((double)Math.round(ticks[i]*100))/100;
			labels[i] = new Double(val).toString();
		}
		autoSet(XTickLabel, labels);
	}

	protected void autoTickLabelY()
	{
		double[] ticks = YTick.getArray();
		String[] labels = new String[ticks.length];
		for (int i=0; i<ticks.length; i++)
		{
			double val = ((double)Math.round(ticks[i]*100))/100;
			labels[i] = new Double(val).toString();
		}
		autoSet(YTickLabel, labels);

	}

	protected void autoTickLabelZ()
	{
		double[] ticks = ZTick.getArray();
		String[] labels = new String[ticks.length];
		for (int i=0; i<ticks.length; i++)
		{
			double val = ((double)Math.round(ticks[i]*100))/100;
			labels[i] = new Double(val).toString();
		}
		autoSet(ZTickLabel, labels);
	}

	protected void autoCamera()
	{
		/* TODO: remove
		AxesGeometry g = getGeometry();
		double[] angles = View.getArray();
		if (CameraTargetMode.is("auto"))
			autoSet(CameraTarget, new double[] {g.cx, g.cy, g.cz});
		if (CameraPositionMode.is("auto"))
		{
			double d = Math.sqrt(75);
			double[] target = CameraTarget.getArray();
			if (angles[1] == 90 || angles[1] == -90)
				autoSet(CameraPosition, new double[] {target[0], target[1], target[2]+d*g.dz});
			else
			{
				double px = target[0]*g.fx+d*Math.cos(g.el)*Math.sin(g.az);
				double py = target[1]*g.fy-d*Math.cos(g.el)*Math.cos(g.az);
				double pz = target[2]*g.fz+d*Math.sin(g.el);
				autoSet(CameraPosition, new double[] {px/g.fx, py/g.fy, pz/g.fz});
			}
		}
		if (CameraUpVectorMode.is("auto"))
		{
			if (angles[1] == 90 || angles[1] == -90)
				autoSet(CameraUpVector,
						new double[] {
							-Math.sin(g.az)/g.fx,
							Math.cos(g.az)/g.fy,
							0
						});
			else
				autoSet(CameraUpVector, new double[] {0,0,1});
		}
		if (CameraViewAngleMode.is("auto"))
		{
		}
		*/
		updateXFormMatrices();
	}

	protected void autoAspectRatio()
	{
		double dx = XLim.elementAt(1)-XLim.elementAt(0);
		double dy = YLim.elementAt(1)-YLim.elementAt(0);
		double dz = ZLim.elementAt(1)-ZLim.elementAt(0);
		
		if (DataAspectRatioMode.is("auto"))
		{
			double dmin = Math.min(Math.min(dx, dy), dz);
			autoSet(DataAspectRatio, new double[] {dx/dmin, dy/dmin, dz/dmin});
		}
		if (PlotBoxAspectRatioMode.is("auto"))
		{
			if (DataAspectRatioMode.is("auto"))
				autoSet(PlotBoxAspectRatio, new double[] {1,1,1});
			else
			{
				double[] daspect = DataAspectRatio.getArray();
				autoSet(PlotBoxAspectRatio, new double[] {
					dx/daspect[0],
					dy/daspect[1],
					dz/daspect[2]});
			}
		}
		// TODO: if plotboxaspectratiomode is "manual", limits
		// and/or dataaspectratio might be adapted
	}

	private void doZoom(int x1, int y1, int x2, int y2)
	{
		double[] pos1 = new double[3], pos2 = new double[3];

		x_renderInv.transform((double)x1, (double)y1, (x_zmin+x_zmax)/2, pos1, 0);
		x_renderInv.transform((double)x2, (double)y2, (x_zmin+x_zmax)/2, pos2, 0);
		zoomStack.push(XLimMode.get());
		zoomStack.push(XLim.get());
		zoomStack.push(YLimMode.get());
		zoomStack.push(YLim.get());
		autoMode++;
		XLim.set(new double[] {Math.min(pos1[0], pos2[0]), Math.max(pos1[0], pos2[0])}, true);
		XLimMode.set("manual", true);
		YLim.set(new double[] {Math.min(pos1[1], pos2[1]), Math.max(pos1[1], pos2[1])}, true);
		YLimMode.set("manual", true);
		autoMode--;
		autoTick();
		autoAspectRatio();
		autoCamera();
		canvas.redraw();
	}

	public void unZoom()
	{
		if (zoomStack.size() >= 4)
		{
			autoMode++;
			YLim.set(zoomStack.pop(), true);
			YLimMode.set(zoomStack.pop(), true);
			XLim.set(zoomStack.pop(), true);
			XLimMode.set(zoomStack.pop(), true);
			autoMode--;
			autoTick();
			autoAspectRatio();
			autoCamera();
			canvas.redraw();
		}
	}

	private void drawZoomBox(int x, int y)
	{
		canvas.getRenderer().drawRubberBox(new int[][] {{xAnchor, yAnchor, x, y}});
	}

	private void drawZoomBox(int x1, int y1, int x2, int y2)
	{
		canvas.getRenderer().drawRubberBox(new int[][]
				{{xAnchor, yAnchor, x1, y1},
				 {xAnchor, yAnchor, x2, y2}});
	}

	public void startOperation(int op, MouseEvent e)
	{
		xAnchor = xPrev = e.getX();
		yAnchor = yPrev = e.getY();

		switch (op)
		{
			case FigureObject.OP_ZOOM:
				// start zoom box only in 2D mode
				if (zstate == AXE_DEPTH_DIR && xstate == AXE_HORZ_DIR && ystate == AXE_VERT_DIR)
				{
					drawZoomBox(xPrev, yPrev);
					zoomBox = true;
				}
				break;
			case FigureObject.OP_ROTATE:
				boundingBox = getBoundingBox();
				break;
		}
	}

	public void endOperation(int op, MouseEvent e)
	{
		switch (op)
		{
			case FigureObject.OP_ZOOM:
				if (zoomBox)
				{
					drawZoomBox(xPrev, yPrev);
					zoomBox = false;
					if (xPrev != xAnchor && yPrev != yAnchor)
						doZoom(xAnchor, yAnchor, xPrev, yPrev);
				}
				break;
			case FigureObject.OP_ROTATE:
				boundingBox = null;
				break;
		}
	}

	public void cancelOperation(int op)
	{
		switch (op)
		{
			case FigureObject.OP_ZOOM:
				if (zoomBox)
				{
					drawZoomBox(xPrev, yPrev);
					zoomBox = false;
				}
				break;
			case FigureObject.OP_ROTATE:
				boundingBox = null;
				break;
		}
	}

	public void operation(int op, MouseEvent e)
	{
		switch (op)
		{
			case FigureObject.OP_ROTATE:
				double new_anglex = View.getArray()[1], new_anglez = View.getArray()[0];

				// TODO: use actual axes size
				new_anglez += (xPrev-e.getX()) * (180.0/boundingBox.width);
				new_anglex += (e.getY()-yPrev) * (180.0/boundingBox.height);

				// clipping
				if (new_anglex > 90) new_anglex = 90;
				else if (new_anglex < -90) new_anglex = -90;
				if (new_anglez > 180) new_anglez -= 360;
				else if (new_anglez < -180) new_anglez += 360;

				// snapping
				double margin = 1;
				for (int alpha = -90; alpha <= 90; alpha += 90)
					if (alpha-margin < new_anglex && new_anglex < alpha+margin)
						new_anglex = alpha;
				for (int alpha = -180; alpha <= 180; alpha += 90)
					if (alpha-margin < new_anglez && new_anglez < alpha+margin)
						if (alpha == 180)
							new_anglez = -180;
						else
							new_anglez = alpha;

				try { set(View, new double[] {new_anglez, new_anglex}); }
				catch (PropertyException ex) {}
				xPrev = e.getX();
				yPrev = e.getY();

				getFigure().redraw(this);
				break;
			case FigureObject.OP_ZOOM:
				if (zoomBox)
				{
					drawZoomBox(xPrev, yPrev, e.getX(), e.getY());
					xPrev = e.getX();
					yPrev = e.getY();
				}
				break;
		}
	}

	double[] convertUnits(double[] pos, String units)
	{
		return convertUnits(pos, units, "data");
	}

	double[] convertUnits(double[] pos, String units, String toUnits)
	{
		double[] p;

		if (units.equalsIgnoreCase("data"))
			p = (double[])pos.clone();
		else if (units.equalsIgnoreCase("pixels"))
		{
			Rectangle bb = getBoundingBox();
			p = new double[3];
			x_renderInv.transform(bb.x+pos[0], bb.y+pos[1], pos[2], p, 0);
		}
		else
		{
			System.err.println("WARNING: cannot from units `" + units + "'");
			p = (double[])pos.clone();
		}

		if (!toUnits.equalsIgnoreCase("data"))
		{
			if (toUnits.equalsIgnoreCase("pixels"))
			{
				Rectangle bb = getBoundingBox();
				x_render.transform(p[0], p[1], p[2], p, 0);
				p[0] = Math.rint(p[0])-bb.x;
				p[1] = Math.rint(p[1])-bb.y;
			}
		}

		return p;
	}

	double[][] convertCData(double[] cdata, String mapping)
	{
		double[] clim = CLim.getArray();
		double[][] cmap = getFigure().Colormap.getMatrix();
		double[][] c = new double[cdata.length][];

		if (mapping.equals("scaled"))
			for (int i=0; i<cdata.length; i++)
			{
				int index = (int)Math.round((cmap.length-1)*(cdata[i]-clim[0])/(clim[1]-clim[0]));
				if (index < 0) index = 0;
				else if (index >= cmap.length) index = cmap.length-1;
				c[i] = cmap[index];
			}
		else
			for (int i=0; i<cdata.length; i++)
			{
				int index = (int)Math.round(cdata[i]);
				if (index < 0) index = 0;
				else if (index >= cmap.length) index = cmap.length-1;
				c[i] = cmap[index];
			}

		return c;
	}

	double[][][] convertCData(double[][] cdata, String mapping)
	{
		double[] clim = CLim.getArray();
		double[][] cmap = getFigure().Colormap.getMatrix();
		double[][][] c = new double[cdata.length][cdata[0].length][];
		boolean scaled = mapping.equals("scaled");

		if (mapping.equals("scaled"))
			for (int i=0; i<cdata.length; i++)
				for (int j=0; j<cdata[i].length; j++)
				{
					int index = (int)Math.round((cmap.length-1)*(cdata[i][j]-clim[0])/(clim[1]-clim[0]));
					if (index < 0) index = 0;
					else if (index >= cmap.length) index = cmap.length-1;
					//System.arraycopy(cmap[index], 0, c[i][j], 0, 3);
					c[i][j] = cmap[index];
				}
		else
			for (int i=0; i<cdata.length; i++)
				for (int j=0; j<cdata[i].length; j++)
				{
					int index = (int)Math.round(cdata[i][j]);
					if (index < 0) index = 0;
					else if (index >= cmap.length) index = cmap.length-1;
					c[i][j] = cmap[index];
				}
		return c;
	}

	double[][] convertCDataToIndex(double[][] cdata)
	{
		double[] clim = CLim.getArray();
		double[][] cmap = getFigure().Colormap.getMatrix();
		double[][]c = new double[cdata.length][cdata[0].length];

		for (int i=0; i<cdata.length; i++)
			for (int j=0; j<cdata[i].length; j++)
				c[i][j] = (cdata[i][j]-clim[0])/(clim[1]-clim[0]);

		return c;
	}

	boolean hasLight()
	{
		return (maxLight > 0);
	}

	public void propertyChanged(Property p) throws PropertyException
	{
		if (autoMode == 0)
		{
			if (p == XLim)
			{
				XLimMode.set("manual");
				autoTickX();
			}
			else if (p == YLim)
			{
				YLimMode.set("manual");
				autoTickY();
			}
			else if (p == ZLim)
			{
				ZLimMode.set("manual");
				autoTickZ();
			}
			else if (p == XLimMode)
			{
				if (XLimMode.is("auto"))
					autoScaleX();
			}
			else if (p == YLimMode)
			{
				if (YLimMode.is("auto"))
					autoScaleY();
			}
			else if (p == ZLimMode)
			{
				if (ZLimMode.is("auto"))
					autoScaleZ();
			}
			else if (p == XTick)
			{
				XTickMode.set("manual");
				autoTickLabelX();
			}
			else if (p == YTick)
			{
				YTickMode.set("manual");
				autoTickLabelY();
			}
			else if (p == ZTick)
			{
				ZTickMode.set("manual");
				autoTickLabelZ();
			}
			else if (p == XTickMode)
			{
				if (XTickMode.is("auto"))
					autoTickX();
			}
			else if (p == YTickMode)
			{
				if (YTickMode.is("auto"))
					autoTickY();
			}
			else if (p == ZTickMode)
			{
				if (ZTickMode.is("auto"))
					autoTickZ();
			}
			else if (p == XTickLabel)
				XTickLabelMode.set("manual");
			else if (p == YTickLabel)
				YTickLabelMode.set("manual");
			else if (p == ZTickLabel)
				ZTickLabelMode.set("manual");
			else if (p == XTickLabelMode)
			{
				if (XTickLabelMode.is("auto"))
					autoTickLabelX();
			}
			else if (p == YTickLabelMode)
			{
				if (YTickLabelMode.is("auto"))
					autoTickLabelY();
			}
			else if (p == ZTickLabelMode)
			{
				if (ZTickLabelMode.is("auto"))
					autoTickLabelZ();
			}
			else if (p == TickDir)
				TickDirMode.set("manual");
			else if (p == CLim)
				CLimMode.set("manual");
			else if (p == CLimMode)
			{
				if (CLimMode.is("auto"))
					autoScaleC();
			}
			else if (p == ALim)
				ALimMode.set("manual");
			else if (p == ALimMode)
			{
				if (ALimMode.is("auto"))
					autoScaleA();
			}
			else if (p == CameraTarget)
				CameraTargetMode.set("manual");
			else if (p == CameraTargetMode)
			{
				if (CameraTargetMode.is("auto"))
					autoCamera();
			}
			else if (p == CameraPosition)
				CameraPositionMode.set("manual");
			else if (p == CameraPositionMode)
			{
				if (CameraPositionMode.is("auto"))
					autoCamera();
			}
			else if (p == CameraUpVector)
				CameraUpVectorMode.set("manual");
			else if (p == CameraUpVectorMode)
			{
				if (CameraUpVectorMode.is("auto"))
					autoCamera();
			}
			else if (p == CameraViewAngle)
				CameraViewAngleMode.set("manual");
			else if (p == CameraViewAngleMode)
			{
				if (CameraViewAngleMode.is("auto"))
					autoCamera();
			}
			else if (p == DataAspectRatio)
			{
				DataAspectRatioMode.set("manual");
				autoAspectRatio();
				autoCamera();
			}
			else if (p == DataAspectRatioMode)
			{
				if (DataAspectRatioMode.is("auto"))
				{
					autoAspectRatio();
					autoCamera();
				}
			}
			else if (p == PlotBoxAspectRatio)
			{
				PlotBoxAspectRatioMode.set("manual");
				autoAspectRatio();
				autoCamera();
			}
			else if (p == PlotBoxAspectRatioMode)
			{
				if (PlotBoxAspectRatioMode.is("auto"))
				{
					autoAspectRatio();
					autoCamera();
				}
			}
			else if (p == OuterPosition)
			{
				updatePosition();
				ActivePositionProperty.set("outerposition");
			}
			else if (p == Position)
			{
				updateOuterPosition();
				ActivePositionProperty.set("position");
			}
		} /* autoMode == 0 */

		if (p == View)
			autoCamera();
		else if (p == Units)
		{
			FigureObject fig = getFigure();
			OuterPosition.reset(fig.convertPosition(OuterPosition.getArray(), currentUnits, Units.getValue()));
			Position.reset(fig.convertPosition(Position.getArray(), currentUnits, Units.getValue()));
			currentUnits = Units.getValue();
		}

		if (autoMode == 0 && (p == XLim || p == YLim || p == ZLim ||
			p == XLimMode || p == YLimMode || p == ZLimMode ||
			p == XDir || p == YDir || p == ZDir || p == Position || p == OuterPosition))
		{
			zoomStack.clear();
			autoAspectRatio();
			autoCamera();
		}

		if (p.getParent() != this)
		{
			String name = p.getName();

			if (name.equals("XLim"))
				autoScaleX();
			else if (name.equals("YLim"))
				autoScaleY();
			else if (name.equals("ZLim"))
				autoScaleZ();
			else if (name.equals("CLim"))
				autoScaleC();
			autoCamera();
		}
	}

	/* Transformation computation */

	Matrix3D x_view = new Matrix3D();
	Matrix3D x_projection = new Matrix3D();
	Matrix3D x_viewport = new Matrix3D();
	Matrix3D x_normrender = new Matrix3D();
	Matrix3D x_render = new Matrix3D();
	Matrix3D x_renderInv;
	Matrix3D x_mat1 = new Matrix3D();
	Matrix3D x_mat2 = new Matrix3D();
	double x_zmin, x_zmax;

	public void updateXFormMatrices()
	{
		double xd = (XDir.is("normal") ? 1 : -1);
		double yd = (YDir.is("normal") ? 1 : -1);
		double zd = (ZDir.is("normal") ? 1 : -1);

		double[] xlim = XLim.getArray();
		double[] ylim = YLim.getArray();
		double[] zlim = ZLim.getArray();

		double xo = xlim[xd > 0 ? 0 : 1];
		double yo = ylim[yd > 0 ? 0 : 1];
		double zo = zlim[zd > 0 ? 0 : 1];

		double[] pb = PlotBoxAspectRatio.getArray();

		boolean autocam = CameraPositionMode.is("auto") &&
				CameraTargetMode.is("auto") && CameraUpVectorMode.is("auto") &&
				CameraViewAngleMode.is("auto");
		boolean dowarp = autocam && DataAspectRatioMode.is("auto") &&
				PlotBoxAspectRatioMode.is("auto");

		Vector3D c_eye;
		Vector3D c_center;
		Vector3D c_upv;

		if (CameraTargetMode.is("auto"))
		{
			double[] p = new double[] {(xlim[0]+xlim[1])/2, (ylim[0]+ylim[1])/2, (zlim[0]+zlim[1])/2};
			c_center = new Vector3D(p);
			autoSet(CameraTarget, p);
		}
		else
			c_center = new Vector3D(CameraTarget.getArray());

		if (CameraPositionMode.is("auto"))
		{
			double az = View.getArray()[0];
			double el = View.getArray()[1];
			double d = 5*Math.sqrt(pb[0]*pb[0]+pb[1]*pb[1]+pb[2]*pb[2]);

			if (el == 90 || el == -90)
				c_eye = new Vector3D(new double[] {0, 0, d*Math.signum(el)});
			else
			{
				az *= Math.PI/180.0;
				el *= Math.PI/180.0;
				c_eye = new Vector3D(new double[] {
					d*Math.cos(el)*Math.sin(az),
					-d*Math.cos(el)*Math.cos(az),
					d*Math.sin(el)}, false);
			}
			c_eye.scale((xlim[1]-xlim[0])/(xd*pb[0]), (ylim[1]-ylim[0])/(yd*pb[1]), (zlim[1]-zlim[0])/(zd*pb[2]));
			c_eye.add(c_center);
			autoSet(CameraPosition, c_eye.getData().clone());
		}
		else
			c_eye = new Vector3D(CameraPosition.getArray());

		if (CameraUpVectorMode.is("auto"))
		{
			double az = View.getArray()[0];
			double el = View.getArray()[1];

			if (el == 90 || el == -90)
			{
				c_upv = new Vector3D(new double[] {
					-Math.sin(az*Math.PI/180.0),
					Math.cos(az*Math.PI/180.0),
					0});
				c_upv.scale((xlim[1]-xlim[0])/(/*xd**/pb[0]), (ylim[1]-ylim[0])/(/*yd**/pb[1]), 0);
			}
			else
				c_upv = new Vector3D(new double[] {0,0,1}, false);
			autoSet(CameraUpVector, c_upv.getData().clone());
		}
		else
			c_upv = new Vector3D(CameraUpVector.getArray());

		x_view.eye();
		x_projection.eye();
		x_viewport.eye();
		x_normrender.eye();
		x_render.eye();

		Matrix3D x_pre = new Matrix3D();

		x_pre.scale(pb[0], pb[1], pb[2]);
		x_pre.translate(-0.5, -0.5, -0.5);
		x_pre.scale(xd/(xlim[1]-xlim[0]), yd/(ylim[1]-ylim[0]), zd/(zlim[1]-zlim[0]));
		x_pre.translate(-xo, -yo, -zo);

		c_eye.transform(x_pre);
		c_center.transform(x_pre);
		c_upv.scale(
			pb[0]/**xd*//(xlim[1]-xlim[0]),
			pb[1]/**yd*//(ylim[1]-ylim[0]),
			pb[2]/**zd*//(zlim[1]-zlim[0]));
		c_center.sub(c_eye);

		Vector3D F = c_center;
		Vector3D f = Vector3D.normalize(F);
		Vector3D UP = Vector3D.normalize(c_upv);

		if (Math.abs(Vector3D.dot(f, UP)) > 1e-15)
		{
			double fa = 1/Math.sqrt(1-f.get(2)*f.get(2));
			UP.scale(fa, fa, fa);
		}

		Vector3D s = Vector3D.cross(f, UP);
		Vector3D u = Vector3D.cross(s, f);

		x_view.scale(1, 1, -1);
		x_view.mult(
			new double[] {
				s.get(0), u.get(0), -f.get(0), 0,
				s.get(1), u.get(1), -f.get(1), 0,
				s.get(2), u.get(2), -f.get(2), 0,
				0, 0, 0, 1});
		x_view.translate(-c_eye.get(0), -c_eye.get(1), -c_eye.get(2));
		x_view.scale(pb[0], pb[1], pb[2]);
		x_view.translate(-0.5, -0.5, -0.5);

		double[] unitCube = {
			0,0,0,1,
			1,0,0,1,
			0,1,0,1,
			0,0,1,1,
			1,1,0,1,
			1,0,1,1,
			0,1,1,1,
			1,1,1,1};
		double[] xUnitCube = new double[32];
		double xm = Double.POSITIVE_INFINITY, xM = Double.NEGATIVE_INFINITY;
		double ym = Double.POSITIVE_INFINITY, yM = Double.NEGATIVE_INFINITY;
		x_view.transform(unitCube, xUnitCube, 8, 0, 0);
		for (int i=0; i<8; i++)
		{
			if (xUnitCube[i*4] < xm) xm = xUnitCube[i*4];
			else if (xUnitCube[i*4] > xM) xM = xUnitCube[i*4];
			if (xUnitCube[i*4+1] < ym) ym = xUnitCube[i*4+1];
			else if (xUnitCube[i*4+1] > yM) yM = xUnitCube[i*4+1];
		}
		xM -= xm;
		yM -= ym;

		Rectangle bb = getBoundingBox();

		if (CameraViewAngleMode.is("auto"))
		{
			double af;
			if (dowarp)
				af = 1/Math.max(xM, yM);
			else
			{
				if (((double)bb.width)/bb.height > xM/yM)
					af = 1/yM;
				else
					af = 1/xM;
			}
			double ang = 2*(180.0/Math.PI)*Math.atan(1/(2*af*F.norm()));
			autoSet(CameraViewAngle, new Double(ang));
		}

		double pf = 1/(2*Math.tan((CameraViewAngle.doubleValue()/2)*Math.PI/180.0)*F.norm());
		x_projection.scale(pf, pf, 1);

		if (dowarp)
		{
			xM *= pf;
			yM *= pf;
			x_viewport.translate(bb.x+bb.width/2, canvas.getHeight()-(bb.y+bb.height/2)+1, 0);
			x_viewport.scale(bb.width/xM, -bb.height/yM, 1);
		}
		else
		{
			double pix = 1;
			if (autocam)
			{
				if (((double)bb.width)/bb.height > xM/yM)
					pix = bb.height;
				else
					pix = bb.width;
			}
			else
				pix = Math.min(bb.width, bb.height);
			x_viewport.translate(bb.x+bb.width/2, canvas.getHeight()-(bb.y+bb.height/2)+1, 0);
			x_viewport.scale(pix, -pix, 1);
		}

		x_normrender.mult(x_viewport);
		x_normrender.mult(x_projection);
		x_normrender.mult(x_view);

		x_normrender.transform(unitCube, xUnitCube, 8, 0, 0);
		x_zmin = Double.POSITIVE_INFINITY;
		x_zmax = Double.NEGATIVE_INFINITY;
		for (int i=0; i<8; i++)
		{
			if (xUnitCube[i*4+2] < x_zmin) x_zmin = xUnitCube[i*4+2];
			else if (xUnitCube[i*4+2] > x_zmax) x_zmax = xUnitCube[i*4+2];
		}

		//System.out.println(x_zmin);
		//System.out.println(x_zmax);

		x_render.mult(x_normrender);
		x_render.scale(xd/(xlim[1]-xlim[0]), yd/(ylim[1]-ylim[0]), zd/(zlim[1]-zlim[0]));
		x_render.translate(-xo, -yo, -zo);
		x_renderInv = x_render.inv();

		x_mat1.eye();
		x_mat1.mult(x_view);
		x_mat1.scale(xd/(xlim[1]-xlim[0]), yd/(ylim[1]-ylim[0]), zd/(zlim[1]-zlim[0]));
		x_mat1.translate(-xo, -yo, -zo);
		x_mat2.eye();
		x_mat2.mult(x_viewport);
		x_mat2.mult(x_projection);
		
		x_NormRenderTransform.reset(x_normrender.getData());
		x_RenderTransform.reset(x_render.getData());
	}
}
