//+------------------------------------------------------------------+
//|                                              PriceMonitoring.mq4 |
//|                                          Copyright 2015, jinsong |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, jinsong"
#property link      "https://www.mql5.com"
#property version   "1.03"
#property strict



extern double MaxTodayLoss=0.01;//当天最大亏损比率,超过则将强制平仓
extern bool bTrendDirection=true;//true为sell,false为buy,下单方向与设置不一致则被强制平仓
bool bRealGuaDan=false;//进行实时双向挂单交易
int interval=60;//挂单更新间隔（秒）
#include <js_include_Trend.mqh> 
extern bool bTuXingHua=true;//是否进行图形化反转交易
#include <Tool_TP_Wnd.mqh>
bool bCloseManualOrder=true;

int OnInit()
{
//  if (bAccount("Song Jin")==true || AccountNumber()==20890203)

  if (AccountNumber()==20890203 || AccountNumber()==91515244 )
   {
      bAccountCanTrade=true;
      //Alert("用户认证成功，系统交易开始运行 !");
   } 
   else
   {
  
     bAccountCanTrade=false;
     return INIT_FAILED;
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
   WindowInit(); 
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
    if(bTuXingHua)  XTradeTick();    
    
    if (bCloseManualOrder) CloseManualOrder(0,ChartSymbol(),bTrendDirection,1); //强制关闭手动单  
    //ModifyTradeStop();    //手动单止盈指止损
  
    Comment(StringFormat("当前盈亏= %G , 交易方向=%d   \n当前时间=%s ",NormalizeDouble(HisLoss/zhanghuzijin,3),bTrendDirection,TimeToString(TimeCurrent()) )); 
      
}


//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
    if(bRealGuaDan)  RealGuaDan();
    //else ClosePendingOrderByMagic(0,ChartSymbol());//与图形挂单冲突
   
    OrderProfitManage(80,MagicBuyStop,MagicSellStop);//利润管理      
   
    ManageEquity();    
    
//    DisplayTrend(bTrendDirection);
  }
  
void CloseManualOrder(int majic=0,string comment="",bool dir=true,int time_period=1){
  int    cmd=0,i; 
  bool   OrderDir;
  int total=OrdersTotal(); 
  for( i=0; i<total; i++){
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {                   
         cmd=OrderMagicNumber();
         if(OrderType()!=OP_BUY && OrderType()!=OP_SELL) continue;
         if(StringCompare(comment,"")==0){
             continue;
         }
         else{
            if(cmd==majic && StringCompare(comment,OrderSymbol())==0 ){
               //if(OrderType()==OP_BUY) OrderDir=false;
               //if(OrderType()==OP_SELL) OrderDir=true;
               //printf(" %d %s  %s %d  %d  %d",majic,comment,OrderComment(),dir,OrderDir,OrderType());
               //if(dir!=OrderDir)
            if( TimeDay(TimeCurrent()) == TimeDay( OrderOpenTime())  && TimeHour(TimeCurrent())- TimeHour(OrderOpenTime()) <time_period )//只关一小时内的单子
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
int ClosePendingOrderByMagic(int majic=0,string comment=""){
  int    cmd=0,i; 
  int total=OrdersTotal(); 
  for( i=0; i<total; i++){
    if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)){
         if((OrderType()==OP_SELLSTOP || OrderType()==OP_BUYSTOP) && (OrderMagicNumber()== MagicSellStop || OrderMagicNumber()==MagicBuyStopUp) ){
         //cmd=OrderMagicNumber();
         if(StringCompare(comment,"")==0){         
            //if(cmd==majic)     OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,0);         
         }
         else{           
            if(StringCompare(comment,OrderSymbol())==0 ){
             // printf(" %d %s  %s",majic,comment,OrderComment());
             OrderDelete(OrderTicket());            
            }
         }
       }    
    }//if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)){

  }//for
   return (0);
}   
double OrderProfitManage(int MinProfit=60,int buy_mn1=1,int sell_mn2=2 ){
   double LossCount=0,cmd=0;
   int  total=OrdersHistoryTotal();
   //printf(" total%d",total);
   for(int i=0; i<total; i++)
   {
        if(OrderSelect(total-i,SELECT_BY_POS,MODE_HISTORY))
        {             
            cmd=OrderMagicNumber();
            //printf("mn=%d,tk=%d ,NU=%d",OrderMagicNumber(),OrderTicket(),total-i);
            if((cmd==buy_mn1 || cmd==sell_mn2 ) && (OrderType()==OP_BUY || OrderType()==OP_SELL) && OrderSymbol()==ChartSymbol() ){
                  double stop,profit;
                  stop=OrderStopLoss();
                  profit=OrderTakeProfit();
                  double OrderCount=OrderLots();
                  if(OrderType()==OP_SELL){
                        if(OrderTakeProfit() < OrderClosePrice() && OrderTakeProfit()!=0 && OrderClosePrice() < OrderOpenPrice() ){
  
                        if(JudgeMagicNumberExit(sell_mn2,OrderSymbol())==0) {
                            OpenShort(OrderCount,sell_mn2,stop,profit,OrderSymbol()); 
                        } 
                     }            
                  }
                  else{
                  
                      if(OrderTakeProfit() > OrderClosePrice() && OrderTakeProfit()!=0 && OrderClosePrice() > OrderOpenPrice() ){
                        if(JudgeMagicNumberExit(buy_mn1,OrderSymbol())==0) {
                         OpenLong(OrderCount,buy_mn1,stop,profit,OrderSymbol());                                  
                        } 
                       }
                     }
              break; //只判断最后一次
            }

      
         }
         if(i>20) break;//最近20单
     } 
     
    return LossCount;      
}
void DisplayTrend(bool directon=true)
  {
//---
  //---
   int i; 
   string obj_name="label_object"; 
   long current_chart_id=ChartID(); 
//--- creating label object (it does not have time/price coordinates) 
   if(!ObjectCreate(current_chart_id,obj_name,OBJ_LABEL,0,0,0)) 
     { 
      Print("Error: can't create label! code #",GetLastError()); 
      ObjectDelete(obj_name);  
      return ; 
     } 

//--- move object down and change its text 
   if(directon){
//--- set color to Red 
   ObjectSetInteger(current_chart_id,obj_name,OBJPROP_COLOR,clrWhite);    
   for(i=0; i<200; i++) 
     { 
      //--- set text property 
      ObjectSetString(current_chart_id,obj_name,OBJPROP_TEXT,StringFormat(" %s:  下跌！，不能Buy！\r\n",_Symbol)); 
      //--- set distance property 
      ObjectSet(obj_name,OBJPROP_YDISTANCE,i); 
      //--- forced chart redraw 
      ChartRedraw(current_chart_id); 
      Sleep(20); 
     }    
   }
   else{
//--- set color to Blue 
   ObjectSetInteger(current_chart_id,obj_name,OBJPROP_COLOR,clrWhite); 
//--- move object up and change its text 
   for(i=200; i>0; i--) 
     { 
      //--- set text property 
      ObjectSetString(current_chart_id,obj_name,OBJPROP_TEXT,StringFormat(" %s:  上涨！，不能Sell\r\n",_Symbol)); 
      //--- set distance property 
      ObjectSet(obj_name,OBJPROP_YDISTANCE,i); 
      //--- forced chart redraw 
      ChartRedraw(current_chart_id); 
      Sleep(20); 
     }    
   }


//--- delete object 
   ObjectDelete(obj_name);      
  }
