/* Copyright (C) 2007 Michael Goffioul
**
** This program is free software; you can redistribute it and/or modify
** it under the terms of the GNU General Public License as published by
** the Free Software Foundation; either version 2 of the License, or
** (at your option) any later version.
**
** This program is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
** GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with this program; if not, write to the Free Software
** Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301
*/

package org.octave;

import java.io.File;

public class OctClassLoader extends java.net.URLClassLoader
{
  public OctClassLoader ()
    {
      super (new java.net.URL[0]);
    }

  public OctClassLoader (ClassLoader parent)
    {
      super (new java.net.URL[0], parent);
    }

  protected Class findClass (String name) throws ClassNotFoundException
    {
      //System.out.println ("Looking for class " + name);
      return super.findClass (name);
    }

  protected String findLibrary (String libname)
    {
      // Look dynamically into java.library.path, because Sun VM does
      // not do it (seems to cache initial java.library.path instead)

      String[] paths = System.getProperty ("java.library.path").split (File.pathSeparator);
      
      libname = System.mapLibraryName (libname);
      for (int i=0; i<paths.length; i++)
        {
          File f = new File (paths[i], libname);
          if (f.exists ())
            return f.getAbsolutePath();
        }

      return null;
    }

  public void addClassPath (String name) throws Exception
    {
      java.io.File f = new java.io.File (name);
      addURL (f.toURI ().toURL ());
    }

  public void removeClassPath (String name) throws Exception
    {
      throw new Exception ("not implemented yet");
    }
}
