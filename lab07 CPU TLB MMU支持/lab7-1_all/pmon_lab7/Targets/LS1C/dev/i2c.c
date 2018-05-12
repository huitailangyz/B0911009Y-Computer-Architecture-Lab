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


int i2c_rec_haf_word(unsigned char *addr,int addrlen,unsigned char reg,unsigned short* buf ,int count)
{
int i;
int j;
	unsigned char value;
    printf ("in %s !\n", __func__);
	for(i=0;i<count;i++)
	{
        for(j=0;j<addrlen;j++)
        {
                /*write slave_addr*/
                * GS_SOC_I2C_TXR = addr[j];
                * GS_SOC_I2C_CR  = (j == 0)? (CR_START|CR_WRITE):CR_WRITE; /* start on first addr */
                while(*GS_SOC_I2C_SR & SR_TIP);
//                    printf ("device's address = 0x%x ,sr = 0x%x !\n", addr[j] ,*GS_SOC_I2C_SR);

                if((* GS_SOC_I2C_SR) & SR_NOACK) return -1;
        }
//        printf ("------1---->\n");

        * GS_SOC_I2C_TXR = reg++;   //lxy reg++ after read once
        * GS_SOC_I2C_CR  = CR_WRITE;
        while(*GS_SOC_I2C_SR & SR_TIP);
        if((* GS_SOC_I2C_SR) & SR_NOACK) return -1;

//        printf ("------2---->\n");

        /*write slave_addr*/
        * GS_SOC_I2C_TXR = addr[0]|1;
        * GS_SOC_I2C_CR  = CR_START|CR_WRITE; /* start on first addr */
        while(*GS_SOC_I2C_SR & SR_TIP);

        if((* GS_SOC_I2C_SR) & SR_NOACK) return -1;

//        printf ("------3---->\n");
        
        * GS_SOC_I2C_CR  = CR_READ; /*read send ack*/
        while(*GS_SOC_I2C_SR & SR_TIP);
        value = * GS_SOC_I2C_TXR;
        buf[i] =  value << 8;

//        printf ("------4---->\n");

        * GS_SOC_I2C_CR  = CR_READ|I2C_WACK; /*last read not send ack*/
        while(*GS_SOC_I2C_SR & SR_TIP);
        value = * GS_SOC_I2C_TXR;
        buf[i] |= value;

        * GS_SOC_I2C_CR  = CR_STOP;
        while(*GS_SOC_I2C_SR & SR_TIP);
//        * GS_SOC_I2C_SR;

 
	}
        while(*GS_SOC_I2C_SR & SR_BUSY);

	return count;
}


int i2c_send_haf_word(unsigned char *addr,int addrlen,unsigned char reg,unsigned short * buf ,int count)
{
        int i;
        int j;
        unsigned char value;
        for(i=0;i<count;i++)
        {
                for(j=0;j<addrlen;j++)
                {
                        /*write slave_addr*/
                        * GS_SOC_I2C_TXR = addr[j];
                        * GS_SOC_I2C_CR  = j == 0? (CR_START|CR_WRITE):CR_WRITE; /* start on first addr */
                        while(*GS_SOC_I2C_SR & SR_TIP);

                        if((* GS_SOC_I2C_SR) & SR_NOACK) return -1;
                }

                * GS_SOC_I2C_TXR = reg++;   //lxy: reg++ after write once
                * GS_SOC_I2C_CR  = CR_WRITE;
                while(*GS_SOC_I2C_SR & SR_TIP);
                if((* GS_SOC_I2C_SR) & SR_NOACK) return -1;

                value = (buf[i] >> 8);
                * GS_SOC_I2C_TXR = value;
                * GS_SOC_I2C_CR  = CR_WRITE;
//                printf ("hi data = 0x%x ,", value);
                while(*GS_SOC_I2C_SR & SR_TIP);
                if((* GS_SOC_I2C_SR) & SR_NOACK) return -1;

                value = buf[i];
                * GS_SOC_I2C_TXR = value;
                * GS_SOC_I2C_CR  = CR_WRITE;
//                printf ("low data = 0x%x ,", value);
                while(*GS_SOC_I2C_SR & SR_TIP);
                if((* GS_SOC_I2C_SR) & SR_NOACK) return -1;

                * GS_SOC_I2C_CR = CR_WRITE|CR_STOP;
                while(*GS_SOC_I2C_SR & SR_TIP);

        }
        while(*GS_SOC_I2C_SR & SR_BUSY);
        return count;
}

/*
 * 0 single: 每次读一个
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
case I2C_HW_SINGLE:
return i2c_rec_haf_word(addr,addrlen-1,addr[addrlen-1],(unsigned short *)buf,count);
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
case I2C_HW_SINGLE:
return i2c_send_haf_word(addr,addrlen-1,addr[addrlen-1],(unsigned short *)buf,count);
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
	*(volatile unsigned int *)(0xbfd010c0) = 0x0;
	*(volatile unsigned int *)(0xbfd010c4) = 0x0;
	*(volatile unsigned int *)(0xbfd010c8) = 0x0;
	* GS_SOC_I2C_PRER_LO = 0x64;
	* GS_SOC_I2C_PRER_HI = 0;
	* GS_SOC_I2C_CTR = 0x80;
}

