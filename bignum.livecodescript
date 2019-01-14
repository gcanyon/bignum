script "bignum"

function bigAddSigned X,Y,Z
   -- returns X+Y. Allows for X,Y to be negative
   -- if Z is > 0, shifts Y to the left by Z (multiplies Y by 10^Z)
   if char 1 of X is "-" then
      if char 1 of Y is "-"  then
         return "-" & bigAdd((char 2 to -1 of X),(char 2 to -1 of Y),Z)
      else
         return bigSubtract(Y,(char 2 to -1 of X),Z)
      end if
   else if char 1 of Y is "-"  then
      return bigSubtract(X,(char 2 to -1 of Y),Z)
   else
      return bigAdd(X,Y,Z)
   end if
end bigAddSigned

function bigAdd X,Y,Z
   -- returns X+Y. X,Y must be non-negative
   -- if Z is > 0, shifts Y to the left by Z (multiplies Y by 10^Z)
   if Z > 0 then return bigAdd((char 1 to -1 - Z of X),Y) & char -Z to -1 of X
   put length(X) into lenX
   put length(Y) into lenY
   put min(lenX,lenY) into minLength
   put max(lenX,lenY) into maxLength
   put 0 into C
   repeat with i = 14 to minLength step 14
      add char -i to 13 - i of X + char -i to 13 - i of Y to C
      put char -14 to -1 of ("00000000000000" & C) before R
      delete char -14 to -1 of C
   end repeat
   repeat with j = i + 14 to maxLength step 14
      if C is empty then
         if lenX > lenY then return (char 1 to 13 - j of X) & R
         return (char 1 to 13 - j of Y) & R
      end if 
      add char -j to 13 - j of X + char -j to 13 - j of Y to C
      put char -14 to -1 of ("00000000000000" & C) before R
      delete char -14 to -1 of C
   end repeat 
   return stripLeadingZeros(C & R)
end bigAdd

function bigSubtractSigned X,Y
   -- returns X-Y. Allows for X,Y to be negative
   if char 1 of X is "-" then
      if char 1 of Y is "-"  then
         return bigSubtract(char 2 to -1 of Y,char 2 to -1 of X)
      else
         return "-" & bigAdd(char 2 to -1 of X,Y)
      end if
   else
      if char 1 of Y is "-"  then
         return bigAdd(X,char 2 to -1 of Y)
      else
         return bigSubtract(X,Y)
      end if
   end if
end bigSubtractSigned

function bigSubtract X,Y
   -- returns X-Y. X,Y must be non-negative
   if bigCompare(X,"<",Y) then return "-" & bigSubtract(Y,X)
   put 1 into C[true]
   put 0 into C[false]
   put false into cCarry
   put (length(Y) + 13) div 14 * 14 into lenY
   repeat with i = 14 to lenY step 14
      put (char -i to 13 - i of X) - C[cCarry] into xBit
      put char -i to 13 - i of Y into yBit
      put (yBit > xBit) into cCarry
      if cCarry then add 100000000000000 to xBit
      put xBit - yBit into dBit
      put char -14 to -1 of ("00000000000000" & dBit) before D
   end repeat
   repeat with i = lenY + 14 to length(X) step 14
      if cCarry is false then return (char 1 to 13 - i of X) & D
      put (char -i to 13 - i of X) - 1 into xBit
      put (xBit < 0) into cCarry
      if cCarry then add 100000000000000 to xBit
      put char -14 to -1 of ("00000000000000" & xBit) before D
   end repeat
   return stripLeadingZeros(D)
end bigSubtract

function bigTimesSigned X,Y
   -- returns X*Y. Allows for X,Y to be negative
   if char 1 of X is "-" then
      put "-" into leadChar
      delete char 1 of X
   end if
   if char 1 of Y is "-"  then
      if leadChar is "-" then put empty into leadChar else put "-" into leadChar
      delete char 1 of Y
   end if
   return leadChar & bigTimes(X,Y)
end bigTimesSigned

