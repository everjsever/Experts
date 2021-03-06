//+------------------------------------------------------------------+
//|                                              PriceMonitoring.mq4 |
//|                                          Copyright 2015, jinsong |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, jinsong"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

extern int OrderLotCount=1;//每次下单量（单位：0.01,偶数）
extern double MaxTodayLoss=0.04;//当天最大亏损比率
extern bool bBackTest=false;//是否进行回测
bool bOrder=false;//是否进行自动交易
extern bool bEquityManage=true;//是否进行资金风险管理
extern bool bJiaTuPo=false;//是否进行趋势反转交易
extern bool bTuXingHua=true;//是否进行图形化反转交易
bool bTuXingHuaTuPo=false;//是否进行图形化突破交易
bool bTuXingHuaRealTime=false;//是否进行图形化实时交易
bool bBoTouPi=false;//是否进行均线突破交易
int  Limit_Step=100;//盈利单位
#include <js_include.mqh> 
     
int long_period=220;
int OnInit()
  {
  
  if (bAccount("Song Jin")==false)
  {
     bAccountCanTrade=false;
    // Alert("用户认证失败!");
  }
   else
   {
      bAccountCanTrade=true;
      //Alert("用户认证成功，系统交易开始运行 !");
   }
   JudgeBigTrend(3,5,10,long_period,100); 
   JudgeBigTrendSell(2,5,10,long_period,100);    
   InitPlatForm(); 
   if(bOrder){
   HlineStart(UpLinePrice,"Pre_High");
   HlineStart(DownLinePrice,"Pre_Low");
   HlineStart(MiddleLinePrice,"First_High",clrYellow);     
   HlineStart(MiddleHLinePriceHigh,"First_Low",clrYellow);
   }
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
 {
   if(bOrder){
      HLineDelete(0,"Pre_High"); 
      HLineDelete(0,"Pre_Low");            
      HLineDelete(0,"First_High");    
      HLineDelete(0,"First_Low");
   }
     PrintAllOrderByMagic(200,100,8);
     PrintAllOrderByMagic(600,100,8);
//     PrintAllOrderByMagic(700,20,40);          
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
  
    //if(bAccountCanTrade==false) return ;      
    //double lot=CalculateLots();
    if(bBackTest){//for back test
      OrderManage();    
      return;
    }
    
    if(bEquityManage){
     if(bTuXingHua && ManageEquity())  XTradeTick(); 
     //if(bTuXingHuaRealTime)  XTradeTickRealTime();            
     if(bOrder && ManageEquity() )
      {
        if(ChartPeriod()!=PERIOD_H1) return ;
        OrderManage();
       }

     }
    else{
       if(bTuXingHua)  XTradeTick();
             
       //if(bTuXingHuaRealTime)  XTradeTickRealTime();
       if(bOrder)
       {
         if(ChartPeriod()!=PERIOD_H1) return ;
         OrderManage();
       } 


    } 
    Comment(StringFormat("当前亏损= %G , 图形化交易状态=%d  ==>  批量交易量= %d  \nBuy状态 = %d ==>约束条件：前2： %G ,前1：%G ,前0：%G ==>  Sell状态=%d => 约束条件=%G, %G, %G  \n日内阻力 = %G\n日内支撑 = %G \nPointUnit=%G \n当前时间=%s",NormalizeDouble(HisLoss/zhanghuzijin,3),bTuXingHua,OrderLotCount, TrendStatus,EarlyPreLowPrice_1,PreLowPrice_1,CurLowPrice_1,SellTrendStatus,EarlyPreHighPrice,PreHighPrice,CurHighPrice,UpLinePrice,DownLinePrice,PointUnit,TimeToString(TimeCurrent()))); 
    
}

void OrderManage(){
    if(bJiaTuPo){
    JudgeBigTrendSell(2,5,10,long_period,0); 
    if(SellByMAJiaTuPo()==true)   SellAllCaseJiaTupo();
    //if(SellByMA()==true)  SellAllCase();
    //SellAllCaseJiaTupoAddLot(OrderLotCount/2);//加仓
    
    JudgeBigTrend(3,5,10,long_period,0); 
    if(BuyMA()==true)     BuyAllCase();  
    if(BuyMAJiaTuPo()==true)     BuyAllCaseJiaTupo();  
    //if(BuyMATuPo()==true)     BuyMATuPo();    
    ModifyTradeStop(); //小额盈利时      
    }
   else{
      if(bBoTouPi){
       JudgeBigTrendSell(2,5,10,long_period,0);  
       //CloseBoTouPi();       
       JudgeBigTrend(3,5,10,long_period,0); 
       if(BuyMALongTerm()==true) LongTermTrade();
      }
   
   }

}
void SellAllCase(){
   double stoploss=0;
   double takeprofit;
   stoploss=NormalizeDouble(Bid+50*Point*PointUnit,Digits);//SellPrice_200;//
   int i=0;
   for(i=1;i<=OrderLotCount;i++){
   takeprofit=NormalizeDouble(Bid-Limit_Step*i*Point*PointUnit,Digits);        
   if(JudgeMagicNumberExit(100+i,ChartSymbol())==0  && JudgeMagicNumberExit(100+OrderLotCount,ChartSymbol())==0){ 
      OpenShort(0.01,100+i,stoploss,takeprofit,ChartSymbol());    
      
   }
   
   }
}
double SellPrice_200;
void SellAllCaseJiaTupo(){
   double stoploss=0;
   double takeprofit;
   int i=0;
   stoploss=NormalizeDouble(Bid+50*Point*PointUnit,Digits);//CurHighPrice_1;//
   for(i=1;i<=OrderLotCount;i++){
   takeprofit=NormalizeDouble(Bid-Limit_Step*i*Point*PointUnit,Digits);        
   if(JudgeMagicNumberExit(200+i,ChartSymbol())==0  && JudgeMagicNumberExit(200+OrderLotCount,ChartSymbol())==0 ){ 
      OpenShort(0.01,200+i,stoploss,takeprofit,ChartSymbol()); 
      SellPrice_200=Bid;   
      
   }
   
   }
/*   stoploss=NormalizeDouble(Bid+30*Point*PointUnit,Digits);//CurHighPrice_1;//
   for(i=1;i<=OrderLotCount;i++){
   takeprofit=NormalizeDouble(Bid-2*i*Point*PointUnit,Digits);        
   if(JudgeMagicNumberExit(300+i,ChartSymbol())==0  && JudgeMagicNumberExit(300+OrderLotCount,ChartSymbol())==0 ){ 
      OpenShort(0.01,300+i,stoploss,takeprofit,ChartSymbol()); 
      
   }
   
   }*/
}

void SellTupo(int lots=40){
   double stoploss=0;
   double takeprofit;
   stoploss=NormalizeDouble(Bid+50*Point*PointUnit,Digits);
   int i=0;
   if(lots<1) lots=1;
   if(JudgeMagicNumberProfit(201,ChartSymbol())< 0.01*30 && JudgeMagicNumberProfit(201,ChartSymbol())> 0.01*10 && JudgeMagicNumberExit(200+3,ChartSymbol())==0){//第三单已盈利出场
       for(i=1;i<=lots;i++){
         takeprofit=NormalizeDouble(Bid-20*i*Point*PointUnit,Digits);        
         if(JudgeMagicNumberExit(300+i,ChartSymbol())==0  && JudgeMagicNumberExit(300+lots,ChartSymbol())==0 ){ 
          OpenShort(0.01,300+i,stoploss,takeprofit,ChartSymbol());    
         
         }
      
       }  
   
    }

}

void BuyAllCase(){
   double stoploss=0;
   double takeprofit;
   stoploss=BuyPrice_600;//NormalizeDouble(Ask-50*Point*PointUnit,Digits); 
   int i=0;
   for(i=1;i<=OrderLotCount;i++){
   takeprofit=NormalizeDouble(Ask+Limit_Step*i*Point*PointUnit,Digits);        
   if(JudgeMagicNumberExit(500+i,ChartSymbol())==0 && JudgeMagicNumberExit(500+OrderLotCount,ChartSymbol())==0 ){ 
      OpenLong(0.01,500+i,stoploss,takeprofit,ChartSymbol());    
      
   }
   
   }
}
double BuyPrice_600;
void BuyAllCaseJiaTupo(){


   double stoploss=0;
   double takeprofit;
   stoploss=NormalizeDouble(Ask-30*Point*PointUnit,Digits); //CurLowPrice_1;//NormalizeDouble(Ask-50*Point*PointUnit,Digits); 
   int i=0;
   for(i=1;i<=OrderLotCount;i++){
   takeprofit=NormalizeDouble(Ask+Limit_Step*i*Point*PointUnit,Digits);        
   if(JudgeMagicNumberExit(600+i,ChartSymbol())==0 && JudgeMagicNumberExit(600+OrderLotCount,ChartSymbol())==0 ){ 
         OpenLong(0.01,600+i,stoploss,takeprofit,ChartSymbol());   
         BuyPrice_600=Ask; 
         
      }
      
   }
/* 
   stoploss=NormalizeDouble(Ask-30*Point*PointUnit,Digits); //CurLowPrice_1;//NormalizeDouble(Ask-50*Point*PointUnit,Digits); 
   for(i=1;i<=OrderLotCount;i++){
   takeprofit=NormalizeDouble(Ask+2*i*Point*PointUnit,Digits);        
   if(JudgeMagicNumberExit(700+i,ChartSymbol())==0 && JudgeMagicNumberExit(700+OrderLotCount,ChartSymbol())==0 ){ 
         OpenLong(0.01,700+i,stoploss,takeprofit,ChartSymbol());   
         
      }
      
   }
*/      
}
void BuyTuPo(int lots=40){

   double stoploss=0;
   double takeprofit;
   stoploss=NormalizeDouble(Ask-50*Point*PointUnit,Digits); //CurLowPrice_1;//NormalizeDouble(Ask-50*Point*PointUnit,Digits); 
   int i=0;
   for(i=1;i<=OrderLotCount;i++){
   takeprofit=NormalizeDouble(Ask+4*i*Point*PointUnit,Digits);        
   if(JudgeMagicNumberExit(700+i,ChartSymbol())==0 && JudgeMagicNumberExit(700+OrderLotCount,ChartSymbol())==0 ){ 
         OpenLong(0.01,700+i,stoploss,takeprofit,ChartSymbol());   
         
      }
      
   }
   stoploss=NormalizeDouble(Ask-50*Point*PointUnit,Digits); //CurLowPrice_1;//NormalizeDouble(Ask-50*Point*PointUnit,Digits); 
   for(i=1;i<=OrderLotCount;i++){
   takeprofit=NormalizeDouble(Ask+2*i*Point*PointUnit,Digits);        
   if(JudgeMagicNumberExit(800+i,ChartSymbol())==0 && JudgeMagicNumberExit(800+OrderLotCount,ChartSymbol())==0 ){ 
         OpenLong(0.01,800+i,stoploss,takeprofit,ChartSymbol());   
         
      }
      
   }   
   
}
void LongTermTrade(int mn=1){
   double stoploss=0;
   double takeprofit;
   stoploss=B_MA3_0;
   takeprofit=NormalizeDouble(Ask+100*Point*PointUnit,Digits);        
   if(JudgeMagicNumberExit(mn,ChartSymbol())==0  ){ 
     OpenLong(0.01,mn,stoploss,takeprofit,ChartSymbol());   
   }   
   
   stoploss=B_MA3_0;
   takeprofit=NormalizeDouble(Ask+200*Point*PointUnit,Digits);        
   if(JudgeMagicNumberExit(mn+1,ChartSymbol())==0  ){ 
     OpenLong(0.01,mn+1,stoploss,takeprofit,ChartSymbol());   
   }   

   stoploss=B_MA3_0;
   takeprofit=NormalizeDouble(Ask+300*Point*PointUnit,Digits);        
   if(JudgeMagicNumberExit(mn+2,ChartSymbol())==0  ){ 
     OpenLong(0.01,mn+2,stoploss,takeprofit,ChartSymbol());   
   }   

   stoploss=B_MA3_0;
   takeprofit=NormalizeDouble(Ask+400*Point*PointUnit,Digits);        
   if(JudgeMagicNumberExit(mn+3,ChartSymbol())==0  ){ 
     OpenLong(0.01,mn+3,stoploss,takeprofit,ChartSymbol());   
   }   


   stoploss=MA3_1;//NormalizeDouble(Bid+8*Point*PointUnit,Digits);
   takeprofit=NormalizeDouble(Bid-100*Point*PointUnit,Digits);        
   if(JudgeMagicNumberExit(mn+10,ChartSymbol())==0  ){ 
      OpenShort(0.01,mn+10,stoploss,takeprofit,ChartSymbol());    
      
    }
   stoploss=MA3_1;//NormalizeDouble(Bid+8*Point*PointUnit,Digits);
   takeprofit=NormalizeDouble(Bid-200*Point*PointUnit,Digits);        
   if(JudgeMagicNumberExit(mn+10+1,ChartSymbol())==0  ){ 
      OpenShort(0.01,mn+10+1,stoploss,takeprofit,ChartSymbol());    
      
    }
   stoploss=MA3_1;//NormalizeDouble(Bid+8*Point*PointUnit,Digits);
   takeprofit=NormalizeDouble(Bid-300*Point*PointUnit,Digits);        
   if(JudgeMagicNumberExit(mn+10+2,ChartSymbol())==0  ){ 
      OpenShort(0.01,mn+10+2,stoploss,takeprofit,ChartSymbol());    
      
    }
   stoploss=MA3_1;//NormalizeDouble(Bid+8*Point*PointUnit,Digits);
   takeprofit=NormalizeDouble(Bid-400*Point*PointUnit,Digits);        
   if(JudgeMagicNumberExit(mn+10+3,ChartSymbol())==0  ){ 
      OpenShort(0.01,mn+10+3,stoploss,takeprofit,ChartSymbol());    
      
    }
}

void OnTimer()
{

}


void ModifyTradeStop(int TrailingStop =20 ,int TrailingStopBig =200 ,int TrailingProfit =100){
  for(int i=0;i<OrdersTotal();i++) {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()==Symbol())
        {
         if(OrderType()==OP_BUY){
           if(Bid-OrderOpenPrice() >  NormalizeDouble(TrailingStop*Point*PointUnit,Digits)){

            if(OrderStopLoss()<Bid-Point*TrailingStop*PointUnit && OrderStopLoss()!=OrderOpenPrice() && (OrderOpenPrice()+ NormalizeDouble(TrailingProfit*Point*PointUnit,Digits)) - OrderStopLoss() > 0.000001  ) 
              { 
               //printf("***%f ",OrderStopLoss()-(OrderOpenPrice()+ NormalizeDouble(TrailingProfit*Point*PointUnit,Digits )));
               bool res=OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0,Blue); 
               if(!res) 
                  Print("Buy Error in OrderModify. Error code=",GetLastError(),"MagicNumber ", OrderMagicNumber()); 
               else 
                  Print("Buy Order modified successfully."); 
             
              }
          }
          
          
           if(Bid-OrderOpenPrice() >  NormalizeDouble(TrailingStopBig*Point*PointUnit,Digits)){

            if(OrderStopLoss()<Bid-Point*TrailingStopBig*PointUnit &&  OrderStopLoss()==OrderOpenPrice() ) 
              { 
               bool res=OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()+ NormalizeDouble(TrailingProfit*Point*PointUnit,Digits),OrderTakeProfit(),0,Blue); 
               if(!res) 
                  Print("Buy Error in OrderModify. Error code=",GetLastError(),"MagicNumber ", OrderMagicNumber()); 
               else 
                  Print("Buy Order modified successfully."); 
             
              }
          }
        }  
          
          
         if(OrderType()==OP_SELL) //信号单
         {
            if(OrderOpenPrice()-Ask >  NormalizeDouble(TrailingStop*Point*PointUnit,Digits)  ){
             if(OrderStopLoss() >  NormalizeDouble(TrailingStop*Point*PointUnit,Digits)  + Ask  && OrderStopLoss()!=OrderOpenPrice() && OrderStopLoss()-( OrderOpenPrice()- NormalizeDouble(TrailingProfit*Point*PointUnit,Digits)) >0.00001   ) //double类型的等号比较方式？
              { 
               //printf("test*%f*%f*%f*%d *%d ",OrderStopLoss(),OrderStopLoss()-(OrderOpenPrice()- NormalizeDouble(TrailingProfit*Point*PointUnit,Digits)),OrderOpenPrice()- NormalizeDouble(TrailingProfit*Point*PointUnit,Digits),OrderMagicNumber(),i);
               bool res=OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice(),OrderTakeProfit(),0,Blue); 
               if(!res) 
                  Print("Sell Error in OrderModify. Error code=",GetLastError(),"MagicNumber ", OrderMagicNumber()); 
               else 
                  Print("Sell Order modified successfully. First,MagicNumber= ",OrderMagicNumber()); 
                  //printf("test*%f*%f*%f*%d *%d ",OrderStopLoss(),OrderOpenPrice(),OrderOpenPrice()- NormalizeDouble(TrailingProfit*Point*PointUnit,Digits),OrderMagicNumber(),i);
             
              }          
             
            }
            
            if(OrderOpenPrice()-Ask >  NormalizeDouble(TrailingStopBig*Point*PointUnit,Digits)){//第二次修改止损

             if(OrderStopLoss()> NormalizeDouble(Point*TrailingStopBig*PointUnit,Digits) + Ask   && OrderStopLoss()==OrderOpenPrice() ) 
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



 
double EarlyPreHighPrice_1=0,PreHighPrice_1=0,CurHighPrice_1=0; 
bool OneTimeSellFlag_1=true;
bool SellByMAJiaTuPo(int StartBar=0) {
  bool doOrder=false;
   double PriceHigh_1 ;

   switch (SellTrendStatus){
      
      case 3000:
      PriceHigh_1 =  High[iHighest(NULL,0,MODE_HIGH,1,StartBar)];
      if(PriceHigh_1 >CurHighPrice_1){
        CurHighPrice_1 =  PriceHigh_1;
        OneTimeSellFlag_1=true; 
      }
     
      break;
      
      case 3003://只有1003时两个高点有效
      if(OneTimeSellFlag_1){
         EarlyPreHighPrice_1=PreHighPrice_1;
         PreHighPrice_1=CurHighPrice_1;
         CurHighPrice_1=0;//不复位的话会记住过去高点，不更新后期的高点
         OneTimeSellFlag_1=false;
      }
      break;
      
      default:
         EarlyPreHighPrice_1=0;PreHighPrice_1=0;CurHighPrice_1=0;      
      break;
   }
  // printf("TrendStatus %d  ,%f ,%f ,%f ",TrendStatus,CurHighPrice_1,EarlyPreHighPrice_1,PreHighPrice_1);   

   UpLinePrice=PreHighPrice;
   MiddleLinePrice=EarlyPreHighPrice;

   double M2_M3= MA2_1-MA3_1;
   double M2x_M3x= MA2_x-MA3_x;    
   if( CurHighPrice_1 > PreHighPrice_1 && CurHighPrice_1 -  PreHighPrice_1 <  NormalizeDouble(50*Point*PointUnit,Digits) &&   Bid < MA1_0 && Bid - MA3_1 >  NormalizeDouble(80*Point*PointUnit,Digits) &&  SellTrendStatus==3000   ) 
   {
      //夹角
      //if( M2_M3 < M2x_M3x )  
      doOrder = true; //假突破
   
   }
   
  

  return doOrder;
  
}

double EarlyPreHighPrice=0,PreHighPrice=0,CurHighPrice=0; 
bool OneTimeSellFlag=true;

bool SellByMA(int StartBar=0) {
   bool doOrder=false;
   double PriceHigh ;
   switch (SellTrendStatus){
      
      case 3000:
      PriceHigh =  High[iHighest(NULL,0,MODE_HIGH,1,StartBar)];
      if(PriceHigh >CurHighPrice){
        CurHighPrice =  PriceHigh;
        OneTimeSellFlag=true; 
      }
     
      break;
      
      case 3003://只有1003时两个高点有效
      if(OneTimeSellFlag){
         EarlyPreHighPrice=PreHighPrice;
         PreHighPrice=CurHighPrice;
         CurHighPrice=0;//不复位的话会记住过去高点，不更新后期的高点
         OneTimeSellFlag=false;
      }
      break;
      
      default:
         EarlyPreHighPrice=0;PreHighPrice=0;CurHighPrice=0;      
      break;
   }
   //printf("TrendStatus %d  ,%f ,%f ,%f ",TrendStatus,CurHighPrice,EarlyPreHighPrice,PreHighPrice);   
  
   UpLinePrice=PreHighPrice;
   MiddleLinePrice=EarlyPreHighPrice;
 
//   if(JudgeMagicNumberExit(200+OrderLotCount,ChartSymbol())!=0)    return doOrder; //240卖单总是更高   
   if(JudgeMagicNumberExit(200+3,ChartSymbol())!=100 && JudgeMagicNumberExit(200+OrderLotCount,ChartSymbol())==100) {   //240盈利时加仓  

     if( EarlyPreHighPrice < PreHighPrice && NormalizeDouble(40*Point*PointUnit,Digits)   > PreHighPrice -EarlyPreHighPrice && SellTrendStatus==3003   )          doOrder=true;
   }
   return doOrder;
  
}

double EarlyPreLowPrice=10000,PreLowPrice=10000,CurLowPrice=10000; 
bool OneTimeBuyFlag=true;
bool BuyMA(int StartBar=0){
   bool doOrder=false;  
   double PriceLow ;

   switch (TrendStatus){
      
      case 1000:
      PriceLow = Low[iLowest(NULL,0,MODE_LOW,1,StartBar)]; 
      if(PriceLow<CurLowPrice) {
        CurLowPrice =  PriceLow;
        OneTimeBuyFlag=true;  
      }
  
      break;
      
      case 1002://只有1002时两个低点有效
      if(OneTimeBuyFlag){
       EarlyPreLowPrice=PreLowPrice;
       PreLowPrice=CurLowPrice;
       CurLowPrice=10000;
       OneTimeBuyFlag=false;     
      }

      break;
      
      default:
      EarlyPreLowPrice=10000;PreLowPrice=10000;CurLowPrice=10000;       
      break;
  
   
   }
   //printf("TrendStatus %d  ,%f ,%f ,%f ",TrendStatus,CurLowPrice,EarlyPreLowPrice,PreLowPrice);
   MiddleHLinePriceHigh=EarlyPreLowPrice; 
   DownLinePrice=PreLowPrice;     
   
  if(JudgeMagicNumberExit(100+OrderLotCount,ChartSymbol())!=0)    return doOrder;//有卖单 
  if(JudgeMagicNumberExit(200+OrderLotCount,ChartSymbol())!=0)    return doOrder;//有卖单     
  //if(JudgeMagicNumberExit(600+OrderLotCount,ChartSymbol())!=0)    return doOrder; //600买单更低
  if(JudgeMagicNumberExit(600+3,ChartSymbol())!=100 && JudgeMagicNumberExit(600+OrderLotCount,ChartSymbol())==100){    //盈利时加仓,3为盈利60点
  double M2_M3= B_MA3_0-B_MA2_0;
  double M2x_M3x= B_MA3_x-B_MA2_x; 
  if( EarlyPreLowPrice > PreLowPrice && (EarlyPreLowPrice - PreLowPrice) < NormalizeDouble(40*Point*PointUnit,Digits) &&  TrendStatus ==1002 && B_MA3_0 - Ask > NormalizeDouble(100*Point*PointUnit,Digits) && MathAbs(M2x_M3x-M2_M3) < NormalizeDouble(5*Point*PointUnit,Digits) )             doOrder=true;
   
  }
  return doOrder;  
}
  
double EarlyPreLowPrice_1=10000,PreLowPrice_1=10000,CurLowPrice_1=10000,LowPrice_1002=10000; 
bool OneTimeBuyFlag_1=true;

bool BuyMAJiaTuPo(int StartBar=0){
  bool doOrder=false;  
  if(JudgeMagicNumberExit(OrderLotCount+200,ChartSymbol())!=0)    return doOrder;   
//  if(JudgeMagicNumberExit(100+OrderLotCount,ChartSymbol())!=0)    return doOrder; 
   double PriceLow_1 ;
   switch (TrendStatus){
      
      case 1000:
      PriceLow_1 = Low[iLowest(NULL,0,MODE_LOW,1,StartBar)]; 
      if(PriceLow_1<CurLowPrice_1) {
        CurLowPrice_1 =  PriceLow_1;
        OneTimeBuyFlag_1=true;  
      }
  
      break;
      
      case 1002://只有1002时两个低点有效
      /*1002_Low = Low[iLowest(NULL,0,MODE_LOW,1,StartBar)]; 
      if(1002_Low<1002_LowPrice) {
        1002_LowPrice =  1002_Low;
       } */     
            
      if(OneTimeBuyFlag_1){
       EarlyPreLowPrice_1=PreLowPrice_1;
       PreLowPrice_1=CurLowPrice_1;
       CurLowPrice_1=10000;
       OneTimeBuyFlag_1=false;     
      }

      break;
      
      default:
      EarlyPreLowPrice_1=10000;PreLowPrice_1=10000;CurLowPrice_1=10000;       
      break;
  
   
   }
   //printf("TrendStatus %d  ,%f ,%f ,%f ,%d ,%d",TrendStatus,CurLowPrice_1,EarlyPreLowPrice_1,PreLowPrice_1,OneTimeBuyFlag_1,StartBar);
 

   if((  ( 0  < PreLowPrice_1 - CurLowPrice_1  &&  NormalizeDouble(80*Point*PointUnit,Digits)  > PreLowPrice_1 -CurLowPrice_1 ) || (( NormalizeDouble(10*Point*PointUnit,Digits)  > CurLowPrice_1 - PreLowPrice_1 &&  0  <  CurLowPrice_1 - PreLowPrice_1 ))  )   &&  TrendStatus ==1000 && Ask > B_MA1_0 && B_MA3_0 - Ask > NormalizeDouble(100*Point*PointUnit,Digits)  )
     {
        double M2_M3= B_MA3_0-B_MA2_0;
        double M2x_M3x= B_MA3_x-B_MA2_x; 
            
        if(MathAbs(M2x_M3x-M2_M3) < NormalizeDouble(5*Point*PointUnit,Digits) ) doOrder=true;//均线和趋势线夹角
         
 
     }     
   
  return doOrder;  
}  

bool BuyMATuPo(int StartBar=0){
  bool doOrder=false;  
  if(JudgeMagicNumberExit(OrderLotCount+200,ChartSymbol())!=0)    return doOrder;   

  if( (TrendStatus ==3003 ||  TrendStatus ==3000) && Ask < B_MA3_1  )
     {
         doOrder=true;
     }     
   
  return doOrder;  
}  


bool BuyMALongTerm(int StartBar=0){
   bool doOrder=false;  
//  if(JudgeMagicNumberExit(OrderLotCount+200,ChartSymbol())!=0)    return doOrder;   
//  if(JudgeMagicNumberExit(100+OrderLotCount,ChartSymbol())!=0)    return doOrder; 
/*   double PriceLow_1 ;
   switch (TrendStatus){
      
      case 1000:
      PriceLow_1 = Low[iLowest(NULL,0,MODE_LOW,1,StartBar)]; 
      if(PriceLow_1<CurLowPrice_1) {
        CurLowPrice_1 =  PriceLow_1;
        OneTimeBuyFlag_1=true;  
      }
  
      break;
      
      case 1002://只有1002时两个低点有效
      if(OneTimeBuyFlag_1){
       EarlyPreLowPrice_1=PreLowPrice_1;
       PreLowPrice_1=CurLowPrice_1;
       CurLowPrice_1=10000;
       OneTimeBuyFlag_1=false;     
      }

      break;
      
      default:
      EarlyPreLowPrice_1=10000;PreLowPrice_1=10000;CurLowPrice_1=10000;       
      break;
  
   } */
   //printf("TrendStatus %d  ,%f ,%f ,%f ,%d ,%d",TrendStatus,CurLowPrice_1,EarlyPreLowPrice_1,PreLowPrice_1,OneTimeBuyFlag_1,StartBar);
  double tmp=(B_MA3_0 + MA3_0)/2 - Ask;
  if(   NormalizeDouble(1*Point*PointUnit,Digits) < tmp && NormalizeDouble(4*Point*PointUnit,Digits) > tmp   )             doOrder=true;
    
  return doOrder;  
}  

void CloseBoTouPi(){
   if( Bid > MA2_0 + NormalizeDouble(1*Point*PointUnit,Digits) ||  ( TrendStatus==1000 ||TrendStatus==3000 ) ){
     for(int i=0;i<OrdersTotal();i++)
     {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()==Symbol())
        {
            int orderTP=OrderType();
            if(orderTP==OP_BUY  ){
               if(OrderMagicNumber()==1)    OrderClose(OrderTicket(),OrderLots(),Bid,3,clrNONE); 
            }
            if(orderTP==OP_SELL  ) 
            {
                //if(OrderMagicNumber()==11)   OrderClose(OrderTicket(),OrderLots(),Ask,3,clrNONE);     
                   
            }
        }
     }
   
   }

} 