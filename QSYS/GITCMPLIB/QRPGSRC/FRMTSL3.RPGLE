      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2000 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  FRMTSL3   Format dpt/asl/dsp
     *  28 May 2002
     *  Roxanne Harrison
     *   - Created using FRMTLS2
     *
     *  Revisions
     *
     *    04/11/04  DAS  5.00
     *      - Converted to ILE
     *      - Re-wrote using ILE functions.
     *      - Removed all old code.
     *      - If not slot exists it will send back 'NO SLOT'
     *
600 A*    04/25/08  DAS  6.00  P#00045
     *      - License Tracking
     *
     *----------------------------------------------------------------
     *  Program info data structure
     *
     D                sds
     D  #prog            *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PWHDP  Department
     *      $PAISL  Aisle
     *      $PDISP  Slot display
     *
     *    Returned Parameters
     *      $PSTR   Formated string.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pwhdp            5
     C                   parm                    $paisl            3
     C                   parm                    $pdisp           12
     C                   parm                    $pstr            38
     *----------------------------------------------------------------
     *  Main line
     *
     C                   select

     C                   when      $pwhdp = ' '
     C                             and $paisl = ' '
     C                             and $pdisp = ' '
     C                   eval      $pstr = 'NO SLOT'

     C                   when      $pwhdp <> ' '
     C                             and $paisl = ' '
     C                             and $pdisp = ' '
     C                   eval      $pstr = %subst($pwhdp:1:1)
     C                                   + '/NO SLOT'

     C                   other
     C                   eval      $pstr = %subst($pwhdp:1:1)
     C                                   + '/'
     C                                   + %trim($paisl)
     C                                   + '/'
     C                                   + %trim($pdisp)

     C                   endsl
     *
     C                   return
