# https://python-graph-gallery.com/371-surface-plot/

# Variable
#image="local_defocus_surface.png"
image="local_defocus_points.png"

# library
from mpl_toolkits.mplot3d import Axes3D
import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns
 
# Get the data
data = pd.read_csv('local_defocus.csv', sep=' ', header=None, names=['X', 'Y', 'Z'])

df=data
 
# Make the plot surface
#fig = plt.figure()
#ax = fig.gca(projection='3d')
#ax.plot_trisurf(df['Y'], df['X'], df['Z'], cmap=plt.cm.viridis, linewidth=0.2)
#plt.show()

# Plot alternate surface palette
#fig = plt.figure()
#ax = fig.gca(projection='3d')
#surf=ax.plot_trisurf(df['Y'], df['X'], df['Z'], cmap=plt.cm.jet, linewidth=0.01)
#plt.show()

# to Add a color bar which maps values to colors.
#fig.colorbar( surf, shrink=0.5, aspect=5)
#plt.show()

# Make the plot scatter
fig = plt.figure()
ax = fig.add_subplot(111, projection='3d')
ax.scatter(df['Y'], df['X'], df['Z'], c='skyblue', s=15)
#plt.show()

# Axes labels
ax.set_xlabel('Particle X coordinate')
ax.set_ylabel('Particle Y coordinate')
ax.set_zlabel('Defocus (Å)')
#plt.show()

# Rotate it
ax.view_init(35, -44)

#save plot
fig.savefig(str(image), dpi=300, transparent=True)

# Show the plot
plt.show()