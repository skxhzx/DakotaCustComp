500gA /COPY *libl/qcopysrc,hspecs

     *----------------------------------------------------------------
     *   BFC Software, Inc.
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  SPLITSTR    Split string
     *  30 January 2017
     *  Kenneth Elder / Dave Sommerville
     *
416  *    01/30/17  DAS  7.10
     *      - Created
     *----------------------------------------------------------------
     *
     *  This routine is based on a split routine Kenneth found at
     *
     *    www.sausagetools.com/rpgle-split
     *
     *  Example:
     *
     *   If string "blue+++green+++yellow+++fuchsia" with
     *   delimiter "+++" is passed in, the returned array
     *   would contain "blue", "green", "yellow", and "fuchsia".
     *
     *   See program TSTSPLITST.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      strToSplit  Delimited string to split
     *      delimiter   Delimiter character(s) to split on
     *
     *    Returned Parameters
     *      strArray    Array of extracted values
     *
     *----------------------------------------------------------------

     D splitstr        pr                  extpgm('SPLITSTR')
710 AD  strToSplit                 1000    const varying
710 AD  delimiter                     3    const varying
     D  strArray                    100    dim(50)

     D splitstr        pi
710 AD  strToSplit                 1000    const varying
710 AD  delimiter                     3    const varying
     D  strArray                    100    dim(50)

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

710 AD startPos        s             10i 0
710 AD endPos          s             10i 0
710 AD foundPos        s             10i 0
710 AD increment       s             10i 0
710 AD index           s              5i 0
710 AD maxIndex        s              5i 0

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

710 A  clear strArray;

710 A  if strToSplit = '';
         return;
710 A  endif;

710 A  increment = %len(delimiter);
710 A  startPos = 1;
710 A  endPos = %len(strToSplit) + 1;
710 A  index = 0;
710 A  maxIndex = %elem(strArray);

710 A  dou foundPos = endPos or index = maxIndex;
710 A     foundPos = %scan(delimiter: strToSplit: startPos);
710 A     if foundPos = 0;
710 A        foundPos = endPos;
710 A     endif;
710 A     index += 1;
710 A     strArray(index) = %subst(strToSplit: startPos: foundPos - startPos);
710 A     startPos = foundPos + increment;
710 A  enddo;

       return;
      /end-free
