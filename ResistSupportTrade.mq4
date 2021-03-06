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
extern bool bOrder=false;//是否进行自动交易
bool bEquityManage=true;//是否进行资金风险管理



bool bBoTouPi=false;//是否进行均线突破交易
extern int  Limit_Step=100;//盈利单位
#include <js_include_Trend.mqh> 
     
int long_period=220;
int middle_period=220;
int OrderMaxToday=10;
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
   //JudgeBigTrend(3,5,10,long_period,100); 
   JudgeBigTrendSell(2,5,10,long_period,100);    
   InitPlatForm(); 
   if(bOrder){
   HlineStart(UpLinePrice,"Second_High");
   HlineStart(DownLinePrice,"Second_Low");
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
      HLineDelete(0,"Second_High"); 
      HLineDelete(0,"Second_Low");            
      HLineDelete(0,"First_High");    
      HLineDelete(0,"First_Low");
   }
     PrintAllOrderByMagic(200,Limit_Step,OrderLotCount);
     //PrintAllOrderByMagic(600,100,OrderLotCount);
     //PrintAllOrderByMagic(300,20,OrderLotCount);          
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
      //ModifyTradeStop(); //风险控制，移动止损      
      return;
     }
    
     if(bOrder) {
         if(ChartPeriod()!=PERIOD_H1) return ;
         OrderManage();
     } 
 


    ModifyTradeStop(); //风险控制，移动止损      
//    ModifyTradeStopSmaller(SellStop_StopLoss);//风险控制，移动止损
    Comment(StringFormat("当前亏损= %G , 图形化交易状态=%d  ==>  批量交易量= %d  \nBuy状态 = %d ==>约束条件：前2： %G ,前1：%G ,前0：%G ==>  Sell状态=%d => 约束条件=%G, %G, %G  \n日内阻力 = %G\n日内支撑 = %G \nPointUnit=%G \n当前时间=%s \n买入条件=%G \n卖出条件=%G ",NormalizeDouble(HisLoss/zhanghuzijin,3),true,OrderLotCount, TrendStatus,EarlyPreLowPrice,PreLowPrice,CurLowPrice,SellTrendStatus,EarlyPreHighPrice_1,PreHighPrice_1,CurHighPrice_1,UpLinePrice,DownLinePrice,PointUnit,TimeToString(TimeCurrent()),B_MA3_0  - Ask ,Bid - MA3_0 )); 
    
}

void OrderManage(){


    JudgeBigTrendSell(2,5,10,long_period,0); 

    if(SellByMAJiaTuPo()==true)   SellAllCaseJiaTupo();
    //SellByOrder();
    //if(SellTrendInitialStage()==true)  OrderSellTrendInitial();

    
    /*JudgeBigTrend(3,5,10,long_period,0); 
    if(BuyTrendinitialStage()==true)     OrderBuyTrendInitial();*/    
   
    //if(BuyMA()==true)     BuyAllCase();  
    //if(BuyMAJiaTuPo()==true)     OrderBuyTrendInitial(); 
     


}
void OrderSellTrendInitial(){
   double stoploss=0;
   double takeprofit;
   stoploss=NormalizeDouble(Bid+200*Point*PointUnit,Digits);//SellPrice_200;//
   int i=0;
   for(i=1;i<=OrderLotCount;i++){
   takeprofit=NormalizeDouble(Bid-Limit_Step*i*Point*PointUnit,Digits);        
   if(JudgeMagicNumberExit(100+i,ChartSymbol())==0  && JudgeMagicNumberExit(100+OrderLotCount,ChartSymbol())==0){ 
      OpenShort(0.01,100+i,stoploss,takeprofit,ChartSymbol());    
      
   }
   
   }
}
double SellPrice_200;
extern int OrderStop=25;
void SellAllCaseJiaTupo(){
   double stoploss=0;
   double takeprofit;
   int i=0;
   stoploss=NormalizeDouble(Bid+OrderStop*Point*PointUnit,Digits);//CurHighPrice_1;//
   for(i=1;i<=OrderLotCount;i++){
   takeprofit=NormalizeDouble(Bid-Limit_Step*i*Point*PointUnit,Digits);        
   if(JudgeMagicNumberExit(200+i,ChartSymbol())==0  && JudgeMagicNumberExit(200+OrderLotCount,ChartSymbol())==0 ){ 
      OpenShort(0.01,200+i,stoploss,takeprofit,ChartSymbol()); 
      SellPrice_200=Bid;   
      
   }
   
   }
}

