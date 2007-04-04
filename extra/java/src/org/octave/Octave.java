package org.octave;

public class Octave
{
  static
  {
    System.load (System.getProperty ("octave.java.path") + java.io.File.separator + "__java__.oct");
  }

  private static Object notifyObject = null;
  private static Object[] args = null;

  public native static boolean call (String name, Object[] argin, Object[] argout);
  public native static void doInvoke(int ID, Object[] args);
  public native static void doEvalString(String cmd);
  public native static boolean needThreadedInvokation();

  public static void checkPendingAction()
    {
      if (notifyObject != null)
        {
          synchronized(notifyObject)
            {
              if (notifyObject instanceof OctaveReference)
                doInvoke(((OctaveReference)notifyObject).getID(), args);
              else if (notifyObject instanceof String)
                doEvalString((String)notifyObject);
              notifyObject.notifyAll();
            }
          notifyObject = null;
          args = null;
        }
    }

  public static void invokeAndWait(OctaveReference ref, Object[] invokeArgs)
    {
      if (needThreadedInvokation())
        {
          synchronized(ref)
            {
              notifyObject = ref;
              args = invokeArgs;
              try { ref.wait(); }
              catch (InterruptedException e) {}
            }
        }
      else
        doInvoke(ref.getID(), invokeArgs);
    }

  public static void evalAndWait(String cmd)
    {
      if (needThreadedInvokation())
        {
          synchronized(cmd)
            {
              notifyObject = cmd;
              args = null;
              try { cmd.wait(); }
              catch (InterruptedException e) {}
            }
        }
      else
        doEvalString(cmd);
    }

  public static Object do_test (String name, Object arg0) throws Exception
    {
      Object[] argin = new Object[] { arg0 };
	  Object[] argout = new Object[1];
      if (call (name, argin, argout))
        return argout[0];
      throw new Exception ("octave call failed");
    }
}
