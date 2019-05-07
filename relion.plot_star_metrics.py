#!/usr/bin/env python
#

#Import libraries required for plotting
import pandas as pd
import seaborn as sns
from matplotlib import pyplot as plt

#Read in .csv file
df = pd.read_csv('defocus.csv')
#Make astigmatism column absolute values
df['Astigmatism'] = df['Astigmatism'].abs()

#Get number of rows in data frame
xlim = len(df.index)

###Per data line plots

#Get max values of columns
s=df.max()
maxU = s['DefocusU']
maxV = s['DefocusV']
maxA = s['Astigmatism']
#Get min values of columns
s=df.min()
minU = s['DefocusU']
minV = s['DefocusV']
minA = s['Astigmatism']

#Plot setup
sns.set_style('ticks')
fig, axs = plt.subplots(nrows=3)
# the size of A4 paper
fig.set_size_inches(11.7, 15)
#Plot defocus
g = sns.regplot(x="Micrograph", y="DefocusU", data=df, fit_reg=False, ax=axs[0])
g.set(ylim=(minU, maxU))
g.set(xlim=(0, xlim))
#Plot astigmatism
g = sns.regplot(x="Micrograph", y="Astigmatism", data=df, fit_reg=False, ax=axs[1])
g.set(ylim=(minA, maxA))
g.set(xlim=(0, xlim))
#Plot phase
g = sns.regplot(x="Micrograph", y="PhaseShift", data=df, fit_reg=False, ax=axs[2])
g.set(ylim=(0, 180))
g.set(xlim=(0, xlim))
#Save plot
g.figure.savefig("relion_star_plot_all_data.png")

##Defocus
#Plot setup
sns.set_style('ticks')
fig, ax = plt.subplots()
# the size of A4 paper
fig.set_size_inches(11.7, 8.27)
#Plot
g = sns.regplot(x="Micrograph", y="DefocusU", data=df, fit_reg=False, ax=ax)
g.set(ylim=(minU, maxU))
g.set(xlim=(0, xlim))
#Save plot
g.figure.savefig("relion_star_plot_defocusU.png")

##Phase evolution
#Plot setup
sns.set_style('ticks')
fig, ax = plt.subplots()
# the size of A4 paper
fig.set_size_inches(11.7, 8.27)
#Plot
g = sns.regplot(x="Micrograph", y="PhaseShift", data=df, fit_reg=False, ax=ax)
g.set(ylim=(0, 180))
g.set(xlim=(0, xlim))
#Save plot
g.figure.savefig("relion_star_plot_phase.png")

##Astigmatism
#Plot setup
sns.set_style('ticks')
fig, ax = plt.subplots()
# the size of A4 paper
fig.set_size_inches(11.7, 8.27)
#Plot
g = sns.regplot(x="Micrograph", y="Astigmatism", data=df, fit_reg=False, ax=ax)
g.set(ylim=(minA, maxA))
g.set(xlim=(0, xlim))
#Save plot
g.figure.savefig("relion_star_plot_astigmatism.png")

###Distribution plots

#Get data for dist plots
DefocusUDist = df['DefocusU']
PhaseShiftDist = df['PhaseShift']
MaxCtfDist = df['CtfMaxResolution']
CtfMeritDist = df['CtfFigureOfMerit']

##Plot distplots all together
#Plot setup
sns.set_style('ticks')
fig, axs = plt.subplots(ncols=2, nrows=2)
# the size of A4 paper
fig.set_size_inches(11.7, 15)
#Plot defocus distribution
g = sns.distplot(DefocusUDist, kde=False, ax=axs[0,0], color='blue')
#Plot phase distribution
g = sns.distplot(PhaseShiftDist, kde=False, ax=axs[1,0], color='blue')
#Plot max res ctf
g = sns.distplot(MaxCtfDist, kde=False, ax=axs[0,1], color='blue')
#Plot ctfmerit
g = sns.distplot(CtfMeritDist, kde=False, ax=axs[1,1], color='blue')
#Save plot
g.figure.savefig("relion_star_plot_all_dist.png")

##Plot distribution single plots
#Defocus
#Plot setup
fig, ax = plt.subplots()
fig.set_size_inches(11.7, 8.27)
ax.set(ylabel='Frequency count')
g = sns.distplot(DefocusUDist, kde=False, ax=ax, color='blue')
ax2 = ax.twinx()
ax2.set(ylabel='Frequency percentage')
g = sns.distplot(DefocusUDist, kde=True, ax=ax2, color='black')
#Save plot
g.figure.savefig("relion_star_plot_DefocusU_dist.png")

#Phase shift
#Plot setup
fig, ax = plt.subplots()
fig.set_size_inches(11.7, 8.27)
ax.set(ylabel='Frequency count')
g = sns.distplot(PhaseShiftDist, kde=False, ax=ax, color='blue')
ax2 = ax.twinx()
ax2.set(ylabel='Frequency percentage')
g = sns.distplot(PhaseShiftDist, kde=True, ax=ax2, color='black')
#Save plot
g.figure.savefig("relion_star_plot_PhaseShift_dist.png")

#MaxCtfResolution
#Plot setup
fig, ax = plt.subplots()
fig.set_size_inches(11.7, 8.27)
ax.set(ylabel='Frequency count')
g = sns.distplot(MaxCtfDist, kde=False, ax=ax, color='blue')
ax2 = ax.twinx()
ax2.set(ylabel='Frequency percentage')
g = sns.distplot(MaxCtfDist, kde=True, ax=ax2, color='black')
#Save plot
g.figure.savefig("relion_star_plot_MaxCtfResolution_dist.png")

#MaxFigureOfMerit
#Plot setup
fig, ax = plt.subplots()
fig.set_size_inches(11.7, 8.27)
ax.set(ylabel='Frequency count')
g = sns.distplot(CtfMeritDist, kde=False, ax=ax, color='blue')
ax2 = ax.twinx()
ax2.set(ylabel='Frequency percentage')
g = sns.distplot(CtfMeritDist, kde=True, ax=ax2, color='black')
#Save plot
g.figure.savefig("relion_star_plot_CtfFOM_dist.png")
