"""=============================================================================
Copyright (C) John-Philip Taylor
jpt13653903@gmail.com

This file is part of the FPGA Masters Course

This file is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>
============================================================================="""

from math import *

import numpy as np
import matplotlib.pyplot as plt
#-------------------------------------------------------------------------------

fs = 44100
N  = 30

x = np.ones(10000)
t = np.arange(len(x)) / fs

plt.plot(t/1e-3, x)
plt.xlabel('Time [ms]')
plt.grid()

z  = 1/sqrt(2)
for f0 in [10, 100, 1e3, 10e3]:
    w0 = 2 * pi * f0

    a =   fs**2 + 2*z*w0*fs + w0**2
    b = 2*fs**2 + 2*z*w0*fs
    c =   fs**2
    # print(f'{round(f0)}\t{w0**2/a}\t{b/a}\t{c/a}')

    A = round((2**N / a) * w0**2)
    B = round((2**N / a) * b)
    C = round((2**N / a) * c)

    print(f'{round(f0)}\t{A}\t{B}\t{C}')
    #---------------------------------------------------------------------------

    y = np.zeros(len(x))

    for n in range(2, len(y)):
        y[n] = (A*x[n] + B*y[n-1] - C*y[n-2]) / (2**N)
    #---------------------------------------------------------------------------

    plt.plot(t/1e-3, y)
#-------------------------------------------------------------------------------

plt.show()
#-------------------------------------------------------------------------------

