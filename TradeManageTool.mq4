//+------------------------------------------------------------------+
//|                                              TradeManageTool.mq4 |
//|                                          Copyright 2015, jinsong |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, jinsong"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer

      
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer

      
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   int count=  OrderProfitManage();
   //printf("count=%d",count);
   if(count>10){
      CloseManualOrder();
   }
   
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   
  }
//+------------------------------------------------------------------+
double OrderProfitManage (){
   double cmd=0;
   int  total=OrdersHistoryTotal();
   int TodayCount=0;
   //printf(" total%d",total);
   int i;
   for(i=0; i<total; i++)
   {
        if(OrderSelect(total-i,SELECT_BY_POS,MODE_HISTORY))
        {             
            cmd=OrderMagicNumber();
            
            if (OrderType()==OP_BUY || OrderType()==OP_SELL)  {
              //printf("TodayCount=%d %d , %d" ,TodayCount,TimeDay(OrderOpenTime()),TimeDay(TimeCurrent()));
               if( TimeDay(TimeCurrent()) ==TimeDay(OrderOpenTime()) ) {//当天交易
                  TodayCount++;//当天交易次数                

                   }                  

               }
            }//

         if(i>20) break;//最近20单
      
      }
    return TodayCount;      
}

  
void CloseManualOrder(int majic=0){
  int    cmd=0,i; 
  bool   OrderDir;
  int total=OrdersTotal(); 
  for( i=0; i<total; i++){
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {                   
         if(OrderType()!=OP_BUY && OrderType()!=OP_SELL) continue;
            cmd=OrderMagicNumber();
            if(cmd==0 ){
 
           // if( TimeDay(TimeCurrent()) == TimeDay( OrderOpenTime())  && TimeHour(TimeCurrent())- TimeHour(OrderOpenTime()) <1 )//只关一小时内的单子
                  OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,0);
            }
        }
     }
   return;
}
