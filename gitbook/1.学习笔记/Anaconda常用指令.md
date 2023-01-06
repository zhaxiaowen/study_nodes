# Anaconda常用指令

#### 1.创建虚拟环境

`conda create -n learn python=3.6`

#### 2.切换环境

`activate learn`

`activate`

#### 3.安装/卸载包

```
conda install requests
pip install requests

conda uninstall requests
pip uninstall requests
```

#### 4.查看环境包信息

```
conda env list
conda list
```

#### 5.删除环境

```
conda remove -n learn --all 
```

#### 6.导出当前环境包

```
conda env export > environment.yaml
```

#### 7.用配置文件创建新的虚拟环境

```
conda env create -f environment.yaml 
```

#### 8.关闭虚拟环境
```
source deactivate
```

#### 9.激活虚拟环境
```
source ~/.bashrc
```