function bigTimes X,Y 
   -- returns X*Y.  X,Y must be non-negative
   put (5 + length(X)) div 6 * 6 into XL
   put char 1 to XL - length(X) of "0000000" before X
   put (5 + length(Y)) div 6 * 6 into YL
   put char 1 to YL - length(y) of "0000000" before y
   put 0 into sFinal
   put 0 into S
   repeat with N = XL + YL down to 13 step -6
      put max(6,N - YL) into startVal
      put min(XL,N - 6) into endVal
      if endVal - startVal > 50000 then
         repeat with M30000 = startVal to endVal step 30000
            repeat with M = M30000 to min((M30000 + 29994),min(XL,N - 6)) step 6
               add (char M - 5 to M of X) * (char N - M - 5 to N - M of Y) to S
            end repeat
            put bigAdd(sFinal,S) into sFinal
            put 0 into S
         end repeat
         put char -6 to -1 of ("000000" & sFinal) before R
         delete char -6 to -1 of sFinal
      else
         repeat with M = startVal to endVal step 6
            add (char M - 5 to M of X) * (char N - M - 5 to N - M of Y) to sFinal
         end repeat
         put char -6 to -1 of ("000000" & sFinal) before R
         delete char -6 to -1 of sFinal
      end if
   end repeat
   if (sFinal <> 0) and (sFinal is not empty) then return sFinal & R
   repeat with i = 1 to 10
      if char i of R is not "0" then exit repeat
   end repeat
   return char i to -1 of R
end bigTimes

function bigDivSigned X,D
   -- returns (X div D),(X mod D). Allows for X,D to be negative
   if char 1 of X is "-" then
      put "-" into leadChar
      delete char 1 of X
   end if
   if char 1 of D is "-"  then
      if leadChar is "-" then put empty into leadChar else put "-" into leadChar
      delete char 1 of D
   end if
   return leadChar & bigDiv(X,D)
end bigDivSigned


function bigDiv N,D
   -- returns (N div D),(N mod D). N,D must be non-negative
   put length(D) into lenD
   if lenD < 15 then return bigishDiv(X,D)
   if bigCompare(N,"<",D) then return 0,N
   put D into dArray[1]
   put min(-1,14 - lenD) into lenDbit
   put char 1 to lenDbit of D into dBitArray[1]
   repeat with i = 2 to 9
      put bigAdd(dArray[i - 1],D) into dArray[i]
      put char 1 to lenDbit of dArray[i] into dBitArray[i]
   end repeat
   put char 1 to lenD - 1 of N into nBit
   repeat with m = lenD to length(N)
      put char m of N after nBit
      if length(nBit) < lenD then
         put 0 after Q
         next repeat
      end if
      put char 1 to lenDbit of nBit into nCompareBit
      if nCompareBit >= dBitArray[5] then
         if nCompareBit >= dBitArray[8] then
            if nCompareBit >= dBitArray[9] then put 9 into C 
            else put 8 into C
         else if nCompareBit >= dBitArray[7] then put 7 into C
         else if nCompareBit >= dBitArray[6] then put 6 into C 
         else put 5 into C
      else if nCompareBit >= dBitArray[3] then
         if nCompareBit >= dBitArray[4] then put 4 into C 
         else put 3 into C
      else if nCompareBit >= dBitArray[2] then put 2 into C
      else if nCompareBit >= dBitArray[1] then put 1 into C 
      else 
         put 0 after Q
         next repeat
      end if
      if nCompareBit = dBitArray[C] and bigCompare(nBit,"<",dArray[C]) then subtract 1 from C
      put bigSubtract(nBit,dArray[C]) into nBit
      put C after Q 
   end repeat
   if Q is empty then return 0,nBit else return stripLeadingZeros(Q),nBit 
end bigDiv

