前期准备：
    1、下载安装 git  （git 是工具，github是网站，是两个东西）： https://registry.npmmirror.com/-/binary/git-for-windows/v2.43.0.windows.1/Git-2.43.0-64-bit.exe
    
    2、下载安装 Watt Toolkit  。这个是 通用加速器，能加速 github 。官网 ：  https://steampp.net/
    
git bash 黑框技巧：
    快捷键 shift + insert  是粘贴
    快捷键 ctrl + insert 是复制

下载步骤：
    1、启用 Watt Toolkit 。加速选项里  勾选 【Github】  和 【国外验证码平台】、【公共CDN】

    2、进入 饥荒 MOD的根目录，如【E:\SteamLibrary\steamapps\common\Don't Starve Together\mods】

    3、右键空白处，选择【Git Bash Here】

    4、 输入命令关闭SSL验证（反正很容易验证失败，干脆直接关闭）：
        git config --global http.sslverify false

    5、 输入 命令   ：     
        git clone https://github.com/UnderDarkNight/dst_mod_character_loramia.git

    6、 等待下载完成。这个时候会多出个文件夹【dst_mod_character_loramia】。这个就是MOD的所有东西。

    7、 进入【dst_mod_character_loramia】文件夹，重新右键【Git Bash Here】

    8、 输入以下命令：
        git reset --hard
    
    9、 输入以下命令：
        git pull
    
    10、 输入以下命令：
        git pull -f origin master

更新步骤：
    1、启用 Watt Toolkit 。加速选项里  勾选 【Github】  和 【国外验证码平台】、【公共CDN】

    2、进入【dst_mod_character_loramia】文件夹，重新右键【Git Bash Here】

    3、 输入命令： 【注意！！！】最后那个  【点】不能漏掉。
        git checkout .
    
    4、 输入以下命令：
        git pull -f origin master

    5、进入 modinfo.lua 文件，修改版本号后再上传steam。版本号不能和steam上页面的一样。

意外情况：
    1、 SSL 验证失败，关闭git验证SSL：  git config --global http.sslverify false

强制完全同步远程版本：
    git fetch --all
    git reset --hard origin/master
    git pull 
    git pull -f origin master