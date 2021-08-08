/**
 * @file
 * Implements Alligator strategy based on the Alligator indicator.
 */

// User input params.
INPUT_GROUP("Alligator strategy: strategy params");
INPUT float Alligator_LotSize = 0;                // Lot size
INPUT int Alligator_SignalOpenMethod = 2;         // Signal open method (-127-127)
INPUT float Alligator_SignalOpenLevel = 0.0f;     // Signal open level (-49-49)
INPUT int Alligator_SignalOpenFilterMethod = 32;  // Signal open filter method
INPUT int Alligator_SignalOpenBoostMethod = 0;    // Signal open filter method
INPUT int Alligator_SignalCloseMethod = 2;        // Signal close method (-127-127)
INPUT float Alligator_SignalCloseLevel = 0.0f;    // Signal close level (-49-49)
INPUT int Alligator_PriceStopMethod = 1;          // Price stop method
INPUT float Alligator_PriceStopLevel = 10;        // Price stop level
INPUT int Alligator_TickFilterMethod = 1;         // Tick filter method
INPUT float Alligator_MaxSpread = 4.0;            // Max spread to trade (pips)
INPUT short Alligator_Shift = 2;                  // Shift
INPUT int Alligator_OrderCloseTime = -20;         // Order close time in mins (>0) or bars (<0)
INPUT_GROUP("Alligator strategy: Alligator indicator params");
INPUT int Alligator_Indi_Alligator_Period_Jaw = 21;                                       // Jaw Period
INPUT int Alligator_Indi_Alligator_Period_Teeth = 8;                                      // Teeth Period
INPUT int Alligator_Indi_Alligator_Period_Lips = 8;                                       // Lips Period
INPUT int Alligator_Indi_Alligator_Shift_Jaw = 5;                                         // Jaw Shift
INPUT int Alligator_Indi_Alligator_Shift_Teeth = 5;                                       // Teeth Shift
INPUT int Alligator_Indi_Alligator_Shift_Lips = 3;                                        // Lips Shift
INPUT ENUM_MA_METHOD Alligator_Indi_Alligator_MA_Method = (ENUM_MA_METHOD)2;              // MA Method
INPUT ENUM_APPLIED_PRICE Alligator_Indi_Alligator_Applied_Price = (ENUM_APPLIED_PRICE)4;  // Applied Price
INPUT int Alligator_Indi_Alligator_Shift = 0;                                             // Shift

// Structs.

// Defines struct with default user indicator values.
struct Indi_Alligator_Params_Defaults : AlligatorParams {
  Indi_Alligator_Params_Defaults()
      : AlligatorParams(::Alligator_Indi_Alligator_Period_Jaw, ::Alligator_Indi_Alligator_Shift_Jaw,
                        ::Alligator_Indi_Alligator_Period_Teeth, ::Alligator_Indi_Alligator_Shift_Teeth,
                        ::Alligator_Indi_Alligator_Period_Lips, ::Alligator_Indi_Alligator_Shift_Lips,
                        ::Alligator_Indi_Alligator_MA_Method, ::Alligator_Indi_Alligator_Applied_Price,
                        ::Alligator_Indi_Alligator_Shift) {}
} indi_alli_defaults;

// Defines struct with default user strategy values.
struct Stg_Alligator_Params_Defaults : StgParams {
  Stg_Alligator_Params_Defaults()
      : StgParams(::Alligator_SignalOpenMethod, ::Alligator_SignalOpenFilterMethod, ::Alligator_SignalOpenLevel,
                  ::Alligator_SignalOpenBoostMethod, ::Alligator_SignalCloseMethod, ::Alligator_SignalCloseLevel,
                  ::Alligator_PriceStopMethod, ::Alligator_PriceStopLevel, ::Alligator_TickFilterMethod,
                  ::Alligator_MaxSpread, ::Alligator_Shift, ::Alligator_OrderCloseTime) {}
} stg_alli_defaults;

