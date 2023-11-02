//+------------------------------------------------------------------+
//|                                      FXTT_StrategyChecklist.mq4 |
//|                                  Copyright 2016, Carlos Oliveira |
//|                                         https://www.forextradingtools.eu |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Carlos Oliveira"
#property link      "https://www.forextradingtools.eu/products/indicators/forex-scanner-free-indicator/?utm_campaign=properties.indicator&utm_medium=special&utm_source=mt4terminal"
#property version   "1.00"
#property strict
#property indicator_chart_window

string INDI_NAME="MPSCN-";

input int TimerInterval=60; //Update interval (secs)
input int FontSize=10;  //Font Size
input string FontName="Calibri"; //Font Name

input string Group0; //---------------------------------------------------
input bool ShowPrice=true; //Show Price
input string Group01; //---------------------------------------------------
input bool ShowSpread=true; //Show Spread

input string Group1; //---------------------------------------------------
input bool ShowATR=true; //Show ATR
input ENUM_TIMEFRAMES AtrTimeframe=PERIOD_H1; //ATR Timeframe
input int AtrPeriod=20; //ATR Period

input string Group2; //---------------------------------------------------
input bool ShowVolume=true; //Show Volume
input ENUM_TIMEFRAMES VolumeTimeframe=PERIOD_H1; //Volume Timeframe
input int VolumePeriod=60; //Volume Period

input string Group3; //---------------------------------------------------
input bool ShowRsi=true; //Show RSI
input ENUM_TIMEFRAMES RsiTimeframe=PERIOD_H1; //RSI Timeframe
input int RsiPeriod=14; //RSI Period
input int RsiUpperLevel = 75; //RSI Upper Level
input int RsiLowerLevel = 25; //RSI Lower Level

input string Group4; //---------------------------------------------------
input bool ShowStoch=true; //Show Stochastic
input ENUM_TIMEFRAMES StochTimeframe=PERIOD_H1; //Stoch Timeframe
input int StochK = 5;   //%K period
input int StochD = 3;   //%D period
input int StochSlow = 3;//Slowing
input ENUM_MA_METHOD StochMethod= MODE_SMA; //MA Method
input ENUM_STO_PRICE StochPrice = STO_LOWHIGH; //Price Field
input int StochUpperLevel = 80; //Stoch Upper Level
input int StochLowerLevel = 20; //Stoch Lower Level

input string Group5; //---------------------------------------------------
input bool ShowAdx=true; //Show ADX
input ENUM_TIMEFRAMES AdxTimeframe=PERIOD_H1; //ADX Timeframe
input int AdxPeriod=20; //ADX Period
input ENUM_APPLIED_PRICE AdxAppliedPrice=PRICE_CLOSE; //ADX Applied Price

input string Group6; //---------------------------------------------------
input bool ShowPivots=true; //Show Pivots

int GUIXOffset = 20;
int GUIYOffset = 45;

int GUIHeaderXOffset = 20;
int GUIHeaderYOffset = 0;

int GUIColOffset=100;

int ListXOffset = 10;
int ListYOffset = 15;

int ListXMultiplier = 10;
int ListYMultiplier = 15;

datetime TimeMissing;


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {   
//--- indicator buffers mapping      
   ChartColorSet(CHART_COLOR_BACKGROUND,clrBlack);
   ChartColorSet(CHART_COLOR_FOREGROUND,clrWhite);
   ChartColorSet(CHART_COLOR_GRID,clrNONE);
   ChartColorSet(CHART_COLOR_VOLUME,clrNONE);
   ChartColorSet(CHART_COLOR_CHART_UP,clrNONE);
   ChartColorSet(CHART_COLOR_CHART_DOWN,clrNONE);
   ChartColorSet(CHART_COLOR_CHART_LINE,clrNONE);
   ChartColorSet(CHART_COLOR_CANDLE_BULL,clrNONE);
   ChartColorSet(CHART_COLOR_CANDLE_BEAR,clrNONE);
   ChartColorSet(CHART_COLOR_BID,clrNONE);
   ChartColorSet(CHART_COLOR_ASK,clrNONE);
   ChartColorSet(CHART_COLOR_LAST,clrNONE);
   ChartColorSet(CHART_COLOR_STOP_LEVEL,clrNONE);
   ChartModeSet(CHART_LINE);
//---
   EventSetTimer(1);

   DrawHeader();
   DrawScanner();

   return(INIT_SUCCEEDED);
  }
