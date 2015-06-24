// refs https://en.wikipedia.org/wiki/Q_(number_format)
// refs http://www.atmel.com/images/doc1631.pdf
// results of mul_q*_q* are approximated

var mul_q16_q16 = function(x, y) {
  var result  = high_byte(low_byte(x) * high_byte(y));
  result     += high_byte(high_byte(x) * low_byte(y));
  result     += high_byte(x) * high_byte(y);
  return result;
}

var mul_q15_q15 = function(x, y) {
  var result  = high_sbyte(low_byte(x) * high_sbyte(y));
  result     += high_sbyte(high_sbyte(x) * low_byte(y));
  result     += high_sbyte(x) * high_sbyte(y);
  return result;
}

var mul_q15_q16 = function(x, y) {
  var result  = high_byte(low_byte(x) * high_byte(y));
  result     += high_sbyte(high_sbyte(x) * low_byte(y));
  result     += high_sbyte(x) * high_byte(y);
  return result;
}

var mul_q16_q8 = function(x, y) {
  var result  = high_byte(low_byte(x) * y);
  result     += high_byte(x) * y;
  return result;
}

var mul_q15_q7 = function(x, y) {
  var result  = high_sbyte(low_byte(x) * y);
  result     += high_sbyte(x) * y;
  return result;
}
