//+------------------------------------------------------------------+
//|                                              NewsTradeTool.mq4 |
//|                                          Copyright 2015, jinsong |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, jinsong"
#property link      "https://www.mql5.com"
#property version   "1.04"
#property strict
/////////////////for MTK Platform,BJ 8AM=LON 0AM//////////////////////////


extern double MaxTodayLoss=0.05;//当天最大亏损比率,超过则将强制平仓
extern bool bTrendDirection=true;//true为sell,false为buy,下单方向与设置不一致则被强制平仓
bool bRealGuaDan=false;//进行实时双向挂单交易
int interval=30;//挂单更新间隔（秒）
#include <js_include_Trend.mqh> 
extern bool bTuXingHua=true;//是否进行图形化反转交易
int BreakOutActiveTime=2;//突破有效时间（小时）
extern bool bPriceAlert=true;//是否价格报警

/////////peak trough start//////
extern int x_peak=4;//波峰左侧K线
extern int y_peak=4;//波峰右侧K线
extern int n_trough=4;//波谷左侧K线
extern int m_trough=4;//波谷右侧K线
double cur_peak=0;
double high_peak=0;
int positon_peak=0,positon_trough=0;
double cur_trough=0;
double low_trough=0;
double pre_peak=0;
double pre_trough=0;
/////////peak trough end//////
bool bCloseManualOrder=true;
#include <Tool_TP_Wnd.mqh>
int OnInit()
{
//  if (bAccount("Song Jin")==true || AccountNumber()==20890203)

  if (AccountNumber()==6669637 || AccountNumber()==91515244 ||  AccountNumber()==91515252  )
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
   
   HistoryTodayDirection=-1;  
   
   if (bCloseManualOrder) CloseManualOrder(0,ChartSymbol(),bTrendDirection,1); //强制关闭手动单   
   OrderTodayCNT=OrderProfitManage(OneTwoBuy,OneTwoSell);//利润管理   
   
   EventSetTimer(interval); 
   WindowInit(); 

   PrintAllMyOrder();
    
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
    if(bTuXingHua) { XTradeTick(); XTradeTickRealTime();}//图形化实时交易    
    
    PriceAlarm();
    StatusDisplay();     
}


//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
//    if(bRealGuaDan)  RealGuaDan();
    //else ClosePendingOrderByMagic(0,ChartSymbol());//与图形挂单冲突
    bExit24HOrder=false;//复位该单不存在
    bTuPoOrder=false;
    bTrendOrder=false;
    bRightOrder=false;
    HistoryTodayDirection=-1;     
    if (bCloseManualOrder) CloseManualOrder(0,ChartSymbol(),bTrendDirection,1); //强制关闭手动单  
   
    OrderTodayCNT=OrderProfitManage(OneTwoBuy,OneTwoSell);//利润管理      
   
    ManageEquity();    
    
