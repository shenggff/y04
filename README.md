# y04 share repository
Welcome to share your code !

## git basic command
1.download the code # 下载代码
```
cd /a/certain/directory #进入某个指定的目录
git clone https://github.com/JasonNullx/y04.git
```
2.modify the code at your computer

3.checkin your code #提交你的代码
```
git add .
git commit -m "your reason or describe what you changed" 
git push
```

**PS:** the first time, your should run the following code to set up your account #第一次你可能需要运行下面的代码进行设置
```
#全局设置(在你电脑上的所有提交都会使用下面的配置信息)
git config --global user.name "your name"
git config --global user.email "your email address"

#只在该仓库的的提交会使用下面的配置信息
git config --local user.name "your name"
git config --local user.email "your email address"
```
