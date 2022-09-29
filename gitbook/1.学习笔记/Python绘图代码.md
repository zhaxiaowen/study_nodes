# Python绘图代码

#### 定义域有取不到的值,可以通过设置多个分段的定义域来实现

```
import matplotlib.pyplot as plt
import numpy as np

plt.rcParams["font.sans-serif"] = ["SimHei"]  # 设置字体
plt.rcParams["axes.unicode_minus"] = False  # 该语句解决图像中的“-”负号的乱码问题

fig, axes = plt.subplots(1, 1)
# x取值范围
x1 = np.setdiff1d(np.linspace(-10, 0, 256),[0])
x2 = np.setdiff1d(np.linspace(0, 10, 256),[0])
x3 = np.linspace(-10, 10, 256)
y1 = 1 / x1 + x1
y2 = 1 / x2 + x2
m1 = 2**x3

axes.plot(x1, y1, 'b',x2,y2,'b',x3,m1)
axes.legend(labels=(r'$1/x + x$',), loc='lower right')
# 设置x,y轴
axes.spines['bottom'].set_color('k')
axes.spines['left'].set_color('k')
axes.spines['right'].set_color('None')
axes.spines['top'].set_color('None')
axes.spines['bottom'].set_position(('data', 0))
axes.spines['left'].set_position(('data', 0))

# 开启网格
axes.grid(True)
axes.grid(color='k', ls='-', lw=0.25)

plt.xlim(-6, 6)
plt.ylim(-6, 6)
plt.show()
# ani.save("animation.gif", fps=25, writer="imagemagick")
```

#### y=1/x

```
import matplotlib.pyplot as plt
import numpy as np

plt.rcParams["font.sans-serif"] = ["SimHei"]  # 设置字体
plt.rcParams["axes.unicode_minus"] = False  # 该语句解决图像中的“-”负号的乱码问题

fig, axes = plt.subplots(1, 1)
# x取值范围
x = np.linspace(-10,10, 256)

y=1/x
y[:-1][np.diff(y) > 0] = np.nan
axes.plot(x,y,'b')
axes.legend(labels=('1/x',), loc='lower right')

# 设置x,y轴
axes.spines['bottom'].set_color('k')
axes.spines['left'].set_color('k')
axes.spines['right'].set_color('None')
axes.spines['top'].set_color('None')
axes.spines['bottom'].set_position(('data', 0))
axes.spines['left'].set_position(('data', 0))

# 开启网格
axes.grid(True)
axes.grid(color='k', ls='-', lw=0.25)

plt.xlim(-6,6)
plt.ylim(-6,6)

plt.show()
# ani.save("animation.gif", fps=25, writer="imagemagick")

```

#### y=1/x +x :通过insert nan

```
import matplotlib.pyplot as plt
import numpy as np

plt.rcParams["font.sans-serif"] = ["SimHei"]  # 设置字体
plt.rcParams["axes.unicode_minus"] = False  # 该语句解决图像中的“-”负号的乱码问题

fig, axes = plt.subplots(1, 1)
# x取值范围
x = np.linspace(-10, 10, 256)
y = 1 / x + x
# you could insert a 'nan' element at the index where the sign flips,
idx = np.argmax(np.diff(np.sign(y))) + 1
x = np.insert(x, idx, np.nan)
y = np.insert(y, idx, np.nan)
axes.plot(x, y, 'b')
axes.legend(labels=(r'1/x + x',), loc='lower right')

# 设置x,y轴
axes.spines['bottom'].set_color('k')
axes.spines['left'].set_color('k')
axes.spines['right'].set_color('None')
axes.spines['top'].set_color('None')
axes.spines['bottom'].set_position(('data', 0))
axes.spines['left'].set_position(('data', 0))

# 开启网格
axes.grid(True)
axes.grid(color='k', ls='-', lw=0.25)

plt.xlim(-6, 6)
plt.ylim(-6, 6)
plt.show()
# ani.save("animation.gif", fps=25, writer="imagemagick")
```

