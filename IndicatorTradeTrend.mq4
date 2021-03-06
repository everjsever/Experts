//+------------------------------------------------------------------+
//|                                                   FlashTrade.mq4 |
//|                                          Copyright 2015, jinsong |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, jinsong"
#property link      "https://www.mql5.com"
#property version   "1.01"
#property strict
#include <js_include_standard.mqh> 
double       MACD_FastEMA    = 12;
double       MACD_SlowEMA    = 26;
double       MACD_SMA        = 9;
extern double OrderCount=0.01;//交易量
int PriceInterval=300;//时间间隔（秒）
extern int fST=40;//止损
extern int fLI=80;//止盈
extern bool bCanTrade=false;//进行交易吗？


int fandanLot=10;//反跟单交易量
bool bfandan=false;//是否反跟，true为反跟

extern int tradeTime1=0;//交易开始时间【欧洲】
extern int tradeTime2=0;//交易结束时间【欧洲】
extern int tradeTime4=6;//交易开始时间【欧洲数据】
extern int tradeTime5=14;//交易结束时间【美国美国数据】
//14-22 H4  

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
//   EventSetMillisecondTimer(1000);
     InitPlatForm();      
//---

    

     //EventSetTimer(PriceInterval);

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
//   EventKillTimer();
     //PrintAllOrderByMagic(NewsMagicBuy-1,fLI,1); 
     //PrintAllOrderByMagic(NewsMagicSell-1,fLI,1);     
                   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+

void OnTick()
  {
//---

   if(bCanTrade){
  
   IndicatorRun();
   int weekday=TimeDayOfWeek(TimeCurrent()); 
   switch(weekday)
   {
      case 1:
      case 2:
      
      break;
      case 3:
      case 4:
      case 5:
      if( (TimeHour(TimeCurrent())>=tradeTime4 && TimeHour(TimeCurrent()) <= tradeTime5 ) || ( TimeHour(TimeCurrent()) >= tradeTime1 && TimeHour(TimeCurrent()) <= tradeTime2 )) 
      {
         NewsTrade();
      }      
      break;
      default:
      break;
      
   }

   
     //SecondsTrade(200);

     CloseOrder();
     if(bfandan){
        ReverseOrder(NewsMagicSell+1,NewsMagicSell);     
        ReverseOrder(NewsMagicBuy+1,NewsMagicBuy);  
     }     
      //ModifyTradeStopSmaller(fST);   
   }

    Comment(StringFormat("交易状态= %d , 当日盈亏=%d       ",bCanTrade,NormalizeDouble(HisLoss/zhanghuzijin,3))); 

  }
  


//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {

  }