//+-------------------------------------------------------------------------------------------+
int deinit()
  {   
   ObjectsDeleteAll(ChartID(),INDI_NAME);
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   DrawMissingTime();
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   DrawMissingTime();
   if(TimeSeconds(TimeCurrent())%TimerInterval==0)
     {
      DrawScanner();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
long getAvgVolume(string symbol,int period)
  {
   long volume_total=0;
   for(int i=0; i<period; i++)
     {
      volume_total+=iVolume(symbol,VolumeTimeframe,i);
     }
   return volume_total / period;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getRange(string symbol,int period)
  {
   int DataPeriod=PERIOD_D1;
   int DataBar=iBarShift(symbol,DataPeriod,Time[0]);
   double range = iHigh(symbol, period, DataBar) - iLow(symbol, period, DataBar);
   double point = MarketInfo(symbol, MODE_POINT);
   if(point > 0) return (NormalizeDouble(range / point, 0));
   return 1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawMissingTime(int deltaY=0)
  {
   int x=GUIXOffset+ListXOffset,y=20;

   DrawLabel("CurTimeLbl",x,y,"Server Time:"+TimeToStr(TimeCurrent(),TIME_MINUTES),FontSize,FontName,clrWhite);
   DrawLabel("LocalTimeLbl",x+=150,y,"Local Time:"+TimeToStr(TimeLocal(),TIME_MINUTES),FontSize,FontName,clrWhite);
   DrawLabel("TimeLeftLbl",x+=150,y,"Time until Candle close:",FontSize,FontName,clrWhite);
   DrawTimeMissingColum(PERIOD_M1,x+=150,y);
   DrawTimeMissingColum(PERIOD_M5,x+=GUIColOffset,y);
   DrawTimeMissingColum(PERIOD_M15,x+=GUIColOffset,y,30);
   DrawTimeMissingColum(PERIOD_H1,x+=GUIColOffset, y);
   DrawTimeMissingColum(PERIOD_H4,x+=GUIColOffset, y);
   DrawTimeMissingColum(PERIOD_D1,x+=GUIColOffset, y);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawTimeMissingColum(int period,int x,int y,int dxOffset=25)
  {
   int dx=x;
   color timeColor;
   string periodStr= GetPeriodStr(period);
   string timeLeft = GetTimeToClose(period, timeColor);

   DrawLabel("TimeLeftLbl_"+periodStr,dx,y,periodStr+":",FontSize,FontName,clrWhite);
   DrawLabel("TimeLeftVal_"+periodStr,dx+=dxOffset,y,timeLeft,FontSize,FontName,timeColor);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetTimeToClose(int period,color &timeColor)
  {
   int periodMinutes = periodToMinutes(period);
   int shift         = periodMinutes*60;
   int currentTime   = (int)TimeCurrent();
   int localTime     = (int)TimeLocal();
   int barTime       = (int)iTime(period);
   int diff          = (int)MathMax(round((currentTime-localTime)/3600.0)*3600,-24*3600);

   string time=getTime(barTime+periodMinutes*60-localTime-diff,timeColor);
   time=(TerminalInfoInteger(TERMINAL_CONNECTED)) ? time : time+" x";

   return time;
  }
//+------------------------------------------------------------------+

void DrawLabel(string name,int x,int y,string label,int size=9,string font="Arial",color clr=DimGray,string tooltip="")
  {
   name=INDI_NAME+":"+name;
   ObjectDelete(name);
   ObjectCreate(name,OBJ_LABEL,0,0,0);
   ObjectSetText(name,label,size,font,clr);
   ObjectSet(name,OBJPROP_CORNER,0);
   ObjectSet(name,OBJPROP_XDISTANCE,x);
   ObjectSet(name,OBJPROP_YDISTANCE,y);
   ObjectSetString(0,name,OBJPROP_TOOLTIP,tooltip);
//--- justify text
//ObjectSet(name, OBJPROP_ANCHOR, 0);
//ObjectSetString(0, name, OBJPROP_TOOLTIP, tooltip);
//ObjectSet(name, OBJPROP_SELECTABLE, 0);
//---
  }
//+------------------------------------------------------------------+
//| The function sets chart background color.                        |
//+------------------------------------------------------------------+
bool ChartColorSet(int prop_id,const color clr,const long chart_ID=0)
  {
//--- reset the error value
   ResetLastError();
//--- set the chart background color
   if(!ChartSetInteger(chart_ID,prop_id,clr))
     {
      //--- display the error message in Experts journal
      Print(__FUNCTION__+", Error Code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Set chart display type (candlesticks, bars or                    |
//| line).                                                           |
//+------------------------------------------------------------------+
bool ChartModeSet(const long value,const long chart_ID=0)
  {
//--- reset the error value
   ResetLastError();
//--- set property value
   if(!ChartSetInteger(chart_ID,CHART_MODE,value))
     {
      //--- display the error message in Experts journal
      Print(__FUNCTION__+", Error Code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
void DrawScanner()
  {
   Print("=============>DrawScanner");
   for(int x=0; x<SymbolsTotal(true); x++)
     {
      DrawSymbol(SymbolName(x,true),x);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawSymbol(string symbolName,int symbolIdx)
  {
   int x= GUIXOffset+ListXOffset + ListXMultiplier;
   int y= GUIYOffset+ListYOffset + ListYMultiplier *symbolIdx;

   DrawSymbolColumn(symbolName,x,y,symbolName,FontSize,FontName);

   if(ShowPrice)
      DrawPriceColumn(symbolName,x+=GUIColOffset,y,symbolName,FontSize,FontName);
   if(ShowSpread)
      DrawSpreadColumn(symbolName,x+=GUIColOffset,y,symbolName,FontSize,FontName);
   if(ShowATR)
      DrawRangeColumn(symbolName,x+=GUIColOffset,y,symbolName,FontSize,FontName);
   if(ShowVolume)
      DrawVolumeColumn(symbolName,x+=GUIColOffset,y,symbolName,FontSize,FontName);
   if(ShowRsi)
      DrawRsiColumn(symbolName,x+=GUIColOffset,y,symbolName,FontSize,FontName);
   if(ShowStoch)
      DrawStochColumn(symbolName,x+=GUIColOffset,y,symbolName,FontSize,FontName);
   if(ShowAdx)
      DrawAdxColumn(symbolName,x+=GUIColOffset,y,symbolName,FontSize,FontName);
   if(ShowPivots)
      DrawPivotsColumn(symbolName,x+=GUIColOffset,y,symbolName,FontSize,FontName);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double getPoint(string symbol)
  {
   return MarketInfo(symbol,MODE_POINT);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getModifier(string symbol)
  {
   int digits=(int)MarketInfo(symbol,MODE_DIGITS);
   double modifier=1;
   if(digits==3 || digits==5)
      modifier=10.0;
   return modifier;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawRsiColumn(string symbolName,int x,int y,string text,int fontSize=8,string fontName="Calibri")
  {
   double rsi=NormalizeDouble(iRSI(symbolName,RsiTimeframe,RsiPeriod,PRICE_CLOSE,0),0);
   string tooltip=symbolName+"\n.: "+GetPeriodStr(RsiTimeframe)+" RSI ("+IntegerToString(RsiPeriod)+"):.\nCurrent  ("+DoubleToStr(rsi,1)+")";
   DrawLabel("rsi_"+symbolName,x,y,DoubleToStr(rsi,1),fontSize,fontName,GetRsiColor(rsi),tooltip);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawStochColumn(string symbolName,int x,int y,string text,int fontSize=8,string fontName="Calibri")
  {
   double stoch=iStochastic(symbolName,StochTimeframe,StochK,StochD,StochSlow,StochMethod,StochPrice,MODE_MAIN,0);
   string tooltip=symbolName+"\n.: "+GetPeriodStr(StochTimeframe)+" Stoch :.\nCurrent  ("+DoubleToStr(stoch,1)+")";
   DrawLabel("stoch_"+symbolName,x,y,DoubleToStr(stoch,1),fontSize,fontName,GetStochColor(stoch),tooltip);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawAdxColumn(string symbolName,int x,int y,string text,int fontSize=8,string fontName="Calibri")
  {
   double adx=iADX(symbolName,AdxTimeframe,AdxPeriod,AdxAppliedPrice,MODE_MAIN,0);
   string tooltip=symbolName+"\n.: "+GetPeriodStr(AdxTimeframe)+" ADX ("+IntegerToString(AdxPeriod)+"):.\nCurrent  ("+DoubleToStr(adx,1)+")";
   DrawLabel("adx_"+symbolName,x,y,GetAdxStr(adx),fontSize,fontName,GetAdxColor(adx),tooltip);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetAdxStr(double adx)
  {
   if(adx<=25)
      return "No Trend";
   if(adx<=50)
      return "Weak Trend";
   if(adx<=75)
      return "Strong Trend";
   return "Very Strong Trend";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
color GetAdxColor(double adx)
  {
   if(adx<=25)
      return clrWhite;
   if(adx<=50)
      return clrGreen;
   if(adx<=75)
      return clrYellow;
   return clrRed;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawPriceColumn(string symbolName,int x,int y,string text,int fontSize=8,string fontName="Calibri")
  {
   int digits=(int)MarketInfo(symbolName,MODE_DIGITS);
   double vAsk=NormalizeDouble(MarketInfo(symbolName,MODE_ASK),digits);
   double vBid=NormalizeDouble(MarketInfo(symbolName,MODE_BID),digits);
   double vSpread=NormalizeDouble(MarketInfo(symbolName,MODE_SPREAD),digits);
   string tooltip=symbolName+"\n.: Price :.\nAsk: "+(string)vAsk+"\nBid: "+(string)vBid+"\nSpread: "+(string)vSpread;
   DrawLabel("price_"+symbolName,x,y,(string)vBid,fontSize,fontName,clrWhite,tooltip);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawSpreadColumn(string symbolName,int x,int y,string text,int fontSize=8,string fontName="Calibri")
  {
   int digits=(int)MarketInfo(symbolName,MODE_DIGITS);
   double vAsk=NormalizeDouble(MarketInfo(symbolName,MODE_ASK),digits);
   double vBid=NormalizeDouble(MarketInfo(symbolName,MODE_ASK),digits);
   double vSpread=NormalizeDouble(MarketInfo(symbolName,MODE_SPREAD),digits);
   string tooltip=symbolName+"\n.: SPREAD :.\nAsk: "+(string)vAsk+"\nBid: "+(string)vBid+"\nSpread: "+(string)vSpread;
   DrawLabel("spread_"+symbolName,x,y,(string)vSpread,fontSize,fontName,clrWhite,tooltip);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawPivotsColumn(string symbolName,int x,int y,string text,int fontSize=8,string fontName="Calibri")
  {
   double pivots[7];
   int digits=(int)MarketInfo(symbolName,MODE_DIGITS);
   double vAsk=MarketInfo(symbolName,MODE_BID);
   double pivot=NormalizeDouble((GetPivotValue(symbolName,PERIOD_D1)),digits);

   pivots[0]=pivot;

   pivots[1]=NormalizeDouble((GetPivotResistance(symbolName,PERIOD_D1,pivot,1)),digits);
   pivots[2]=NormalizeDouble((GetPivotResistance(symbolName,PERIOD_D1,pivot,2)),digits);
   pivots[3]=NormalizeDouble((GetPivotResistance(symbolName,PERIOD_D1,pivot,3)),digits);

   pivots[4]=NormalizeDouble((GetPivotSupport(symbolName,PERIOD_D1,pivot,1)),digits);
   pivots[5]=NormalizeDouble((GetPivotSupport(symbolName,PERIOD_D1,pivot,2)),digits);
   pivots[6]=NormalizeDouble((GetPivotSupport(symbolName,PERIOD_D1,pivot,3)),digits);

   int closestIdx=GetClosestPivot(vAsk,pivots);
   double pips=vAsk-pivots[closestIdx];

   string tooltip=symbolName+"\n.: Daily Pivots :.\nPP: "+DoubleToStr(pivots[0])+"\nR1: "+DoubleToStr(pivots[1]);
   string pivotText=GetPivotDirection(pips)+" "+GetPivotStr(closestIdx);

   DrawLabel("pivots_"+symbolName,x,y,pivotText,fontSize,fontName,GetPivotColor(closestIdx),tooltip);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
color GetPivotColor(int pivotIdx)
  {
   if(pivotIdx==0)
      return clrWhite;
   if(pivotIdx<=3)
      return clrGreen;
   return clrRed;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetClosestPivot(double ask,double &pivots[])
  {
   int idx=0;
   double minDistance=1.7976931348623158e+308;
   for(int i=0;i<ArraySize(pivots);i++)
     {
      double dist=MathAbs(ask-pivots[i]);
      if(dist<minDistance)
        {
         minDistance=dist;
         idx=i;
        }
     }
   return idx;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetPivotDirection(double value)
  {
   if(value>0)
      return "Above";
   return "Bellow";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetPivotValue(string symbolName,int timeframe)
  {
//Pivot point (PP) = (High + Low + Close) / 3
   return (iHigh(symbolName,timeframe,1)+iLow(symbolName,timeframe,1)+iClose(symbolName,timeframe,1))/3;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetPivotResistance(string symbolName,int timeframe,double pivotValue,int resistanceIdx=1)
  {
   switch(resistanceIdx)
     {
      case 3:
         //Third resistance (R3) = High + 2(PP – Low)
         return iHigh(symbolName,timeframe,1) + 2*(pivotValue - iLow(symbolName,timeframe,1));
      case 2:
         //Second resistance (R2) = PP + (High – Low)
         return pivotValue + (iHigh(symbolName,timeframe,1)-iLow(symbolName,timeframe,1));
      default:
         //First resistance (R1) = (2 x PP) – Low
         return (2*pivotValue) - iLow(symbolName,timeframe,1);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetPivotSupport(string symbolName,int timeframe,double pivotValue,int supportIdx=1)
  {
   switch(supportIdx)
     {
      case 3:
         //Third support (S3) = Low – 2(High – PP)
         return iLow(symbolName,timeframe,1) - 2*(iHigh(symbolName,timeframe,1)-pivotValue);
      case 2:
         //Second support (S2) = PP – (High – Low)
         return pivotValue - (iHigh(symbolName,timeframe,1) - iLow(symbolName,timeframe,1));
      default:
         //First support (S1) = (2 x PP) – High
         return (2*pivotValue) - iHigh(symbolName,timeframe,1);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawVolumeColumn(string symbolName,int x,int y,string text,int fontSize=8,string fontName="Calibri")
  {
   long volume=iVolume(symbolName,VolumeTimeframe,0);
   double volAvg=(double)getAvgVolume(symbolName,VolumePeriod);
   double volPercent=(volume/volAvg)*100;
   string tooltip=symbolName+"\n.: "+GetPeriodStr(VolumeTimeframe)+" Volume ("+IntegerToString(VolumePeriod)+"):.\nCurrent  ("+DoubleToStr(volume,0)+")\nAverage ("+DoubleToStr(volAvg,0)+")";

   DrawLabel("vol"+symbolName,x,y,DoubleToStr(volPercent,2)+"%",fontSize,fontName,GetPercentColor(volPercent),tooltip);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawRangeColumn(string symbolName,int x,int y,string text,int fontSize=8,string fontName="Calibri")
  {
   double atr=0;
   double point=getPoint(symbolName);
   double modifier=getModifier(symbolName);

   if(point>0)
      atr=(NormalizeDouble(iATR(symbolName,AtrTimeframe,AtrPeriod,0)/point,0))/modifier;
   double range=getRange(symbolName,AtrTimeframe)/modifier;
   double rangePercent=(range/atr)*100;
   string tooltip=symbolName+"\n.: "+GetPeriodStr(AtrTimeframe)+" ATR ("+IntegerToString(AtrPeriod)+"):.\nCurrent  ("+DoubleToStr(range,1)+")\nAverage ("+DoubleToStr(atr,1)+")";

   DrawLabel("atr_"+symbolName,x,y,DoubleToStr(rangePercent,1)+"%",fontSize,fontName,GetPercentColor(rangePercent),tooltip);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
color GetRsiColor(double value)
  {
   if(value>=RsiUpperLevel)
      return clrGreen;
   if(value<=RsiLowerLevel)
      return clrRed;
   return clrWhite;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
color GetStochColor(double value)
  {
   if(value>=StochUpperLevel)
      return clrGreen;
   if(value<=StochLowerLevel)
      return clrRed;
   return clrWhite;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
color GetPercentColor(double value)
  {
   if(value<=25)
      return clrWhite;
   if(value<=50)
      return clrGreen;
   if(value<=75)
      return clrYellow;
   if(value<=100)
      return clrRed;
   return clrPurple;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawSymbolColumn(string symbolName,int x,int y,string text,int fontSize=8,string fontName="Calibri")
  {
   DrawLabel("lbl_"+symbolName,x,y,text,fontSize,fontName,clrWhite,symbolName);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawHeader()
  {

   string objName="Header";

   int x = GUIXOffset+GUIHeaderXOffset;
   int y = GUIYOffset+GUIHeaderYOffset;

   DrawLabel(objName+"name",x,y,"Name",FontSize,FontName,clrWhite,"Name");
   DrawHorizontalLine(objName+"namehline",x,y,15);

   if(ShowPrice)
     {
      DrawLabel(objName+"price",x+=GUIColOffset,y,"Price",FontSize,FontName,clrWhite,"Price");
      DrawHorizontalLine(objName+"pricehline",x,y,15);
     }
   if(ShowSpread)
     {
      DrawLabel(objName+"spread",x+=GUIColOffset,y,"Spread",FontSize,FontName,clrWhite,"Spread");
      DrawHorizontalLine(objName+"spreadhline",x,y,15);
     }
   if(ShowATR)
     {
      DrawLabel(objName+"range",x+=GUIColOffset,y,"ATR ("+GetPeriodStr(AtrTimeframe)+")",FontSize,FontName,clrWhite,"Range");
      DrawHorizontalLine(objName+"rangehline",x,y,15);
     }
   if(ShowVolume)
     {
      DrawLabel(objName+"curvolume",x+=GUIColOffset,y,"Vol ("+GetPeriodStr(VolumeTimeframe)+")",FontSize,FontName,clrWhite,"Volume");
      DrawHorizontalLine(objName+"volhline",x,y,15);
     }
   if(ShowRsi)
     {
      DrawLabel(objName+"rsi",x+=GUIColOffset,y,"RSI ("+GetPeriodStr(RsiTimeframe)+")",FontSize,FontName,clrWhite,"Pivots");
      DrawHorizontalLine(objName+"rsihline",x,y,15);
     }
   if(ShowStoch)
     {
      DrawLabel(objName+"stoch",x+=GUIColOffset,y,"Stoch ("+GetPeriodStr(StochTimeframe)+")",FontSize,FontName,clrWhite,"Stochastic");
      DrawHorizontalLine(objName+"stochhline",x,y,15);
     }
   if(ShowAdx)
     {
      DrawLabel(objName+",adx",x+=GUIColOffset,y,"ADX ("+GetPeriodStr(AdxTimeframe)+")",FontSize,FontName,clrWhite,"ADX");
      DrawHorizontalLine(objName+"adxhline",x,y,15);
     }

   if(ShowPivots)
     {
      DrawLabel(objName+"pivots",x+=GUIColOffset,y,"Pivots",FontSize,FontName,clrWhite,"Pivots");
      DrawHorizontalLine(objName+"pvotshline",x,y,15);
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawHorizontalLine(string objName,int x,int y,int length=250)
  {
   string line;
   for(int i=0;i<length;i++)
      line += "_";

   DrawLabel(objName+"1",x,y,line,FontSize,FontName,clrWhite,"");
//DrawLabel(objName+"2",x+380,y,line,FontSize,FontName,clrWhite,"");
  }
//+------------------------------------------------------------------+
int periodToMinutes(int period)
  {
   int i;
   static int _per[]={1,2,3,4,5,6,10,12,15,20,30,60,120,180,240,360,480,720,1440,10080,43200,0x4001,0x4002,0x4003,0x4004,0x4006,0x4008,0x400c,0x4018,0x8001,0xc001};
   static int _min[]={1,2,3,4,5,6,10,12,15,20,30,60,120,180,240,360,480,720,1440,10080,43200};
//---
   if(period==PERIOD_CURRENT)
      period=Period();
   for(i=0;i<20;i++) if(period==_per[i]) break;
   return(_min[i]);
  }
//+------------------------------------------------------------------+
datetime iTime(int period)
  {
   datetime times[];
   if(CopyTime(Symbol(),period,0,1,times)<=0)
      return(TimeLocal());
   return(times[0]);
  }
//+------------------------------------------------------------------+
string getTime(int times,color &theColor)
  {
   string stime="";
   int    seconds;
   int    minutes;
   int    hours;

   if(times<0)
     {
      theColor=clrRed;
      times=(int)fabs(times);
     }
   else if(times>0)
     {
      theColor=clrYellow;
     }

   seconds = (times%60);
   hours   = (times-times%3600)/3600;
   minutes = (times-seconds)/60-hours*60;
//---
   if(hours>0)
      if(minutes<10)
         stime = stime+(string)hours+":0";
   else  stime = stime+(string)hours+":";
   stime=stime+(string)minutes;
   if(seconds<10)
      stime=stime+":0"+(string)seconds;
   else  stime=stime+":"+(string)seconds;
   return(stime);
  }
//+------------------------------------------------------------------+
string GetPivotStr(int pivotIdx)
  {
   switch(pivotIdx)
     {
      case 1:
         return "R1";
      case 2:
         return "R2";
      case 3:
         return "R3";
      case 4:
         return "S1";
      case 5:
         return "S2";
      case 6:
         return "S3";
      default:
         return "PP";
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetPeriodStr(int period)
  {
   string TMz="";
   switch(period)
     {
      case 1:     TMz = "M1";  break;
      case 2:     TMz = "M2";  break;
      case 3:     TMz = "M3";  break;
      case 4:     TMz = "M4";  break;
      case 5:     TMz = "M5";  break;
      case 6:     TMz = "M6";  break;
      case 7:     TMz = "M7";  break;
      case 8:     TMz = "M8";  break;
      case 9:     TMz = "M9";  break;
      case 10:    TMz = "M10"; break;
      case 11:    TMz = "M11"; break;
      case 12:    TMz = "M12"; break;
      case 13:    TMz = "M13"; break;
      case 14:    TMz = "M14"; break;
      case 15:    TMz = "M15"; break;
      case 20:    TMz = "M20"; break;
      case 25:    TMz = "M25"; break;
      case 30:    TMz = "M30"; break;
      case 40:    TMz = "M40"; break;
      case 45:    TMz = "M45"; break;
      case 50:    TMz = "M50"; break;
      case 60:    TMz = "H1";  break;
      case 120:   TMz = "H2";  break;
      case 180:   TMz = "H3";  break;
      case 240:   TMz = "H4";  break;
      case 300:   TMz = "H5";  break;
      case 360:   TMz = "H6";  break;
      case 420:   TMz = "H7";  break;
      case 480:   TMz = "H8";  break;
      case 540:   TMz = "H9";  break;
      case 600:   TMz = "H10"; break;
      case 660:   TMz = "H11"; break;
      case 720:   TMz = "H12"; break;
      case 1440:  TMz = "D1";  break;
      case 10080: TMz = "W1";  break;
      case 43200: TMz = "M1";  break;
     }
   return TMz;
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Create a trend line by the given coordinates                     |
//+------------------------------------------------------------------+
bool TrendCreate(const long            chart_ID=0,        // chart's ID
                 const string          name="TrendLine",  // line name
                 const int             sub_window=0,      // subwindow index
                 datetime              time1=0,           // first point time
                 double                price1=0,          // first point price
                 datetime              time2=0,           // second point time
                 double                price2=0,          // second point price
                 const color           clr=clrRed,        // line color
                 const ENUM_LINE_STYLE style=STYLE_SOLID, // line style
                 const int             width=1,           // line width
                 const bool            back=false,        // in the background
                 const bool            selection=true,    // highlight to move
                 const bool            ray_right=false,   // line's continuation to the right
                 const bool            hidden=true,       // hidden in the object list
                 const long            z_order=0)         // priority for mouse click
  {
//--- set anchor points' coordinates if they are not set
   ChangeTrendEmptyPoints(time1,price1,time2,price2);
//--- reset the error value
   ResetLastError();
//--- create a trend line by the given coordinates
   if(!ObjectCreate(chart_ID,name,OBJ_TREND,sub_window,time1,price1,time2,price2))
     {
      Print(__FUNCTION__,
            ": failed to create a trend line! Error code = ",GetLastError());
      return(false);
     }
//--- set line color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set line display style
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set line width
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the line by mouse
//--- when creating a graphical object using ObjectCreate function, the object cannot be
//--- highlighted and moved by default. Inside this method, selection parameter
//--- is true by default making it possible to highlight and move the object
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- enable (true) or disable (false) the mode of continuation of the line's display to the right
   ObjectSetInteger(chart_ID,name,OBJPROP_RAY_RIGHT,ray_right);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Check the values of trend line's anchor points and set default   |
//| values for empty ones                                            |
//+------------------------------------------------------------------+
void ChangeTrendEmptyPoints(datetime &time1,double &price1,
                            datetime &time2,double &price2)
  {
//--- if the first point's time is not set, it will be on the current bar
   if(!time1)
      time1=TimeCurrent();
//--- if the first point's price is not set, it will have Bid value
   if(!price1)
      price1=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- if the second point's time is not set, it is located 9 bars left from the second one
   if(!time2)
     {
      //--- array for receiving the open time of the last 10 bars
      datetime temp[10];
      CopyTime(Symbol(),Period(),time1,10,temp);
      //--- set the second point 9 bars left from the first one
      time2=temp[0];
     }
//--- if the second point's price is not set, it is equal to the first point's one
   if(!price2)
      price2=price1;
  }
//+------------------------------------------------------------------+