function bigishDiv N,D
   -- returns (N div D),(N mod D). N,D must be non-negative
   -- works with any length N, values of D up to 14 digits
   put length(D) into lenD
   put length(N) into lenN
   put (char 1 to 15 of N) div D into Q
   put max(0,(lenN - 15)) + length(Q) into lenQ
   put (char 1 to 15 of N) mod D into char 1 to 15 of N
   put length(N) into lenNn
   repeat until lenNn <= lenD and N < D
      put max(15,lenNn) - lenN into pad0
      put lenNn into lenN
      put char pad0 to -1 of ("000000000000000" & ((char 1 to 15 of N) div D)) after Q
      put (char 1 to 15 of N) mod D into char 1 to 15 of N
      put length(N) into lenNn
   end repeat
   put char 1 to lenQ - length(Q) of "000000000000000" after Q
   if Q is empty then return 0,N else return Q,N
end bigishDiv


function bigishDiv X,D
   -- returns (X div D),(X mod D). X,D must be non-negative
   -- works only with values of D within LC's numeric limits
   put length(D) into lenD
   put length(X) into lenX
   repeat until length(X) <= lenD and X < D
      put (char 1 to 14 of X) div D into QN
      put (char 1 to 14 of X) mod D into char 1 to 14 of X
      put length(X) into lenXN
      put QN & (char 1 to lenX - lenXN - length(QN) of "000000000000000") after Q
      put lenXN into lenX
   end repeat
   if Q is empty then return 0,X else return Q,X
end bigishDiv


local zeroString

function bigDivFlawed X,D
   -- SOMETIMES RETURNS WRONG VALUES
   -- returns (X div D),(X mod D). X,D must be non-negative
   -- about 40% faster than bigDiv, but the final runthrough of the loop sometimes uses the wrong offset, so the last several digits will be wrong
   -- maybe someone will see the fix
   if bigCompare(X,"<",D) then return 0,X
   put length(D) into lenD
   if lenD < 15 then return bigishDiv(X,D)
   put 1 + char 1 to 7 of D into dProxy
   put length(dProxy) into lenDProxy
   put 8 + lenD into lenXBit
   put length(zeroString) into zLen
   repeat (lenXBit - zLen + 30) div 30
      put "000000000000000000000000000000" after zeroString
   end repeat
   put 15 into xProxyLength
   put 0 into Q
   repeat
      put length(X) into lenX
      if lenX - xProxyLength + lenDProxy < lenD then put lenX + lenDProxy - lenD into xProxyLength
      put (char 1 to xProxyLength of X) div dProxy into qBit
      put bigAdd(Q,qBit) into Q
      put char 1 to lenXBit of X into xBit
      put bigTimes(D,qBit) into sBit
      put bigSubtract(xBit,sBit) into newXBit
      if char 1 of newXBit is "-" then breakpoint
      put length(newXBit) into lenNewXBit
      put newXBit into char 1 to lenXBit of X
      if bigCompare(X,"<",D) then return Q,X
      put char 1 to ((lenXBit - lenNewXBit) - max(0,xProxyLength - lenX + lenD)) of zeroString after Q
   end repeat
end bigDivFlawed


function bigCompare X,OP,Y
   -- returns whether the operator in OP is true or false for X and Y.
   -- X,Y must be non-negative
   -- OP can be >,<,=,<=,>=
   put length(X) into lenX
   put length(Y) into lenY
   if lenX <> lenY then return (lenX > lenY) is (OP contains ">")
   repeat with i = 1 to lenX step 14
      put (char i to i + 13 of X) - (char i to i + 13 of Y) into D
      if D > 0 then return (OP contains ">")
      else if D < 0 then return (OP contains "<")
   end repeat
   return (OP contains "=")
end bigCompare


function stripLeadingZeros X
   -- returns X without any leading zeros
   -- X must be non-negative
   repeat with i = 1 to length(X)
      if char i of X is not "0" then return char i to -1 of X
   end repeat
end stripLeadingZeros

function bigCheck N,D
   put bigDiv(N,D) into BD
   put bigishDiv(N,D) into BID
   --if BD is not BID then breakpoint
   put bigTimes(item 1 of BID,D) into BP
   put bigAdd(BP,item 2 of BID) into BS
   if BS is not N then breakpoint
   return "'saul good, man"
end bigCheck
