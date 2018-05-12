GCC4.3，下载地址：http://ftp.loongnix.org/toolchain/gcc/release/gcc-4.3-ls232.tar.gz

下载后解压，将gcc4-4.3-ls232放在/opt/下，在PATH中加入路径：/opt/gcc-4.3-ls232/bin。
            如果是64位系统，还需要sudo apt-get install lsb-core

安装步骤如下：
在终端下进入gcc-4.3-ls232.tar.gz所在目录，依次运行：
   [abc@www ~]$ sudo tar –zxvf gcc-4.3-ls232.tar.gz –C /
   [abc@www ~]$ echo “export PATH=/opt/gcc-4.3-ls232/bin:$PATH” >> ~/.bashrc
对于64位系统，还要安装lsb-core：
   [abc@www ~]$ sudo apt-get install lsb-core
完成上述工作后如果可以输入mipsel-linux-gcc -v命令，如果可以正确查看版本号则说明配置正确。
