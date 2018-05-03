//+------------------------------------------------------------------+
//|                                               CloseAllTrades.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   
  int EA_Magic = 12345;
  MqlTick latest_price; //getting recent/latest price quotes
  MqlTradeRequest mrequest; //sending our trade requests
  MqlTradeResult mresult; //get our trade result
  MqlRates mrate[]; // store prices, volumes and spread of each bar
  while(true){
   int total=PositionsTotal(); // number of open positions   
   //--- iterate over all open positions
   for(int i=total-1; i>=0; i--)
     {
     if(!SymbolInfoTick(_Symbol,latest_price)){
                  Print("Error getting the latest price quote - error:",GetLastError(),"!!");
                  return;
      }   
      //--- parameters of the order
      ulong  position_ticket=PositionGetTicket(i);                                    // ticket of the position
      string position_symbol=PositionGetString(POSITION_SYMBOL);                      // symbol 
      int    digits=(int)SymbolInfoInteger(position_symbol,SYMBOL_DIGITS);            // ticket of the position
      ulong  magic=PositionGetInteger(POSITION_MAGIC);                                // MagicNumber of the position
      double volume=PositionGetDouble(POSITION_VOLUME);                               // volume of the position
      double sl=PositionGetDouble(POSITION_SL);                                       // Stop Loss of the position
      double tp=PositionGetDouble(POSITION_TP);                                       // Take Profit of the position
      double price=(double)latest_price.bid;
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
                  
               
               
               
               
               //--- zeroing the request and result values
               ZeroMemory(mrequest);
               ZeroMemory(mresult);
               //--- setting the operation parameters
               
               mrequest.action   =TRADE_ACTION_DEAL;        // type of trade operation
               mrequest.position =position_ticket;          // ticket of the position
               mrequest.symbol   =position_symbol;          // symbol 
               mrequest.volume   =volume;                   // volume of the position
               mrequest.deviation=5;                        // allowed deviation from the price
               mrequest.magic    =EA_Magic;             // MagicNumber of the position
               //--- set the price and order type depending on the position type
               if(type==POSITION_TYPE_BUY)
               {
                  mrequest.price=SymbolInfoDouble(position_symbol,SYMBOL_BID);
                  mrequest.type =ORDER_TYPE_SELL;
               }
               else
               {
                  mrequest.price=SymbolInfoDouble(position_symbol,SYMBOL_ASK);
                  mrequest.type =ORDER_TYPE_BUY;
               }
               //--- output information about the closure
               PrintFormat("Close #%I64d %s %s",position_ticket,position_symbol,EnumToString(type));
               //--- send the request
               if(!OrderSend(mrequest,mresult))
                  PrintFormat("OrderSend error %d",GetLastError());  // if unable to send the request, output the error code
               //--- information about the operation   
               PrintFormat("retcode=%u  deal=%I64u  order=%I64u",mresult.retcode,mresult.deal,mresult.order);
              
      
        }
   }
  }
//+------------------------------------------------------------------+
