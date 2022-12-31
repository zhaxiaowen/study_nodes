# Python学习

### 1.画图

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

#### x,y坐标轴

```
import numpy as np
import matplotlib.pyplot as plt

plt.rcParams["font.sans-serif"] = ["SimHei"]  # 设置字体
plt.rcParams["axes.unicode_minus"] = False  # 该语句解决图像中的“-”负号的乱码问题

n = np.linspace(-5, 4, 30,endpoint=False) #在-5到4之间绘制30个点,不想包括最后一个点,通过设置endpoint=False
m1 = 3 * n + 2
m2 = n ** 2
plt.plot(n, m1, 'r-.', n, m2, 'b')
plt.xlim((-2, 4))
plt.ylim((-5, 15))
x_ticks = np.linspace(-5, 4, 10)
plt.xticks(x_ticks)
plt.yticks([-2.5, 7.5], ['hate', 'love'])
plt.xlabel('XXX')
plt.ylabel('YYY')
ax = plt.gca()
ax.xaxis.set_ticks_position('bottom')
ax.spines['bottom'].set_position(('data', 0))

ax.yaxis.set_ticks_position('left')
ax.spines['left'].set_position(('data', 0))

ax.spines['top'].set_color('none')
ax.spines['right'].set_color('none')

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

#### [用matplotlib的Animation画动图](https://zhuanlan.zhihu.com/p/442932579)



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

### 2.操作excel

#### xlwt写excel

```
import xlwt
wb =xlwt.Workbook()
sh1=wb.add_sheet('成绩')
sh2=wb.add_sheet('汇总')

# 第一个参数是行,第二个是列,第三个是值
sh1.write(0,0,'姓名')
sh1.write(0,1,'专业')
sh1.write(0,2,'科目')
sh1.write(0,3,'成绩')
sh1.write(1, 0, '张三')
sh1.write(1, 1, '信息与通信工程')
sh1.write(1, 2, '数值分析')
sh1.write(1, 3, 88)
# 保存
wb.save('test.xls')
```

#### xlrd读excel

```
import xlrd
wb = xlrd.open_workbook("test.xls")

print( "sheet 数量:", wb.nsheets)			# 获取并打印 sheet 数量
print( "sheet 名称:", wb.sheet_names())	# 获取并打印 sheet 名称
sh1 = wb.sheet_by_index(0)    			 # 根据 sheet 索引获取内容
sh = wb.sheet_by_name('成绩')  		    #根据 sheet 名称获取内容
print(sh1.name, sh1.nrows, sh1.ncols)    # 获取并打印该 sheet 行数和列数

rows = sh1.row_values(0) 				 # 获取第一行内容
cols = sh1.col_values(1) 				 # 获取第二列内容

print( "第二行第一列的值类型为:", sh1.cell(1, 0).ctype)   # 获取单元格内容的数据类型

# 遍历所有表单内容
for sh in wb.sheets():
    for r in range(sh.nrows):
        # 输出指定行
        print( sh.row(r))
```

#### xlrd修改excel

```
# 导入相应模块
import xlrd
from xlutils.copy import copy

readbook = xlrd.open_workbook("test.xls")  		# 打开 excel 文件
wb = copy(readbook)								# 复制一份
sh1 = wb.get_sheet(0)							# 选取第一个表单
# 在第五行新增写入数据
sh1.write(4, 0, '王欢')				
sh1.write(4, 1, '通信工程')
sh1.write(4, 2, '机器学习')
sh1.write(4, 3, 89)
sh1 = wb.get_sheet(1)							# 选取第二个表单
sh1.write(1, 0, 362)							# 替换总成绩数据
```

#### 修改表格格式

```
import xlwt												# 导入 xlwt 库

# 设置写出格式字体红色加粗
styleBR = xlwt.easyxf('font: name Times New Roman, color-index red, bold on')
styleNum = xlwt.easyxf(num_format_str='#,##0.00')		# 设置数字型格式为小数点后保留两位
styleDate = xlwt.easyxf(num_format_str='YYYY-MM-DD')	# 设置日期型格式显示为YYYY-MM-DD

wb = xlwt.Workbook()									# 创建 xls 文件对象

sh1 = wb.add_sheet('成绩')							   # 新增两个表单页
sh2 = wb.add_sheet('汇总')

# 然后按照位置来添加数据,第一个参数是行，第二个参数是列
sh1.write(0, 0, '姓名', styleBR)   # 设置表头字体为红色加粗
sh1.write(0, 1, '日期', styleBR)   # 设置表头字体为红色加粗
sh1.write(0, 2, '成绩', styleBR)   # 设置表头字体为红色加粗

