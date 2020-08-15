/*
 * @file
 * Defines default strategy parameter values for the given timeframe.
 */

// Defines indicator's parameter values for the given pair symbol and timeframe.
struct Indi_Alligator_Params_H8 : Indi_Alligator_Params {
  Indi_Alligator_Params_H8() : Indi_Alligator_Params(indi_alli_defaults, PERIOD_H8) { shift = 0; }
} indi_alli_h8;

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_Alligator_Params_H8 : StgParams {
  // Struct constructor.
  Stg_Alligator_Params_H8() : StgParams(stg_alli_defaults) {
    lot_size = 0;
    signal_open_method = 0;
    signal_open_filter = 1;
    signal_open_level = 0;
    signal_open_boost = 0;
    signal_close_method = 0;
    signal_close_level = 0;
    price_limit_method = 0;
    price_limit_level = 2;
    tick_filter_method = 1;
    max_spread = 0;
  }
} stg_alli_h8;
