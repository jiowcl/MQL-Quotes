//+------------------------------------------------------------------+
//|                                            JiowclQuoteServer.mq5 |
//|                                Copyright 2017-2021, Ji-Feng Tsai |
//|                                        https://github.com/jiowcl |
//+------------------------------------------------------------------+
#property copyright          "Copyright 2021, Ji-Feng Tsai"
#property link               "https://github.com/jiowcl/MQL-Quotes"
#property version            "1.00"
#property description        "MT5 Quote export application. Push all quotes price to subscribers."
#property strict
#property script_show_inputs

#include <Zmq/Zmq.mqh>

//--- Inputs
input string Server                  = "tcp://*:5559";  // Push server ip
input uint   ServerDelayMilliseconds = 300;             // Push to clients delay milliseconds (Default is 300)
input bool   ServerReal              = false;           // Under real server (Default is false)
input string AllowSymbols            = "";              // Allow Trading Symbols (Ex: EURUSDq,EURUSDx,EURUSDa)
input bool   OnlyInMarketWatch       = true;            // Only push the symbols in marketwatch (Default is true)

//--- Globales Struct
struct Symbols
  {
    double bid;
    double ask;
    double point;
    int    digits;
    int    spread;
  };

//--- Globales Application
const string app_name    = "Jiowcl Expert Advisor";

//--- Globales ZMQ
Context context;
Socket  publisher(context, ZMQ_PUB);

string zmq_server        = "";
uint   zmq_pushdelay     = 0;
bool   zmq_runningstatus = false;

//--- Globales Symbol
int     symbolinfosize      = 0;
bool    symbolinmarketwatch = false;
Symbols symbolinfo[];

int     prev_symbolinfosize = 0;

//--- Globales File
string  local_symbolallow[];
int     symbolallow_size = 0;

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {  
    if (DetectEnvironment() == false)
      {
        Alert("Error: The property is fail, please check and try again.");
        return;
      }
      
    StartZmqServer();
    StopZmqServer();
  }

//+------------------------------------------------------------------+
//| Detect the script parameters                                     |
//+------------------------------------------------------------------+
bool DetectEnvironment()
  {
    if (Server == "") 
      return false;
    
    ENUM_ACCOUNT_TRADE_MODE accountTradeMode = (ENUM_ACCOUNT_TRADE_MODE) AccountInfoInteger(ACCOUNT_TRADE_MODE);
    
    if (ServerReal == true && accountTradeMode == ACCOUNT_TRADE_MODE_DEMO)
      {
        Print("Account is Demo, please switch the Demo account to Real account.");
        return false;
      }
      
    if ((bool) TerminalInfoInteger(TERMINAL_DLLS_ALLOWED) == false)
      {
        Print("DLL call is not allowed. ", app_name, " cannot run.");
        return false;
      }
    
    zmq_server          = Server;
    zmq_pushdelay       = (ServerDelayMilliseconds > 0) ? ServerDelayMilliseconds : 10;
    zmq_runningstatus   = false;
    symbolinmarketwatch = OnlyInMarketWatch;
    
    // Load the Symbol allow map
    if (AllowSymbols != "")
      {
        string symboldata[];
        int    symbolsize  = StringSplit(AllowSymbols, ',', symboldata);
        int    symbolindex = 0;
        
        ArrayResize(local_symbolallow, symbolsize);
        
        for (symbolindex=0; symbolindex<symbolsize; symbolindex++)
          {
            if (symboldata[symbolindex] == "")
              continue;
              
            local_symbolallow[symbolindex] = symboldata[symbolindex];
          }
          
        symbolallow_size = symbolsize;
      }

    return true;
  }

//+------------------------------------------------------------------+
//| Start the zmq server                                             |
//+------------------------------------------------------------------+
void StartZmqServer()
  {  
    if (zmq_server == "")
      return;
      
    int result = publisher.bind(zmq_server);
    
    if (result != 1)
      {
        Alert("Error: Unable to bind server, please check your port.");
        return;
      }
    
    Print("Load Server: ", zmq_server);
    
    int  changed     = 0;
    uint delay       = zmq_pushdelay;
    uint ticketstart = 0; 
    uint tickcount   = 0;
    
    zmq_runningstatus = true;
   
    while (!IsStopped())
      {
        ticketstart = GetTickCount();
        changed     = GetCurrentSymbolsOnTicket();
        
        if (changed > 0)
          UpdateCurrentSymbolsOnTicket();
        
        tickcount = GetTickCount() - ticketstart;
        
        if (delay > tickcount)
          Sleep(delay-tickcount-2);
      }
  }

