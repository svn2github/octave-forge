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
import java.awt.event.*;
import java.awt.image.*;
import java.nio.*;
import java.util.*;
import javax.swing.*;
import org.octave.Matrix;

public class FigureObject extends HandleObject
	implements WindowListener, RenderEventListener,
			   MouseListener, MouseMotionListener,
			   ComponentListener
{
	private class FigurePanel extends Panel
	{
		FigurePanel()
		{
			super();
		}

		public void paint(Graphics g)
		{
			super.paint(g);
		}

		public void update(Graphics g)
		{
			paint(g);
		}
	}

	private Frame frame;
	private Panel tbPanel;
	private Panel axPanel;
	private RenderCanvas canvas;

	private AxesObject axesToUpdate = null;
	private AxesObject mouseAxes = null;
	private int mouseOp = OP_NONE;
	private int defaultMouseOp = OP_ZOOM;
	private String currentUnits;

	public static final int OP_NONE = 0;
	public static final int OP_ZOOM = 1;
	public static final int OP_ROTATE = 2;

	/* properties */
	VectorProperty              Alphamap;
	CallbackProperty            CloseRequestFcn;
	ColorProperty               /* Color */ FigColor;
	ArrayProperty               Colormap;
	HandleObjectListProperty    CurrentAxes;
	BooleanProperty             IntegerHandle;
	StringProperty              Name;
	RadioProperty               NextPlot;
	BooleanProperty             NumberTitle;
	RadioProperty               PaperOrientation;
	VectorProperty              Position;
	CallbackProperty            ResizeFcn;
	RadioProperty               Units;

	// Constructor

	public FigureObject(int fignum)
	{
		super(RootObject.getInstance(), fignum, "figure");

		CurrentAxes = new HandleObjectListProperty(this, "CurrentAxes", 1);
		Name = new StringProperty(this, "Name", "");
		NumberTitle = new BooleanProperty(this, "NumberTitle", true);
		NextPlot = new RadioProperty(this, "NextPlot", new String[] {"new", "add", "replace", "replacechildren"}, "add");
		FigColor = new ColorProperty(this, "Color", Utils.getBackgroundColor());
		Colormap = new ArrayProperty(this, "Colormap",
			new Matrix(RootObject.getInstance().defaultColorMap()), new String[] {"double"}, 2);
		ResizeFcn = new CallbackProperty(this, "ResizeFcn", (String)null);
		CloseRequestFcn = new CallbackProperty(this, "CloseRequestFcn", "closereq");
		double[] amap = new double[64];
		for (int i=0; i<amap.length; i++)
			amap[i] = ((double)i)/(amap.length-1);
		Alphamap = new VectorProperty(this, "Alphamap", amap, -1);
		PaperOrientation = new RadioProperty(this, "PaperOrientation", new String[] {"portrait", "landscape"}, "portrait");
		IntegerHandle = new BooleanProperty(this, "IntegerHandle", true);
		Units = new RadioProperty(this, "Units", new String[] {"pixels", "normalized", "inches", "centimeters",
			"points", "characters"}, "pixels");
		currentUnits = Units.getValue();
		Dimension d = Utils.getScreenSize();
		Position = new VectorProperty(this, "Position", new double[] {1, d.height-500, 600, 500}, 4);

		listen(Name);
		listen(NumberTitle);
		listen(IntegerHandle);
		listen(Position);
		listen(Units);
	}

	// Methods
	
	private void createFigure()
	{
		// setup window frame
		frame = new Frame();
		frame.setBackground(FigColor.getColor());
		frame.addWindowListener(this);
		frame.addComponentListener(this);

		// setup toolbar panel
		tbPanel = new Panel(new GridLayout(1, 1));
		frame.add(tbPanel, BorderLayout.NORTH);

		// dummy toolbar
		/*
		JToolBar tb = new JToolBar();
		tb.setFloatable(false);
		tb.add(new JButton("Button 1"));
		tb.add(new JButton("Button 2"));
		tb.add(new JButton("Button 3"));
		tbPanel.add(tb);
		*/

		// setup axes panel
		axPanel = new Panel(new PositionLayout());
		frame.add(axPanel, BorderLayout.CENTER);

		// setup RenderCanvas
		canvas = new GLRenderCanvas();
		canvas.addRenderEventListener(this);
		canvas.addMouseListener(this);
		canvas.addMouseMotionListener(this);
		axPanel.add(canvas.getComponent());

		updateTitle();
		updateFramePosition();
		frame.setVisible(true);
	}
	
	private void updateHandle()
	{
		int handle = getHandle();
		if (IntegerHandle.isSet() && handle < 0)
			setHandle(RootObject.getInstance().getUnusedFigureNumber());
		else if (!IntegerHandle.isSet() && handle > 0)
			setHandle(newHandle());
		updateTitle();
	}
	
	public void validate()
	{
		createFigure();
		updateHandle();
		super.validate();
		activate();
	}
	
	private void updatePosition()
	{
		Dimension d = Utils.getScreenSize();
		double[] pos = new double[] {frame.getX()+1, d.height-frame.getY()-frame.getHeight()+1,
			frame.getWidth(), frame.getHeight()};
		autoSet(Position, Utils.convertPosition(pos, "pixels", Units.getValue(), null));
	}

	private void updateFramePosition()
	{
		double[] pos = Utils.convertPosition(Position.getVector(), Units.getValue(), "pixels", null);
		Dimension d = Utils.getScreenSize();
		pos[0]--;
		pos[1] = d.height-pos[1]-pos[3]+1;
		frame.setBounds((int)pos[0], (int)pos[1], (int)pos[2], (int)pos[3]);
	}

	private void updateTitle()
	{
		String title = (NumberTitle.isSet() ? "Figure " + getHandle() : ""), name = Name.toString();
		if (name.length() > 0)
		{
			if (title.length() > 0)
				title += ": " + name;
			else
				title = name;
		}
		frame.setTitle(title);
	}
	
	public void delete()
	{
		frame.setVisible(false);
		super.delete();
		//frame.dispose();
		//frame.setVisible(false);
		EventQueue.invokeLater(new Runnable() { public void run() { frame.dispose(); } });
	}

	public RenderCanvas getCanvas()
	{
		return canvas;
	}

	public AxesObject getAxesForPoint(Point pt)
	{
		return (CurrentAxes.size() > 0 ? (AxesObject)CurrentAxes.elementAt(0) : null);
	}

	public void activate()
	{
		frame.toFront();
	}

	public void redraw()
	{
		axesToUpdate = null;
		canvas.redraw();
	}

	public void redraw(AxesObject ax)
	{
		//axesToUpdate = ax;
		canvas.redraw();
		//axesToUpdate = null;
	}

	public void print(String format, String filename) throws java.io.IOException
	{
		Color fcolor = FigColor.getColor();
		FigColor.reset(Color.white);
		BufferedImage img = canvas.toImage();
		FigColor.reset(fcolor);
		javax.imageio.ImageIO.write(img, format, new java.io.File(filename));
		redraw();
	}

	private Buffer makeColormapTextureData()
	{
		double[][] cmap = Colormap.asDoubleMatrix();
		float[] buf = new float[cmap.length*4];

		for (int i=0; i<cmap.length; i++)
		{
			buf[4*i]   = (float)cmap[i][0];
			buf[4*i+1] = (float)cmap[i][1];
			buf[4*i+2] = (float)cmap[i][2];
			buf[4*i+3] = 1;
		}

		return FloatBuffer.wrap(buf);
	}
	
	public void propertyChanged(Property p) throws PropertyException
	{
		super.propertyChanged(p);

		if (p == Name || p == NumberTitle)
			updateTitle();
		else if (p == IntegerHandle)
			updateHandle();
		else if (p == Position && !isAutoMode())
		{
			updateFramePosition();
		}
		else if (p == Units)
		{
			updatePosition();
			currentUnits = Units.getValue();
		}
	}

	public Component getComponent()
	{
		return axPanel;
	}

	public Object get(Property p)
	{
		if (p == Position)
			updatePosition();
		return super.get(p);
	}

	// WindowListener interface
	
	public void windowClosing(WindowEvent e)
	{
		//this.delete();
		CloseRequestFcn.execute();
	}

	public void windowActivated(WindowEvent e)
	{
		RootObject.getInstance().CurrentFigure.addElement(this);
	}

	public void windowDeactivated(WindowEvent e)
	{
		if (mouseOp != OP_NONE && mouseAxes != null)
		{
			mouseAxes.cancelOperation(mouseOp);
			mouseAxes = null;
			mouseOp = OP_NONE;
		}
	}

	public void windowClosed(WindowEvent e){}

	public void windowIconified(WindowEvent e){}

	public void windowDeiconified(WindowEvent e){}

	public void windowOpened(WindowEvent e){}

	// RenderEventListener interface

	public void reshape(RenderCanvas c, int x, int y, int width, int height)
	{
		synchronized (Children)
		{
			Iterator it = Children.iterator();
			while (it.hasNext())
			{
				HandleObject hObj = (HandleObject)it.next();
				if (hObj instanceof AxesObject && hObj.isValid())
					((AxesObject)hObj).updateActivePosition();
			}
		}
	}

	public void display(RenderCanvas c)
	{
		Renderer r = c.getRenderer();

		Rectangle rect = (axesToUpdate != null ? axesToUpdate.getOuterBoundingBox() : null);
		if (rect != null)
		{
			/* TODO: do some clipping */
		}

		// clear background
		r.clear(FigColor.getColor());
		// iterate over axes objects
		synchronized (Children)
		{
			Iterator it = Children.iterator();
			while (it.hasNext())
			{
				HandleObject hObj = (HandleObject)it.next();
				if (hObj instanceof AxesObject)
				{
					AxesObject aObj = (AxesObject)hObj;
					if (aObj.isValid() && (rect == null || rect.intersects(aObj.getOuterBoundingBox())))
					{
						aObj.draw(r);
					}
				}
			}
		}
		/* TODO: disable potential clipping */
	}

	// MouseListener interface

	public void mouseClicked(MouseEvent e)
	{
		if (e.getButton() == MouseEvent.BUTTON2)
		{
			if (defaultMouseOp == OP_ZOOM)
				defaultMouseOp = OP_ROTATE;
			else
				defaultMouseOp = OP_ZOOM;
		}

		if (e.getButton() == MouseEvent.BUTTON3 && mouseOp == OP_NONE && defaultMouseOp == OP_ZOOM)
		{
			AxesObject ax = getAxesForPoint(e.getPoint());
			if (ax != null)
				ax.unZoom();
		}
	}
	
	public void mouseEntered(MouseEvent e) {}

	public void mouseExited(MouseEvent e) {}
	
	public void mousePressed(MouseEvent e)
	{
		if (mouseOp == OP_NONE)
		{
			// Only do something if no operation pending
			if (e.getButton() == MouseEvent.BUTTON1)
			{
				mouseAxes = getAxesForPoint(e.getPoint());
				if (mouseAxes != null)
				{
					mouseOp = defaultMouseOp;
					mouseAxes.startOperation(mouseOp, e);
				}
			}
		}
	}
	
	public void mouseReleased(MouseEvent e)
	{
		if (mouseOp != OP_NONE)
		{
			if (e.getButton() == MouseEvent.BUTTON1)
			{
				if (mouseAxes != null)
					mouseAxes.endOperation(mouseOp, e);
				mouseAxes = null;
				mouseOp = OP_NONE;
			}
		}
	}

	// MouseMotionListener interface
	
	public void mouseMoved(MouseEvent e) {}

	public void mouseDragged(MouseEvent e)
	{
		if (mouseAxes != null && mouseOp != OP_NONE)
			mouseAxes.operation(mouseOp, e);
	}

	/* ComponentListener interface */

	public void componentHidden(ComponentEvent e) {}
	
	public void componentMoved(ComponentEvent e) {}

	public void componentResized(ComponentEvent e)
	{
		//System.out.println("resized");
		ResizeFcn.execute();
	}
	
	public void componentShown(ComponentEvent e) {}
}
