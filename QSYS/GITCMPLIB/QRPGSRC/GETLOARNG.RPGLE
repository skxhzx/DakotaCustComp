     *----------------------------------------------------------------
     *   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  GETLOARNG  Get route loading start and end time range.
     *  13 January 2009
     *  Retha Davis
     *
     *  Revisions
     *
520 A*   01/13/09  RBD  5.20
     *     - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Foptions   if   e           k disk

     *----------------------------------------------------------------
     *  *LOADER  -  Loader options
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPSTTM  -  Start time for a day's routes.
     *    OPENTM  -  End time for a day's routes.
     *
     * Data structure
     *
     D opdata          ds
     D  opsttm                 1      6  0
     D  opentm                 7     12  0
     D  optend               117    117

     *----------------------------------------------------------------
     *  Input parameters
     *
     *      $whse      -  warehouse
     *
     *  Output parameters
     *
     *      $opsttm    -  route loading start time
     *      $opentm    -  route loading end time
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $whse             3 0
     C                   parm                    $opsttm           6 0
     C                   parm                    $opentm           6 0

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     C                   exsr      getrange
     C                   return

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

     C     *inzsr        begsr

     *  Define key for OPTIONS file.

     C     keyop         klist
     C                   kfld                    $whse
     C                   kfld                    opcode

     C                   endsr

     *----------------------------------------------------------------
     *  getrange      Get route loading start and end time range.
     *----------------------------------------------------------------

     C     getrange      begsr

     *  Get loader options.

     C                   eval      opcode = '*LOADER'
     C     keyop         chain     options
     C                   if        not %found
     C                   eval      opsttm = 0
     C                   eval      opentm = 0
     C                   endif

     C                   eval      $opsttm = opsttm
     C                   eval      $opentm = opentm

     C                   endsr