// Struct to define strategy parameters to override.
struct Stg_Alligator_Params : StgParams {
  AlligatorParams iparams;
  StgParams sparams;

  // Struct constructors.
  Stg_Alligator_Params(AlligatorParams &_iparams, StgParams &_sparams)
      : iparams(indi_alli_defaults, _iparams.tf.GetTf()), sparams(stg_alli_defaults) {
    iparams = _iparams;
    sparams = _sparams;
  }
};

// Loads pair specific param values.
#include "config/EURUSD_H1.h"
#include "config/EURUSD_H4.h"
#include "config/EURUSD_H8.h"
#include "config/EURUSD_M1.h"
#include "config/EURUSD_M15.h"
#include "config/EURUSD_M30.h"
#include "config/EURUSD_M5.h"

class Stg_Alligator : public Strategy {
 public:
  Stg_Alligator(StgParams &_sparams, TradeParams &_tparams, ChartParams &_cparams, string _name = "")
      : Strategy(_sparams, _tparams, _cparams, _name) {}

  static Stg_Alligator *Init(ENUM_TIMEFRAMES _tf = NULL, long _magic_no = NULL, ENUM_LOG_LEVEL _log_level = V_INFO) {
    // Initialize strategy initial values.
    AlligatorParams _indi_params(indi_alli_defaults, _tf);
    StgParams _stg_params(stg_alli_defaults);
#ifdef __config__
    SetParamsByTf<AlligatorParams>(_indi_params, _tf, indi_alli_m1, indi_alli_m5, indi_alli_m15, indi_alli_m30,
                                   indi_alli_h1, indi_alli_h4, indi_alli_h8);
    SetParamsByTf<StgParams>(_stg_params, _tf, stg_alli_m1, stg_alli_m5, stg_alli_m15, stg_alli_m30, stg_alli_h1,
                             stg_alli_h4, stg_alli_h8);
#endif
    // Initialize indicator.
    AlligatorParams alli_params(_indi_params);
    _stg_params.SetIndicator(new Indi_Alligator(_indi_params));
    // Initialize Strategy instance.
    ChartParams _cparams(_tf, _Symbol);
    TradeParams _tparams(_magic_no, _log_level);
    Strategy *_strat = new Stg_Alligator(_stg_params, _tparams, _cparams, "Alligator");
    return _strat;
  }