# 插入数据
sh1.write(1, 0, '张三',)
sh1.write(1, 1, '2020-07-01', styleDate)
sh1.write(1, 2, 90, styleNum)
sh1.write(2, 0, '李四')
sh1.write(2, 1, '2020-08-02')
sh1.write(2, 2, 95, styleNum)

# 设置单元格内容居中的格式
alignment = xlwt.Alignment()
alignment.horz = xlwt.Alignment.HORZ_CENTER
style = xlwt.XFStyle()
style.alignment = alignment

sh1.write_merge(3, 3, 0, 1, '总分', style)			# 合并A4,B4单元格，并将内容设置为居中
sh1.write(3, 2, xlwt.Formula("C2+C3"))				 # 通过公式，计算C2+C3单元格的和

# 对 sheet2 写入数据
sh2.write(0, 0, '总分', styleBR)
sh2.write(1, 0, 185)

# 最后保存文件即可
wb.save('test.xls')
```

#### openpyxl操作excel

https://blog.csdn.net/weixin_44288604/article/details/120731317

https://cloud.tencent.com/developer/article/1694251



### 3.pandas写excel

[Pandas写入Excel函数——to_excel 技术总结](https://blog.csdn.net/HJ_xing/article/details/112390297#:~:text=Pandas%E5%86%99%E5%85%A5Excel%E5%87%BD%E6%95%B0%E2%80%94%E2%80%94to_excel%20%E6%8A%80%E6%9C%AF%E6%80%BB%E7%BB%93%201%20%E4%B8%80%E3%80%81%E5%8D%95%E4%B8%AAsheet%E5%86%99%E5%85%A5%EF%BC%9A%20import%20pandas%20as%20pd,3%20%E5%9B%9B%E3%80%81%E4%BF%AE%E6%94%B9sheet%E4%B8%AD%E7%9A%84%E5%86%85%E5%AE%B9%EF%BC%8C%E4%B8%8D%E8%A6%86%E7%9B%96%E5%B7%B2%E5%AD%98%E5%9C%A8%E7%9A%84sheet%20%E6%B2%BF%E7%94%A8%E4%B8%8A%E9%9D%A2%E7%9A%84%E4%BB%A3%E7%A0%81%EF%BC%8C%E4%BF%AE%E6%94%B9Sheet4%E3%80%81Sheet5%E3%80%82%20import%20pandas%20as%20pd%20)

```
stock=pd.DataFrame(l2)
print(stock.shape)												 # 获取数组有多少行,多少列
stock_code=['股票' + str(i) for i in range(stock.shape[0])]		# 构造行索引序列				 
date = pd.date_range('2017-01-01', periods=stock.shape[1], freq='B')  # 构造列索引数据
data = pd.DataFrame(stock, index=stock_index, columns=date)		# 添加行索引 ,添加列索引
data.shape														# 获取数组有多少行,多少列
data.index														# 获取行索引信息
data.columns													# 获取列索引信息
data.value														# 获取数组数据
data.T															# 行和列置换
data.index = stock_code											# 修改行索引值
data.reset_index(drop=False) 									# 重置索引,drop:默认为False，不删除原来索引，如果为True,删除原来的索引值
data.set_index(keys, drop=True)									# 以某列值设为新的索引
																# keys : 列索引名成或者列索引名称的列表;['year', 'month']
																# drop : boolean, default True.当做新的索引，删除原来的列
==================================================================================================================
将要写入的数据准备好,l2=[[1,2,3],[4,5,6]],类似这种格式
df=pd.DataFrame(l2,columns=['服务名','port','ip'])
df = df.append(pd.DataFrame(list, columns=['服务名','port','ip']),ignore_index=True)
==================================================================================================================
# excel_writer ：'excel_output.xls'输出路径
# sheet_name='2':设置表明
# na_rep ： 缺失值填充 ，可以设置为字符串
# columns ：选择输出的的列存入
# 默认为True，显示index，当index=False 则不显示行索引
# header :指定作为列名的行，默认0，即取第一行，数据为列名行以下的数据；若数据不含列名，则设定 header = None:不显示列索引
# index_label设置索引列的列名
# 以下写法:如果df.xlsx不存在则创建,存在则覆盖
df.to_excel('df.xlsx',sheet_name='2',index=False,header=None)

# 不覆盖写法
with pd.ExcelWriter('df.xlsx',mode='a') as writer:
    df1.to_excel(writer, sheet_name='Sheet1', index=False)
    df2.to_excel(writer, sheet_name='Sheet2', index=False)
==================================================================================================================
```

