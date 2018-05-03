//+------------------------------------------------------------------+
//|                                                     CloseAll.mq5 |
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
for (int k=1000; k>=0; k--){
  MqlTradeRequest mrequest; //sending our trade requests
  MqlTradeResult mresult; //get our trade result
  int total=PositionsTotal(); // number of open positions   
for(int i=total-1; i>=0; i--){
    //--- parameters of the order
      ulong  position_ticket=PositionGetTicket(i);                                    // ticket of the position
      string position_symbol=PositionGetString(POSITION_SYMBOL);                      // symbol 
      int    digits=(int)SymbolInfoInteger(position_symbol,SYMBOL_DIGITS);            // ticket of the position
      ulong  magic=PositionGetInteger(POSITION_MAGIC);                                // MagicNumber of the position
      double volume=PositionGetDouble(POSITION_VOLUME);                               // volume of the position
             
for(int j=0; j<i; j++)
           {
           Print("Here 1");
            
            
               Print("Here 2");   
               
               ZeroMemory(mrequest);
               ZeroMemory(mresult);
               //--- setting the operation parameters
               Print("Here 3");
               mrequest.action=TRADE_ACTION_CLOSE_BY;                         // type of trade operation
               mrequest.position=position_ticket;                             // ticket of the position
               mrequest.position_by=PositionGetInteger(POSITION_TICKET);      // ticket of the opposite position
               Print ("Sold it!!!!!");
               //request.symbol     =position_symbol;
               //--- output information about the closure by opposite position
               //PrintFormat("Close #%I64d %s %s by #%I64d",position_ticket,position_symbol,EnumToString(type),mrequest.position_by);
               //--- send the request
               if(!OrderSend(mrequest,mresult))
                 PrintFormat("OrderSend error %d",GetLastError()); // if unable to send the request, output the error code
 
               //--- information about the operation   
               //PrintFormat("retcode=%u  deal=%I64u  order=%I64u",mresult.retcode,mresult.deal,mresult.order);
               }
              }
           
        }
        
  }
//+------------------------------------------------------------------+
