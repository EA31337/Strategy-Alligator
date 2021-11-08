/**
 * @file
 * Implements Alligator strategy based on the Alligator indicator.
 */

// User input params.
INPUT_GROUP("Alligator strategy: strategy params");
INPUT float Alligator_LotSize = 0;                // Lot size
INPUT int Alligator_SignalOpenMethod = -1;        // Signal open method (-127-127)
INPUT float Alligator_SignalOpenLevel = 0.0f;     // Signal open level (-49-49)
INPUT int Alligator_SignalOpenFilterMethod = 32;  // Signal open filter method
INPUT int Alligator_SignalOpenFilterTime = 3;     // Signal open filter time
INPUT int Alligator_SignalOpenBoostMethod = 0;    // Signal open boost method
INPUT int Alligator_SignalCloseMethod = 2;        // Signal close method (-127-127)
INPUT int Alligator_SignalCloseFilter = 0;        // Signal close filter (-127-127)
INPUT float Alligator_SignalCloseLevel = 0.0f;    // Signal close level (-49-49)
INPUT int Alligator_PriceStopMethod = 16;         // Price stop method (0-127)
INPUT float Alligator_PriceStopLevel = 2;         // Price stop level
INPUT int Alligator_TickFilterMethod = 32;        // Tick filter method
INPUT float Alligator_MaxSpread = 4.0;            // Max spread to trade (pips)
INPUT short Alligator_Shift = 2;                  // Shift
INPUT float Alligator_OrderCloseLoss = 80;        // Order close loss
INPUT float Alligator_OrderCloseProfit = 80;      // Order close profit
INPUT int Alligator_OrderCloseTime = -30;         // Order close time in mins (>0) or bars (<0)
INPUT_GROUP("Alligator strategy: Alligator indicator params");
INPUT int Alligator_Indi_Alligator_Period_Jaw = 30;                               // Jaw Period
INPUT int Alligator_Indi_Alligator_Period_Teeth = 6;                              // Teeth Period
INPUT int Alligator_Indi_Alligator_Period_Lips = 4;                               // Lips Period
INPUT int Alligator_Indi_Alligator_Shift_Jaw = 6;                                 // Jaw Shift
INPUT int Alligator_Indi_Alligator_Shift_Teeth = 4;                               // Teeth Shift
INPUT int Alligator_Indi_Alligator_Shift_Lips = 2;                                // Lips Shift
INPUT ENUM_MA_METHOD Alligator_Indi_Alligator_MA_Method = MODE_LWMA;              // MA Method
INPUT ENUM_APPLIED_PRICE Alligator_Indi_Alligator_Applied_Price = PRICE_TYPICAL;  // Applied Price
INPUT int Alligator_Indi_Alligator_Shift = 0;                                     // Shift

// Structs.

// Defines struct with default user strategy values.
struct Stg_Alligator_Params_Defaults : StgParams {
  Stg_Alligator_Params_Defaults()
      : StgParams(::Alligator_SignalOpenMethod, ::Alligator_SignalOpenFilterMethod, ::Alligator_SignalOpenLevel,
                  ::Alligator_SignalOpenBoostMethod, ::Alligator_SignalCloseMethod, ::Alligator_SignalCloseFilter,
                  ::Alligator_SignalCloseLevel, ::Alligator_PriceStopMethod, ::Alligator_PriceStopLevel,
                  ::Alligator_TickFilterMethod, ::Alligator_MaxSpread, ::Alligator_Shift) {
    Set(STRAT_PARAM_LS, Alligator_LotSize);
    Set(STRAT_PARAM_OCL, Alligator_OrderCloseLoss);
    Set(STRAT_PARAM_OCP, Alligator_OrderCloseProfit);
    Set(STRAT_PARAM_OCT, Alligator_OrderCloseTime);
    Set(STRAT_PARAM_SOFT, Alligator_SignalOpenFilterTime);
  }
};