void SellByOrder(){
   double stoploss=0;
   double takeprofit;
   stoploss=NormalizeDouble(Bid+200*Point*PointUnit,Digits);
   int i=0;
   int lotAdd=8;//OrderLotCount;
//   if(JudgeMagicNumberProfit(201,ChartSymbol())< -0.1*100 && JudgeMagicNumberProfit(201,ChartSymbol())> -0.1*110){
   if( JudgeMagicNumberProfit(201,ChartSymbol())< 0.1*100 && JudgeMagicNumberProfit(201,ChartSymbol()) > 0.1*90 ){
       for(i=1;i<=lotAdd;i++){
         takeprofit=NormalizeDouble(Bid-10*i*Point*PointUnit,Digits);        
         if(JudgeMagicNumberExit(300+i,ChartSymbol())==0  && JudgeMagicNumberExit(300+lotAdd,ChartSymbol())==0 ){ 
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
void OrderBuyTrendInitial(){


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


void OnTimer()
{

}

double OrderMaxLoss[1000],CurLoss[1000];
double OrderMaxProfit[1000],CurProfit[1000];
void ModifyTradeStop(int TrailingStop =20 ,int TrailingStopBig =300 ,int TrailingProfit =200,int MaxLoss=50){
  for(int i=0;i<OrdersTotal();i++) {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
//      if(OrderSymbol()==Symbol()&& OrderMagicNumber()!=0 )
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
            
            if(OrderOpenPrice()-Ask >  NormalizeDouble(TrailingStop*Point*PointUnit,Digits)  ){//减少回撤
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
            
            //////亏损时
             int MN=OrderMagicNumber();
             CurLoss[MN]= Ask - OrderOpenPrice();

             if(CurLoss[MN] >  NormalizeDouble(MaxLoss*Point*PointUnit,Digits)){//亏损大于设定值时
               
                if(CurLoss[MN]>OrderMaxLoss[MN]){
                  OrderMaxLoss[MN]=CurLoss[MN];//记录最大亏损
                } 
             }

            if(OrderMaxLoss[MN] > NormalizeDouble(MaxLoss*Point*PointUnit,Digits)){//亏损时
             if(CurLoss[MN]/OrderMaxLoss[MN]<0.5) {//亏损缩小
                // printf("*********%f******%f***%f*****",CurLoss[MN]/OrderMaxLoss[MN],CurLoss[MN],OrderMaxLoss[MN]);
                OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,0);
                OrderMaxLoss[MN]=0;
                CurLoss[MN]=0;
                
                }

             
             }
            //////盈利时 
            int OrderMinProfit=70;
            CurProfit[MN]= OrderOpenPrice() - Ask;
               if(CurProfit[MN] >  NormalizeDouble(OrderMinProfit*Point*PointUnit,Digits)){//盈利大于设定值时
               
               if(CurProfit[MN]>OrderMaxProfit[MN]){
                  OrderMaxProfit[MN]=CurProfit[MN];//记录最大盈利
                } 
             } 

            if(OrderMaxProfit[MN] > NormalizeDouble(OrderMinProfit*Point*PointUnit,Digits)){//盈利时
             if(CurProfit[MN]/OrderMaxProfit[MN]<0.1) {//亏损缩小
                
                OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),3,0);
                OrderMaxProfit[MN]=0;
                CurProfit[MN]=0;
                
                }

             
             }             
             
             
            /////////////////////////         
            
            
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

   UpLinePrice=PreHighPrice_1;
   MiddleLinePrice=EarlyPreHighPrice_1;

   double M2_M3= MA2_1-MA3_1;
   double M2x_M3x= MA2_x-MA3_x;
   //PreHighPrice_1=MathMax(PreHighPrice_1,EarlyPreHighPrice_1);  //效果不佳  
//   if( CurHighPrice_1 -  PreHighPrice_1 > 0 && CurHighPrice_1 -  PreHighPrice_1 <  NormalizeDouble(50*Point*PointUnit,Digits) &&   Bid < MA1_0 && Bid - MA3_1 >  NormalizeDouble(80*Point*PointUnit,Digits) &&  SellTrendStatus==3000   ) //80参数低则交易次数增多，由于高度不够胜率低
   if( CurHighPrice_1 -  PreHighPrice_1 > 0 && CurHighPrice_1 -  PreHighPrice_1 <  NormalizeDouble(50*Point*PointUnit,Digits) &&   Bid < MA1_0 &&  SellTrendStatus==3003  ) //80参数低则交易次数增多，由于高度不够胜率低

   {
      //夹角
      //if( M2_M3 < M2x_M3x )  
      doOrder = true; //假突破
   
   }
  
 // if(MathAbs(PreHighPrice_1-EarlyPreHighPrice_1)>NormalizeDouble(80*Point*PointUnit,Digits))   doOrder = false;  //避开强势,过于优化
  

  return doOrder;
  
}

double EarlyPreHighPrice=0,PreHighPrice=0,CurHighPrice=0; 
bool OneTimeSellFlag=true;

bool SellTrendInitialStage(int StartBar=0) {
  bool doOrder=false;
  double tmp=Bid-MA3_0 ;
  if(   NormalizeDouble(100*Point*PointUnit,Digits) < tmp && NormalizeDouble(106*Point*PointUnit,Digits) > tmp  &&   SellTrendStatus == 3003   )  {
         doOrder=true;
        // printf("Sell:  SellTrendStatus= %d , %d",SellTrendStatus,TrendStatus);         
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

bool BuyTrendinitialStage(int StartBar=0){
  bool doOrder=false;  
  if(JudgeMagicNumberExit(OrderLotCount+200,ChartSymbol())!=0)    return doOrder;   

  double tmp=B_MA3_0  - Ask;
  if(   NormalizeDouble(100*Point*PointUnit,Digits) < tmp && NormalizeDouble(104*Point*PointUnit,Digits) > tmp  && SellTrendStatus != 1000 ) 
    {
         doOrder=true;
        // printf("buy:  SellTrendStatus= %d , %d",SellTrendStatus,TrendStatus);   
     }     
   
  return doOrder;  
}  



