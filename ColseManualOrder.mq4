//+------------------------------------------------------------------+
//|                                              NewsTradeTool.mq4 |
//|                                          Copyright 2015, jinsong |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, jinsong"
#property link      "https://www.mql5.com"
#property version   "1.03"
#property strict



 double MaxTodayLoss=0.01;//当天最大亏损比率,超过则将强制平仓
 bool bTrendDirection=true;//true为sell,false为buy,下单方向与设置不一致则被强制平仓
bool bRealGuaDan=false;//进行实时双向挂单交易
int interval=30;//挂单更新间隔（秒）
#include <js_include_Trend.mqh> 
 bool bTuXingHua=true;//是否进行图形化反转交易
 int MinProfit=50;//最小盈利点数
 int BreakOutActiveTime=2;//突破有效时间（小时）
extern bool bCloseManualOrder=true;

int OnInit()
{
   
   InitPlatForm(); 
   
    
   EventSetTimer(interval); 

    
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
 {
  EventKillTimer();           
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
}


//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {

    if (bCloseManualOrder) CloseManualOrder(0,ChartSymbol(),bTrendDirection,1); //强制关闭手动单  
   
  }

  
void CloseManualOrder(int majic=0,string comment="",bool dir=true,int time_period=1){
  int    cmd=0,i; 
  bool   OrderDir;
  int total=OrdersTotal(); 
  for( i=0; i<total; i++){
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {                   


         if(OrderType()!=OP_BUY && OrderType()!=OP_SELL) continue;
            cmd=OrderMagicNumber();
            if(cmd==0 ){
 
            if( TimeDay(TimeCurrent()) == TimeDay( OrderOpenTime())  && TimeHour(TimeCurrent())- TimeHour(OrderOpenTime()) <time_period )//只关一小时内的单子
                  OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,0);
            }
        }
     }
   return;
}