#ifdef __config__
// Loads pair specific param values.
#include "config/H1.h"
#include "config/H4.h"
#include "config/H8.h"
#include "config/M1.h"
#include "config/M15.h"
#include "config/M30.h"
#include "config/M5.h"
#endif

class Stg_Alligator : public Strategy {
 public:
  Stg_Alligator(StgParams &_sparams, TradeParams &_tparams, ChartParams &_cparams, string _name = "")
      : Strategy(_sparams, _tparams, _cparams, _name) {}

  static Stg_Alligator *Init(ENUM_TIMEFRAMES _tf = NULL) {
    // Initialize strategy initial values.
    Stg_Alligator_Params_Defaults stg_alli_defaults;
    StgParams _stg_params(stg_alli_defaults);
#ifdef __config__
    SetParamsByTf<StgParams>(_stg_params, _tf, stg_alli_m1, stg_alli_m5, stg_alli_m15, stg_alli_m30, stg_alli_h1,
                             stg_alli_h4, stg_alli_h8);
#endif
    // Initialize indicator.
    // Initialize Strategy instance.
    ChartParams _cparams(_tf, _Symbol);
    TradeParams _tparams;
    Strategy *_strat = new Stg_Alligator(_stg_params, _tparams, _cparams, "Alligator");
    return _strat;
  }

  /**
   * Event on strategy's init.
   */
  void OnInit() {
    IndiAlligatorParams _indi_params(::Alligator_Indi_Alligator_Period_Jaw, ::Alligator_Indi_Alligator_Shift_Jaw,
                                     ::Alligator_Indi_Alligator_Period_Teeth, ::Alligator_Indi_Alligator_Shift_Teeth,
                                     ::Alligator_Indi_Alligator_Period_Lips, ::Alligator_Indi_Alligator_Shift_Lips,
                                     ::Alligator_Indi_Alligator_MA_Method, ::Alligator_Indi_Alligator_Applied_Price,
                                     ::Alligator_Indi_Alligator_Shift);
    _indi_params.SetTf(Get<ENUM_TIMEFRAMES>(STRAT_PARAM_TF));
    SetIndicator(new Indi_Alligator(_indi_params));
  }

  /**
   * Check strategy's opening signal.
   */
  bool SignalOpen(ENUM_ORDER_TYPE _cmd, int _method = 0, float _level = 0.0f, int _shift = 0) {
    Indi_Alligator *_indi = GetIndicator();
    int _ishift = _shift + ::Alligator_Indi_Alligator_Shift;
    bool _result = _indi.GetFlag(INDI_ENTRY_FLAG_IS_VALID, _ishift);
    if (!_result) {
      // Returns false when indicator data is not valid.
      return false;
    }
    double _level_pips = _level * Chart().GetPipSize();
    switch (_cmd) {
      case ORDER_TYPE_BUY:
        _result = (_indi[_ishift][(int)LINE_LIPS] >
                       _indi[_ishift][(int)LINE_TEETH] + _level_pips &&  // Check if Lips are above Teeth ...
                   _indi[_ishift][(int)LINE_TEETH] >
                       _indi[_ishift][(int)LINE_JAW] + _level_pips  // ... Teeth are above Jaw ...
        );
        if (_method != 0) {
          if (METHOD(_method, 0))
            _result &=
                (_indi[_ishift][(int)LINE_LIPS] > _indi[_ishift + 1][(int)LINE_LIPS] &&    // Check if Lips increased.
                 _indi[_ishift][(int)LINE_TEETH] > _indi[_ishift + 1][(int)LINE_TEETH] &&  // Check if Teeth increased.
                 _indi[_ishift][(int)LINE_JAW] > _indi[_ishift + 1][(int)LINE_JAW]         // // Check if Jaw increased.
                );
          if (METHOD(_method, 1))
            _result &=
                (_indi[_ishift + 1][(int)LINE_LIPS] > _indi[_ishift + 2][(int)LINE_LIPS] &&  // Check if Lips increased.
                 _indi[_ishift + 1][(int)LINE_TEETH] >
                     _indi[_ishift + 2][(int)LINE_TEETH] &&                             // Check if Teeth increased.
                 _indi[_ishift + 1][(int)LINE_JAW] > _indi[_ishift + 2][(int)LINE_JAW]  // // Check if Jaw increased.
                );
          if (METHOD(_method, 2))
            _result &= _indi[_ishift][(int)LINE_LIPS] > _indi[_ishift + 2][(int)LINE_LIPS];  // Check if Lips increased.
          if (METHOD(_method, 3))
            _result &= _indi[_ishift][(int)LINE_LIPS] - _indi[_ishift][(int)LINE_TEETH] >
                       _indi[_ishift][(int)LINE_TEETH] - _indi[_ishift][(int)LINE_JAW];
          if (METHOD(_method, 4))
            _result &= (_indi[_ishift + 2][(int)LINE_LIPS] <=
                            _indi[_ishift + 2][(int)LINE_TEETH] ||  // Check if Lips are below Teeth and ...
                        _indi[_ishift + 2][(int)LINE_LIPS] <=
                            _indi[_ishift + 2][(int)LINE_JAW] ||  // ... Lips are below Jaw and ...
                        _indi[_ishift + 2][(int)LINE_TEETH] <=
                            _indi[_ishift + 2][(int)LINE_JAW]  // ... Teeth are below Jaw ...
            );
        }
        break;
      case ORDER_TYPE_SELL:
        _result = (_indi[_ishift][(int)LINE_LIPS] + _level_pips <
                       _indi[_ishift][(int)LINE_TEETH] &&  // Check if Lips are below Teeth and ...
                   _indi[_ishift][(int)LINE_TEETH] + _level_pips <
                       _indi[_ishift][(int)LINE_JAW]  // ... Teeth are below Jaw ...
        );
        if (_method != 0) {
          if (METHOD(_method, 0))
            _result &=
                (_indi[_ishift][(int)LINE_LIPS] < _indi[_ishift + 1][(int)LINE_LIPS] &&    // Check if Lips decreased.
                 _indi[_ishift][(int)LINE_TEETH] < _indi[_ishift + 1][(int)LINE_TEETH] &&  // Check if Teeth decreased.
                 _indi[_ishift][(int)LINE_JAW] < _indi[_ishift + 1][(int)LINE_JAW]         // // Check if Jaw decreased.
                );
          if (METHOD(_method, 1))
            _result &=
                (_indi[_ishift + 1][(int)LINE_LIPS] < _indi[_ishift + 2][(int)LINE_LIPS] &&  // Check if Lips decreased.
                 _indi[_ishift + 1][(int)LINE_TEETH] <
                     _indi[_ishift + 2][(int)LINE_TEETH] &&                             // Check if Teeth decreased.
                 _indi[_ishift + 1][(int)LINE_JAW] < _indi[_ishift + 2][(int)LINE_JAW]  // // Check if Jaw decreased.
                );
          if (METHOD(_method, 2))
            _result &= _indi[_ishift][(int)LINE_LIPS] < _indi[_ishift + 2][(int)LINE_LIPS];  // Check if Lips decreased.
          if (METHOD(_method, 3))
            _result &= _indi[_ishift][(int)LINE_TEETH] - _indi[_ishift][(int)LINE_LIPS] >
                       _indi[_ishift][(int)LINE_JAW] - _indi[_ishift][(int)LINE_TEETH];
          if (METHOD(_method, 4))
            _result &= (_indi[_ishift + 2][(int)LINE_LIPS] >=
                            _indi[_ishift + 2][(int)LINE_TEETH] ||  // Check if Lips are above Teeth ...
                        _indi[_ishift + 2][(int)LINE_LIPS] >=
                            _indi[_ishift + 2][(int)LINE_JAW] ||  // ... Lips are above Jaw ...
                        _indi[_ishift + 2][(int)LINE_TEETH] >=
                            _indi[_ishift + 2][(int)LINE_JAW]  // ... Teeth are above Jaw ...
            );
        }
        break;
    }
    return _result;
  }
};
