//+------------------------------------------------------------------+
//|                                        RocAndDeviationExpert.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

input int      EA_Magic = 12345;
input double   Lot = 0.1;
input double   threshold = 5;

double price;


double sdRoc;
double total;
double avg;



int OnInit()
  {
//---
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
     
     int Mybars= Bars(_Symbol, _Period);
     if (Mybars <60){
         Print("Don't have enough bars");
         return;
         }
     
     MqlTick latest_price; //getting recent/latest price quotes
     MqlTradeRequest mrequest; //sending our trade requests
     MqlTradeResult mresult; //get our trade result
     MqlRates mrate[]; // store prices, volumes and spread of each bar
     ZeroMemory(mrequest); //Initialization of mrequest structure
     ArraySetAsSeries(mrate,true);
     if(!SymbolInfoTick(_Symbol,latest_price)){
      Print("Error getting the latest price quote - error:",GetLastError(),"!!");
      return;
     }
     
     //--- Get the details of the latest 3 bars
     if(CopyRates(_Symbol,_Period,0,60,mrate)<0){
        Print("Error copying rates/history data - error:",GetLastError(),"!!");
        return;
     } 
     double roc[sizeof(mrate)];
     int i=0;
     for (i=1; i<sizeof(mrate); i++){
         double first = mrate[i-1].open;
         double second = mrate[i].open;
         
         roc[i] = ((second - first)/2.0);
         avg = (avg + mrate[i].open);
     }
     avg = avg/sizeof(mrate);
     
     for (int j=1; j<sizeof(roc); j++){
         
         Print (j," ", roc[j]," " ,sizeof(roc));
         total = (total + pow((roc[j]-avg),2));
         
     }
     sdRoc = sqrt(total/(sizeof(roc)-1));
     Print (sdRoc);
  }
//+------------------------------------------------------------------+
