# Python学习

#### 在同一画布上绘制多个子图

* plt.subplot(nrows, ncols, index)
* fig , ax = plt.subplots(nrows, ncols)
* plt.subplot2grid(shape, location, rowspan, colspan)

```
from matplotlib import pyplot as plt
import numpy as np
import math
x = np.arange(0, math.pi*2, 0.05)
y = np.sin(x)
fig = plt.figure()
ax = fig.add_axes([0.1,0.1,0.8,0.8]) # 代表着从画布 10% 的位置开始绘制, 宽高是画布的 80%
ax.plot(x,y)
ax.legend(labels = ('tv',), loc = 'lower right')
ax.set_title("sine wave")
ax.set_xlabel('angle')
ax.set_ylabel('sine')
plt.show()
```



```
import numpy as np
import matplotlib.pyplot as plt
plt.rcParams["font.sans-serif"]=["SimHei"] #设置字体
plt.rcParams["axes.unicode_minus"]=False #该语句解决图像中的“-”负号的乱码问题

# figsize:指定画布的大小,(宽度,高度)
# dpi:指定绘图对象的分辨率
# facecolor:背景颜色
fig,axes=plt.subplots(1,1,figsize=(12,4),dpi=80,facecolor='blue') #创建一个1行1列的图
x = np.arange(1,11)
axes.plot(x,x**2)

# 对绘制的图线做备注说明
axes.legend(labels = ('tv', 'Smartphone'), loc = 'lower right')

# 开启网格
axes.grid(True)
axes.grid(color='b',ls='-',lw=0.25)

# 设置title名
axes.set_title("title")
# 设置x轴标签
axes.set_xlabel('x轴')
axes.set_xticks([0,2,4,6])
axes.set_xticklabels(['zero','two','four','six'])
# 设置y轴标签
axes.set_ylabel('y轴')
axes.set_yticks([0,2,4,6])
axes.set_yticklabels(['zero','two','four','six'])

#设置x,y轴取值范围
axes.set_xlim(0,10)
axes.set_ylim(0,1000)

# 为左侧轴,底部轴添加颜色,隐藏侧轴和顶部轴
axes.spines['bottom'].set_color('blue')
axes.spines['left'].set_color('blue')
axes.spines['bottom'].set_linewidth(1)
axes.spines['right'].set_color(None)
axes.spines['top'].set_color(None)
```





#### legend()

| 位置     | 字符串表示   | 整数数字表示 |
| -------- | ------------ | ------------ |
| 自适应   | Best         | 0            |
| 右上方   | upper right  | 1            |
| 左上方   | upper left   | 2            |
| 左下     | lower left   | 3            |
| 右下     | lower right  | 4            |
| 右侧     | right        | 5            |
| 居中靠左 | center left  | 6            |
| 居中靠右 | center right | 7            |
| 底部居中 | lower center | 8            |
| 上部居中 | upper center | 9            |
| 中部     | center       | 10           |

#### axes.plot()

| 'b'  | 蓝色   |
| ---- | ------ |
| 'g'  | 绿色   |
| 'r'  | 红色   |
| 'c'  | 青色   |
| 'm'  | 品红色 |
| 'y'  | 黄色   |
| 'k'  | 黑色   |
| 'w'  | 白色   |

| 标记符号 | 描述       |
| -------- | ---------- |
| '.'      | 点标记     |
| 'o'      | 圆圈标记   |
| 'x'      | 'X'标记    |
| 'D'      | 钻石标记   |
| 'H'      | 六角标记   |
| 's'      | 正方形标记 |
| '+'      | 加号标记   |

| 字符 | 描述     |
| ---- | -------- |
| '-'  | 实线     |
| '--' | 虚线     |
| '-.' | 点划线   |
| ':'  | 虚线     |
| 'H'  | 六角标记 |

