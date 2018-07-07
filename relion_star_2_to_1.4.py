#!/usr/bin/env python
#

import sys
import os

arg=str(sys.argv[1])
file=os.path.splitext(arg)[0]
out=file+"_rln1.4.star"

from pyrelion import *
md = MetaData(arg)
md.removeLabels('rlnAutopickFigureOfMerit')
md.removeLabels('rlnCtfBfactor')
md.removeLabels('rlnCtfScalefactor')
md.removeLabels('rlnPhaseShift')
md.removeLabels('rlnCtfMaxResolution')
md.removeLabels('rlnCtfFigureOfMerit')
md.write(out)
