sys = ss (-2,3,4,5)

H = idfrd (sys)

H.frequency
H.responsedata


dat = iddata (H)
dat.y
H.responsedata

dat.u           % alles 1!
dat.frequency
H.frequency