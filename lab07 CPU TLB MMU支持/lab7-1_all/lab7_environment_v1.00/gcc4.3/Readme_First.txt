GCC4.3�����ص�ַ��http://ftp.loongnix.org/toolchain/gcc/release/gcc-4.3-ls232.tar.gz

���غ��ѹ����gcc4-4.3-ls232����/opt/�£���PATH�м���·����/opt/gcc-4.3-ls232/bin��
            �����64λϵͳ������Ҫsudo apt-get install lsb-core

��װ�������£�
���ն��½���gcc-4.3-ls232.tar.gz����Ŀ¼���������У�
   [abc@www ~]$ sudo tar �Czxvf gcc-4.3-ls232.tar.gz �CC /
   [abc@www ~]$ echo ��export PATH=/opt/gcc-4.3-ls232/bin:$PATH�� >> ~/.bashrc
����64λϵͳ����Ҫ��װlsb-core��
   [abc@www ~]$ sudo apt-get install lsb-core
������������������������mipsel-linux-gcc -v������������ȷ�鿴�汾����˵��������ȷ��
