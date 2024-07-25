     H COPYRIGHT('(c) Copyright BFC Software, Inc - 2001')

     *----------------------------------------------------------------
     *   Copyright (C) 2001 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  VFYDESG   Verify designation code
     *  13 October 2001
     *  Dave Sommerville
     *
416  *    10/13/01  DAS  4.16
     *      - Created
     *
416a *    10/17/01  DAS  4.16a
     *      - Added option *VFY&ADD to create code if not found.
     *      - Added $pmessage parameter.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * File Specs
     *----------------------------------------------------------------

     Fdesig     uf a e           k disk
     F                                     infds(file1ds)

     *----------------------------------------------------------------
     *  Constants
     *----------------------------------------------------------------

     D $codedesc       c                   const('Designation Area')
     D $notfound       c                   const('INVLDDESG')

     *----------------------------------------------------------------
     *  File info data structures
     *----------------------------------------------------------------

     D File1DS         ds
     D  f1filename             1      8
     D  f1openind              9      9
     D  f1endoffile           10     10
     D  f1status              11     15  0
     D  f1opercode            16     21
     D  f1routine             22     29
     D  f1stmtnbr             30     37
     D  f1recordcd            38     45
     D  f1messageid           46     52
     D  f1sourceid            53     54

      *----------------------------------------------------------------
      *  Parameters
      *
      *    Input Parameters
      *      $pcommand  *OPEN    - Open program and return.
      *                 *CLOSE   - Close program with LR and return.
      *                 *VERIFY  - Verify warehouse.
      *      $pprg      Program to send messages back to.
      *                 If not using program msg queue, leave blank or *NONE
      *      $pcode     Code being verified.
      *
      *    Returned Parameters
416aA *      $pdesc     Adjustment code description
      *      $preturn   *OK      - Code found.
      *                 *NOTFND  - Code not found.
      *                 *PGMQ    - Code not found. Message sent to pgmq
      *      $pmessage  Error message
      *      $pmsgk     Key of message sent to program msg queue.
      *
      *----------------------------------------------------------------

      *----------------------------------------------------------------
      *  Let the show begin .....
      *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pcommand         8
     C                   parm                    $pprg            10
     C                   parm                    $pcode            5
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

     *  Code is optional so blank is allowed.

     C                   if        $pcode = ' '
     C                   eval      $pdesc = ' '
     C                   eval      $preturn = '*OK'
     C                   goto      bottom
     C                   endif

     *  Validate code.

     C     $pcode        chain(n)  desig

     *    Code found.

     C                   if        %found
     C                   eval      $pdesc = dsdesc
     C                   eval      $preturn = '*OK'
     C                   goto      bottom
     C                   endif

     *    Code not found.

     *      Are we supposed to add it?

     C                   select
     C                   when      $pcommand = '*VFY&ADD'
     C                   eval      dscode = $pcode
     C                   eval      dsdesc = '** Created by VFYDESG **'
     C                   write(e)  dsrec
     C                   if        %error
     C                   eval      $preturn = 'WRITEERROR'
     C                   eval      $pmessage = 'Error on Write for '
     C                                       + $codedesc + ' '
     C                                       + '(' + %trim($pcode) + ')'
     C                                       + '-' + f1messageid
     C                   else
     C                   eval      $pdesc = dsdesc
     C                   eval      $preturn = '*CREATED'
     C                   eval      $pmessage = $codedesc + ' '
     C                                       + '"' + %trim($pcode) + '"'
     C                                       + ' created.'
     C                   endif

     *      Otherwise, send back error.

     C                   other
     C                   eval      $pdesc = ' '
     C                   if        $pprg = '*NONE' or $pprg = ' '
     C                   eval      $preturn = $notfound
     C                   eval      $pmessage = 'Invalid ' + $codedesc + ' '
     C                                       + '(' + %trim($pcode) + ')'
     C                   else
     C                   eval      $preturn = '*PGMQ'
     C                   exsr      zm1001
416aAC                   endif

416aAC                   endsl

     C     bottom        tag

     C                   return

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
