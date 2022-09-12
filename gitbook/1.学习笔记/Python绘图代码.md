# Python绘图代码

#### y = 1/x + x

```
# !coding:utf-8
import matplotlib.pyplot as plt
import numpy as np

plt.rcParams['font.size'] = 14

fig = plt.figure(figsize=(8, 8))
ax = fig.add_subplot(111)

plt.plot([-10, 10], [0, 0], 'gray', ':')
plt.plot([0, 0], [-10, 10], 'gray', ':')

x1 = np.arange(-10, 0, 0.1)
y1 = 1 / x1 + x1
plt.plot(x1, y1)

x2 = np.arange(0.1, 10, 0.1)
y2 = 1 / x2 + x2
plt.plot(x2, y2)

plt.xlabel('x')
plt.ylabel('y')
plt.xticks(range(-10, 11, 2))
plt.yticks(range(-10, 11, 2))
ax.set_yticklabels(range(-10, 11, 2))
plt.axis([-10, 10, -10, 10])
plt.title(u'$y=\\frac{1}{x}$')
plt.grid(True)

plt.savefig(u"反比例函数.png")
plt.show()
```

#### sin和cos

```
import numpy as np
import matplotlib.pyplot as plt
 
#生成数据
x=np.arange(0,6,0.1)#以0.1为单位，生成0到6的数据
y1=np.sin(x)
y2=np.cos(x)
 
#绘制图形
plt.rcParams['font.sans-serif']=['SimHei']#解决标题、坐标轴标签不能是中文的问题
plt.rcParams['axes.unicode_minus']=False#标题等默认是英文输出
plt.plot(x,y1,label='sinx')
plt.plot(x,y2,linestyle='--',label='cosx')#用虚线绘制
plt.xlabel('X')
plt.ylabel('Y')
plt.title('正弦余弦函数图像')
plt.legend()
plt.show()
```

