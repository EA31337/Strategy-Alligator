/*
 * @file
 * Defines default strategy parameter values for the given timeframe.
 */

// Defines indicator's parameter values for the given pair symbol and timeframe.
struct Indi_Alligator_Params_M5 : IndiAlligatorParams {
  Indi_Alligator_Params_M5() : IndiAlligatorParams(indi_alli_defaults, PERIOD_M5) {
    applied_price = (ENUM_APPLIED_PRICE)0;
    jaw_period = 9;
    jaw_shift = 10;
    lips_period = 4;
    lips_shift = 7;
    ma_method = (ENUM_MA_METHOD)2;
    shift = 0;
    teeth_period = 2;
    teeth_shift = 0;
  }
} indi_alli_m5;

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_Alligator_Params_M5 : StgParams {
  // Struct constructor.
  Stg_Alligator_Params_M5() : StgParams(stg_alli_defaults) {
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
} stg_alli_m5;
