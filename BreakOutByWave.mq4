//+------------------------------------------------------------------+
//|                                               BreakOutByWave.mq4 |
//|                                          Copyright 2015, jinsong |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, jinsong"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#include <js_include_mini.mqh> 
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
extern int x_peak=2;//波峰左侧K线
extern int y_peak=2;//波峰右侧K线
extern int n_trough=2;//波谷左侧K线
extern int m_trough=2;//波谷右侧K线

double pre_peak=0;
double cur_peak=0;
double high_peak=0;
double pre_trough=0;
double cur_trough=0;
double low_trough=0;

int OnInit()
  {
//---
    InitPlatForm();  
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
int Magic_Sell=100;
int Magic_Buy=101;
extern double OrderCount=1;//交易量
void OnTick()
  {
//---
   double stoploss=0;
   double takeprofit;
  
   //int bar_trough=iLowest(NULL,0,MODE_LOW,m_trough+1,0); 
   cur_trough=Low[m_trough+1];
   double left_trough=Low[iLowest(NULL,0,MODE_LOW,n_trough,m_trough+2)];
   double right_trough=Low[iLowest(NULL,0,MODE_LOW,m_trough,1)];
     
   //printf("right_trough-bar=%d,Ask=%f,left_trough=%f ,cur_trough=%f ,right_trough =%f",iLowest(NULL,0,MODE_LOW,m_trough,1),Ask,left_trough,cur_trough,right_trough);            

   if(  Ask <  cur_trough  && left_trough > cur_trough   && right_trough > cur_trough ){//&& FobidTradeByHour(8,NewsMagicSell)==1   

         stoploss=0;//NormalizeDouble(Bid+fST*Point*PointUnit,Digits);
         takeprofit=0;//NormalizeDouble(Bid-fLI*Point*PointUnit,Digits);
         if(JudgeMagicNumberExit(Magic_Sell,ChartSymbol())==0) {
             OpenShort(OrderCount,Magic_Sell,stoploss,takeprofit,ChartSymbol());              
             CloseOrderByMagicNumber(Magic_Buy,ChartSymbol());
         }

      }

   //int bar_peak=iHighest(NULL,0,MODE_HIGH,y_peak+1,0);
   cur_peak= High[y_peak+1]; 
   double left_peak=High[iHighest(NULL,0,MODE_HIGH,x_peak,y_peak+2)];
   double right_peak=High[iHighest(NULL,0,MODE_HIGH,y_peak,1)];      
    if( Bid > cur_peak &&  left_peak < cur_peak && right_peak < cur_peak ){// && FobidTradeByHour(8,NewsMagicBuy)==1   
         stoploss=0;//NormalizeDouble(Ask-fST*Point*PointUnit,Digits);
         takeprofit=0;//NormalizeDouble(Ask+fLI*Point*PointUnit,Digits);    
         if(JudgeMagicNumberExit(Magic_Buy,ChartSymbol())==0) {
          OpenLong(OrderCount,Magic_Buy,stoploss,takeprofit,ChartSymbol()); 
          CloseOrderByMagicNumber(Magic_Sell,ChartSymbol()); 
                  
         }

     }
   
   
  }
//+------------------------------------------------------------------+
double JudgePeak(){


  return  cur_peak;
}

double JudgeTrough(){

  return cur_trough;
}