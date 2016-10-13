////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//|Caution:
//|All performance tested with this Indicator/EA are regarded as hypothetical.
//|Before using this Indicator/EA on real account, you should be aware that there is often a vast
//|difference between hypothetical results and real-life trading results achievable in a real brokerage
//|account, and real-live results are almost always vastly worse than hypothetical results. 
//|Performance results for strategies in this Indicator/EA may not take into account fees,spreads and/or trading commissions that may be charged by your broker. 
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//|Copy-Right Claim:
//|Without the official permission of Robbie Ruan (robbie.ruan@gmail.com), you must not recopy or deliver this Indicator/EA's execution file,
//|or all/part of its source code, or sell this Indicator/EA, or used for any commercial purpose, or change the copyright, and you must not delete this copy-right claim. 
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//+------------------------------------------------------------------+
//|                                           HistoryEquityCurve.mq4 |
//|                                                     Robbie Ruan  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015.9.30 Robbie Ruan Ver0.06"
#property link      "robbie.ruan@gmail.com"

#property indicator_separate_window
#property indicator_buffers   2

#property indicator_color1    clrOrange
#property indicator_color2    clrRed


extern string StartTradeTime="2015.09.03 00:00";
 
extern double InitialDeposit = 5000;

extern double Offset = 0;                
extern string Note1 = "Equity in Chocolate, Balance in Red";

extern string Copyright ="Robbie.Ruan@gmail.com V0.07 2015.10.10";

double   Equity[];
double   Balance[];

datetime StartTime;


//int LisenceStartTime = D'31.12.2009 11:30';
  int LisenceEndTime = D'30.05.2017 00:00';

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE,EMPTY,STYLE_DOT);
   SetIndexBuffer(0,Equity);
   IndicatorDigits(2);


   SetIndexStyle(1,DRAW_LINE,EMPTY,STYLE_DASH);
   SetIndexBuffer(1,Balance);   
   IndicatorDigits(2);

   SetIndexLabel(0,"Equity");
   SetIndexLabel(1,"Balance");
   
   StartTime=StrToTime(StartTradeTime);
  
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
  
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int BarNumber, StartBar;
   
   if (TimeCurrent() >= LisenceEndTime )
   {
      Print("Time Expired, please contact robbie.ruan@gmail.com");
      Alert("Time Expired, please contact robbie.ruan@gmail.com");
      return(0);
   }
   
   int   symbolPeriod = Period();
   datetime BarTimeLast  = Time[1]-Time[2];
      
   StartBar = iBarShift(Symbol(),symbolPeriod,StartTime,false);
      
   for(BarNumber=StartBar;BarNumber>=0;BarNumber--)
     {
         //Equity[BarNumber] = CalcDynamicEquity(BarNumber,symbolPeriod, BarTimeLast);
         CalcDynamicEquity(BarNumber,symbolPeriod, BarTimeLast);
     }
     
   Sleep(500);
//----
   return(0);
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------------------------------------------------------------------------------+
//+------------------------------------------------------------------------------------------------------------------------------------------+
//+------------------------------------------------------------------------------------------------------------------------------------------+


