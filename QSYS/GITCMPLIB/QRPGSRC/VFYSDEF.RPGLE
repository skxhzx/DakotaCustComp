     H COPYRIGHT('(c) Copyright BFC Software, Inc - 2001')

     *----------------------------------------------------------------
     *   Copyright (C) 2001 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  VFYSDEF   Verify slot definition code
     *  13 October 2001
     *  Dave Sommerville
     *
416  *    10/13/01  DAS  4.16
     *      - Created
     *
416a *    10/17/01  DAS  4.16a
     *      - Added $pmessage parameter.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fslotdef   if   e           k disk

     *----------------------------------------------------------------
     *  Constants
     *----------------------------------------------------------------

     D $codedesc       c                   const('Slot Definition Code')
     D $notfound       c                   const('INVLDSDEF')

      *----------------------------------------------------------------
      *  Parameters
      *
      *    Input Parameters
      *      $pcommand  *OPEN    - Open program and return.
      *                 *CLOSE   - Close program with LR and return.
      *                 *VERIFY  - Verify warehouse.
      *      $pprg      Program to send messages back to.
      *                 If not using program msg queue, leave blank or *NONE
      *      $pwhse     Warehouse
      *      $pcode     Code to verify.
      *
      *    Returned Parameters
416aA *      $pdesc     Adjustment code description
      *      $preturn   *OK      - Code found.
      *                 *NOTFND  - Code not found.
      *                 *PGMQ    - Code not found. Message sent to pgmq
      *      $pmessage  Error message.
      *      $pmsgk     Key of message sent to program msg queue.
      *
      *----------------------------------------------------------------

      *----------------------------------------------------------------
      *  Let the show begin .....
      *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pcommand         8
     C                   parm                    $pprg            10
     C                   parm                    $pwhse            3 0
     C                   parm                    $pcode            2
     C                   parm                    $pdesc           30
     C                   parm                    $preturn         10
     C                   parm                    $pmessage        60
     C                   parm                    $pmsgk            4

     C                   eval      $pdesc    = ' '
     C                   eval      $preturn  = ' '
     C                   eval      $pmessage = ' '
     C                   eval      $pmsgk    = ' '

     *----------------------------------------------------------------
     * Main line
     *----------------------------------------------------------------

     *  See if we are just opening or closing program.

     C                   select

     C                   when      $pcommand = '*OPEN'
     C                   goto      bottom

     C                   when      $pcommand = '*CLOSE'
     C                   eval      *inlr = *on
     C                   goto      bottom

     C                   endsl

     *  Validate code.

     C     filekey       chain     slotdef

     *    Code found.

     C                   if        %found
     C                   eval      $pdesc = sddesc
     C                   eval      $preturn = '*OK'
     C                   goto      bottom
     C                   endif

     *    Code not found.

     C                   if        $pprg = '*NONE' or $pprg = ' '
     C                   eval      $pmessage = 'Invalid ' + $codedesc + ' '
     C                                       + '(' + %trim($pcode) + ')'
     C                   eval      $preturn = $notfound
     C                   else
     C                   eval      $preturn = '*PGMQ'
     C                   exsr      zm1001
416aAC                   endif

     C     bottom        tag

     C                   return

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

     C     *inzsr        begsr

     *  Define key for SLOTDEF file.

     C     filekey       klist
     C                   kfld                    $pwhse
     C                   kfld                    $pcode

     C                   endsr

     C*----------------------------------------------------------------
     C*    ZMSMSG  Send program message to a different program msgq
     C*----------------------------------------------------------------
     C     zmsmsg        begsr
     C                   call      'PUTMSG'
     C                   parm      'PIRMSGF'     #msgf            10
     C                   parm                    #msgid            7
     C                   parm                    #msgtp            7
     C                   parm                    #msgdt          128
     C                   parm      $pprg         #pgmq            10
     C                   parm                    #msgk             4
     C                   endsr

     C*----------------------------------------------------------------
     C*     PIR1001  Invalid code.
     C*----------------------------------------------------------------
     C     zm1001        begsr
     C                   eval      #msgid = 'PIR1001'
     C                   eval      #msgtp = '*DIAG'
     C                   eval      #msgdt = $codedesc
     C                   exsr      zmsmsg
     C                   eval      $pmsgk = #msgk
     C                   endsr
