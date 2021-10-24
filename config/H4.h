/*
 * @file
 * Defines default strategy parameter values for the given timeframe.
 */

// Defines indicator's parameter values for the given pair symbol and timeframe.
struct Indi_Alligator_Params_H4 : IndiAlligatorParams {
  Indi_Alligator_Params_H4() : IndiAlligatorParams(indi_alli_defaults, PERIOD_H4) {
    applied_price = (ENUM_APPLIED_PRICE)0;
    jaw_period = 13;
    jaw_shift = 8;
    lips_period = 5;
    lips_shift = 3;
    ma_method = (ENUM_MA_METHOD)2;
    shift = 0;
    teeth_period = 8;
    teeth_shift = 5;
  }
} indi_alli_h4;

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_Alligator_Params_H4 : StgParams {
  // Struct constructor.
  Stg_Alligator_Params_H4() : StgParams(stg_alli_defaults) {
    lot_size = 0;
    signal_open_method = 2;
    signal_open_level = (float)0;
    signal_open_boost = 0;
    signal_close_method = 2;
    signal_close_level = (float)0;
    price_profit_method = 60;
    price_profit_level = (float)6;
    price_stop_method = 60;
    price_stop_level = (float)6;
    tick_filter_method = 1;
    max_spread = 0;
  }
} stg_alli_h4;
