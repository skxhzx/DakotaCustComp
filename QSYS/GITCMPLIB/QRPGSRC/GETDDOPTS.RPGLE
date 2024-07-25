      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  GETDDOPTS - Get Drag Drop Options
     *  09 January 2009
     *  Chuck Manny
     *
     *----------------------------------------------------------------
     *  Revisions:
     *
     *    01/09/09  CWM  5.20
     *      - Created
520aA*    02/02/09  MLB  5.20a
     *      - Enh: Revised length of poptstr to 2048 from 1024.
     *      - Added %trim to two portions of the string building.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     fddopts    if   e           k disk

     *----------------------------------------------------------------
     *  Constants
     *----------------------------------------------------------------

     d crlf            c                   Const(x'0D25')

     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

520aDd* pOptStr         s           1024A   varying
520aMd pOptStr         s           2048A   varying

     *----------------------------------------------------------------
     * Let the show begin ...
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pOptStr

     *----------------------------------------------------------------
     * Main Line
     *----------------------------------------------------------------

     c     *loval        setll     ddopts
     c                   dou       %eof(ddopts)
     c                   read      ddopts

     c                   if        %eof(ddOpts)
     c                   leave
     c                   else
     c                   eval      pOptStr  = %trim(pOptStr)
     c                                      + %trim(docode)
     C                                      + '='
     c                                      + %trim(dovalue)
     c                                      + crlf
     c                   endIf

     c                   endDo

     c                   eval      *inlr = *on