  /**
   * Check strategy's opening signal.
   */
  bool SignalOpen(ENUM_ORDER_TYPE _cmd, int _method = 0, float _level = 0.0f, int _shift = 0) {
    Indi_Alligator *_indi = GetIndicator();
    bool _result = _indi.GetFlag(INDI_ENTRY_FLAG_IS_VALID);
    if (!_result) {
      // Returns false when indicator data is not valid.
      return false;
    }
    double _level_pips = _level * Chart().GetPipSize();
    switch (_cmd) {
      case ORDER_TYPE_BUY:
        _result =
            (_indi[CURR][(int)LINE_LIPS] >
                 _indi[CURR][(int)LINE_TEETH] + _level_pips &&  // Check if Lips are above Teeth ...
             _indi[CURR][(int)LINE_TEETH] > _indi[CURR][(int)LINE_JAW] + _level_pips  // ... Teeth are above Jaw ...
            );
        if (_method != 0) {
          if (METHOD(_method, 0))
            _result &= (_indi[CURR][(int)LINE_LIPS] > _indi[PREV][(int)LINE_LIPS] &&    // Check if Lips increased.
                        _indi[CURR][(int)LINE_TEETH] > _indi[PREV][(int)LINE_TEETH] &&  // Check if Teeth increased.
                        _indi[CURR][(int)LINE_JAW] > _indi[PREV][(int)LINE_JAW]         // // Check if Jaw increased.
            );
          if (METHOD(_method, 1))
            _result &= (_indi[PREV][(int)LINE_LIPS] > _indi[PPREV][(int)LINE_LIPS] &&    // Check if Lips increased.
                        _indi[PREV][(int)LINE_TEETH] > _indi[PPREV][(int)LINE_TEETH] &&  // Check if Teeth increased.
                        _indi[PREV][(int)LINE_JAW] > _indi[PPREV][(int)LINE_JAW]         // // Check if Jaw increased.
            );
          if (METHOD(_method, 2))
            _result &= _indi[CURR][(int)LINE_LIPS] > _indi[PPREV][(int)LINE_LIPS];  // Check if Lips increased.
          if (METHOD(_method, 3))
            _result &= _indi[CURR][(int)LINE_LIPS] - _indi[CURR][(int)LINE_TEETH] >
                       _indi[CURR][(int)LINE_TEETH] - _indi[CURR][(int)LINE_JAW];
          if (METHOD(_method, 4))
            _result &=
                (_indi[PPREV][(int)LINE_LIPS] <=
                     _indi[PPREV][(int)LINE_TEETH] ||  // Check if Lips are below Teeth and ...
                 _indi[PPREV][(int)LINE_LIPS] <= _indi[PPREV][(int)LINE_JAW] ||  // ... Lips are below Jaw and ...
                 _indi[PPREV][(int)LINE_TEETH] <= _indi[PPREV][(int)LINE_JAW]    // ... Teeth are below Jaw ...
                );
        }
        break;
      case ORDER_TYPE_SELL:
        _result =
            (_indi[CURR][(int)LINE_LIPS] + _level_pips <
                 _indi[CURR][(int)LINE_TEETH] &&  // Check if Lips are below Teeth and ...
             _indi[CURR][(int)LINE_TEETH] + _level_pips < _indi[CURR][(int)LINE_JAW]  // ... Teeth are below Jaw ...
            );
        if (_method != 0) {
          if (METHOD(_method, 0))
            _result &= (_indi[CURR][(int)LINE_LIPS] < _indi[PREV][(int)LINE_LIPS] &&    // Check if Lips decreased.
                        _indi[CURR][(int)LINE_TEETH] < _indi[PREV][(int)LINE_TEETH] &&  // Check if Teeth decreased.
                        _indi[CURR][(int)LINE_JAW] < _indi[PREV][(int)LINE_JAW]         // // Check if Jaw decreased.
            );
          if (METHOD(_method, 1))
            _result &= (_indi[PREV][(int)LINE_LIPS] < _indi[PPREV][(int)LINE_LIPS] &&    // Check if Lips decreased.
                        _indi[PREV][(int)LINE_TEETH] < _indi[PPREV][(int)LINE_TEETH] &&  // Check if Teeth decreased.
                        _indi[PREV][(int)LINE_JAW] < _indi[PPREV][(int)LINE_JAW]         // // Check if Jaw decreased.
            );
          if (METHOD(_method, 2))
            _result &= _indi[CURR][(int)LINE_LIPS] < _indi[PPREV][(int)LINE_LIPS];  // Check if Lips decreased.
          if (METHOD(_method, 3))
            _result &= _indi[CURR][(int)LINE_TEETH] - _indi[CURR][(int)LINE_LIPS] >
                       _indi[CURR][(int)LINE_JAW] - _indi[CURR][(int)LINE_TEETH];
          if (METHOD(_method, 4))
            _result &=
                (_indi[PPREV][(int)LINE_LIPS] >= _indi[PPREV][(int)LINE_TEETH] ||  // Check if Lips are above Teeth ...
                 _indi[PPREV][(int)LINE_LIPS] >= _indi[PPREV][(int)LINE_JAW] ||    // ... Lips are above Jaw ...
                 _indi[PPREV][(int)LINE_TEETH] >= _indi[PPREV][(int)LINE_JAW]      // ... Teeth are above Jaw ...
                );
        }
        break;
    }
    return _result;
  }
};
