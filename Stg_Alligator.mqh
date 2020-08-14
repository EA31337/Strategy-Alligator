/**
 * @file
 * Implements Alligator strategy based on the Alligator indicator.
 */

// User input params.
INPUT int Alligator_Period_Jaw = 16;                   // Jaw Period
INPUT int Alligator_Period_Teeth = 8;                  // Teeth Period
INPUT int Alligator_Period_Lips = 6;                   // Lips Period
INPUT int Alligator_Shift_Jaw = 5;                     // Jaw Shift
INPUT int Alligator_Shift_Teeth = 7;                   // Teeth Shift
INPUT int Alligator_Shift_Lips = 5;                    // Lips Shift
INPUT ENUM_MA_METHOD Alligator_MA_Method = 2;          // MA Method
INPUT ENUM_APPLIED_PRICE Alligator_Applied_Price = 4;  // Applied Price
INPUT int Alligator_Shift = 2;                         // Shift
INPUT int Alligator_SignalOpenMethod = 0;              // Signal open method (-63-63)
INPUT float Alligator_SignalOpenLevel = 36;            // Signal open level (-49-49)
INPUT int Alligator_SignalOpenFilterMethod = 36;       // Signal open filter method
INPUT int Alligator_SignalOpenBoostMethod = 36;        // Signal open filter method
INPUT int Alligator_SignalCloseMethod = 0;             // Signal close method (-63-63)
INPUT float Alligator_SignalCloseLevel = 36;           // Signal close level (-49-49)
INPUT int Alligator_PriceLimitMethod = 0;              // Price limit method
INPUT float Alligator_PriceLimitLevel = 10;            // Price limit level
INPUT float Alligator_MaxSpread = 0;                   // Max spread to trade (pips)

// Includes.
#include <EA31337-classes/Indicators/Indi_Alligator.mqh>
#include <EA31337-classes/Strategy.mqh>

// Struct to define strategy parameters to override.
struct Stg_Alligator_Params : StgParams {
  unsigned int Alligator_Period_Jaw;
  unsigned int Alligator_Period_Teeth;
  unsigned int Alligator_Period_Lips;
  int Alligator_Shift_Jaw;
  int Alligator_Shift_Teeth;
  int Alligator_Shift_Lips;
  ENUM_MA_METHOD Alligator_MA_Method;
  ENUM_APPLIED_PRICE Alligator_Applied_Price;
  int Alligator_Shift;
  int Alligator_SignalOpenMethod;
  float Alligator_SignalOpenLevel;
  int Alligator_SignalOpenFilterMethod;
  int Alligator_SignalOpenBoostMethod;
  int Alligator_SignalCloseMethod;
  float Alligator_SignalCloseLevel;
  int Alligator_PriceLimitMethod;
  float Alligator_PriceLimitLevel;
  float Alligator_MaxSpread;

  // Constructor: Set default param values.
  Stg_Alligator_Params()
      : Alligator_Period_Jaw(::Alligator_Period_Jaw),
        Alligator_Period_Teeth(::Alligator_Period_Teeth),
        Alligator_Period_Lips(::Alligator_Period_Lips),
        Alligator_Shift_Jaw(::Alligator_Shift_Jaw),
        Alligator_Shift_Teeth(::Alligator_Shift_Teeth),
        Alligator_Shift_Lips(::Alligator_Shift_Lips),
        Alligator_MA_Method(::Alligator_MA_Method),
        Alligator_Applied_Price(::Alligator_Applied_Price),
        Alligator_Shift(::Alligator_Shift),
        Alligator_SignalOpenMethod(::Alligator_SignalOpenMethod),
        Alligator_SignalOpenLevel(::Alligator_SignalOpenLevel),
        Alligator_SignalOpenFilterMethod(::Alligator_SignalOpenFilterMethod),
        Alligator_SignalOpenBoostMethod(::Alligator_SignalOpenBoostMethod),
        Alligator_SignalCloseMethod(::Alligator_SignalCloseMethod),
        Alligator_SignalCloseLevel(::Alligator_SignalCloseLevel),
        Alligator_PriceLimitMethod(::Alligator_PriceLimitMethod),
        Alligator_PriceLimitLevel(::Alligator_PriceLimitLevel),
        Alligator_MaxSpread(::Alligator_MaxSpread) {}
  void Init() {}
};

// Loads pair specific param values.
#include "sets/EURUSD_H1.h"
#include "sets/EURUSD_H4.h"
#include "sets/EURUSD_M1.h"
#include "sets/EURUSD_M15.h"
#include "sets/EURUSD_M30.h"
#include "sets/EURUSD_M5.h"

class Stg_Alligator : public Strategy {
 public:
  Stg_Alligator(StgParams &_params, string _name) : Strategy(_params, _name) {}

