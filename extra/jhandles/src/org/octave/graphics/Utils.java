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

public class Utils
{
	public static void crossProduct(double ax, double ay, double az, double bx, double by, double bz, double[] res)
	{
		crossProduct(ax, ay, az, bx, by, bz, res, 0, 1);
	}

	public static void crossProduct(double ax, double ay, double az, double bx, double by, double bz,
			double[] res, int offset, int ldr)
	{
		res[offset+0*ldr] += (ay*bz-az*by);
		res[offset+1*ldr] += (az*bx-ax*bz);
		res[offset+2*ldr] += (ax*by-ay*bx);
	}

	public static void printCpuTime()
	{
		System.out.println(java.lang.management.ManagementFactory.getThreadMXBean().getCurrentThreadCpuTime());
	}

	public static double[][] getAlphaData(ArrayProperty adata, RadioProperty mapping, AxesObject axes)
	{
		if (adata.getNDims() != 2)
			return null;

		if (mapping.is("none"))
		{
			if (adata.isType("double"))
				return adata.asDoubleMatrix();
		}
		else if (mapping.is("direct"))
		{
			double[] amap = axes.getFigure().Alphamap.getArray();
			if (adata.isType("double"))
			{
				double[][] aa = adata.asDoubleMatrix();
				double[][] res = new double[aa.length][aa[0].length];

				for (int i=0; i<res.length; i++)
					for (int j=0; j<res[i].length; j++)
						res[i][j] = amap[(int)Math.min(Math.max(1, aa[i][j]), amap.length)-1];
				return res;
			}
			else if (adata.isType("integer"))
			{
				int[][] aa = adata.asIntMatrix();
				double[][] res = new double[aa.length][aa[0].length];
				
				for (int i=0; i<res.length; i++)
					for (int j=0; j<res[i].length; j++)
						res[i][j] = amap[Math.min(Math.max(0, aa[i][j]), amap.length-1)];
				return res;
			}
		}
		else if (mapping.is("scaled"))
		{
			double[] amap = axes.getFigure().Alphamap.getArray();
			double[] alim = axes.ALim.getArray();

			if (adata.isType("double"))
			{
				double[][] aa = adata.asDoubleMatrix();
				double[][] res = new double[aa.length][aa[0].length];

				for (int i=0; i<aa.length; i++)
					for (int j=0; j<aa[0].length; j++)
					{
						double s = (aa[i][j]-alim[0])/(alim[1]-alim[0]);
						res[i][j] = amap[(int)Math.round((amap.length-1)*s)];
					}
				return res;
			}
		}

		return null;
	}
}
