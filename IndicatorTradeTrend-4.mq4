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
extern int fST=100;//止损
extern int fLI=100;//止盈
extern bool bCanTrade=false;//进行交易吗？

int bBuyOrSell=0;//设定交易方向[0为双向，1为卖，2为买]
int fandanLot=10;//反跟单交易量
bool bfandan=false;//是否反跟，true为反跟

//extern int tradeTime1=0;//交易开始时间【欧洲】
//extern int tradeTime2=0;//交易结束时间【欧洲】
//extern int tradeTime4=6;//交易开始时间【欧洲数据】
//extern int tradeTime5=14;//交易结束时间【美国美国数据】
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
      
      //break;
      case 3:
      case 4:
      case 5:
      //if( (TimeHour(TimeCurrent())>=tradeTime4 && TimeHour(TimeCurrent()) <= tradeTime5 ) || ( TimeHour(TimeCurrent()) >= tradeTime1 && TimeHour(TimeCurrent()) <= tradeTime2 )) 
      {
         NewsTrade();
      }      
      break;
      default:
      break;
      
   }

   
     //ModifyTradeStop();

     CloseOrder();
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
   BAND_MAIN=iBands(NULL,0,20,1.8,0,PRICE_HIGH,MODE_MAIN,1); 
   BAND_UP=iBands(NULL,0,20,1.8,0,PRICE_HIGH,MODE_UPPER,1);
   BAND_LOW=iBands(NULL,0,20,1.8,0,PRICE_HIGH,MODE_LOWER,1);  
   //IMA=iMA(NULL,0,30,0,MODE_SMMA,PRICE_MEDIAN,0);
   //IMA1=iMA(NULL,0,30,0,MODE_SMMA,PRICE_MEDIAN,1);             
} 
int NewsMagicBuy=6004;
int NewsMagicSell=6014;
int NewsMagicBuyPair=6024;
int NewsMagicSellPair=6034;
bool bTradeFlag=True;
void NewsTrade(){
   double stoploss=0;
   double takeprofit;
   int trend=JudgeTrendByHour(80);
 //价格变化
   if((bBuyOrSell==0)){
      if(  Ask < BAND_LOW -  NormalizeDouble(1*Point*PointUnit,Digits) &&  Ask > BAND_LOW -  NormalizeDouble(4*Point*PointUnit,Digits) && FobidTradeByHour(4,NewsMagicBuy)==1 ){
         stoploss=NormalizeDouble(Ask-fST*Point*PointUnit,Digits);
         takeprofit=NormalizeDouble(Ask+fLI*Point*PointUnit,Digits);    
         if(JudgeMagicNumberExit(NewsMagicBuy,ChartSymbol())==0) {
          //OpenShort(OrderCount,NewsMagicSell,stoploss,takeprofit,ChartSymbol());
          OpenLong(OrderCount,NewsMagicBuy,stoploss,takeprofit,ChartSymbol()); 

          bTradeFlag=false;
          CloseOrderByMagicNumber(NewsMagicSell,ChartSymbol());  

          //CloseOrderByMagicNumber(NewsMagicBuyPair,ChartSymbol());                    
         }


      }

        if( Bid > BAND_UP +  NormalizeDouble(1*Point*PointUnit,Digits) && Bid < BAND_UP +  NormalizeDouble(4*Point*PointUnit,Digits) && FobidTradeByHour(4,NewsMagicBuy)==1 ){
         stoploss=NormalizeDouble(Bid+fST*Point*PointUnit,Digits);
         takeprofit=NormalizeDouble(Bid-fLI*Point*PointUnit,Digits);
         if(JudgeMagicNumberExit(NewsMagicSell,ChartSymbol())==0) {
             //OpenLong(OrderCount,NewsMagicBuy,stoploss,takeprofit,ChartSymbol());
             OpenShort(OrderCount,NewsMagicSell,stoploss,takeprofit,ChartSymbol());              
             bTradeFlag=true;
             CloseOrderByMagicNumber(NewsMagicBuy,ChartSymbol()); 
             //CloseOrderByMagicNumber(NewsMagicSellPair,ChartSymbol());                   
         }

     }

   
   }
   else if(bBuyOrSell==2){

   }
   else if(bBuyOrSell==1){

   }

}
extern int RSICloseSellCondition=20;//RSI value when Close Sell Order
extern int RSICloseBuyCondition=85;//RSI value when Close buy Order
extern int LimitBand=20;//Limit Band Value
extern int StopBand=10;//Stop Band Value
void CloseOrder(){

      //平仓
      if( Ask < BAND_LOW -  NormalizeDouble(20*Point*PointUnit,Digits)){
//        if(  Ask < BAND_LOW -  NormalizeDouble(LimitBand*Point*PointUnit,Digits)|| Bid > BAND_UP +  NormalizeDouble(StopBand*Point*PointUnit,Digits)){

            CloseOrderByMagicNumber(NewsMagicBuy,ChartSymbol(),true);       
         }
      //平仓
      if(  Bid > BAND_UP +  NormalizeDouble(20*Point*PointUnit,Digits)  ) {
      //if(    Ask < BAND_LOW -  NormalizeDouble(StopBand*Point*PointUnit,Digits) || Bid > BAND_UP +  NormalizeDouble(LimitBand*Point*PointUnit,Digits)  ) {

            CloseOrderByMagicNumber(NewsMagicSell,ChartSymbol(),true);                
      }
}
  



