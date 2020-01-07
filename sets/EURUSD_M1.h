//+------------------------------------------------------------------+
//|                  EA31337 - multi-strategy advanced trading robot |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_Alligator_EURUSD_M1_Params : Stg_Alligator_Params {
  void Stg_Alligator_EURUSD_M1_Params() {
    symbol = "EURUSD";
    tf = PERIOD_M1;
    Alligator_Period_Jaw = 16;
    Alligator_Period_Teeth = 8;
    Alligator_Period_Lips = 6;
    Alligator_Shift_Jaw = 0;
    Alligator_Shift_Teeth = 0;
    Alligator_Shift_Lips = 0;
    Alligator_MA_Method = 2;
    Alligator_Applied_Price = 4;
    Alligator_Shift = 2;
    Alligator_TrailingStopMethod = 7;
    Alligator_TrailingProfitMethod = 25;
    Alligator_SignalLevel1 = 0.1;
    Alligator_SignalLevel2 = 0;
    Alligator_SignalBaseMethod = 19;
    Alligator_SignalOpenMethod1 = 971;
    Alligator_SignalOpenMethod2 = 0;
    Alligator_SignalCloseMethod1 = 4;
    Alligator_SignalCloseMethod2 = 0;
    Alligator_MaxSpread = 2;
  }
};