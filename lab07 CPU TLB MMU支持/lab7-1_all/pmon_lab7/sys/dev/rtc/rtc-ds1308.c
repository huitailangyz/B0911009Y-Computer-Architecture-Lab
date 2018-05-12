#include <time.h>
#include <pmon.h>

#define DS_REG_SECS		0x00	/* 00-59 */
#	define DS_BIT_CH		0x80
#define DS_REG_MIN		0x01	/* 00-59 */
#define DS_REG_HOUR		0x02	/* 00-23, or 1-12{am,pm} */
#	define DS1340_BIT_CENTURY_EN	0x80	/* in REG_HOUR */
#	define DS1340_BIT_CENTURY	0x40	/* in REG_HOUR */
#define DS_REG_WDAY		0x03	/* 01-07 */
#define DS_REG_MDAY		0x04	/* 01-31 */
#define DS_REG_MONTH	0x05	/* 01-12 */
#	define DS_BIT_CENTURY	0x80	/* in REG_MONTH */
#define DS_REG_YEAR		0x06	/* 00-99 */

#define BCD2BIN(val)	(((val) & 0x0f) + ((val)>>4)*10)
#define BIN2BCD(val)	((((val)/10)<<4) + (val)%10)

static char i2caddr[] = { 0xd0, 0};
extern int clk_invalid;

void tgt_settime(time_t t)
{
	struct tm *tm;
	char tmp;
	char buf[8];

#ifdef HAVE_TOD
	if(!clk_invalid) {
		tm = gmtime(&t);
		i2caddr[1] = 0;

		buf[DS_REG_SECS] = BIN2BCD(tm->tm_sec);
		buf[DS_REG_MIN] = BIN2BCD(tm->tm_min);
		buf[DS_REG_HOUR] = BIN2BCD(tm->tm_hour);
		buf[DS_REG_WDAY] = BIN2BCD(tm->tm_wday + 1);
		buf[DS_REG_MDAY] = BIN2BCD(tm->tm_mday);
		buf[DS_REG_MONTH] = BIN2BCD(tm->tm_mon + 1);

		/* assume 20YY not 19YY */
		tmp = tm->tm_year - 100;
		buf[DS_REG_YEAR] = BIN2BCD(tmp);
		tgt_i2cwrite(I2C_SINGLE,i2caddr,2,buf,7);
	}
#endif
}

time_t tgt_gettime()
{
	struct tm tm;
	char tmp;
	char regs[7];
	time_t t;


#ifdef HAVE_TOD
	if(!clk_invalid) {

		i2caddr[1] = 0;
		tgt_i2cread(I2C_SINGLE,i2caddr,2,regs,7);


		tm.tm_sec = BCD2BIN(regs[DS_REG_SECS] & 0x7f);
		tm.tm_min = BCD2BIN(regs[DS_REG_MIN] & 0x7f);
		tmp = regs[DS_REG_HOUR] & 0x3f;
		tm.tm_hour = BCD2BIN(tmp);
		tm.tm_wday = BCD2BIN(regs[DS_REG_WDAY] & 0x07) - 1;
		tm.tm_mday = BCD2BIN(regs[DS_REG_MDAY] & 0x3f);
		tmp = regs[DS_REG_MONTH] & 0x1f;
		tm.tm_mon = BCD2BIN(tmp) - 1;

		/* assume 20YY not 19YY, and ignore DS1337_BIT_CENTURY */
		tm.tm_year = BCD2BIN(regs[DS_REG_YEAR]) + 100;

		tm.tm_isdst = tm.tm_gmtoff = 0;
		t = gmmktime(&tm);
	}
	else 
#endif
	{
		t = 957960000;  /* Wed May 10 14:00:00 2000 :-) */
	}
	return(t);
}

int tgt_getsec()
{
	unsigned char sec;
	time_t t;
	i2caddr[1] = 0;
	tgt_i2cread(I2C_SINGLE,i2caddr,2,&sec,1);
	sec = BCD2BIN(sec & 0x7f);
	return sec;
}

void init_legacy_rtc(void)
{
	struct tm *tm;
	time_t t;

	clk_invalid = 0;
	t = tgt_gettime();
	tm = gmtime(&t);

        if( tm->tm_mon > 11 ||
                (tm->tm_mday < 1 || tm->tm_mday > 31) || (tm->tm_hour > 23) || (tm->tm_min > 59) ||
                (tm->tm_sec > 59) ){
                
		tm->tm_sec = 0;
		tm->tm_min = 0;
		tm->tm_hour = 0;
		tm->tm_mday = 1;
		tm->tm_mon = 0;
		tm->tm_year = 108;
		t = mktime(tm);
		tgt_settime(t);
	}
	clk_invalid = 1;

}

