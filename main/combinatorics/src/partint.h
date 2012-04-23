// Copyright (C) 2006 Torsten Finke <fi@igh-essen.com>
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation; either version 3 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
// FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
// details.
//
// You should have received a copy of the GNU General Public License along with
// this program; if not, see <http://www.gnu.org/licenses/>.

class int_partition
// Integer partitions
// Reference: 
//    Joerg Arndt: Algorithms for programmers
//    (http://www.jjj.de), 2006.
{
private:
    unsigned long *c_;  // partition:  c[1]* 1 + c[2]* 2 + ... + c[n]* n == n
    unsigned long *s_;  // cumulative sums:  s[j+1] = c[1]* 1 + c[2]* 2 + ... + c[j]* j
    unsigned long n_;   // partitions of n

public:
    int_partition(unsigned long n)
    {
        n_ = n;
        c_ = new unsigned long[n+1];
        s_ = new unsigned long[n+1];
        s_[0] = 0;  // unused
        c_[0] = 0;  // unused
        first();
    }

    ~int_partition()
    {
        delete [] c_;
        delete [] s_;
    }

    void first()
    {
        c_[1] = n_;
        for (unsigned long i=2; i<=n_; i++)  { c_[i] = 0; }
        s_[1] = 0;
        for (unsigned long i=2; i<=n_; i++)  { s_[i] = n_; }
    }

    const unsigned long *data() const  { return c_; }  // one-based!

    bool next()
    {
        // This algorithm was given by Torsten Finke
        if ( c_[n_]!=0 )  return false;  // last == 1* n (c[n]==1)

        // Find first coefficient c[i], i>=2 that can be increased:
        unsigned long i = 2;
        while ( s_[i]<i )  ++i;

        ++c_[i];
        s_[i] -= i;
        unsigned long z = s_[i];
        // Now set c[1], c[2], ..., c[i-1] to the first partition
        // of z into i-1 parts, i.e. set to  z, 0, 0, ..., 0:
        while ( --i > 1 )
        {
            s_[i] = z;
            c_[i] = 0;
        }
        c_[1] = z;  // z* 1 == z
        // s_[1] unused

        return true;
    }
};
