package org.octave;

public class Octave
{
  static
  {
    System.load (System.getProperty ("octave.java.path") + java.io.File.separator + "__java__.oct");
  }

  private static Object notifyObject = null;
  private static Object[] args = null;
  private static java.util.LinkedList invokeList = new java.util.LinkedList();

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

      synchronized(invokeList)
        {
          while (invokeList.size() > 0)
            {
              Object obj = invokeList.remove();
	      if (obj instanceof Runnable)
                ((Runnable)obj).run();
              if (obj instanceof OctaveReference)
                {
                  Object[] objArgs = (Object[])invokeList.remove();
                  doInvoke(((OctaveReference)obj).getID(), objArgs);
                }
              else if (obj instanceof String)
                doEvalString((String)obj);
            }
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

  public static void invokeLater(Runnable r)
    {
      if (needThreadedInvokation())
        synchronized(invokeList)
          {
            invokeList.add(r);
          }
      else
        r.run();
    }

  public static void invokeLater(OctaveReference ref, Object[] invokeArgs)
    {
      if (needThreadedInvokation())
        synchronized(invokeList)
          {
            invokeList.add(ref);
            invokeList.add(invokeArgs);
          }
      else
        doInvoke(ref.getID(), invokeArgs);
    }

  public static void evalLater(String cmd)
    {
      if (needThreadedInvokation())
        synchronized(invokeList)
          {
            invokeList.add(cmd);
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
