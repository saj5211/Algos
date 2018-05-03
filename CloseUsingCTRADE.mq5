//+------------------------------------------------------------------+
//|                                             CloseUsingCTRADE.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Trade\Trade.mqh>
//--- object of class CTrade
CTrade trade;
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
int EA_Magic = 12345;
  
  int i=1;
  while(i>0){
   int total=PositionsTotal();
   i = total; // number of open positions   
   //--- iterate over all open positions
   for(int i=total-1; i>=0; i--)
     {
      MqlTick latest_price; //getting recent/latest price quotes
      MqlTradeRequest mrequest; //sending our trade requests
      MqlTradeResult mresult; //get our trade result
  
      //--- parameters of the order
      ulong  position_ticket=PositionGetTicket(i);                                    // ticket of the position
      string position_symbol=PositionGetString(POSITION_SYMBOL);                      // symbol 
      int    digits=(int)SymbolInfoInteger(position_symbol,SYMBOL_DIGITS);            // ticket of the position
      ulong  magic=PositionGetInteger(POSITION_MAGIC);
      double profit = PositionGetDouble(POSITION_PROFIT);                                // MagicNumber of the position
      double volume=PositionGetDouble(POSITION_VOLUME);                               // volume of the position
                                             // Take Profit of the position
      if (Symbol()==position_symbol){
      
      ENUM_POSITION_TYPE type=PositionGetInteger(POSITION_TYPE);  // type of the position
      //--- output information about the position
      /*PrintFormat("#%I64u %s  %s  %.2f  %s  sl: %s  tp: %s  [%I64d]",
                  position_ticket,
                  position_symbol,
                  EnumToString(type),
                  volume,
                  DoubleToString(PositionGetDouble(POSITION_PRICE_OPEN),digits),
                  DoubleToString(sl,digits),
                  DoubleToString(tp,digits),
                  magic);*/
                  
               
               
               
               if (profit >=5*volume){
               Print(profit, " ", position_ticket," ", position_symbol);
               //--- zeroing the request and result values
               ZeroMemory(mrequest);
               ZeroMemory(mresult);
               //--- setting the operation parameters
               trade.PositionClose(position_ticket);
                              //--- output information about the closure
               
              
            }
            }
        }
   }
   
  }
//+------------------------------------------------------------------+
