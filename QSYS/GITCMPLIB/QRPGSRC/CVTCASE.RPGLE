      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     * Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     * BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  CVTCASE     Convert character case
     *  23 November 2009
     *  Dave Sommerville
     *
     *  Revisions
     *
610 A*    11/23/09  DAS  6.10
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Input Parameters
     *----------------------------------------------------------------

     D pCmd            s             10
     D pIn             s            500
     D pOut            s            500

     *----------------------------------------------------------------
     *  Translation strings
     *----------------------------------------------------------------

     D   xupper        C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     D   xlower        C                   'abcdefghijklmnopqrstuvwxyz'

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PCMD   *UPR2LOW    = Translate uppercase to lowercase
     *              *LOW2UPR    = Translate lowercase to uppercase
     *      $PIN    Input string
     *
     *    Returned Parameters
     *      $POUT   Output string
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pCmd
     C                   parm                    pIn
     C                   parm                    pOut

     C                   select

     C                   when      pCmd = '*UPR2LOW'
     C     xupper:xlower xlate(p)  pIn           pOut

     C                   when      pCmd = '*LOW2UPR'
     C     xlower:xupper xlate(p)  pIn           pOut

     C                   other
     C                   eval      pOut = pIn

     C                   endsl

     C                   return
