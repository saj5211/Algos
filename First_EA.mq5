//+------------------------------------------------------------------+
//|                                                     First_EA.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

//--- input parameters
input int      StopLoss=30;
input int      TakeProfit=2;
input int      ADX_Period=8;
input int      MA_Period=8;
input int      EA_Magic = 12345;
input double   Adx_Min = 22.0;
input double   Lot = 5;


//Other parameters
int adxHandle;
int maHandle;
double plsDI[],minDI[],adxVal[];
double maVal[];
double p_close;
int STP,TKP;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   //Get handle for AFDX indicator
   adxHandle = iADX(NULL,0,ADX_Period);
   
   //Get handle for Moving Average indicator
   maHandle = iMA(_Symbol,_Period,MA_Period,0,MODE_EMA,PRICE_CLOSE);
   
   // What if handle returns invalid Handle
      if (adxHandle<0 || maHandle<0){
      Print("Error Creating Handles for Indicators ", GetLastError());
      }
   STP = StopLoss;
   TKP = TakeProfit;
   if(_Digits==5 || _Digits==3){
      STP= STP*10;
      TKP= TKP*10;
   }
   return NULL;
   
  }
  //+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   IndicatorRelease(adxHandle);
   IndicatorRelease(maHandle);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   // Is there enough bars for EA
   if (Bars(_Symbol,_Period)<60){
      Print("We have less than 60 bars, EA will now exit!!");
      return;
      };
      // We will use the static Old_Time variable to serve the bar time.
      // At each OnTick execution we will check the current bar time with the saved one.
      // If the bar time isn't equal to the saved time, it indicates that we have a new tick.
      static datetime Old_Time;
      datetime New_Time[1];
      bool isNewBar = false;
      
      // copying the last bar time to the element New_Time[0]
      int copied = CopyTime(_Symbol,_Period,0,1,New_Time);
      if (copied>0){
         if(Old_Time != New_Time[0]){
         
            isNewBar = true;
            
            };
         }
      else{
      
      Print("Error in copying hostorical times data, error =", GetLastError());
      ResetLastError();
      return;
   
      };
  
  //-- EA should only check for new trade if we have bar
  if (isNewBar==false){
   return;
   };
   
   
  //--Do we have enough bars to work with?
  int Mybars=Bars(_Symbol,_Period);
  if (Mybars < 60){
     Print("We have less than 60 bars, EA will biw exit!!");
   };
   
 
  // Define MQL5 structure that will be used to trade
  MqlTick latest_price; //getting recent/latest price quotes
  MqlTradeRequest mrequest; //sending our trade requests
  MqlTradeResult mresult; //get our trade result
  MqlRates mrate[]; // store prices, volumes and spread of each bar
  ZeroMemory(mrequest); //Initialization of mrequest structure
   /*
     Let's make sure our arrays values for the Rates, ADX Values and MA values 
     is store serially similar to the timeseries array
   */
   // the rates arrays
   ArraySetAsSeries(mrate,true);
   // the ADX DI+values array
   ArraySetAsSeries(plsDI,true);
   // the ADX DI-values array
   ArraySetAsSeries(minDI,true);
   // the ADX values arrays
   ArraySetAsSeries(adxVal,true);
   // the MA-8 values arrays
   ArraySetAsSeries(maVal,true);
      
         
   //--- Get the last price quote using the MQL5 MqlTick Structure
   if(!SymbolInfoTick(_Symbol,latest_price)){
      Print("Error getting the latest price quote - error:",GetLastError(),"!!");
      return;
   }
   
   //--- Get the details of the latest 3 bars
   if(CopyRates(_Symbol,_Period,0,3,mrate)<0){
      Print("Error copying rates/history data - error:",GetLastError(),"!!");
      return;
     }
    
   
   //mrate[1].time;   // Bar 1 Start time
   //mrate[1].open;   // Bar 1 Open price
   //mrate[0].high;   // Bar 0 (current bar) high price, etc  
   
   
   //--- Copy the new values of our indicators to buffers (arrays) using the handle
   if(CopyBuffer(adxHandle,0,0,3,adxVal)<0 || CopyBuffer(adxHandle,1,0,3,plsDI)<0
      || CopyBuffer(adxHandle,2,0,3,minDI)<0)
     {
      Print("Error copying ADX indicator Buffers - error:",GetLastError(),"!!");
      return;
     }
   if(CopyBuffer(maHandle,0,0,3,maVal)<0)
     {
      Print("Error copying Moving Average indicator buffer - error:",GetLastError());
      return;
     }
     
   //--- we have no errors, so continue
   //--- Do we have positions opened already?
   bool Buy_opened=false;  // variable to hold the result of Buy opened position
   bool Sell_opened=false; // variable to hold the result of Sell opened position
    
   if (PositionSelect(_Symbol) ==true){  // we have an opened position
     if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
         {
            Buy_opened = true;  //It is a Buy
         }
     else if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
         {
            Sell_opened = true; // It is a Sell
         }
   }
   p_close = mrate[1].close;
   /*
    1. Check for a long/Buy Setup : MA-8 increasing upwards, 
    previous price close above it, ADX > 22, +DI > -DI
*/
//--- Declare bool type variables to hold our Buy Conditions
   bool Buy_Condition_1 = (maVal[0]>maVal[1]) && (maVal[1]>maVal[2]); // MA-8 Increasing upwards
   bool Buy_Condition_2 = (p_close > maVal[1]);         // previuos price closed above MA-8
   bool Buy_Condition_3 = (adxVal[0]>Adx_Min);          // Current ADX value greater than minimum value (22)
   bool Buy_Condition_4 = (plsDI[0]>minDI[0]);          // +DI greater than -DI

//--- Putting all together   
   if(Buy_Condition_1 && Buy_Condition_2 && Sell_opened==false)
     {
      if(Buy_Condition_3 && Buy_Condition_4 )
        {
         // any opened Buy position?
         
         mrequest.action = TRADE_ACTION_DEAL;                                // immediate order execution
         mrequest.price = NormalizeDouble(latest_price.ask,_Digits);          // latest ask price
         
         mrequest.symbol = _Symbol;                                         // currency pair
         mrequest.volume = Lot;                                            // number of lots to trade
         mrequest.magic = EA_Magic;                                        // Order Magic Number
         mrequest.type = ORDER_TYPE_BUY;                                     // Buy Order
         mrequest.type_filling = ORDER_FILLING_FOK;                          // Order execution type
         mrequest.deviation=100;                                            // Deviation from current price
         //--- send order
         OrderSend(mrequest,mresult);
         // get the result code
         if(mresult.retcode==10009 || mresult.retcode==10008) //Request is completed or order placed
           {
            Print("A Buy order has been successfully placed with Ticket#:",mresult.order,"!!");
           }
         else
           {
            Print("The Buy order request could not be completed -error:",GetLastError());
            ResetLastError();           
            return;
           }
       }
      }
      
      
     /*
    2. Check for a Short/Sell Setup : MA-8 decreasing downwards, 
    previous price close below it, ADX > 22, -DI > +DI
*/
//--- Declare bool type variables to hold our Sell Conditions
   bool Sell_Condition_1 = (maVal[0]<maVal[1]) && (maVal[1]<maVal[2]);  // MA-8 decreasing downwards
   bool Sell_Condition_2 = (p_close <maVal[1]);                         // Previous price closed below MA-8
   bool Sell_Condition_3 = (adxVal[0]>Adx_Min);                         // Current ADX value greater than minimum (22)
   bool Sell_Condition_4 = (plsDI[0]<minDI[0]);                         // -DI greater than +DI
   
 //--- Putting all together
   if(Sell_Condition_1 && Sell_Condition_2 && Buy_opened==false)
       {
         if(Sell_Condition_3 && Sell_Condition_4 )
           {
            // any opened Sell position?
           
            mrequest.action = TRADE_ACTION_DEAL;                                 // immediate order execution
            mrequest.price = NormalizeDouble(latest_price.bid,_Digits);          // latest Bid price
            
            mrequest.symbol = _Symbol;                                         // currency pair
            mrequest.volume = Lot;                                            // number of lots to trade
            mrequest.magic = EA_Magic;                                        // Order Magic Number
            mrequest.type= ORDER_TYPE_SELL;                                     // Sell Order
            mrequest.type_filling = ORDER_FILLING_FOK;                          // Order execution type
            mrequest.deviation=100;                                           // Deviation from current price
            //--- send order
            OrderSend(mrequest,mresult);
            if(mresult.retcode==10009 || mresult.retcode==10008) //Request is completed or order placed
           {
            Print("A Sell order has been successfully placed with Ticket#:",mresult.order,"!!");
           }
         else
           {
            Print("The Sell order request could not be completed -error:",GetLastError());
            ResetLastError();
            return;

          }
          }
                
      
        }
     
          
 }
 
