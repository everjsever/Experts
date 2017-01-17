//+------------------------------------------------------------------+
//|                                            MonitoringAnother.mq4 |
//|                                          Copyright 2015, jinsong |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, jinsong"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#import "gendan.dll"
int OrderFileOpen(string);
string OrderFileClose();

#import
string             InpFileName="mtorder.csv";       // File name 
string             InpDirectoryName="d:";     // Folder name 


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int file_handle=0;
int OnInit()
  {
   EventSetMillisecondTimer(300);     
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   EventKillTimer(); 
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
      WriteOrderToFile(  CheckOrder()); 
      
  }
int curOrder=0;
int preOrder=0;  
void OnTimer()
  {
//---
   curOrder= OrdersTotal();
   if(curOrder!=preOrder){
      WriteOrderToFile(  CheckOrder()); 
      preOrder=curOrder;   
   }
  }  
//+------------------------------------------------------------------+
void WriteOrderToFile(string str="#"){
   

   ResetLastError(); 


   file_handle=OrderFileOpen(str);

   //printf("%s ,file_handle=%d",str,file_handle);
}
string CheckOrder(){
  string str="#";
  for(int i=0;i<OrdersTotal();i++)
     {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderType()==OP_BUY || OrderType()==OP_SELL ){
         str+=IntegerToString(OrderTicket())+",";
         str+=IntegerToString(OrderType())+","; 
         str+=OrderSymbol()+",";             
         str+=DoubleToString(OrderLots())+"#";      
      }
     }
     
  return str;   
}
