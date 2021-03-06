
//////////////////////////////////////////////////////////////////////
#ifdef __MQL5__
//bool His =false;
//bool PositionOpened = false;

#define DoubleToStr DoubleToString
#define TimeToStr TimeToString
#define StrToTime StringToTime 

int Digits=_Digits;
double High[],Low[],Open[],Close[];
double Ask,Bid;
datetime Time[];

extern int ArrayMax=MathMax(shift1,shift2)+1;


#define ObjectSetText(x, y, z,a, b) \      
      ObjectSetInteger(0,x,OBJPROP_COLOR,b); \
      ObjectSetString(0,x,OBJPROP_TEXT, y); \
      ObjectSetString(0,x,OBJPROP_FONT,a); \
      ObjectSetInteger(0,x,OBJPROP_FONTSIZE,z); 

int TimeMinute(datetime T){
   MqlDateTime dow;
   TimeToStruct(T,dow);
   return(dow.min);
}

int TimeHour(datetime T){
   MqlDateTime dow;
   TimeToStruct(T,dow);
   return(dow.hour);
}

int TimeDayOfWeek(datetime T){
   MqlDateTime dow;
   TimeToStruct(T,dow);
   return(dow.day_of_week);
}

double AccountBalance(){
   return(0);
}

#define MODE_POINT 11
#define MODE_STOPLEVEL 14
#define MODE_LOTSIZE 15
#define MODE_TICKVALUE 16
#define MODE_TICKSIZE 17
#define MODE_MINLOT 23
#define MODE_LOTSTEP 24
#define MODE_MAXLOT 25

double MarketInfo(string symbol,int type){
   return(0);
}

string OrderSymbol(){
   return(OrderGetString(ORDER_SYMBOL));
}
int OrderMagicNumber(){
   return(OrderGetInteger(ORDER_MAGIC));
}
int OrderType(){
   return(OrderGetInteger(ORDER_TYPE));
}
double OrderOpenPrice(){
   return(OrderGetDouble(ORDER_PRICE_OPEN));
}
double OrderClosePrice(){
   return(0);//need to modified需要修改
}
double OrderProfit(){
   return(PositionGetDouble(POSITION_PROFIT));//need to modified需要修改
}
double OrderStopLoss(){
   return(OrderGetDouble(ORDER_SL));
}
double OrderTakeProfit(){
   return(OrderGetDouble(ORDER_TP));
}
double OrderLots(){
   return(OrderGetDouble(ORDER_VOLUME_CURRENT));
}
bool RefreshRates(){
   return(true);//
}
bool IsTradeAllowed(){
   return(TerminalInfoInteger(TERMINAL_TRADE_ALLOWED));
}
int OrdersHistoryTotal(){
   //His=true;
   return(HistoryOrdersTotal());
}
datetime OrderOpenTime(){
   return(OrderGetInteger(ORDER_TIME_DONE));
}
datetime OrderCloseTime(){
   return(OrderGetInteger(ORDER_TIME_DONE));//need to modified需要修改
}

int OrderTicket(){
  return(OrderGetInteger(ORDER_TICKET));
}

#define SELECT_BY_POS 0
#define SELECT_BY_TICKET 1
bool OrderSelect(int index,int select){
   //His=false;
   if( select==SELECT_BY_POS) return(OrderSelect(OrderGetTicket(index)));   
   else if( select==SELECT_BY_TICKET) return(OrderSelect(index));
   else return(false);
}
#define MODE_TRADES 0
#define MODE_HISTORY 1
bool OrderSelect(int index,int select,int pool){
   if( pool == MODE_HISTORY && select==SELECT_BY_POS)  return(HistoryOrderSelect(HistoryOrderGetTicket(index))); //need to modified需要修改
   else if( pool == MODE_HISTORY && select==SELECT_BY_TICKET)  return(HistoryOrderSelect(index)); //need to modified需要修改
   else if( pool==MODE_TRADES && select==SELECT_BY_POS) {//His=false;
            return(OrderSelect(OrderGetTicket(index)));}   
   else if( pool==MODE_TRADES && select==SELECT_BY_TICKET) {//His=false;
            return(OrderSelect(index));}
   else return(false);
}

