//+------------------------------------------------------------------+
//|                                              PriceMonitoring.mq4 |
//|                                          Copyright 2015, jinsong |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, jinsong"
#property link      "https://www.mql5.com"
#property version   "1.01"
#property strict

double MaxTodayLoss=0.10;//当天最大亏损比率,超过则将强制平仓
bool bTrendDirection=true;//true为sell,false为buy,手动下单方向与设置不一致则被强制平仓
extern bool bRealGuaDan=true;//进行实时双向挂单交易
extern int interval=60;//挂单更新间隔（秒）
//eu:
bool bTuXingHua=false;//是否进行图形化反转交易

#include <js_include_Trend.mqh> 

int OnInit()
{
  if (bAccount("Song Jin")==true || AccountNumber()==187392)
   {
      bAccountCanTrade=true;
      //Alert("用户认证成功，系统交易开始运行 !");
   } 
   else
   {
  
     bAccountCanTrade=false;
     Alert("用户认证失败!");
   }    
   if(bAccountCanTrade==false){bTuXingHua=false;bRealGuaDan=false;}
   InitPlatForm(); 
   /*if(bOrder){
   HlineStart(UpLinePrice,"Second_High");
   HlineStart(DownLinePrice,"Second_Low");
   HlineStart(MiddleLinePrice,"First_High",clrYellow);     
   HlineStart(MiddleHLinePriceHigh,"First_Low",clrYellow);
   }*/
   
   EventSetTimer(interval);   
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
 {
   /*if(bOrder){
      HLineDelete(0,"Second_High"); 
      HLineDelete(0,"Second_Low");            
      HLineDelete(0,"First_High");    
      HLineDelete(0,"First_Low");
   }*/
  EventKillTimer();           
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    //ManageEquity();
    //if(bTuXingHua)  XTradeTick();
    
    //CloseWrongTrendTrade(0,ChartSymbol(),bTrendDirection);   
    //ModifyTradeStop();    
    Comment(StringFormat("当前盈亏= %G , 交易方向=%d   \n当前时间=%s ",NormalizeDouble(HisLoss/zhanghuzijin,3),bTrendDirection,TimeToString(TimeCurrent()) )); 
      
}


//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
    if(bRealGuaDan)  RealGuaDan();
  }
  
void CloseWrongTrendTrade(int majic=0,string comment="",bool dir=true){
  int    cmd=0,i; 
  bool   OrderDir;
  int total=OrdersTotal(); 
  for( i=0; i<total; i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
                   
         cmd=OrderMagicNumber();
         if(OrderType()!=OP_BUY && OrderType()!=OP_SELL) continue;
         if(StringCompare(comment,"")==0){
         
             continue;
         
            }
         else{
           
            if(cmd==majic && StringCompare(comment,OrderSymbol())==0 ){

               if(OrderType()==OP_BUY) OrderDir=false;
               if(OrderType()==OP_SELL) OrderDir=true;
               //printf(" %d %s  %s %d  %d  %d",majic,comment,OrderComment(),dir,OrderDir,OrderType());
               if(dir!=OrderDir)
               if( TimeDay(TimeCurrent()) == TimeDay( OrderOpenTime())  && TimeHour(TimeCurrent())- TimeHour(OrderOpenTime()) <1 )//只关一小时内的单子
                  OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,0);
            
            }
         }
            
        }

     }
   return;
}


void ModifyTradeStop(int TrailingStop =60 ,int TrailingProfit =60){
  for(int i=0;i<OrdersTotal();i++) {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()==Symbol() &&  OrderMagicNumber()==0 && OrderStopLoss() ==0  && OrderTakeProfit() ==0 )
        {
         if(OrderType()==OP_BUY){
           double CurStop,CurTK;
            CurStop=OrderOpenPrice() - NormalizeDouble(TrailingStop*Point*PointUnit,Digits ) ;
            CurTK= OrderOpenPrice() +  NormalizeDouble(TrailingProfit*Point*PointUnit,Digits);
            bool res=OrderModify(OrderTicket(),OrderOpenPrice(),CurStop,CurTK,0,Blue); 
            if(!res) 
               Print("Buy Error in OrderModify. Error code=",GetLastError(),"MagicNumber ", OrderMagicNumber()); 
            else 
               Print("Buy Order modified successfully."); 
             
              }            
          
   
        if(OrderType()==OP_SELL ) 
         {

           double CurStop,CurTK;
           //printf("CurProfit=%f",CurProfit);
            CurStop=OrderOpenPrice()+ NormalizeDouble(TrailingStop*Point*PointUnit,Digits) ;
            CurTK= OrderOpenPrice() -  NormalizeDouble(TrailingProfit*Point*PointUnit,Digits);
            bool res=OrderModify(OrderTicket(),OrderOpenPrice(),CurStop,CurTK,0,Blue); 
            if(!res) 
               Print("Sell Error in OrderModify. Error code=",GetLastError(),"MagicNumber ", OrderMagicNumber()); 
            else 
               Print("Sell Order modified successfully. First,MagicNumber= ",OrderMagicNumber()); 
               //printf("test*%f*%f*%f*%d *%d ",OrderStopLoss(),OrderOpenPrice(),OrderOpenPrice()- NormalizeDouble(TrailingProfit*Point*PointUnit,Digits),OrderMagicNumber(),i);
             
              
         }
      }   
   }//for
}

 