double QuickRSI,RSI,MACD,STOCHASTKC,STOCHASTKC_MAIN,STOCHASTKC_1,STOCHASTKC_MAIN_1,BAND_MAIN,BAND_UP,BAND_LOW,IMA,IMA1;
void IndicatorRun(){
   RSI = iRSI(NULL,0,20,PRICE_CLOSE,0);
   QuickRSI=iRSI(NULL,0,5,PRICE_CLOSE,0);
   //MACD   = iMACD(NULL,0,MACD_FastEMA,MACD_SlowEMA,MACD_SMA,PRICE_CLOSE,MODE_MAIN,1);
   STOCHASTKC_MAIN=iStochastic(NULL,0,120,60,80,MODE_SMA,0,MODE_MAIN,1);
   STOCHASTKC=iStochastic(NULL,0,120,60,80,MODE_SMA,0,MODE_SIGNAL,1);   
   //STOCHASTKC_MAIN_1=iStochastic(NULL,0,8,3,5,MODE_SMA,0,MODE_MAIN,2);
   //STOCHASTKC_1=iStochastic(NULL,0,8,3,5,MODE_SMA,0,MODE_SIGNAL,2);  
   BAND_MAIN=iBands(NULL,0,20,2,0,PRICE_HIGH,MODE_MAIN,1); 
   BAND_UP=iBands(NULL,0,20,2,0,PRICE_HIGH,MODE_UPPER,1);
   BAND_LOW=iBands(NULL,0,20,2,0,PRICE_HIGH,MODE_LOWER,1);  
   //IMA=iMA(NULL,0,30,0,MODE_SMMA,PRICE_MEDIAN,0);
   //IMA1=iMA(NULL,0,30,0,MODE_SMMA,PRICE_MEDIAN,1);             
} 
int NewsMagicBuy=6000;
int NewsMagicSell=6010;
int NewsMagicBuyPair=6020;
int NewsMagicSellPair=6030;
extern int QuickRSI_high=70;//买快RSI值
extern int QuickRSI_low=30;//卖快RSI值
void NewsTrade(){
   double stoploss=0;
   double takeprofit;
   int trend=JudgeTrendByHour(80);
 //价格变化

//      if(STOCHASTKC_MAIN_1 <= STOCHASTKC_1  && STOCHASTKC_MAIN > STOCHASTKC && STOCHASTKC_MAIN_1 < 30 && RSI <40 && trend==0 ){
//      if( BAND_UP - BAND_LOW < NormalizeDouble(50*Point*PointUnit,Digits)  && Ask - BAND_UP > NormalizeDouble(5*Point*PointUnit,Digits) && Ask - BAND_UP < NormalizeDouble(10*Point*PointUnit,Digits)  ){
      //printf("JudgeLastOrderDirection()=%d   BAND_LOW-Ask=%f",JudgeLastOrderDirection(), BAND_LOW-Ask);
      //if(RSI<35 && STOCHASTKC_MAIN < 20)
//      if( BAND_UP - BAND_LOW > NormalizeDouble(3*Point*PointUnit,Digits) && BAND_LOW-Ask  > NormalizeDouble(1*Point*PointUnit,Digits) && BAND_LOW-Ask  < NormalizeDouble(15*Point*PointUnit,Digits)   && FobidTradeByHour(1,NewsMagicBuy)==1 ){//&& (JudgeLastOrderDirection()==OP_SELL || JudgeLastOrderDirection()==-1 ) 
      if( QuickRSI >QuickRSI_high && Ask > BAND_UP && MainTrend ==1 && FobidTradeByHour(4,NewsMagicBuy)==1 ){
        //buy
         stoploss=NormalizeDouble(Ask-fST*Point*PointUnit,Digits);
         takeprofit=NormalizeDouble(Ask+fLI*Point*PointUnit,Digits);
         if(JudgeMagicNumberExit(NewsMagicBuy,ChartSymbol())==0) {
             OpenLong(OrderCount,NewsMagicBuy,stoploss,takeprofit,ChartSymbol());
             //if(bfandan) OpenShort(OrderCount*fandanLot,NewsMagicBuy+1,0,0,ChartSymbol());
             CloseOrderByMagicNumber(NewsMagicSell,ChartSymbol(),true);  
             //CloseOrderByMagicNumber(NewsMagicSellPair,ChartSymbol());                   
         }
      }
      
//      if(STOCHASTKC_MAIN_1 >= STOCHASTKC_1  && STOCHASTKC_MAIN < STOCHASTKC && STOCHASTKC_MAIN_1 >70 && RSI >60 && trend==0 ){
//      if( BAND_UP - BAND_LOW < NormalizeDouble(50*Point*PointUnit,Digits)  && Ask - BAND_LOW > NormalizeDouble(5*Point*PointUnit,Digits) && Ask - BAND_LOW < NormalizeDouble(10*Point*PointUnit,Digits) ){
//      if(RSI>70 && STOCHASTKC_MAIN >70 )
//      if( BAND_UP - BAND_LOW > NormalizeDouble(3*Point*PointUnit,Digits) && Ask - BAND_UP > NormalizeDouble(1*Point*PointUnit,Digits) && Ask - BAND_UP < NormalizeDouble(15*Point*PointUnit,Digits)    && FobidTradeByHour(1,NewsMagicSell)==1){
        if( QuickRSI < QuickRSI_low && Bid < BAND_LOW && MainTrend ==2 && FobidTradeByHour(4,NewsMagicSell)==1){
        //sell
         stoploss=NormalizeDouble(Bid+fST*Point*PointUnit,Digits);
         takeprofit=NormalizeDouble(Bid-fLI*Point*PointUnit,Digits);    
         if(JudgeMagicNumberExit(NewsMagicSell,ChartSymbol())==0) {
          OpenShort(OrderCount,NewsMagicSell,stoploss,takeprofit,ChartSymbol()); 
          //if(bfandan) OpenLong(OrderCount*fandanLot,NewsMagicSell+1,0,0,ChartSymbol()); 
          CloseOrderByMagicNumber(NewsMagicBuy,ChartSymbol(),true); 
          //CloseOrderByMagicNumber(NewsMagicBuyPair,ChartSymbol());                    
         }

     }

}

void CloseOrder(){

      //平仓
      if( RSI >70 ){
            //CloseOrderByMagicNumber(NewsMagicBuy,ChartSymbol());  
            //CloseOrderByMagicNumber(NewsMagicBuyPair,ChartSymbol());             
      }
      //平仓
      if(  RSI < 30  ) {
            //CloseOrderByMagicNumber(NewsMagicSell,ChartSymbol()); 
            //CloseOrderByMagicNumber(NewsMagicSellPair,ChartSymbol());               
      }
}
  


int MainTrend=0;//
int JudgeTrendByHour(int barCount=100){
   if(STOCHASTKC_MAIN > STOCHASTKC )MainTrend=1;//up
   else if(STOCHASTKC_MAIN  < STOCHASTKC ) MainTrend=2;//down
   else MainTrend=0;
   
   return MainTrend;
   


}