#define OP_BUY ORDER_TYPE_BUY
#define OP_SELL ORDER_TYPE_SELL
#define OP_BUYSTOP ORDER_TYPE_BUY_STOP
#define OP_SELLSTOP ORDER_TYPE_SELL_STOP
#define OP_BUYLIMIT ORDER_TYPE_BUY_LIMIT
#define OP_SELLLIMIT ORDER_TYPE_SELL_LIMIT
MqlTradeRequest  request;      // query structure 
MqlTradeResult   result;        // structure of the answer 

int  OrderSend( 
   string   symbol,              // symbol 
   int      cmd,                 // operation 
   double   volume,              // volume 
   double   price,               // price 
   int      slippage,            // slippage 
   double   stoploss,            // stop loss 
   double   takeprofit,          // take profit 
   string   comment=NULL,        // comment 
   int      magic=0,             // magic number 
   datetime expiration=0,        // pending order expiration 
   color    arrow_color=clrNONE  // color 
   ){
   request.symbol=symbol;
   request.type=cmd;
   if(cmd==OP_BUY ||cmd==OP_SELL) request.action=TRADE_ACTION_DEAL;
   else request.action=TRADE_ACTION_PENDING;
   request.volume=volume;
   request.price=price;
   request.deviation=slippage;
   request.sl=stoploss;
   request.tp=takeprofit;
   request.comment=comment;
   request.magic=magic;
   request.expiration=expiration;
   OrderSend(request,result);   
   return(result.order);
}

bool  OrderClose( 
   int        ticket,      // ticket 
   double     lots,        // volume 
   double     price,       // close price 
   int        slippage    // slippage 
   ){
   request.order=ticket;
   request.action=TRADE_ACTION_DEAL;   
   request.volume=lots;
   request.price=price;
   request.deviation=slippage;
   if(OrderGetInteger(ORDER_TYPE)==ORDER_TYPE_BUY) request.type=ORDER_TYPE_SELL;
   if(OrderGetInteger(ORDER_TYPE)==ORDER_TYPE_SELL) request.type=ORDER_TYPE_BUY;
   return(OrderSend(request,result) );
}

bool OrderDelete(int ticket){
   request.action=TRADE_ACTION_REMOVE ;
   request.order=ticket;
   return(OrderSend(request,result));
}

bool  OrderModify( 
   int        ticket,      // ticket 
   double     price,       // price 
   double     stoploss,    // stop loss 
   double     takeprofit,  // take profit 
   datetime   expiration,  // expiration 
   color      arrow_color  // color 
   ){
   request.order=ticket;
   request.price=price;
   request.sl=stoploss;
   request.tp=takeprofit;
   request.expiration=expiration;
   return(OrderSend(request,result));
}

bool  OrderModify( 
   int        ticket,      // ticket 
   double     price,       // price 
   double     stoploss,    // stop loss 
   double     takeprofit,  // take profit 
   datetime   expiration  // expiration 
   ){
   request.order=ticket;
   request.price=price;
   request.sl=stoploss;
   request.tp=takeprofit;
   request.expiration=expiration;
   return(OrderSend(request,result));
}

//////////////////////////////////////

int OnTick(void){

   Ask=SymbolInfoDouble(Symbol(),SYMBOL_ASK);
   Bid=SymbolInfoDouble(Symbol(),SYMBOL_BID); 

   int copied = CopyHigh(Symbol(), Period() ,0,ArrayMax,High);
   copied = CopyLow(Symbol(), Period() ,0,ArrayMax,Low);
   copied = CopyLow(Symbol(), Period() ,0,ArrayMax,Close);
   copied = CopyLow(Symbol(), Period() ,0,ArrayMax,Open);

   CopyTime(Symbol(),Period(),0,1,Time);

#else
int start() {
#endif





//////////////////////////////////////////////////////////////////////////////////////////








































////////////////////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////
#ifdef __MQL5__
int OnInit() {

ArrayResize(High,ArrayMax);
ArrayResize(Low,ArrayMax);
ArrayResize(Close,ArrayMax);
ArrayResize(Open,ArrayMax);

ArraySetAsSeries(High,true);
ArraySetAsSeries(Low,true);
ArraySetAsSeries(Close,true);
ArraySetAsSeries(Open,true);

ArrayResize(Time,1);
ArraySetAsSeries(Time,true);

#else
int init() {
#endif 
//////////////////////////////////////////////////////////////////////