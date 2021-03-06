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

input int fST=700;//止损
input int fLI=700;//止盈
double cur_peak=0;
double high_peak=0;
int positon_peak=0,positon_trough=0;
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
   PeakTrough();
   
  }
void OnlyPeakTrough(){

//---
   double stoploss=0;
   double takeprofit;
  
   //int bar_trough=iLowest(NULL,0,MODE_LOW,m_trough+1,0); 
   cur_trough=Low[m_trough+1];
   double left_trough=Low[iLowest(NULL,0,MODE_LOW,n_trough,m_trough+2)];
   double right_trough=Low[iLowest(NULL,0,MODE_LOW,m_trough,1)];
     
   //printf("right_trough-bar=%d,Ask=%f,left_trough=%f ,cur_trough=%f ,right_trough =%f",iLowest(NULL,0,MODE_LOW,m_trough,1),Ask,left_trough,cur_trough,right_trough);            

   if(  Ask <  cur_trough  && left_trough > cur_trough   && right_trough > cur_trough ){//  

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

void PeakTrough(int InitCount=200){

//---
   double stoploss=0;
   double takeprofit;
   double from_peak,from_trough,highValue,lowValue;    


   bool bHaveTrough=false,bHavePeak=false;
   bHaveTrough=false;
   bHavePeak=false;
   for(int i=0;i<InitCount ;i++){
      
      cur_trough=iLow(NULL,0,m_trough+1+i);
      double left_trough=iLow(NULL,0,iLowest(NULL,0,MODE_LOW,n_trough,m_trough+2+i));
      double right_trough=iLow(NULL,0,iLowest(NULL,0,MODE_LOW,m_trough,1+i));
      if( left_trough > cur_trough  && right_trough > cur_trough ){
         //找到谷
         bHaveTrough=true;
         positon_trough=m_trough+1+i;
         low_trough=iLow(NULL,0,iLowest(NULL,0,MODE_LOW,positon_trough,1+0));
         if(low_trough<cur_trough) cur_trough=low_trough;
         break;
      }
      else{
      
      }      
      if(i==InitCount-1) {Alert("在前面K线中没有找到谷");cur_trough=0; }

   }  




   if(  Bid <  cur_trough  && bHaveTrough ){//&& FobidTradeByHour(8,NewsMagicSell)==1   

         stoploss=NormalizeDouble(Bid+fST*Point*PointUnit,Digits);
         takeprofit=NormalizeDouble(Bid-fLI*Point*PointUnit,Digits);
         if(JudgeMagicNumberExit(Magic_Sell,ChartSymbol())==0) {
             OpenShort(OrderCount,Magic_Sell,stoploss,takeprofit,ChartSymbol());              
             CloseOrderByMagicNumber(Magic_Buy,ChartSymbol());
         }

      }

   for(int i=0;i<InitCount ;i++){
      
      cur_peak= iHigh(NULL,0,y_peak+1+i); 
      double left_peak=iHigh(NULL,0,iHighest(NULL,0,MODE_HIGH,x_peak,y_peak+2+i));
      double right_peak=iHigh(NULL,0,iHighest(NULL,0,MODE_HIGH,y_peak,1+i));
      if( cur_peak > left_peak  && cur_peak > right_peak ){
         //找到峰
         bHavePeak=true;
         positon_peak=y_peak+1+i;
         high_peak=iHigh(NULL,0,iHighest(NULL,0,MODE_HIGH,positon_peak,1+0));
         if(high_peak > cur_peak) cur_peak=high_peak;
         break;
      }
      else{
      
      }      
      if(i==InitCount-1) {Alert("在前面K线中没有找到峰");cur_peak=0; }

   }  
    
    if( Ask > cur_peak &&   bHavePeak ){// && FobidTradeByHour(8,NewsMagicBuy)==1   
         stoploss=NormalizeDouble(Ask-fST*Point*PointUnit,Digits);
         takeprofit=NormalizeDouble(Ask+fLI*Point*PointUnit,Digits);    
         if(JudgeMagicNumberExit(Magic_Buy,ChartSymbol())==0) {
          OpenLong(OrderCount,Magic_Buy,stoploss,takeprofit,ChartSymbol()); 
          CloseOrderByMagicNumber(Magic_Sell,ChartSymbol()); 
                  
         }

     }
   
}