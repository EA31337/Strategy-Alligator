//+------------------------------------------------------------------+
//|                  EA31337 - multi-strategy advanced trading robot |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/**
 * @file
 * Implements Alligator strategy.
 */

// Includes.
#include <EA31337-classes/Indicators/Indi_Alligator.mqh>
#include <EA31337-classes/Strategy.mqh>

// User input params.
INPUT string __Alligator_Parameters__ = "-- Settings for the Alligator indicator --"; // >>> ALLIGATOR <<<
INPUT int Alligator_Active_Tf = 127; // Activate timeframes (1-255, e.g. M1=1,M5=2,M15=4,M30=8,H1=16,H2=32,H4=64...)
INPUT int Alligator_Period_Jaw = 16; // Jaw Period
INPUT int Alligator_Period_Teeth = 8; // Teeth Period
INPUT int Alligator_Period_Lips = 6; // Lips Period
INPUT int Alligator_Shift_Jaw = 5; // Jaw Shift
INPUT int Alligator_Shift_Teeth = 7; // Teeth Shift
INPUT int Alligator_Shift_Lips = 5; // Lips Shift
INPUT ENUM_MA_METHOD Alligator_MA_Method = 2; // MA Method
INPUT ENUM_APPLIED_PRICE Alligator_Applied_Price = 4; // Applied Price
INPUT int Alligator_Shift = 2; // Shift
INPUT ENUM_TRAIL_TYPE Alligator_TrailingStopMethod = 7; // Trail stop method
INPUT ENUM_TRAIL_TYPE Alligator_TrailingProfitMethod = 25; // Trail profit method
INPUT double Alligator_SignalLevel1 = 0.1; // Signal level 1
INPUT double Alligator_SignalLevel2 = 0.0; // Signal level 2
INPUT int Alligator_SignalBaseMethod = 19; // Signal method (-63-63)
INPUT int Alligator_SignalOpenMethod1 = 971; // Open condition 1 (0-1023)
INPUT int Alligator_SignalOpenMethod2 = 0; // Open condition 2 (0-1023)
INPUT ENUM_MARKET_EVENT Alligator_SignalCloseMethod1 = 4; // Close condition 1
INPUT ENUM_MARKET_EVENT Alligator_SignalCloseMethod2 = 0; // Close condition 2
INPUT double Alligator_MaxSpread  =  0; // Max spread to trade (pips)

// Struct to define strategy parameters to override.
struct Stg_Alligator_Params : Stg_Params {
  unsigned int Alligator_Period_Jaw;
  unsigned int Alligator_Period_Teeth;
  unsigned int Alligator_Period_Lips;
  int Alligator_Shift_Jaw;
  int Alligator_Shift_Teeth;
  int Alligator_Shift_Lips;
  ENUM_MA_METHOD Alligator_MA_Method;
  ENUM_APPLIED_PRICE Alligator_Applied_Price;
  int Alligator_Shift;
  ENUM_TRAIL_TYPE Alligator_TrailingStopMethod;
  ENUM_TRAIL_TYPE Alligator_TrailingProfitMethod;
  double Alligator_SignalLevel1;
  double Alligator_SignalLevel2;
  long Alligator_SignalBaseMethod;
  long Alligator_SignalOpenMethod1;
  long Alligator_SignalOpenMethod2;
  ENUM_MARKET_EVENT Alligator_SignalCloseMethod1;
  ENUM_MARKET_EVENT Alligator_SignalCloseMethod2;
  double Alligator_MaxSpread;

  // Constructor: Set default param values.
  Stg_Alligator_Params() :
    Alligator_Period_Jaw(::Alligator_Period_Jaw),
    Alligator_Period_Teeth(::Alligator_Period_Teeth),
    Alligator_Period_Lips(::Alligator_Period_Lips),
    Alligator_Shift_Jaw(::Alligator_Shift_Jaw),
    Alligator_Shift_Teeth(::Alligator_Shift_Teeth),
    Alligator_Shift_Lips(::Alligator_Shift_Lips),
    Alligator_MA_Method(::Alligator_MA_Method),
    Alligator_Applied_Price(::Alligator_Applied_Price),
    Alligator_Shift(::Alligator_Shift),
    Alligator_TrailingStopMethod(::Alligator_TrailingStopMethod),
    Alligator_TrailingProfitMethod(::Alligator_TrailingProfitMethod),
    Alligator_SignalLevel1(::Alligator_SignalLevel1),
    Alligator_SignalLevel2(::Alligator_SignalLevel2),
    Alligator_SignalBaseMethod(::Alligator_SignalBaseMethod),
    Alligator_SignalOpenMethod1(::Alligator_SignalOpenMethod1),
    Alligator_SignalOpenMethod2(::Alligator_SignalOpenMethod2),
    Alligator_SignalCloseMethod1(::Alligator_SignalCloseMethod1),
    Alligator_SignalCloseMethod2(::Alligator_SignalCloseMethod2),
    Alligator_MaxSpread(::Alligator_MaxSpread)
  {}
  void Init() {}
};

