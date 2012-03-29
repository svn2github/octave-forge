function [r, sv, n] = identtest (dat, s = [], n = [], ldwork)

  [r, sv, n] = slitest (dat.y{1}, dat.u{1}, s, ldwork);

endfunction