double PriceHigh,PriceLow;
int MainTrend=0;//
int JudgeTrendByHour(int barCount=100){

   //PriceHigh= High[iHighest(NULL,0,MODE_HIGH,barCount,1)]; //for 5MIN
   //PriceLow=Low[iLowest(NULL,0,MODE_LOW,barCount,1)];  
   
   if(STOCHASTKC_MAIN > STOCHASTKC )MainTrend=1;//up
   else if(STOCHASTKC_MAIN  < STOCHASTKC ) MainTrend=2;//down
   else MainTrend=0;
   
   return MainTrend;

}


void ModifyTradeStop(int TrailingStop =180 ,int TrailingProfit =30){
  for(int i=0;i<OrdersTotal();i++) {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()==ChartSymbol()  )
        {
         if(OrderType()==OP_BUY){
          
           if(Bid-OrderOpenPrice() >  NormalizeDouble(TrailingStop*Point*PointUnit,Digits)){

            if(OrderStopLoss()< OrderOpenPrice()+ NormalizeDouble(TrailingProfit*Point*PointUnit,Digits) ) 
              { 
               bool res=OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()+ NormalizeDouble(TrailingProfit*Point*PointUnit,Digits),OrderTakeProfit(),0,Blue); 
               if(!res) 
                  Print("Buy Error in OrderModify. Error code=",GetLastError(),"MagicNumber ", OrderMagicNumber()); 
               else 
                  Print("Buy Order modified successfully."); 
             
              }
          }
        } 
         if(OrderType()==OP_SELL) 
         {
            if(OrderOpenPrice()-Ask >  NormalizeDouble(TrailingStop*Point*PointUnit,Digits)){

             if(OrderStopLoss()> OrderOpenPrice()- NormalizeDouble(TrailingProfit*Point*PointUnit,Digits)   ) 
              { 
               bool res=OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()- NormalizeDouble(TrailingProfit*Point*PointUnit,Digits),OrderTakeProfit(),0,Blue); 
               if(!res) 
                  Print("Sell Error in OrderModify. Error code=",GetLastError(),"MagicNumber ", OrderMagicNumber()); 
               else 
                  Print("Sell Order modified successfully. MagicNumber= ",OrderMagicNumber()); 
//                  printf("TEST*%f*%f*%f*%d *%d ",OrderStopLoss(),TrailingProfit*Point*PointUnit,OrderOpenPrice()- NormalizeDouble(TrailingProfit*Point*PointUnit,Digits),OrderMagicNumber(),i);
              
              }         
             
            }

          }        
        
      }   
   }//for
}