//    DisplayTrend(bTrendDirection);
}
double RecentHigh=0,RecentLow=0; 
void StatusDisplay(){
   if ( HistoryTodayDirection==OP_BUY) OrderDirStr="B";
   else if(HistoryTodayDirection==OP_SELL) OrderDirStr="S";
   else  OrderDirStr=""; 
   Comment(StringFormat("                                   当交次=%d  方向=%s     当前盈亏= %G ,   当前时间=%s ",OrderTodayCNT,OrderDirStr,NormalizeDouble(HisLoss/zhanghuzijin,4),TimeToString(TimeCurrent()) )); 
}
double BAND_MAIN,BAND_UP,BAND_LOW;
void PriceAlarm(){
   RecentHigh=High[iHighest(NULL,0,MODE_HIGH,72,1)];
   RecentLow=Low[iLowest(NULL,0,MODE_LOW,72,1)];
   
   BAND_MAIN=iBands(NULL,PERIOD_H1,20,2,0,PRICE_HIGH,MODE_MAIN,1); 
   BAND_UP=iBands(NULL,PERIOD_H1,20,2,0,PRICE_HIGH,MODE_UPPER,1);
   BAND_LOW=iBands(NULL,PERIOD_H1,20,2,0,PRICE_HIGH,MODE_LOWER,1);     
   
   if(bPriceAlert ){
   if(Bid>RecentHigh) Alert(ChartSymbol()+":创最新高！");
   if(Ask<RecentLow) Alert(ChartSymbol()+":破最新低！");
   if(Ask > BAND_UP) Alert(ChartSymbol()+":上破布林带！");
   if(Bid < BAND_LOW) Alert(ChartSymbol()+":下破布林带！");
   }
}
int CurentOrderTotal; 
int ZoneStopTime=-1,BreakOutStopTime=-1,TrendStopTime=-1; 
int ZoneStopTimeEnd=-1,BreakOutStopTimeEnd=-1,TrendStopTimeEnd=-1; 
int MaxDayStop=40;//日内单最大亏损
void CloseManualOrder(int majic=0,string comment="",bool dir=true,int time_period=1){
   int    cmd=0,i; 
   bool   OrderDir;
   MqlDateTime str1,str2;   
   CurentOrderTotal=OrdersTotal(); 
   for( i=0; i<CurentOrderTotal; i++){
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {                   
         cmd=OrderMagicNumber();
         //当天方向
         if(StringCompare(OrderSymbol(),ChartSymbol())==0){
            if (OrderType()==OP_BUY){ HistoryTodayDirection=OP_BUY; OrderDirStr="B";}
            else { HistoryTodayDirection=OP_SELL; OrderDirStr="S";}
                     //printf("TodayCount=%d %d , %d %d  %s %d" ,TodayCount,TimeDay(OrderOpenTime()),TimeDay(TimeCurrent()),OrderType(),OrderSymbol(),HistoryTodayDirection);
          }
                     
         /////////////关闭突破单///////////////////////
         if(cmd==BreakOutMagicBuy || cmd==BreakOutMagicSell){
            double tmpProfit=0;
            if(OrderType()==OP_SELL && StringCompare(OrderSymbol(),ChartSymbol())==0 ){//max stop
            //Modefy Min Limit value
            double sl,tp;
            if(OrderOpenPrice()-OrderTakeProfit()<  NormalizeDouble( MinBreakOutProfit*Point*PointUnit,Digits) ) {//limit less than min limit
            tp=OrderOpenPrice()-  NormalizeDouble( MinBreakOutProfit*Point*PointUnit,Digits);
            sl=OrderStopLoss();
            if(OrderModify(OrderTicket(), OrderOpenPrice(), sl, tp, 0, Green) == false)
                   Print("Err (", GetLastError(), ") Modify  Price= ", OrderOpenPrice(),
                         " SL= ", sl, " TP= ", tp);               
            }           

             //tmpProfit=OrderOpenPrice()-Ask;//浮盈
             //if(tmpProfit>TemporyBreakOutProift)  TemporyBreakOutProift=tmpProfit;//当前突破单最大盈利
            if(Ask-OrderOpenPrice() >  NormalizeDouble( MaxDayStop*Point*PointUnit,Digits))  OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,0);
            
             if(OrderOpenPrice()-Ask >  NormalizeDouble( 17*Point*PointUnit,Digits) && OrderLots()== SellStop_Lot )  OrderClose(OrderTicket(),OrderLots()/2,OrderClosePrice(),3,0);  //盈利17点平仓一半 
            }
            else if(OrderType()==OP_BUY && StringCompare(OrderSymbol(),ChartSymbol())==0){
             //tmpProfit=Bid-OrderOpenPrice();
             //if(tmpProfit>TemporyBreakOutProift)  TemporyBreakOutProift=tmpProfit;
            double sl,tp;
            if(OrderTakeProfit()-OrderOpenPrice()<  NormalizeDouble( MinBreakOutProfit*Point*PointUnit,Digits) ) {//limit less than min limit
            tp=OrderOpenPrice()+ NormalizeDouble( MinBreakOutProfit*Point*PointUnit,Digits);
            sl=OrderStopLoss();
            if(OrderModify(OrderTicket(), OrderOpenPrice(), sl, tp, 0, Green) == false)
                   Print("Err (", GetLastError(), ") Modify  Price= ", OrderOpenPrice(),
                         " SL= ", sl, " TP= ", tp);               
            }              
             if(OrderOpenPrice()-Bid >  NormalizeDouble( MaxDayStop*Point*PointUnit,Digits))  OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,0); 

             if(Bid- OrderOpenPrice() >  NormalizeDouble( 17*Point*PointUnit,Digits ) && OrderLots()== BuyStop_Lot)  OrderClose(OrderTicket(),OrderLots()/2,OrderClosePrice(),3,0);              
            }
         
          /* if( MathAbs(TimeHour(TimeCurrent())- TimeHour(OrderOpenTime())) >= BreakOutActiveTime &&  (StringCompare(OrderSymbol(),ChartSymbol())==0) ){
                 if( OrderProfit()<0 ) OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,0);
           }*/
        
         }
         ////////////////关闭趋势单 ////////////////////
          if(cmd==FollowTrendBuy || cmd==FollowTrendSell ){
           
           if( OrderType()==OP_SELL && StringCompare(OrderSymbol(),ChartSymbol())==0 ){//趋势单，max stop
                  PeakTrough(400,true);
            }
            
           if( OrderType()==OP_BUY && StringCompare(OrderSymbol(),ChartSymbol())==0){    
                  PeakTrough(400,false);
            }
                     
           /*TimeToStruct(TimeCurrent(),str1); 
           TimeToStruct(OrderOpenTime(),str2);  
           if( str1.day_of_year-str2.day_of_year >= 1 &&  (StringCompare(OrderSymbol(),ChartSymbol())==0) ){//超过1天              
                  OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,0);       
           }
           
           if( OrderType()==OP_SELL && StringCompare(OrderSymbol(),ChartSymbol())==0 ){//趋势单，max stop

                 if(Ask-OrderOpenPrice() >  NormalizeDouble( MaxDayStop*Point*PointUnit,Digits)) {
                  TrendStopTime=str1.min;                   
                   if( TrendStopTimeEnd!=-1 &&  TrendStopTime!=-1 && (TrendStopTime - TrendStopTimeEnd > 3  || ( (TrendStopTime - TrendStopTimeEnd > -57) && (TrendStopTime - TrendStopTimeEnd < 0) ) ) ) OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,0);
                  
                  }
                  else{
                        TrendStopTimeEnd=str1.min;
                        TrendStopTime=-1;                  
                  }
            }
            
           if( OrderType()==OP_BUY && StringCompare(OrderSymbol(),ChartSymbol())==0){    
  
              if(OrderOpenPrice()-Bid >  NormalizeDouble( MaxDayStop*Point*PointUnit,Digits)){
                 TrendStopTime=str1.min; 
                 if( TrendStopTimeEnd!=-1 &&  TrendStopTime!=-1 && (TrendStopTime - TrendStopTimeEnd > 3  || ( (TrendStopTime - TrendStopTimeEnd > -57) && (TrendStopTime - TrendStopTimeEnd < 0) ) ) ) OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,0); 
                }
            
            else{
                  TrendStopTimeEnd=str1.min;
                  TrendStopTime=-1; 
            }
           }*/
         }
         //////////////////判断日内单是否存在，并关闭最大止损//////////////////////////
            
            if((cmd==OneTwoBuy || cmd==OneTwoSell) && (StringCompare(OrderSymbol(),ChartSymbol())==0) ){ 
             TimeToStruct(TimeCurrent(),str1); 
             TimeToStruct(OrderOpenTime(),str2);  
             if( str1.day_of_year-str2.day_of_year >= 1  ){//超过1天              
                  OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,0);       
             }
             
             if(OrderType()==OP_SELL  ){//max stop
                    if(Ask-OrderOpenPrice() >  NormalizeDouble( MaxDayStop*Point*PointUnit,Digits)) {
                        ZoneStopTime=str1.min;  
                        if( ZoneStopTimeEnd!=-1 &&  ZoneStopTime!=-1 && (ZoneStopTime - ZoneStopTimeEnd > 3  || ( (ZoneStopTime - ZoneStopTimeEnd > -57) && (ZoneStopTime - ZoneStopTimeEnd < 0) ) ) ) OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,0);
                   
                        //printf("ZoneStopTimeEnd=%d,ZoneStopTime=%d",ZoneStopTimeEnd,ZoneStopTime);
                     }
                     else{
                        ZoneStopTimeEnd=str1.min;
                        ZoneStopTime=-1;

                     }
               //if(OrderOpenPrice()-Ask >  NormalizeDouble( MinProfit*Point*PointUnit,Digits) && OrderLots()== SellStop_Lot )  OrderClose(OrderTicket(),OrderLots()/2,OrderClosePrice(),3,0);  //盈利17点平仓一半 
                     
               }
               
              if(OrderType()==OP_BUY ){    
                 if(OrderOpenPrice()-Bid >  NormalizeDouble( MaxDayStop*Point*PointUnit,Digits)) {
                     ZoneStopTime=str1.min;                 
                     if( ZoneStopTimeEnd!=-1 &&  ZoneStopTime!=-1 && (ZoneStopTime - ZoneStopTimeEnd > 3  || ( (ZoneStopTime - ZoneStopTimeEnd > -57) && (ZoneStopTime - ZoneStopTimeEnd < 0) ) ) )  OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,0); 
                  }
                  else{
                        ZoneStopTimeEnd=str1.min;
                        ZoneStopTime=-1;                  
                  }
               //if(Bid- OrderOpenPrice() >  NormalizeDouble( MinProfit*Point*PointUnit,Digits ) && OrderLots()== BuyStop_Lot )  OrderClose(OrderTicket(),OrderLots()/2,OrderClosePrice(),3,0);              

               } 
            
               bExit24HOrder=true;

            }
         //////////////////////////close manual order magic number=0///////////////////////////////////
         if(OrderType()!=OP_BUY && OrderType()!=OP_SELL) continue;
         if(StringCompare(comment,"")==0){
             continue;
         }
         else{
            //if(cmd==majic && StringCompare(comment,OrderSymbol())==0 ){
            if(cmd==majic ){ //
            if( TimeDay(TimeCurrent()) == TimeDay( OrderOpenTime())  && TimeHour(TimeCurrent())- TimeHour(OrderOpenTime()) <time_period )//只关一小时内的单子
                  OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,0);
            }
         }
        }
     }
   return ;
}



