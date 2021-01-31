/*
 * @file
 * Defines default strategy parameter values for the given timeframe.
 */

// Defines indicator's parameter values for the given pair symbol and timeframe.
struct Indi_Alligator_Params_M30 : AlligatorParams {
  Indi_Alligator_Params_M30() : AlligatorParams(indi_alli_defaults, PERIOD_M30) {
    applied_price = (ENUM_APPLIED_PRICE)0;
    jaw_period = 17;
    jaw_shift = 10;
    teeth_period = 8;
    teeth_shift = 7;
    lips_period = 7;
    lips_shift = 3;
    ma_method = (ENUM_MA_METHOD)2;
    shift = 0;
  }
} indi_alli_m30;

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_Alligator_Params_M30 : StgParams {
  // Struct constructor.
  Stg_Alligator_Params_M30() : StgParams(stg_alli_defaults) {
    lot_size = 0;
    signal_open_method = 0;
    signal_open_filter = 1;
    signal_open_level = (float)0;
    signal_open_boost = 0;
    signal_close_method = 0;
    signal_close_level = (float)0;
    price_stop_method = 0;
    price_stop_level = (float)2;
    tick_filter_method = 1;
    max_spread = 0;
  }
} stg_alli_m30;