double CalcDynamicEquity(int BarNumber, int symbolPeriod, datetime BarTimeLast)
  {
  
   //double   Result;
   datetime OpenTimeOfHistoryBar = Time[BarNumber];
   datetime CloseTimeOfHistoryBar = OpenTimeOfHistoryBar + BarTimeLast;
      
   int      TotalHistoryOrders = OrdersHistoryTotal();
   int      TotalOpenOrders;
   
   double   SumClosedOrdersDynamicProfit = 0;
   double   SumOpenOrdersDynamicProfit   = 0;
   
   double   SumClosedProfitBeforeThisBar = 0;
   int      TotalTradedSymbols = 0;
   
   int      orderType;
   double   orderLots;
   string   orderSymbol;
   double   PositionCost;
   datetime orderOpenTime;
   datetime orderCloseTime;  
   
   for(int i=0;i<TotalHistoryOrders;i++)      
   {
      if( OrderSelect(i,SELECT_BY_POS,MODE_HISTORY) == false )
      {
         continue;
      }

      orderType   = OrderType();
      
      //to increase execution efficiency, filter out limit/stop orders.
      if(orderType == OP_BUYLIMIT || orderType == OP_BUYSTOP || orderType == OP_SELLLIMIT || orderType == OP_SELLSTOP)
      {
         continue;
      }
      
      orderOpenTime  = OrderOpenTime();
      orderCloseTime = OrderCloseTime();    
//+----------------------------------------------------------------------------+   
      if( orderOpenTime >= StartTime && (orderCloseTime > CloseTimeOfHistoryBar) && (orderOpenTime <= CloseTimeOfHistoryBar) )    
      {
         orderLots      = OrderLots();
         orderSymbol    = OrderSymbol();       
         PositionCost   = OrderOpenPrice();
         
         SumClosedOrdersDynamicProfit += CalculateOrderProfit(orderType,orderLots,orderSymbol,PositionCost,symbolPeriod,CloseTimeOfHistoryBar);

      }
      //+----------------------------------------------------------------------------
      //end Calculate closed orders dynamic profit
      
      //+----------------------------------------------------------------------------
      // Calculate closed orders profit before calculating the bar
      else if( orderOpenTime >= StartTime && orderCloseTime <= CloseTimeOfHistoryBar )
      {
         if(orderType == OP_BUY || orderType == OP_SELL)
         {
            SumClosedProfitBeforeThisBar += OrderProfit() + OrderSwap() + OrderCommission();
         }
      }
//+----------------------------------------------------------------------------+

   } // end for calculating TotalHistoryOrders
   

//+----------------------------------------------------------------------------+
//+----------------------------------------------------------------------------+
//+----------------------------------------------------------------------------+
//Calculate profit of unclosed orders

   if(BarNumber == 0)
   {
      SumOpenOrdersDynamicProfit = AccountInfoDouble(ACCOUNT_PROFIT);
   }
   else //means BarNumber = StartBar-->1
   {
      TotalOpenOrders = OrdersTotal();
      //Print("TotalOpenOrders=================",TotalOpenOrders);
      for(int k=0;k<TotalOpenOrders;k++)      
      {
         if( OrderSelect(k,SELECT_BY_POS,MODE_TRADES) == false )
         {
            continue;
         }
         orderType   = OrderType();
         if(orderType == OP_BUY || orderType == OP_SELL)
         { 

            orderOpenTime  = OrderOpenTime();
            //orderCloseTime = OrderCloseTime();
            //Print("orderCloseTime==================",orderCloseTime);
            //Print("orderOpenTime================================",orderOpenTime);
            if( orderOpenTime >= StartTime && orderOpenTime <= OpenTimeOfHistoryBar )
            {
               orderLots      = OrderLots();
               orderSymbol    = OrderSymbol();       
               PositionCost   = OrderOpenPrice();         
               SumOpenOrdersDynamicProfit += CalculateOrderProfit(orderType,orderLots,orderSymbol,PositionCost,symbolPeriod,CloseTimeOfHistoryBar);
            }
         }
      }
   }
   
   //Print("SumOpenOrdersDynamicProfit===========================================",SumOpenOrdersDynamicProfit);

//+----------------------------------------------------------------------------+
//end Calculate profit of unclosed orders
//+----------------------------------------------------------------------------+
//+----------------------------------------------------------------------------+
//+----------------------------------------------------------------------------+

   //Print("AccountInfoDouble(ACCOUNT_PROFIT)======================",AccountInfoDouble(ACCOUNT_PROFIT));
   Balance[BarNumber] = SumClosedProfitBeforeThisBar + InitialDeposit + Offset;   
   Equity[BarNumber]  = Balance[BarNumber] + SumClosedOrdersDynamicProfit+ SumOpenOrdersDynamicProfit;  

   //Result = SumClosedProfitBeforeThisBar + SumClosedOrdersDynamicProfit+ SumOpenOrdersDynamicProfit + InitialDeposit + Offset;        
   //Result = NormalizeDouble(Result,2);
   return(0);    
}   
   