#### sin和cos

```
import matplotlib.pyplot as plt
import numpy as np

plt.rcParams["font.sans-serif"] = ["SimHei"]  # 设置字体
plt.rcParams["axes.unicode_minus"] = False  # 该语句解决图像中的“-”负号的乱码问题

fig, axes = plt.subplots(1, 1)
# x取值范围
x = np.linspace(-np.pi, np.pi, 256)
y1 = np.cos(x)
y2 = np.sin(x)

axes.plot(x, y1, '--', x, y2)
axes.legend(labels=('cos', 'sin'), loc='lower right')

# 设置x,y轴
axes.spines['bottom'].set_color('k')
axes.spines['left'].set_color('k')
axes.spines['right'].set_color('None')
axes.spines['top'].set_color('None')
axes.spines['bottom'].set_position(('data', 0))
axes.spines['left'].set_position(('data', 0))

# 开启网格
axes.grid(True)
axes.grid(color='k', ls='-', lw=0.25)

plt.xlim(x.min() * 1.1, x.max() * 1.1)
# plt.xticks([-2*np.pi,-np.pi*3/2,-np.pi, -np.pi / 2, 0, np.pi / 2, np.pi,np.pi*3/2,2*np.pi],
#            [r'$-\pi2*$',r'$-\pi*3/2$',r'$-\pi$', r'$-\pi/2$', r'$0$', r'$\pi/2$', r'$\pi$',r'$\pi*3/2$',r'$\pi*2$'])
plt.xticks([-np.pi, -np.pi / 2, 0, np.pi / 2, np.pi],
           [r'$-\pi$', r'$-\pi/2$', r'$0$', r'$\pi/2$', r'$\pi$'])
plt.ylim(y1.min() * 1.1, y1.max() * 1.1)
plt.yticks([-1, 1], [r'$-1$', r'$1$'])

plt.show()
# ani.save("animation.gif", fps=25, writer="imagemagick")

```

#### cos,sin,tan

```
import matplotlib.pyplot as plt
import numpy as np

plt.rcParams["font.sans-serif"] = ["SimHei"]  # 设置字体
plt.rcParams["axes.unicode_minus"] = False  # 该语句解决图像中的“-”负号的乱码问题

fig, axes = plt.subplots(1, 1)
# x取值范围
x = np.linspace(-np.pi, np.pi, 256)
y1 = np.cos(x)
y2 = np.sin(x)
y3=np.tan(x)
y3[:-1][np.diff(y3) < 0] = np.nan
axes.plot(x,y1,x,y2,x,y3)
axes.legend(labels=('cos', 'sin','tan'), loc='lower right')

# 设置x,y轴
axes.spines['bottom'].set_color('k')
axes.spines['left'].set_color('k')
axes.spines['right'].set_color('None')
axes.spines['top'].set_color('None')
axes.spines['bottom'].set_position(('data', 0))
axes.spines['left'].set_position(('data', 0))

# 开启网格
axes.grid(True)
axes.grid(color='k', ls='-', lw=0.25)

plt.xlim(-6,6)
# plt.xticks([-2*np.pi,-np.pi*3/2,-np.pi, -np.pi / 2, 0, np.pi / 2, np.pi,np.pi*3/2,2*np.pi],
#            [r'$-\pi2*$',r'$-\pi*3/2$',r'$-\pi$', r'$-\pi/2$', r'$0$', r'$\pi/2$', r'$\pi$',r'$\pi*3/2$',r'$\pi*2$'])
plt.xticks([-np.pi, -np.pi / 2, 0, np.pi / 2, np.pi],
           [r'$-\pi$', r'$-\pi/2$', r'$0$', r'$\pi/2$', r'$\pi$'])
plt.ylim(-3,3)
plt.yticks([-1, 1], [r'$-1$', r'$1$'])

plt.show()
# ani.save("animation.gif", fps=25, writer="imagemagick")

```

