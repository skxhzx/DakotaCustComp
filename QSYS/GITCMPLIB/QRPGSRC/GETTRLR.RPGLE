640aA /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2011 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------
     *
     *  GETTRLR   Get trailer number
     *  09 March 2011
     *  Dave Sommerville
     *
     *  Revisions
     *
640 A*    03/09/11  DAS  6.40
     *      - Created
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

640aAFldrhdr3   if   e           k disk
640aAFldrhhdr4  if   e           k disk
     *
     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pwhse  Warehouse
     *      $prtid  Route ID
     *
     *    Returned Parameters
     *      $ptrlr  Trailer
     *
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pwhse            3 0
     C                   parm                    $prtid            5
     C                   parm                    $ptrlr            8

     C                   eval      *inlr = *on

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

417aA*  Get employee # for ORDT and export file.
417aAC     keyld         chain     ldrhdr3                            79
417aAC                   if        not *in79
417a C                   eval      $ptrlr = lhtrlr
     C                   else
417aAC     keyld         chain     ldrhhdr4                           79
417aAC                   if        not *in79
417a C                   eval      $ptrlr = lhhtrl
417aAC                   endif
417aAC                   endif

     C                   return
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     C     *inzsr        begsr
     *
     *   Define partial key for ORDD file.
     *
     C     keyld         klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid
     *
     C                   endsr