//+------------------------------------------------------------------------------------------------------------------------------------------+
//+------------------------------------------------------------------------------------------------------------------------------------------+
//+------------------------------------------------------------------------------------------------------------------------------------------+


double CalculateOrderProfit(int orderType, double orderLots, string orderSymbol, double PositionCost, int symbolPeriod, datetime CloseTimeOfHistoryBar )
{
   double ProfitInUSD;
   double ProfitInBaseCurrency;
         
   //PositionCost = OrderOpenPrice();
    
   double Units = orderLots * MarketInfo(orderSymbol,MODE_LOTSIZE);
    
   double DynamicClosePrice = iClose(orderSymbol,symbolPeriod,iBarShift(orderSymbol,symbolPeriod,CloseTimeOfHistoryBar,false));
   //Print("iBarShift(orderSymbol,symbolPeriod,CloseTimeOfHistoryBar + (Time[1] - Time[2]),false)================",iBarShift(orderSymbol,symbolPeriod,CloseTimeOfHistoryBar + (Time[1] - Time[2]),false));
  
   double SpreadCost = MarketInfo(orderSymbol,MODE_POINT) * MarketInfo(orderSymbol,MODE_SPREAD);

   //Print("MODE_TICKVALUE===",MarketInfo(orderSymbol,MODE_TICKVALUE));
   if(orderType == OP_BUY)
   {      
      ProfitInBaseCurrency = Units * ( DynamicClosePrice - PositionCost - SpreadCost );
   }
      
   else if(orderType == OP_SELL)
   {
      ProfitInBaseCurrency = Units * ( PositionCost - DynamicClosePrice - SpreadCost );
   }
    
    
   string BaseCurrency = StringSubstr(orderSymbol,3,3);
   //Print("BaseCurrency=====",BaseCurrency);
    
   if(BaseCurrency=="USD")      ProfitInUSD = ProfitInBaseCurrency;
   else if(BaseCurrency=="GBP") ProfitInUSD = ProfitInBaseCurrency * iClose("GBPUSD",symbolPeriod,iBarShift("GBPUSD",symbolPeriod,CloseTimeOfHistoryBar,false));
   else if(BaseCurrency=="AUD") ProfitInUSD = ProfitInBaseCurrency * iClose("AUDUSD",symbolPeriod,iBarShift("AUDUSD",symbolPeriod,CloseTimeOfHistoryBar,false));
   else if(BaseCurrency=="NZD") ProfitInUSD = ProfitInBaseCurrency * iClose("NZDUSD",symbolPeriod,iBarShift("NZDUSD",symbolPeriod,CloseTimeOfHistoryBar,false));
   else if(BaseCurrency=="CHF") ProfitInUSD = ProfitInBaseCurrency / iClose("USDCHF",symbolPeriod,iBarShift("USDCHF",symbolPeriod,CloseTimeOfHistoryBar,false));
   else if(BaseCurrency=="CAD") ProfitInUSD = ProfitInBaseCurrency / iClose("USDCAD",symbolPeriod,iBarShift("USDCAD",symbolPeriod,CloseTimeOfHistoryBar,false));
   else if(BaseCurrency=="JPY") ProfitInUSD = ProfitInBaseCurrency / iClose("USDJPY",symbolPeriod,iBarShift("USDJPY",symbolPeriod,CloseTimeOfHistoryBar,false));
    
   else
   {
      Print("ERROR: Symbol ",orderSymbol," Not Included");
      Alert("ERROR: Symbol ",orderSymbol," Not Included");
      return(-1);
   }
   
   return(ProfitInUSD);
}
