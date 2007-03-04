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
  private static OctListener _current = null;

  private native static void doInvokeListener (int ID, String name, Object event);
  private native static void doRemoveListener (int ID);

  public static void checkPendingListener ()
    {
      if (_current != null)
        {
          synchronized (_current)
            {
              doInvokeListener (_current.ID, _current.name, _current.event);
              _current.notifyAll ();
            }
          _current = null;
        }
    }

  private int ID;
  private String name = "";
  private Object event = null;

  public OctListener ()
    {
      ID = _counter++;
    }

  public int getID ()
    {
      return this.ID;
    }

  private synchronized void invokeAndWait (String name, Object event)
    {
      this.name = name;
      this.event = event;
      this._current = this;
      try
        {
          System.out.println ("invokeAndWait waiting...");
          this.wait ();
          System.out.println ("invokeAndWait done");
        }
      catch (InterruptedException e) { }
    }

  public void actionPerformed (ActionEvent e)
    {
      invokeAndWait ("actionPerformed", e);
      //doInvokeListener (ID, "actionPerformed", e);
    }
}
