package org.octave;

import java.awt.event.*;

public class OctListener
  implements ActionListener
{
  static
    {
      System.load (System.getProperty ("octave.java.path") + java.io.File.separator + "__java__.oct");
    }

  private static int _counter = 0;
  private int ID;

  public OctListener ()
    {
      ID = _counter++;
    }

  private native static void doInvokeListener (int ID, String name, Object event);
  private native static void doRemoveListener (int ID);

  public int getID ()
	{
		return this.ID;
	}

  public void actionPerformed (ActionEvent e)
    {
      doInvokeListener (this.ID, "actionPerformed", e);
    }
}
