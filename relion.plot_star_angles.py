#!/usr/bin/env python
# Copyright (C) 2018 Kyle Morris
# University of California, Berkeley
#
# Note that this program is dependent on Daniel Asarnow's pyem
# Star file parsing is based on angdist.py of the pyem repository
#
# Program for plotting angular distribution.
# See help text and README file for more information.
#
# Program for projection subtraction in electron microscopy.
# See help text and README file for more information.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
plt.style.use('seaborn-white')
from pyem.star import parse_star

#Extract the angles data
star = parse_star('run_data.star')
xfields = [f for f in star.columns if "Rot" in f]
xfield = xfields[0]
yfields = [f for f in star.columns if "Tilt" in f]
yfield = yfields[0]
angles = star[[xfield, yfield]]
angles.columns = ["rot", "tilt"]

#Plot
fig = plt.figure(figsize=(6,4))
ax = fig.add_subplot(111)
ax.plot(angles.tilt, angles.rot, linestyle='', marker='o', markersize=0.3)
plt.xlabel('Tilt (degrees)')
plt.ylabel('Rotation (degrees)')

#save plot
fig.savefig('run_data_angles.png', dpi=300)

# Finish
echo ""
echo "Done!"
echo "Script written by Kyle Morris"
echo ""