// Loads pair specific param values.
#include "sets/EURUSD_M1.h"
#include "sets/EURUSD_M5.h"
#include "sets/EURUSD_M15.h"
#include "sets/EURUSD_M30.h"
#include "sets/EURUSD_H1.h"
#include "sets/EURUSD_H4.h"


class Stg_Alligator : public Strategy {

  public:

  void Stg_Alligator(StgParams &_params, string _name) : Strategy(_params, _name) {}

  static Stg_Alligator *Init(ENUM_TIMEFRAMES _tf = NULL, long _magic_no = NULL, ENUM_LOG_LEVEL _log_level = V_INFO) {
    // Initialize strategy initial values.
    Stg_Alligator_Params _params;
    switch (_tf) {
      case PERIOD_M1:  { Stg_Alligator_EURUSD_M1_Params  _new_params; _params = _new_params; }
      case PERIOD_M5:  { Stg_Alligator_EURUSD_M5_Params  _new_params; _params = _new_params; }
      case PERIOD_M15: { Stg_Alligator_EURUSD_M15_Params _new_params; _params = _new_params; }
      case PERIOD_M30: { Stg_Alligator_EURUSD_M30_Params _new_params; _params = _new_params; }
      case PERIOD_H1:  { Stg_Alligator_EURUSD_H1_Params  _new_params; _params = _new_params; }
      case PERIOD_H4:  { Stg_Alligator_EURUSD_H4_Params  _new_params; _params = _new_params; }
    }
    // Initialize strategy parameters.
    ChartParams cparams(_tf);
    Alligator_Params alli_params(
     _params.Alligator_Period_Jaw, _params.Alligator_Shift_Jaw,
     _params.Alligator_Period_Teeth, _params.Alligator_Shift_Teeth,
     _params.Alligator_Period_Lips, _params.Alligator_Shift_Lips,
     _params.Alligator_MA_Method, _params.Alligator_Applied_Price);
    IndicatorParams alli_iparams(10, INDI_ALLIGATOR);
    StgParams sparams(new Trade(_tf, _Symbol), new Indi_Alligator(alli_params, alli_iparams, cparams), NULL, NULL);
    sparams.logger.SetLevel(_log_level);
    sparams.SetMagicNo(_magic_no);
    sparams.SetSignals(
      _params.Alligator_SignalBaseMethod,
      _params.Alligator_SignalOpenMethod1, _params.Alligator_SignalOpenMethod2,
      _params.Alligator_SignalCloseMethod1, _params.Alligator_SignalCloseMethod2,
      _params.Alligator_SignalLevel1, _params.Alligator_SignalLevel2
    );
    sparams.SetStops(_params.Alligator_TrailingProfitMethod, _params.Alligator_TrailingStopMethod);
    sparams.SetMaxSpread(_params.Alligator_MaxSpread);
    // Initialize strategy instance.
    Strategy *_strat = new Stg_Alligator(sparams, "Alligator");
    return _strat;
  }