  static Stg_Alligator *Init(ENUM_TIMEFRAMES _tf = NULL, long _magic_no = NULL, ENUM_LOG_LEVEL _log_level = V_INFO) {
    // Initialize strategy initial values.
    Stg_Alligator_Params _params;
    if (!Terminal::IsOptimization()) {
      SetParamsByTf<Stg_Alligator_Params>(_params, _tf, stg_alli_m1, stg_alli_m5, stg_alli_m15, stg_alli_m30,
                                          stg_alli_h1, stg_alli_h4, stg_alli_h4);
    }
    // Initialize strategy parameters.
    AlligatorParams alli_params(_params.Alligator_Period_Jaw, _params.Alligator_Shift_Jaw,
                                _params.Alligator_Period_Teeth, _params.Alligator_Shift_Teeth,
                                _params.Alligator_Period_Lips, _params.Alligator_Shift_Lips,
                                _params.Alligator_MA_Method, _params.Alligator_Applied_Price);
    alli_params.SetTf(_tf);
    StgParams sparams(new Trade(_tf, _Symbol), new Indi_Alligator(alli_params), NULL, NULL);
    sparams.logger.Ptr().SetLevel(_log_level);
    sparams.SetMagicNo(_magic_no);
    sparams.SetSignals(_params.Alligator_SignalOpenMethod, _params.Alligator_SignalOpenLevel,
                       _params.Alligator_SignalOpenFilterMethod, _params.Alligator_SignalOpenFilterMethod,

                       _params.Alligator_SignalCloseMethod, _params.Alligator_SignalCloseLevel);
    sparams.SetPriceLimits(_params.Alligator_PriceLimitMethod, _params.Alligator_PriceLimitLevel);
    sparams.SetMaxSpread(_params.Alligator_MaxSpread);
    // Initialize strategy instance.
    Strategy *_strat = new Stg_Alligator(sparams, "Alligator");
    return _strat;
  }

  /**
   * Check strategy's opening signal.
   */
  bool SignalOpen(ENUM_ORDER_TYPE _cmd, int _method = 0, float _level = 0.0) {
    Indi_Alligator *_indi = Data();
    bool _is_valid = _indi[CURR].IsValid();
    bool _result = _is_valid;
    double _level_pips = _level * Chart().GetPipSize();
    switch (_cmd) {
      case ORDER_TYPE_BUY:
        _result =
            (_indi[CURR].value[LINE_LIPS] >
                 _indi[CURR].value[LINE_TEETH] + _level_pips &&  // Check if Lips are above Teeth ...
             _indi[CURR].value[LINE_TEETH] > _indi[CURR].value[LINE_JAW] + _level_pips  // ... Teeth are above Jaw ...
            );
        if (_method != 0) {
          if (METHOD(_method, 0))
            _result &= (_indi[CURR].value[LINE_LIPS] > _indi[PREV].value[LINE_LIPS] &&    // Check if Lips increased.
                        _indi[CURR].value[LINE_TEETH] > _indi[PREV].value[LINE_TEETH] &&  // Check if Teeth increased.
                        _indi[CURR].value[LINE_JAW] > _indi[PREV].value[LINE_JAW]         // // Check if Jaw increased.
            );
          if (METHOD(_method, 1))
            _result &= (_indi[PREV].value[LINE_LIPS] > _indi[PPREV].value[LINE_LIPS] &&    // Check if Lips increased.
                        _indi[PREV].value[LINE_TEETH] > _indi[PPREV].value[LINE_TEETH] &&  // Check if Teeth increased.
                        _indi[PREV].value[LINE_JAW] > _indi[PPREV].value[LINE_JAW]         // // Check if Jaw increased.
            );
          if (METHOD(_method, 2))
            _result &= _indi[CURR].value[LINE_LIPS] > _indi[PPREV].value[LINE_LIPS];  // Check if Lips increased.
          if (METHOD(_method, 3))
            _result &= _indi[CURR].value[LINE_LIPS] - _indi[CURR].value[LINE_TEETH] >
                       _indi[CURR].value[LINE_TEETH] - _indi[CURR].value[LINE_JAW];
          if (METHOD(_method, 4))
            _result &=
                (_indi[PPREV].value[LINE_LIPS] <=
                     _indi[PPREV].value[LINE_TEETH] ||  // Check if Lips are below Teeth and ...
                 _indi[PPREV].value[LINE_LIPS] <= _indi[PPREV].value[LINE_JAW] ||  // ... Lips are below Jaw and ...
                 _indi[PPREV].value[LINE_TEETH] <= _indi[PPREV].value[LINE_JAW]    // ... Teeth are below Jaw ...
                );
        }
        break;
      case ORDER_TYPE_SELL:
        _result =
            (_indi[CURR].value[LINE_LIPS] + _level_pips <
                 _indi[CURR].value[LINE_TEETH] &&  // Check if Lips are below Teeth and ...
             _indi[CURR].value[LINE_TEETH] + _level_pips < _indi[CURR].value[LINE_JAW]  // ... Teeth are below Jaw ...
            );
        if (_method != 0) {
          if (METHOD(_method, 0))
            _result &= (_indi[CURR].value[LINE_LIPS] < _indi[PREV].value[LINE_LIPS] &&    // Check if Lips decreased.
                        _indi[CURR].value[LINE_TEETH] < _indi[PREV].value[LINE_TEETH] &&  // Check if Teeth decreased.
                        _indi[CURR].value[LINE_JAW] < _indi[PREV].value[LINE_JAW]         // // Check if Jaw decreased.
            );
          if (METHOD(_method, 1))
            _result &= (_indi[PREV].value[LINE_LIPS] < _indi[PPREV].value[LINE_LIPS] &&    // Check if Lips decreased.
                        _indi[PREV].value[LINE_TEETH] < _indi[PPREV].value[LINE_TEETH] &&  // Check if Teeth decreased.
                        _indi[PREV].value[LINE_JAW] < _indi[PPREV].value[LINE_JAW]         // // Check if Jaw decreased.
            );
          if (METHOD(_method, 2))
            _result &= _indi[CURR].value[LINE_LIPS] < _indi[PPREV].value[LINE_LIPS];  // Check if Lips decreased.
          if (METHOD(_method, 3))
            _result &= _indi[CURR].value[LINE_TEETH] - _indi[CURR].value[LINE_LIPS] >
                       _indi[CURR].value[LINE_JAW] - _indi[CURR].value[LINE_TEETH];
          if (METHOD(_method, 4))
            _result &= (_indi[PPREV].value[LINE_LIPS] >=
                            _indi[PPREV].value[LINE_TEETH] ||  // Check if Lips are above Teeth ...
                        _indi[PPREV].value[LINE_LIPS] >= _indi[PPREV].value[LINE_JAW] ||  // ... Lips are above Jaw ...
                        _indi[PPREV].value[LINE_TEETH] >= _indi[PPREV].value[LINE_JAW]    // ... Teeth are above Jaw ...
            );
        }
        break;
    }
    return _result;
  }

