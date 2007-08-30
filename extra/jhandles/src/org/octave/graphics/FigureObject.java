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
import javax.swing.event.*;
import org.octave.Matrix;

public class FigureObject extends AxesContainer
	implements WindowListener, ComponentListener, ActionListener
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

	private int defaultMouseOp = OP_NONE;
	private String currentUnits;

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
	NotImplProperty             Renderer;
	CallbackProperty            ResizeFcn;
	NotImplProperty             Toolbar;
	RadioProperty               Units;

	/* toolbar */
	JToggleButton editBtn;
	JToggleButton zoomBtn;
	JToggleButton rotateBtn;

	// Constructor

	public FigureObject(int fignum)
	{
		super(RootObject.getInstance(), "figure", fignum);

		CurrentAxes = new HandleObjectListProperty(this, "CurrentAxes", 1);
		Name = new StringProperty(this, "Name", "");
		NumberTitle = new BooleanProperty(this, "NumberTitle", true);
		NextPlot = new RadioProperty(this, "NextPlot", new String[] {"new", "add", "replace", "replacechildren"}, "add");
		FigColor = new ColorProperty(this, "Color", Utils.getBackgroundColor());
		Colormap = new ArrayProperty(this, "Colormap", new String[] {"double"}, 2,
			new Matrix(RootObject.getInstance().defaultColorMap()));
		ResizeFcn = new CallbackProperty(this, "ResizeFcn", (String)null);
		CloseRequestFcn = new CallbackProperty(this, "CloseRequestFcn", "closereq");
		double[] amap = new double[64];
		for (int i=0; i<amap.length; i++)
			amap[i] = ((double)i)/(amap.length-1);
		Alphamap = new VectorProperty(this, "Alphamap", -1, amap);
		PaperOrientation = new RadioProperty(this, "PaperOrientation", new String[] {"portrait", "landscape"}, "portrait");
		IntegerHandle = new BooleanProperty(this, "IntegerHandle", true);
		Units = new RadioProperty(this, "Units", new String[] {"pixels", "normalized", "inches", "centimeters",
			"points", "characters"}, "pixels");
		currentUnits = Units.getValue();
		Dimension d = Utils.getScreenSize();
		Position = new VectorProperty(this, "Position", 4, new double[] {1, d.height-500, 600, 500});
		Renderer = new NotImplProperty(this, "Renderer", "OpenGL");
		Toolbar = new NotImplProperty(this, "Toolbar", "figure");

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
		JToolBar tb = new JToolBar();
		tb.setRollover(true);
		tb.setFloatable(false);
		editBtn = new JToggleButton(Utils.loadIcon("edit"));
		editBtn.setActionCommand("edit");
		editBtn.setEnabled(false);
		editBtn.setToolTipText("Edit plot");
		editBtn.addActionListener(this);
		zoomBtn = new JToggleButton(Utils.loadIcon("zoom-original"));
		zoomBtn.setActionCommand("zoom");
		zoomBtn.setToolTipText("Zoom");
		zoomBtn.addActionListener(this);
		rotateBtn = new JToggleButton(Utils.loadIcon("view-refresh"));
		rotateBtn.setActionCommand("rotate");
		rotateBtn.setToolTipText("3D roration");
		rotateBtn.addActionListener(this);
		tb.add(editBtn);
		tb.add(zoomBtn);
		tb.add(rotateBtn);
		tbPanel.add(tb);

		// setup axes panel
		axPanel = new Panel(new PositionLayout());
		frame.add(axPanel, BorderLayout.CENTER);

		// setup RenderCanvas
		axPanel.add(getCanvas().getComponent());

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

	public void activate()
	{
		frame.toFront();
	}

	public void print(String format, String filename) throws java.io.IOException
	{
		Color fcolor = FigColor.getColor();
		FigColor.reset(Color.white);
		try
		{
			if (format .equals("postscript"))
			{
				canvas.toPostScript(filename);
			}
			else
			{
				BufferedImage img = canvas.toImage();
				javax.imageio.ImageIO.write(img, format, new java.io.File(filename));
			}
		}
		finally
		{
			FigColor.reset(fcolor);
			canvas.redraw();
		}
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

	private int commandToOp(String cmd)
	{
		if (cmd.equals("edit")) return OP_NONE;
		else if (cmd.equals("zoom")) return OP_ZOOM;
		else if (cmd.equals("rotate")) return OP_ROTATE;
		else return OP_NONE;
	}

	public int getMouseOp()
	{
		return defaultMouseOp;
	}

	protected Color getBackgroundColor()
	{
		return FigColor.getColor();
	}

	protected Container getEmbeddingComponent()
	{
		return axPanel;
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
		cancelMouseOperation();
	}

	public void windowClosed(WindowEvent e){}

	public void windowIconified(WindowEvent e){}

	public void windowDeiconified(WindowEvent e){}

	public void windowOpened(WindowEvent e){}

	/* ComponentListener interface */

	public void componentHidden(ComponentEvent e) {}
	
	public void componentMoved(ComponentEvent e) {}

	public void componentResized(ComponentEvent e)
	{
		//System.out.println("resized");
		ResizeFcn.execute();
	}
	
	public void componentShown(ComponentEvent e) {}

	/* ChangeListener interface */

	public void actionPerformed(ActionEvent e)
	{
		//System.out.println("action");
		if (e.getSource() == editBtn || e.getSource() == zoomBtn || e.getSource() == rotateBtn)
		{
			if (e.getSource() != editBtn)
				editBtn.setSelected(false);
			if (e.getSource() != zoomBtn)
				zoomBtn.setSelected(false);
			if (e.getSource() != rotateBtn)
				rotateBtn.setSelected(false);
			if (((JToggleButton)e.getSource()).isSelected())
				defaultMouseOp = commandToOp(e.getActionCommand());
			else
				defaultMouseOp = OP_NONE;
		}
	}
}