int HistoryTodayDirection=-1;
string OrderDirStr="";  
int TrendOrderMinTime=2; //最小持仓时间
int TrendOrderMinProfit=30;//2小时内最小min profit  最小持仓时间内最小盈利
bool bExit24HOrder=false;//是否存在
bool bTuPoOrder=false;
bool bTrendOrder=false;
bool bRightOrder=false;
int TodayLossOrder=0;//当天亏损单
int MinBreakOutProfit=150;//突破单最小等待利润
//int MinProfit=60;//日内交易最小盈利点数
double TemporyBreakOutProift=0;//突破单浮盈
double OrderProfitManage(int buy_mn1=1,int sell_mn2=2 ){
   double cmd=0;
   int  total=OrdersHistoryTotal();
   int TodayCount=0;
   TodayCount=CurentOrderTotal;

   int i;
   TodayLossOrder=0;
   for(i=1; i<=total; i++)
   {
        if(OrderSelect(total-i,SELECT_BY_POS,MODE_HISTORY))
        {             
            cmd=OrderMagicNumber();
            //printf(" total%d symbol=%s",total,OrderSymbol());
            if (OrderType()==OP_BUY || OrderType()==OP_SELL)  {
              //printf("TodayCount=%d %d , %d" ,TodayCount,TimeDay(OrderOpenTime()),TimeDay(TimeCurrent()));
               if( TimeDay(TimeCurrent()) ==TimeDay(OrderOpenTime()) ) {//当天交易,不能修改这个逻辑，由于其他地方会自动开单会导致冲突
                  TodayCount++;//当天交易次数
                  //当天方向
                  if(OrderProfit()<0) TodayLossOrder++;//统计当天亏损单数量
                  else TodayLossOrder--;
                  if( StringCompare(OrderSymbol(),ChartSymbol())==0){
                     if (OrderType()==OP_BUY){ HistoryTodayDirection=OP_BUY; OrderDirStr="B";}
                     else { HistoryTodayDirection=OP_SELL; OrderDirStr="S";}
                     //printf("TodayCount=%d %d , %d %d  %s %d" ,TodayCount,TimeDay(OrderOpenTime()),TimeDay(TimeCurrent()),OrderType(),OrderSymbol(),HistoryTodayDirection);
                  }
                                   
                  //趋势单时间限制 开仓
                     if( cmd==FollowTrendSell || cmd==FollowTrendBuy   ) {//趋势单
                     if (StringCompare(OrderSymbol(),ChartSymbol())==0) bTrendOrder=true;
                     if(TimeHour(OrderCloseTime()) - TimeHour(OrderOpenTime()) <TrendOrderMinTime && (StringCompare(OrderSymbol(),ChartSymbol())==0) ){//小于2小时
                           double stop,profit;
                           stop=OrderStopLoss();
                           profit=OrderTakeProfit();
                           double OrderCount=OrderLots();
                           string order_symbol=OrderSymbol();
                           if(OrderType()==OP_SELL && ( OrderOpenPrice() - OrderClosePrice() > 0  &&    OrderOpenPrice() - OrderClosePrice() <  NormalizeDouble( TrendOrderMinProfit*Point*PointUnit,Digits)   ) && OrderCount== SellStop_Lot ){//盈利小于20点
                                
                                 if(IsExitMagicNumberCurrentOrder(FollowTrendSell,order_symbol)==0) {
                                     OpenShort(OrderCount,FollowTrendSell,stop,profit,order_symbol); 
                                 } 
                                          
                           }
                           else if(OrderType()==OP_BUY && ( OrderOpenPrice() - OrderClosePrice() < 0 &&  OrderClosePrice()- OrderOpenPrice()   <  NormalizeDouble( TrendOrderMinProfit*Point*PointUnit,Digits)  ) && OrderCount== BuyStop_Lot ) {
                                 if(IsExitMagicNumberCurrentOrder(FollowTrendBuy,order_symbol)==0) {
                                    OpenLong(OrderCount,FollowTrendBuy,stop,profit,order_symbol);                                  
                                 } 
                                
                              }
                     
                     }
                   
                   }
                   //突破单
                   if( (cmd==BreakOutMagicBuy || cmd==BreakOutMagicSell)   && (StringCompare(OrderSymbol(),ChartSymbol())==0)  )
                   { 
                     bTuPoOrder=true;                            
                     double stop,profit;
                     stop=OrderStopLoss();
                     profit=OrderTakeProfit();
                     double OrderCount=OrderLots();
                     string order_symbol=OrderSymbol();
                     double Order_ClosePrice=OrderClosePrice();//分两次盈利
                     //printf("Bid - Order_ClosePrice=%f ",Bid - Order_ClosePrice);
                     if(OrderType()==OP_SELL && ( OrderOpenPrice() - OrderClosePrice() > NormalizeDouble( 5*Point*PointUnit,Digits)   &&    OrderOpenPrice() - OrderClosePrice() <  NormalizeDouble( MinBreakOutProfit*Point*PointUnit,Digits)   )  && Bid > Order_ClosePrice + NormalizeDouble( 15*Point*PointUnit,Digits) && Bid < Order_ClosePrice + NormalizeDouble( 19*Point*PointUnit,Digits)  && OrderCount== SellStop_Lot ){//盈利小于40点且大于10点
                         if(IsExitMagicNumberCurrentOrder(BreakOutMagicSell,order_symbol)==0  ) {
                                OpenShort(OrderCount,BreakOutMagicSell,stop,profit,order_symbol); 
                         } 
                      }
                      else if(OrderType()==OP_BUY && ( OrderClosePrice()-OrderOpenPrice()  >  NormalizeDouble( 5*Point*PointUnit,Digits) &&  OrderClosePrice()- OrderOpenPrice()   <  NormalizeDouble( MinBreakOutProfit*Point*PointUnit,Digits)  )  && Ask < Order_ClosePrice - NormalizeDouble( 15*Point*PointUnit,Digits) && Ask > Order_ClosePrice - NormalizeDouble( 19*Point*PointUnit,Digits)  && OrderCount== BuyStop_Lot ) {
                         if(IsExitMagicNumberCurrentOrder(BreakOutMagicBuy,order_symbol)==0 ) {
                             OpenLong(OrderCount,BreakOutMagicBuy,stop,profit,order_symbol);                                  
                         } 
                      }
                   }  
                  //12H单时间限制 ，开仓
                  /* if( cmd==OneTwoBuy || cmd==OneTwoSell   ) {
                     if (StringCompare(OrderSymbol(),ChartSymbol())==0) bExit24HOrder=true;
                     if(TimeHour(OrderCloseTime()) - TimeHour(OrderOpenTime()) <12 && (StringCompare(OrderSymbol(),ChartSymbol())==0) ){//小于12小时
                              
                           double stop,profit;
                           stop=OrderStopLoss();
                           profit=OrderTakeProfit();
                           double OrderCount=OrderLots();
                           string order_symbol=OrderSymbol();
                           if(OrderType()==OP_SELL && ( OrderClosePrice() - OrderOpenPrice()  < NormalizeDouble( (ButtonDStop-3)*Point*PointUnit,Digits)  &&    OrderOpenPrice() - OrderClosePrice() <  NormalizeDouble( ButtonDProfit*Point*PointUnit,Digits)   ) ){//盈利小于30点
                                
                                 if(IsExitMagicNumberCurrentOrder(OneTwoSell,order_symbol)==0) {
                                     OpenShort(OrderCount,OneTwoSell,stop,profit,order_symbol); 
                                 } 
                                          
                           }
                           else if(OrderType()==OP_BUY && ( OrderOpenPrice() - OrderClosePrice() < NormalizeDouble( (ButtonDStop-3)*Point*PointUnit,Digits) &&  OrderClosePrice()- OrderOpenPrice()   <  NormalizeDouble( ButtonDProfit*Point*PointUnit,Digits)  )) {
                                 if(IsExitMagicNumberCurrentOrder(OneTwoBuy,order_symbol)==0) {
                                    OpenLong(OrderCount,OneTwoBuy,stop,profit,order_symbol);                                  
                                 } 
                                
                              }
                     
                     }
                   
                   }*/                  
            /////////////////////////////////////////////////////////////////
            //printf("mn=%d,tk=%d ,NU=%d",OrderMagicNumber(),OrderTicket(),total-i);
            //最小盈利
                 /* if((cmd==buy_mn1 || cmd==sell_mn2 ) && (OrderType()==OP_BUY || OrderType()==OP_SELL) && (StringCompare(OrderSymbol(),ChartSymbol())==0) && TimeDay(TimeCurrent()) ==TimeDay(OrderOpenTime()) ){
                        bRightOrder=true;
                        double stop,profit;
                        stop=OrderStopLoss();
                        profit=OrderTakeProfit();
                        double OrderCount=OrderLots();
                        string order_symbol=OrderSymbol();
                        double Order_OpenPrice=OrderOpenPrice();
                        if(OrderType()==OP_SELL){
                              //printf("OrderTakeProfit=%f,minProfit=%d ,OrderClosePrice()=%f  NormalizeDouble( minProfit*Point*PointUnit,Digits) =%f,OrderOpenPrice() - OrderClosePrice()=%f",OrderTakeProfit(),minProfit,OrderClosePrice(),NormalizeDouble( minProfit*Point*PointUnit,Digits) ,OrderOpenPrice() - OrderClosePrice()); 
//                              if( (OrderTakeProfit() -OrderClosePrice() < 0.0  && OrderClosePrice() -OrderOpenPrice() <0.0  && OrderTakeProfit()!=0 ) || (  OrderOpenPrice() - OrderClosePrice() > 0.0 &&   OrderOpenPrice() - OrderClosePrice() <  NormalizeDouble( minProfit*Point*PointUnit,Digits)   ) ){
                              if(   OrderOpenPrice() - OrderClosePrice() > 0.0 &&   OrderOpenPrice() - OrderClosePrice() <  NormalizeDouble( MinProfit*Point*PointUnit,Digits) && Bid < Order_OpenPrice  && OrderCount== SellStop_Lot){
                        
                              if(OrderOpenPrice() - OrderClosePrice() <  NormalizeDouble( MinProfit*Point*PointUnit,Digits)) profit=OrderOpenPrice()-NormalizeDouble( MinProfit*Point*PointUnit,Digits);
                               
                              if(IsExitMagicNumberCurrentOrder(sell_mn2,order_symbol)==0) {
                                  OpenShort(OrderCount,sell_mn2,stop,profit,order_symbol); 
                              } 
                           }            
                        }
                        else{
                        
                            //if((OrderTakeProfit() > OrderClosePrice() && OrderTakeProfit()!=0 && OrderClosePrice() > OrderOpenPrice()) || ( OrderOpenPrice() - OrderClosePrice() < 0 &&  OrderClosePrice()- OrderOpenPrice()   <  NormalizeDouble( minProfit*Point*PointUnit,Digits)  ) ){
                            if( OrderOpenPrice() - OrderClosePrice() < 0 &&  OrderClosePrice()- OrderOpenPrice()   <  NormalizeDouble( MinProfit*Point*PointUnit,Digits)  && Ask > Order_OpenPrice  && OrderCount== BuyStop_Lot ){
                              if(OrderClosePrice()- OrderOpenPrice()   <  NormalizeDouble( MinProfit*Point*PointUnit,Digits)) profit=OrderOpenPrice()+NormalizeDouble( MinProfit*Point*PointUnit,Digits);
                              if(IsExitMagicNumberCurrentOrder(buy_mn1,order_symbol)==0) {
                               OpenLong(OrderCount,buy_mn1,stop,profit,order_symbol);                                  
                              } 
                             }
                           }
                    
                  }*/

               }//the same day
            }//


      
         }
         if(i>20) break;//最近20单
     } 
     
    return TodayCount;      
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

void TradeButtonManage(){


}


void PrintAllMyOrder(int magic=0){
   bool   result;
   double t1=0,s1=0,t2=0,s2=0,t3=0,s3=0,t4=0,s5=0,s6=0,s7=0,t5=0,s8=0,s9=0;
   int    cmd,error=0,i,cnt1=0,cnt2,cnt3,cnt4,cnt6,cnt7,cnt8,cnt9,cnt10,cnt11; 
   cnt1=0; cnt2=0;cnt3=0;cnt4=0;cnt6=0;cnt7=0;cnt8=0;cnt9=0;cnt10=0;cnt11=0;
   int total=OrdersHistoryTotal();
 for( i=0; i<total; i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
        {
         //---- print selected rder
         //OrderPrint();
         switch(OrderMagicNumber()){
         
         case 1101:
            s1=s1+OrderProfit()+OrderCommission()+OrderSwap();
         break;
         
         case 1102:
            t1=t1+OrderProfit()+OrderCommission()+OrderSwap();
            
         break;
         
         case 1103:
            t2=t2+OrderProfit()+OrderCommission()+OrderSwap();

         break;
         
         case 1104:
             t3=t3+OrderProfit()+OrderCommission()+OrderSwap();
             cnt4++;
         break; 
          case 5001:   
             s7=s7+OrderProfit()+OrderCommission()+OrderSwap();      
          break;     
          case 5002:
             s2=s2+OrderProfit()+OrderCommission()+OrderSwap();
             cnt6++;
         break;   
         case 5003:
             s3=s3+OrderProfit()+OrderCommission()+OrderSwap();
         break;  

         case 5004:
             s6=s6+OrderProfit()+OrderCommission()+OrderSwap();
             break;

         case 5006:         
             s5=s5+OrderProfit()+OrderCommission()+OrderSwap(); 
         break;
         case 5005:
             t4=t4+OrderProfit()+OrderCommission()+OrderSwap();
             cnt2++;
         break;  
         case 5007:
             t5=t5+OrderProfit()+OrderCommission()+OrderSwap();  
             cnt3++;   
         break;  
         case 5008:
             s8=s8+OrderProfit()+OrderCommission()+OrderSwap();
         break;  
         case 5009:
             s9=s9+OrderProfit()+OrderCommission()+OrderSwap();
             cnt1++;       
         break;  
         }
         
        }
      else {
       error++;
       Print( "Error when order select ", GetLastError()); break; }
     
     
    }
    Print("Er ",error,"  1101=",s1," 1102=",t1," 1103=",t2," 1104=",t3," 5001=",s7 ," 5002=",s2," 5003 =",s3, " Total:",t1+t2+t3+s1+s2+s3+s5+s6+s7+t4+t5+s8+s9);
    Print(" 5004=",s6," 5005=",t4," 5006=",s5," 4005=",t5 ," 4006=",s8," 4007=",s9,  " Total:",t1+t2+t3+s1+s2+s3+s5+s6+s7+t4+t5+s8+s9);
   
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
void PeakTrough(int InitCount=400,bool Sell_Order=true){

//---
   double stoploss=0;
   double takeprofit;
   double from_peak,from_trough,highValue,lowValue;    


   bool bHaveTrough=false,bHavePeak=false;
   bHaveTrough=false;
   bHavePeak=false;
   if(MathAbs(pre_trough -iLow(NULL,0,positon_trough))>0.00001)//不等于
      for(int i=0;i<InitCount ;i++){
         
         cur_trough=iLow(NULL,0,m_trough+1+i);
         double left_trough=iLow(NULL,0,iLowest(NULL,0,MODE_LOW,n_trough,m_trough+2+i));
         double right_trough=iLow(NULL,0,iLowest(NULL,0,MODE_LOW,m_trough,1+i));
         if( left_trough > cur_trough  && right_trough > cur_trough ){
            //找到谷
            bHaveTrough=true;
            positon_trough=m_trough+1+i;
            pre_trough=cur_trough;//记住谷底         
            low_trough=iLow(NULL,0,iLowest(NULL,0,MODE_LOW,positon_trough,1+0));
            if(low_trough<cur_trough) cur_trough=low_trough;
            break;
         }
         else{
         
         }      
         if(i==InitCount-1) {Alert("在前面K线中没有找到谷");cur_trough=0; }
   
      }
   else   bHaveTrough=true;  




   if(  Bid <  cur_trough  && bHaveTrough ){//&& FobidTradeByHour(8,NewsMagicSell)==1   

         //OP(true,fST,fLI,Magic_Buy,Magic_Sell,OrderCount);
         if(!Sell_Order){
            OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,0);
         }

      }
   if(MathAbs(pre_peak -iHigh(NULL,0,positon_peak))>0.00001)//不等于
      for(int i=0;i<InitCount ;i++){
         
         cur_peak= iHigh(NULL,0,y_peak+1+i); 
         double left_peak=iHigh(NULL,0,iHighest(NULL,0,MODE_HIGH,x_peak,y_peak+2+i));
         double right_peak=iHigh(NULL,0,iHighest(NULL,0,MODE_HIGH,y_peak,1+i));
         if( cur_peak > left_peak  && cur_peak > right_peak ){
            //找到峰
            bHavePeak=true;
            positon_peak=y_peak+1+i;
            pre_peak=cur_peak;
            high_peak=iHigh(NULL,0,iHighest(NULL,0,MODE_HIGH,positon_peak,1+0));
            if(high_peak > cur_peak) cur_peak=high_peak;
            break;
         }
         else{
         
         }      
         if(i==InitCount-1) {Alert("在前面K线中没有找到峰");cur_peak=0; }
   
      }  
    else bHavePeak=true;
    
    
    if( Ask > cur_peak &&   bHavePeak ){// && FobidTradeByHour(8,NewsMagicBuy)==1   
         //OP(false,fST,fLI,Magic_Buy,Magic_Sell,OrderCount);
         if(Sell_Order){
            OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,0);
         }
     }
   
}