//+------------------------------------------------------------------+
//| Stop the zmq server                                              |
//+------------------------------------------------------------------+
void StopZmqServer()
  {
    if (zmq_server == "") 
      return;
    
    ArrayFree(symbolinfo);
    ArrayFree(local_symbolallow);
    
    Print("Unload Server: ", zmq_server);
    
    if (zmq_runningstatus == true)
      publisher.unbind(zmq_server);
      
    zmq_runningstatus = false;
  }

//+------------------------------------------------------------------+
//| Get all of the symbols                                           |
//+------------------------------------------------------------------+
int GetCurrentSymbolsOnTicket()
  {       
    int changed     = 0;
    int symbolindex = 0;
    
    symbolinfosize = SymbolsTotal(symbolinmarketwatch);
    
    if (symbolinfosize > 0 && symbolinfosize != prev_symbolinfosize)
      {
        ArrayResize(symbolinfo, symbolinfosize);
      }
    
    prev_symbolinfosize = symbolinfosize;
    
    for (symbolindex=0; symbolindex<symbolinfosize; symbolindex++)
      {
        int    symbolchanged = false;
        string symbolname    = SymbolName(symbolindex, symbolinmarketwatch);
        double vask          = SymbolInfoDouble(symbolname, SYMBOL_ASK);
        double vbid          = SymbolInfoDouble(symbolname, SYMBOL_BID);
        int    vspread       = (int) SymbolInfoInteger(symbolname, SYMBOL_SPREAD);
        
        if (GetSymbolAllowed(symbolname) == false)
          continue;
        
        if (vask != symbolinfo[symbolindex].ask)
          symbolchanged = true;
          
        if (vbid != symbolinfo[symbolindex].bid)
          symbolchanged = true;
          
        if (symbolchanged == true)
          {
            PushToSubscriber(StringFormat("%d %s|%f|%f|%f",
              AccountInfoInteger(ACCOUNT_LOGIN),
              symbolname,
              vask,
              vbid,
              vspread
            ));
          }
          
        changed ++;
      }
         
    return changed;
  }

//+------------------------------------------------------------------+
//| Update all of the symbols status                                 |
//+------------------------------------------------------------------+
void UpdateCurrentSymbolsOnTicket()
  {    
    int symbolindex = 0;
    
    // Save the symbols to cache
    for (symbolindex=0; symbolindex<symbolinfosize; symbolindex++)
      {
        string symbolname = SymbolName(symbolindex, symbolinmarketwatch);
      
        symbolinfo[symbolindex].ask    = SymbolInfoDouble(symbolname, SYMBOL_ASK);
        symbolinfo[symbolindex].bid    = SymbolInfoDouble(symbolname, SYMBOL_BID);
        symbolinfo[symbolindex].digits = (int) SymbolInfoInteger(symbolname, SYMBOL_DIGITS);
        symbolinfo[symbolindex].point  = SymbolInfoDouble(symbolname, SYMBOL_POINT);
        symbolinfo[symbolindex].spread = (int) SymbolInfoInteger(symbolname, SYMBOL_SPREAD);
      }
  }

//+------------------------------------------------------------------+
//| Push the message for all of the subscriber                       |
//+------------------------------------------------------------------+
bool PushToSubscriber(const string message)
  {
    if (message == "")
      return false;
  
    ZmqMsg replymsg(message);
    
    int result = publisher.send(replymsg);
      
    return (result == 1) ? true : false;
  }

//+------------------------------------------------------------------+
//| Get the symbol allowd on trading                                 |
//+------------------------------------------------------------------+
bool GetSymbolAllowed(const string symbol)
  {
    bool result = true;
    
    if (symbolallow_size == 0)
      return result;
    
    // Change result as FALSE when allow list is not empty
    result = false;
      
    int symbolindex = 0;
    
    for (symbolindex=0; symbolindex<symbolallow_size; symbolindex++)
      {
        if (local_symbolallow[symbolindex] == "")
          continue;
      
        if (symbol == local_symbolallow[symbolindex])
          {
            result = true;
            
            break;
          }
      }
    
    return result;
  }
