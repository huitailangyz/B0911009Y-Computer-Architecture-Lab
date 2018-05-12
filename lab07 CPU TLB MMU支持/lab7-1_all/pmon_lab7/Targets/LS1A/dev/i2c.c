#include <pmon.h>
#include <target/i2c.h>



//----------------------------------------------------

void i2c_stop()
{
  * GS_SOC_I2C_CR  = CR_STOP;
  * GS_SOC_I2C_SR;
  while(*GS_SOC_I2C_SR & SR_BUSY);
}




unsigned char i2c_rec_s(unsigned char *addr,int addrlen,unsigned char* buf ,int count)
{
	int i;
	int j;
	unsigned char value;
	unsigned char reg = addr[addrlen-1];
	for(i=0;i<count;i++)
	{
		for(j=0;j<addrlen;j++)
		{
			/*write slave_addr*/
			* GS_SOC_I2C_TXR = (j==addrlen-1)?reg:addr[j];
			* GS_SOC_I2C_CR  = (j == 0)? (CR_START|CR_WRITE):CR_WRITE; /* start on first addr */
			while(*GS_SOC_I2C_SR & SR_TIP);

			if((* GS_SOC_I2C_SR) & SR_NOACK) { printf("read no ack %d\n",__LINE__); i2c_stop();return i;}
		}

		/*write slave_addr*/
		* GS_SOC_I2C_TXR = addr[0]|1;
		* GS_SOC_I2C_CR  = CR_START|CR_WRITE; /* start on first addr */
		while(*GS_SOC_I2C_SR & SR_TIP);

		if((* GS_SOC_I2C_SR) & SR_NOACK) { printf("read no ack %d\n",__LINE__); i2c_stop();return i;}

		* GS_SOC_I2C_CR  = CR_READ|I2C_WACK; /*last read not send ack*/
		while(*GS_SOC_I2C_SR & SR_TIP);

		buf[i] = * GS_SOC_I2C_TXR;
		* GS_SOC_I2C_CR  = CR_STOP;
		* GS_SOC_I2C_SR;
		while(*GS_SOC_I2C_SR & SR_BUSY);
		reg++;

	}

	return count;
}

unsigned char i2c_send_s(unsigned char *addr,int addrlen,unsigned char * buf ,int count)
{
	int i;
	int j;
	unsigned char reg = addr[addrlen-1];
	for(i=0;i<count;i++)
	{
		for(j=0;j<addrlen;j++)
		{
			/*write slave_addr*/
			* GS_SOC_I2C_TXR = (j==addrlen-1)?reg:addr[j];
			* GS_SOC_I2C_CR  = j == 0? (CR_START|CR_WRITE):CR_WRITE; /* start on first addr */
			while(*GS_SOC_I2C_SR & SR_TIP);

			if((* GS_SOC_I2C_SR) & SR_NOACK) { printf("write no ack %d\n",__LINE__); i2c_stop();return i;}
		}


		* GS_SOC_I2C_TXR = buf[i];
		* GS_SOC_I2C_CR = CR_WRITE|CR_STOP;
		while(*GS_SOC_I2C_SR & SR_TIP);

		if((* GS_SOC_I2C_SR) & SR_NOACK) { printf("write no ack %d\n",__LINE__); i2c_stop();return i;}
		reg++;
	}
	while(*GS_SOC_I2C_SR & SR_BUSY);
	return count;
}


unsigned char i2c_rec_b(unsigned char *addr,int addrlen,unsigned char* buf ,int count)
{
	int i;
	int j;


	unsigned char value;

	for(j=0;j<addrlen;j++)
	{
		/*write slave_addr*/
		* GS_SOC_I2C_TXR = addr[j];
		* GS_SOC_I2C_CR  = j == 0? (CR_START|CR_WRITE):CR_WRITE; /* start on first addr */
		while(*GS_SOC_I2C_SR & SR_TIP);

		if((* GS_SOC_I2C_SR) & SR_NOACK) return i;
	}


	* GS_SOC_I2C_TXR = addr[0]|1;
	* GS_SOC_I2C_CR  = CR_START|CR_WRITE;
	if((* GS_SOC_I2C_SR) & SR_NOACK) return i;

	for(i=0;i<count;i++)
	{
		* GS_SOC_I2C_CR  = (i==count-1)?CR_READ|I2C_WACK:CR_READ; /*last read not send ack*/
		while(*GS_SOC_I2C_SR & SR_TIP);

		buf[i] = * GS_SOC_I2C_TXR;
	}
	* GS_SOC_I2C_CR  = CR_STOP;

	return count;
}

unsigned char i2c_send_b(unsigned char *addr,int addrlen,unsigned char * buf ,int count)
{
	int i;
	int j;
	for(j=0;j<addrlen;j++)
	{
		/*write slave_addr*/
		* GS_SOC_I2C_TXR = addr[j];
		* GS_SOC_I2C_CR  = j == 0? (CR_START|CR_WRITE):CR_WRITE; /* start on first addr */
		while(*GS_SOC_I2C_SR & SR_TIP);

		if((* GS_SOC_I2C_SR) & SR_NOACK) return i;
	}


	for(i=0;i<count;i++)
	{	
		* GS_SOC_I2C_TXR = buf[i];
		* GS_SOC_I2C_CR = CR_WRITE;
		while(*GS_SOC_I2C_SR & SR_TIP);

		if((* GS_SOC_I2C_SR) & SR_NOACK) return i;

	}
	* GS_SOC_I2C_CR  = CR_STOP;
	while(*GS_SOC_I2C_SR & SR_BUSY);
	return count;
}

/*
 * 0 single: ÿ�ζ�һ��
 * 1 smb block
 */
int tgt_i2cread(int type,unsigned char *addr,int addrlen,unsigned char *buf,int count)
{
int i;
tgt_i2cinit();
memset(buf,-1,count);
switch(type)
{
case I2C_SINGLE:
return i2c_rec_s(addr,addrlen,buf,count);
break;
case I2C_BLOCK:
return i2c_rec_b(addr,addrlen,buf,count);
break;

default: return 0;break;
}
return 0;
}

int tgt_i2cwrite(int type,unsigned char *addr,int addrlen,unsigned char *buf,int count)
{
tgt_i2cinit();
switch(type&0xff)
{
case I2C_SINGLE:
i2c_send_s(addr,addrlen,buf,count);
break;
case I2C_BLOCK:
return i2c_send_b(addr,addrlen,buf,count);
break;
case I2C_SMB_BLOCK:
break;
default:return -1;break;
}
return -1;
}


int tgt_i2cinit()
{
static int inited=0;
if(inited)return 0;
inited=1;
 * GS_SOC_I2C_PRER_LO = 0x64;
 * GS_SOC_I2C_PRER_HI = 0;
 * GS_SOC_I2C_CTR = 0x80;
}

