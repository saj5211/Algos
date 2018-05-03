//+------------------------------------------------------------------+
//|                                                CloseOnProfit.mq5 |
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
  int EA_Magic = 12345;
  MqlTick latest_price; //getting recent/latest price quotes
  MqlTradeRequest mrequest; //sending our trade requests
  MqlTradeResult mresult; //get our trade result
  MqlRates mrate[]; // store prices, volumes and spread of each bar
  Print ("Here1");
  while(true){
   int total=PositionsTotal(); // number of open positions   
   //--- iterate over all open positions
   for(int i=total-1; i>=0; i--)
     {
      ulong  position_ticket=PositionGetTicket(i);
      string position_symbol=PositionGetString(POSITION_SYMBOL);
      int    digits=(int)SymbolInfoInteger(position_symbol,SYMBOL_DIGITS);            // ticket of the position
      ulong  magic=PositionGetInteger(POSITION_MAGIC);
      
      
      switch(position_symbol ==_Symbol){
      case true:
         {
         
         //--- parameters of the order
         double sl=PositionGetDouble(POSITION_SL);                                       // Stop Loss of the position
         double tp=PositionGetDouble(POSITION_TP);                                       // Take Profit of the position
         
         if(!SymbolInfoTick(position_symbol,latest_price)){
                Print("Error getting the latest price quote - error:",GetLastError(),"!!");
                return;
            }
                
                     
                     double price=(double)latest_price.bid;
                     ENUM_POSITION_TYPE type=PositionGetInteger(POSITION_TYPE);  // type of the position
      
                     
                     
                     
                     switch(((price >= tp) && (type == POSITION_TYPE_BUY))||((price <= tp) && (type == POSITION_TYPE_SELL))){
                        case true:
                           {
                          
                           //--- zeroing the request and result values
                           ZeroMemory(mrequest);
                           ZeroMemory(mresult);
                           //--- setting the operation parameters
                           
                           mrequest.action   =TRADE_ACTION_DEAL;        // type of trade operation
                           mrequest.position =PositionGetTicket(i);          // ticket of the position
                           mrequest.symbol   =position_symbol;          // symbol 
                           mrequest.volume   =PositionGetDouble(POSITION_VOLUME);    // volume of the position
                           mrequest.deviation=5;                        // allowed deviation from the price
                           mrequest.magic    =EA_Magic;             // MagicNumber of the position
                           //--- set the price and order type depending on the position type
                           switch(type)
                           {
                              case POSITION_TYPE_BUY:
                              
                              mrequest.price=SymbolInfoDouble(position_symbol,SYMBOL_BID);
                              mrequest.type =ORDER_TYPE_SELL;
                              Print ("Sold  ", position_symbol);
                              break;
                              case POSITION_TYPE_SELL:
                              mrequest.price=SymbolInfoDouble(position_symbol,SYMBOL_ASK);
                              mrequest.type =ORDER_TYPE_BUY;
                              Print ("Sold  ", position_symbol);
                              break;
                           }
                           
                           if(!OrderSend(mrequest,mresult))
                              PrintFormat("OrderSend error %d",GetLastError());  // if unable to send the request, output the error code
                           //--- information about the operation   
                          }
                          break;
                        case false:
                          break;
                        }
                          
                          
                       
                     
                
                
               }
               case false: 
           
                 break;  
           
            }
               
            }
            
            
        }
        Sleep(1);
   }
  
//+------------------------------------------------------------------+