  /**
   * Gets price limit value for profit take or stop loss.
   */
  float PriceLimit(ENUM_ORDER_TYPE _cmd, ENUM_ORDER_TYPE_VALUE _mode, int _method = 0, float _level = 0.0) {
    Indi_Alligator *_indi = Data();
    bool _is_valid = _indi[CURR].IsValid();
    double _trail = _level * Market().GetPipSize();
    int _direction = Order::OrderDirection(_cmd, _mode);
    double _default_value = Market().GetCloseOffer(_cmd) + _trail * _method * _direction;
    double _result = _default_value;
    switch (_method) {
      case 0:
        _result = _indi[CURR].value[LINE_JAW] + _trail * _direction;
        break;
      case 1:
        _result = _indi[CURR].value[LINE_TEETH] + _trail * _direction;
        break;
      case 2:
        _result = _indi[CURR].value[LINE_LIPS] + _trail * _direction;
        break;
      case 3:
        _result = _indi[PREV].value[LINE_JAW] + _trail * _direction;
        break;
      case 4:
        _result = _indi[PREV].value[LINE_TEETH] + _trail * _direction;
        break;
      case 5:
        _result = _indi[PREV].value[LINE_LIPS] + _trail * _direction;
        break;
      case 6:
        _result = _indi[PPREV].value[LINE_JAW] + _trail * _direction;
        break;
      case 7:
        _result = _indi[PPREV].value[LINE_TEETH] + _trail * _direction;
        break;
      case 8:
        _result = _indi[PPREV].value[LINE_LIPS] + _trail * _direction;
        break;
      case 9: {
        int _bar_count = (int)_level * (int)_indi.GetLipsPeriod();
        _result = _direction > 0 ? _indi.GetPrice(PRICE_HIGH, _indi.GetHighest(_bar_count))
                                 : _indi.GetPrice(PRICE_LOW, _indi.GetLowest(_bar_count));
        break;
      }
      case 10: {
        int _bar_count = (int)_level * (int)_indi.GetTeethShift();
        _result = _direction > 0 ? _indi.GetPrice(PRICE_HIGH, _indi.GetHighest(_bar_count))
                                 : _indi.GetPrice(PRICE_LOW, _indi.GetLowest(_bar_count));
        break;
      }
      case 11: {
        int _bar_count = (int)_level * (int)_indi.GetJawPeriod();
        _result = _direction > 0 ? _indi.GetPrice(PRICE_HIGH, _indi.GetHighest(_bar_count))
                                 : _indi.GetPrice(PRICE_LOW, _indi.GetLowest(_bar_count));
        break;
      }
    }
    return (float)_result;
  }
};