  /**
   * Check if Alligator indicator is on buy or sell.
   *
   * @param
   *   cmd (int) - type of trade order command
   *   period (int) - period to check for
   *   _signal_method (int) - signal method to use by using bitwise AND operation
   *   _signal_level1 (double) - signal level to consider the signal
   */
  bool SignalOpen(ENUM_ORDER_TYPE cmd, long _signal_method = EMPTY, double _signal_level1 = EMPTY, double _signal_level2 = EMPTY) {
    // [x][0] - The Blue line (Alligator's Jaw), [x][1] - The Red Line (Alligator's Teeth), [x][2] - The Green Line (Alligator's Lips)
    bool _result = false;
    double alligator_0_jaw   = ((Indi_Alligator *) this.Data()).GetValue(LINE_JAW, 0);
    double alligator_0_teeth = ((Indi_Alligator *) this.Data()).GetValue(LINE_TEETH, 0);
    double alligator_0_lips  = ((Indi_Alligator *) this.Data()).GetValue(LINE_LIPS, 0);
    double alligator_1_jaw   = ((Indi_Alligator *) this.Data()).GetValue(LINE_JAW, 1);
    double alligator_1_teeth = ((Indi_Alligator *) this.Data()).GetValue(LINE_TEETH, 1);
    double alligator_1_lips  = ((Indi_Alligator *) this.Data()).GetValue(LINE_LIPS, 1);
    double alligator_2_jaw   = ((Indi_Alligator *) this.Data()).GetValue(LINE_JAW, 2);
    double alligator_2_teeth = ((Indi_Alligator *) this.Data()).GetValue(LINE_TEETH, 2);
    double alligator_2_lips  = ((Indi_Alligator *) this.Data()).GetValue(LINE_LIPS, 2);
    if (_signal_method == EMPTY) _signal_method = GetSignalBaseMethod();
    if (_signal_level1 == EMPTY) _signal_level1 = GetSignalLevel1();
    if (_signal_level2 == EMPTY) _signal_level2 = GetSignalLevel2();
    double gap = _signal_level1 * Chart().GetPipSize();
    switch(cmd) {
      case ORDER_TYPE_BUY:
        _result = (
          alligator_0_lips > alligator_0_teeth + gap && // Check if Lips are above Teeth ...
          alligator_0_teeth > alligator_0_jaw + gap // ... Teeth are above Jaw ...
          );
        if (_signal_method != 0) {
          if (METHOD(_signal_method, 0)) _result &= (
            alligator_0_lips > alligator_1_lips && // Check if Lips increased.
            alligator_0_teeth > alligator_1_teeth && // Check if Teeth increased.
            alligator_0_jaw > alligator_1_jaw // // Check if Jaw increased.
            );
          if (METHOD(_signal_method, 1)) _result &= (
            alligator_1_lips > alligator_2_lips && // Check if Lips increased.
            alligator_1_teeth > alligator_2_teeth && // Check if Teeth increased.
            alligator_1_jaw > alligator_2_jaw // // Check if Jaw increased.
            );
          if (METHOD(_signal_method, 2)) _result &= alligator_0_lips > alligator_2_lips; // Check if Lips increased.
          if (METHOD(_signal_method, 3)) _result &= alligator_0_lips - alligator_0_teeth > alligator_0_teeth - alligator_0_jaw;
          if (METHOD(_signal_method, 4)) _result &= (
            alligator_2_lips <= alligator_2_teeth || // Check if Lips are below Teeth and ...
            alligator_2_lips <= alligator_2_jaw || // ... Lips are below Jaw and ...
            alligator_2_teeth <= alligator_2_jaw // ... Teeth are below Jaw ...
            );
        }
        break;
      case ORDER_TYPE_SELL:
        _result = (
          alligator_0_lips + gap < alligator_0_teeth && // Check if Lips are below Teeth and ...
          alligator_0_teeth + gap < alligator_0_jaw // ... Teeth are below Jaw ...
          );
        if (_signal_method != 0) {
          if (METHOD(_signal_method, 0)) _result &= (
            alligator_0_lips < alligator_1_lips && // Check if Lips decreased.
            alligator_0_teeth < alligator_1_teeth && // Check if Teeth decreased.
            alligator_0_jaw < alligator_1_jaw // // Check if Jaw decreased.
            );
          if (METHOD(_signal_method, 1)) _result &= (
            alligator_1_lips < alligator_2_lips && // Check if Lips decreased.
            alligator_1_teeth < alligator_2_teeth && // Check if Teeth decreased.
            alligator_1_jaw < alligator_2_jaw // // Check if Jaw decreased.
            );
          if (METHOD(_signal_method, 2)) _result &= alligator_0_lips < alligator_2_lips; // Check if Lips decreased.
          if (METHOD(_signal_method, 3)) _result &= alligator_0_teeth - alligator_0_lips > alligator_0_jaw - alligator_0_teeth;
          if (METHOD(_signal_method, 4)) _result &= (
            alligator_2_lips >= alligator_2_teeth || // Check if Lips are above Teeth ...
            alligator_2_lips >= alligator_2_jaw || // ... Lips are above Jaw ...
            alligator_2_teeth >= alligator_2_jaw // ... Teeth are above Jaw ...
            );
        }
        break;
    }
    return _result;
  }

};
