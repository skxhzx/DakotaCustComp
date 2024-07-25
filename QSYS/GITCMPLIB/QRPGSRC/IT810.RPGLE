     *----------------------------------------------------------------
     *   Copyright (C) 1994 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  IT810     View item quantities
     *  19 August 1994
     *  Dave Sommerville
     *
     *  Revisions
     *
     *    01/12/96  DAS  2.10
     *      - Took out PIRUSER file and corresponding code and replaced
     *        with call to GETWHSE.
412 A*    09/16/99  RH   4.12
     *      - Display base item for same slot breakdown, alias,
     *        breakdown, and contract items.
     *
413 A*    11/23/99  DAS  4.13
     *      - Removed all 412 changes.
     *      - Changed display file by making the labels for the item
     *        descriptions variables.
     *      - Re-wrote routine ZZFIL2 to create more meaningfull
     *        labels and item descriptions.
     *      - Added F13=Linked items.
417aA*    08/11/04  RH   4.17a
     *      - Fix: Revised to call GETSLOTITM, if the item was an
     *        alias item for a SSB item, GETBASE would return the SSB
     *        item which is not a slot item.
     *
510aA*    02/28/07  TLJ  5.10a
     *      - Enh: For new item type Repack, call GETBASE to get
     *        parent info for heading.  Fix some heading problems.
650aA*    07/16/13  RH   6.50a
     *      - Fix: Change to NOT use neg held qty to calculate
     *        available, was actually increasing available qty.
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  21 - 30   Field input error (reverse display)
     *  90        View mode (protect all fields)
     *  91        Change mode (protect key fields)
     *  97        Alawys on (used for SFLEND keyword)
     *  98        Error on screen (sound alarm)
     *  99        Universal record indicator (very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fit810fm   cf   e             workstn
     F                                     infds(infds)
     F                                     sfile(msgrec:msgk)
     Fwarehs    if   e           k disk
     Fpiritem   if   e           k disk
     Fitemqty   if   e           k disk
     Funmesr    if   e           k disk
210 D*IRUSER IF  E           K        DISK
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a10             s              1    dim(10)
413 AD a22             s              1    dim(22)
     D desc            s             30    dim(3) ctdata perrcd(1)
413 AD lbl             s             22    dim(3) ctdata perrcd(1)
413 AD typ             s             10    dim(1) ctdata perrcd(1)
     *----------------------------------------------------------------
     *  Called program parameters
     *
     D $lparm          ds
     D  $lcmd                  1      8
     D  $lprg                  9     18
     D  $luky                 19     68
     D  $lrtn                 69     76
     D  $lerm                 77    136
     D  $lmsg                 77     80
     *
     *   Redefine key
     *
     D  $lwhse                19     21  0
     D  $litem                22     36
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D                 ds
     D  $ec                    1      2p 0
     *----------------------------------------------------------------
     *  Message control
     *
     D #msgf           c                   const('PIRMSGF   ')
     *
     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)
417a *----------------------------------------------------------------
417a *  Called programs
417a *
     D @getsi          c                   const('GETSLOTITM')
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
     *  Workstation exception data structure
     *
     D infds           ds
     D  status           *status
     D  rowin                370    370
     D  colin                371    371
     *----------------------------------------------------------------
     *  Workstation exception redefinition data structure
     *
     D                 ds
     D  row#                   1      2b 0
     D  row                    2      2
     D  col#                   3      4b 0
     D  col                    4      4
     *----------------------------------------------------------------
     * Variables
     *----------------------------------------------------------------
     D $msgf           s             10
     D #bsu1           s              5
     D #bsu2           s              5
     D #bsu3           s              5
     D #msgid          s              7
     D #msgtp          s              7
     D #odesc          s             30
     D #oitem          s             15
     D #opdsc          s             15
     D #osu1           s              5
     D #osu2           s              5
     D #osu3           s              5
     D #otype          s              1
     D #oum1           s              2
     D #oum2           s              2
     D #oum3           s              2
     D #pgmq           s             10
     D clear           s              5  0
     D cmdtkn          s              1
     D comand          s              5  0
     D e               s              2  0
     D enter           s              5  0
     D error           s              1
     D help            s              5  0
     D msgk            s              4  0
     D nxtscr          s              3
     D rolldn          s              5  0
     D rollup          s              5  0
     D sclear          s              1
     D temp10          s             10
     D warn            s              1
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PWHSE  Warehouse code.
     *      $PITEM  Item number.
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pwhse            3 0
     C                   parm                    $pitem           15
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      *in97 = *on
     C                   eval      *in90 = *off
     C                   eval      *in91 = *off
     C                   eval      error = *off
     C                   exsr      zzinz2
     C                   if        error = *on
     C                   eval      nxtscr = 'EOJ'
     C                   endif
     *
     C                   dow       nxtscr <> 'EOJ'
     C                   exsr      dspscr
     C     nxtscr        caseq     '01 '         sc1
     C     nxtscr        caseq     '02 '         sc2
     C                   endcs
     C                   enddo
     *
     *   Do some clean up before leaving.
     *
     C                   exsr      zsclr
     C                   return
     *----------------------------------------------------------------
     *  DSPSCR - Display screen
     *
     C     dspscr        begsr
     *
     *   Set ON alarm indicator if error occured
     *
     C                   if        error = *on
     C                   eval      *in98 = *on
     C                   endif
     *
     *   Overlay screen with error messages
     *
     C                   exsr      zmdmsg
     *
     *  Overlay screen with screen to be processed.
     *
     C                   if        nxtscr = '01 '
     C                   exfmt     screen1                              50
     C                   endif
     C                   if        nxtscr = '02 '
     C                   exfmt     screen2                              50
     C                   endif
     *
     *   Initialize error indicators and fields
     *
     C                   setoff                                       010203
     C                   setoff                                       040506
     C                   setoff                                       070809
     C                   setoff                                       101112
     C                   setoff                                       131415
     C                   setoff                                       161718
     C                   setoff                                       1920
     C                   setoff                                       212223
     C                   setoff                                       242526
     C                   setoff                                       272829
     C                   setoff                                       30
     C                   setoff                                       98
     C                   eval      warn = *off
     C                   eval      error = *off
     C                   eval      cmdtkn = *off
     C                   eval      e = 0
     *
     *   Initialize error subfile
     *
     C                   exsr      zmcmsg
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *     Screen initialization and wrap-up routines
     *
     *----------------------------------------------------------------
     *
     *  Screen 01 initialization
     *
     C     scr01i        begsr
     C                   eval      nxtscr = '01 '
     C                   exsr      zzdft1
     C     end01i        endsr
     *----------------------------------------------------------------
     *
     *  Screen 02 initialization
     *
     C     scr02i        begsr
     C                   eval      nxtscr = '02 '
     *
     *  Get existing record(s).
     *
     C                   exsr      zzfil2
     C     end02i        endsr
     *----------------------------------------------------------------
     *
     *              Screen Processing Routines
     *
     *----------------------------------------------------------------
     *
     *  SC1  -  Screen 1
     *
     C     sc1           begsr
     *
     *  Test for F3 - Exit
     *
     C                   if        *inkc
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   exsr      scr01i
     C                   goto      endsc1
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   eval      nxtscr = 'EOJ'
     C                   goto      endsc1
     C                   endif
     *
     *  Test for other command keys
     *
     C                   exsr      zzcmd1
     C     cmdtkn        cabeq     *on           endsc1
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk1
     C     error         cabeq     *on           endsc1
     C                   exsr      zzupd
     C     error         cabeq     *on           endsc1
     C     endsc1        endsr
     *----------------------------------------------------------------
     *
     *  SC2  -  Screen 2
     *
     C     sc2           begsr
     *
     *  Test for F5 - Refresh
     *
     C                   if        *inke
     C                   exsr      scr02i
     C                   goto      endsc2
     C                   endif
     *
     *  Test for F12 - Previous
     *
     C                   if        *inkl
     C                   exsr      scr01i
     C                   goto      endsc2
     C                   endif
     *
     *  Test for other command keys
     *
     C                   exsr      zzcmd2
     C     cmdtkn        cabeq     *on           endsc2
     *
     *  Some other key pressed.
     *
     *     Check input and write/update record.
     *
     C                   exsr      zzchk2
     C     error         cabeq     *on           endsc2
     C                   exsr      zzupd2
     C     error         cabeq     *on           endsc2
     C                   exsr      scr01i
     C     endsc2        endsr
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
     *
     *  Initialize special keys
     *
     C                   eval      enter = 0
     C                   eval      comand = 2
     C                   eval      rollup = 01122
     C                   eval      rolldn = 01123
     C                   eval      clear = 01124
     C                   eval      help = 01125
     *
     *  Initialize message handling
     *
     C                   exsr      zmimsg
     *
     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     C                   endsr
     *---------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMCMSG  Clear message record subfile
     *
     C     zmcmsg        begsr
     C                   eval      *in97 = *off
     C                   write     msgctl
     C                   eval      msgk = *zeros
     C                   write     msgclr
     C                   eval      #msgid = '*CLEAR '
     C                   eval      #msgtp = '*NULL  '
     C                   exsr      zmpmsg
     C                   endsr
     *
     *    ZMDMSG  Display message record subfile
     *
     C     zmdmsg        begsr
     C                   eval      *in97 = *on
     C                   if        msgk > 0
     C                   write     msgctl
     C                   eval      msgk = *zeros
     C                   endif
     C                   endsr
     *
     *    ZMIMSG  Initialization necessary for message subfile
     *
     C     zmimsg        begsr
     C                   eval      #pgmq = #prog
     C                   exsr      zmcmsg
     C                   endsr
     *
     *    ZMPMSG  Add message record to subfile
     *
     C     zmpmsg        begsr
     C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
     C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm                    #pgmq
     C                   parm                    #msgk
     C                   if        #msgid <> '*CLEAR '
     C                   add       1             msgk
     C                   write     msgrec
     C                   endif
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *
     *    ZSCLR   Clear screen
     *
     C     zsclr         begsr
     C                   write     clrscr
     C                   eval      sclear = *on
     C                   endsr
     *
     *    ZMQMSG  Add message record to subfile from program queue
     *
     C     zmqmsg        begsr
     C                   add       1             msgk
     C                   write     msgrec
     C                   endsr
     *
     *    ZMSMSG  Send program message to a different program msgq
     *
     C     zmsmsg        begsr
     C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
     C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid
     C                   parm                    #msgtp
     C                   parm                    #msgdt
     C                   parm                    #pgmq2           10
     C                   parm                    #msgk             4
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *      0105
     *
     C     zm0105        begsr
     C                   eval      #msgid = 'PIR0105'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR0112  Invalid range entered.
     *
     C     zm0112        begsr
     C                   eval      #msgid = 'PIR0112'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR7971  Error in writing a record.
     *
     C     zm71          begsr
     C                   eval      #msgid = 'PIR7971'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR7972  Error in updating a record.
     *
     C     zm72          begsr
     C                   eval      #msgid = 'PIR7972'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *   PIR9905  Cursor not in correct position for lookup.
     *
     C     zm9905        begsr
     C                   eval      #msgid = 'PIR9905'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     IT12210  Can't lock item record.
     *
     C     zm10          begsr
     C                   eval      #msgid = 'IT12210'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *     IT12273  Item does not exist.
     *
     C     zm73i         begsr
     C                   eval      #msgid = 'IT12273'
     C                   eval      #msgtp = '*DIAG  '
     C                   eval      $md(1) = *blanks
     C                   exsr      zmpmsg
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK1   Screen 1 error checking.
     *
     C     zzchk1        begsr
     C                   eval      error = *off
     *
     *  Verify warehouse code.
     *
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1whse
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in21 = *on
     C                   eval      *in01 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     *
     *  Verify item number
     *
     C                   eval      $lcmd = '*VERIFY '
     C                   eval      $lwhse = w1whse
     C                   eval      $litem = w1item
     C                   call      'IT900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*ERROR  '
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   movel     $lerm         errmsg
     C                   exsr      zm0105
     C                   else
     C                   if        $lrtn = '*PGMQ   '
     C                   eval      error = *on
     C                   eval      *in22 = *on
     C                   eval      *in02 = *on
     C                   eval      #msgk = $lmsg
     C                   exsr      zmqmsg
     C                   endif
     C                   endif
     C     endck1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCHK2   Screen 2 error checking.
     *
     C     zzchk2        begsr
     C                   eval      error = *off
     C     endck2        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD1   User defined command keys for screen 1.
     *
     C     zzcmd1        begsr
     C                   eval      cmdtkn = *off
     *
     *  Test for F4 - Lookup
     *
     C                   if        *inkd
     C                   eval      cmdtkn = *on
     C                   z-add     0             row#
     C                   eval      row = rowin
     C                   z-add     0             col#
     C                   eval      col = colin
     *
     C                   select
     *
     *     Warehouse.
     *
     C                   when      row# = 8
     C                   eval      *in01 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = w1whse
     C                   call      'WH900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1whse = $lwhse
     C                   endif
     *
     *     Item number.
     *
     C                   when      row# = 9
     C                   eval      *in02 = *on
     C                   eval      $lcmd = '*LOOKUP '
     C                   eval      $lwhse = w1whse
     C                   eval      $litem = w1item
     C                   call      'IT900'
     C                   parm                    $lparm
     C                   if        $lrtn = '*SELECT '
     C                   eval      w1item = $litem
     C                   endif
     *
     C                   other
     *
     *     Cursor not on a valid lookup field.
     *
     C                   eval      error = *on
     C                   exsr      zm9905
     C                   endsl
     C                   endif
     C     endcm1        endsr
     *----------------------------------------------------------------
     *
     *  ZZCMD2   User defined command keys for screen 2.
     *
     C     zzcmd2        begsr
     C                   eval      cmdtkn = *off
     *
413 A*  Test for F13 - Linked items
     *
     C                   if        *inkm
     C                   eval      cmdtkn = *on
     C                   call      'IT170CL'
     C                   parm      $pwhse        $lwhse
     C                   parm                    $pitem
     C                   parm                    $lrtn
     C                   endif
     C     endcm2        endsr
     *----------------------------------------------------------------
     *
     *  ZZDFT1   Get default values for add.
     *
     C     zzdft1        begsr
     C                   if        $pitem = *blanks
     C                   eval      w1item = *blanks
     C                   else
     C                   eval      nxtscr = 'EOJ'
     C                   endif
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZFIL2   Fill screen 2 fields with info from file.
     *
     C     zzfil2        begsr
     *
     *   Get warehouse description.
     *
     C     w1whse        chain     warehs                             79
     C                   if        *in79
     C                   eval      whdesc = desc(1)
     C                   endif
     *
     *   Initialize quanitities.
     *
     C                   clear                   iqstk1
     C                   clear                   iqstk2
     C                   clear                   iqstk3
     C                   clear                   iqalc1
     C                   clear                   iqalc2
     C                   clear                   iqalc3
     C                   clear                   iqtri1
     C                   clear                   iqtri2
     C                   clear                   iqtri3
     C                   clear                   iqtro1
     C                   clear                   iqtro2
     C                   clear                   iqtro3
     *
     *   Initialize headings
     *
     C                   eval      w2lbl1 = *blanks
     C                   eval      w2head = *blanks
     C                   eval      w2lblx = *blanks
     C                   eval      w2hedx = *blanks
     C                   eval      w2um1 = *blanks
     C                   eval      w2um2 = *blanks
     C                   eval      w2um3 = *blanks
     *
     *   Get selected item info.
     *
     C     itkey         chain     piritem                            79
     C                   if        *in79
     C                   clear                   ittype
     C                   clear                   itdesc
     C                   clear                   itpdsc
     C                   clear                   itum1
     C                   clear                   itum2
     C                   clear                   itum3
     C                   eval      ititem = w1item
     C                   eval      itdesc = desc(2)
     C     '-'           cat       itdesc:1      itdesc
     C     w1item        cat       itdesc:1      itdesc
     C                   goto      endfl2
     C                   endif
     *
     *  Save information about selected item (Item that was sent in)
     *
     C                   eval      #otype = ittype
     C                   eval      #oitem = ititem
     C                   eval      #odesc = itdesc
     C                   eval      #opdsc = itpdsc
     C                   eval      #oum1 = itum1
     C                   eval      #oum2 = itum2
     C                   eval      #oum3 = itum3
     *
     *   Get short UOM descriptions for selected item.
     *
     C                   eval      #osu1 = *blanks
     C                   eval      #osu2 = *blanks
     C                   eval      #osu3 = *blanks
     *
     C                   if        itum1 <> *blanks
     C     itum1         chain     unmesr                             77
     C                   if        not *in79
     C                   eval      #osu1 = umshrt
     C                   else
     C                   movel     itum1         #osu1
     C                   endif
     C                   endif
     *
     C                   if        itum2 <> *blanks
     C     itum2         chain     unmesr                             77
     C                   if        not *in79
     C                   eval      #osu2 = umshrt
     C                   else
     C                   movel     itum2         #osu2
     C                   endif
     C                   endif
     *
     C                   if        itum3 <> *blanks
     C     itum3         chain     unmesr                             77
     C                   if        not *in79
     C                   eval      #osu3 = umshrt
     C                   else
     C                   movel     itum3         #osu3
     C                   endif
     C                   endif
     *
     C                   eval      w2um1 = #osu1
     C                   eval      w2um2 = #osu2
     C                   eval      w2um3 = #osu3
     *
     *   Initialize base information.
     *
     C                   eval      #bitem = ititem
417aAC                   eval      #sitem = ititem
     C                   eval      #bityp = ittype
     C                   eval      #bdesc = itdesc
     C                   eval      #bpdsc = itpdsc
     C                   eval      #bum1 = itum1
     C                   eval      #bum2 = itum2
     C                   eval      #bum3 = itum3
     C                   eval      #bsu1 = #osu1
     C                   eval      #bsu2 = #osu2
     C                   eval      #bsu3 = #osu3
     *
     *  If select item is a Base item  . . .
     *    Then try to get a corresponding SSB item.
     *
     C                   if        ittype = ' '
     C                   call      'GETSSB'
     C                   parm      w1whse        $gwhse            3 0
     C                   parm      w1item        $gitem           15
     C                   parm      ' '           #bitem           15
     C                   parm                    #bdesc           30
     C                   parm                    #bpdsc           15
     C                   parm                    #bwhdp            5
     C                   parm                    #bstyp            1
     C                   parm                    #bum              2
     C                   parm                    #bum2             2
     C                   parm                    #bumq2            3 0
     C                   parm                    #bum3             2
     C                   parm                    #bumq3            3 0
     C                   parm                    #brtn             8
     C                   if        #brtn = '*FOUND  '
     C                   eval      #bityp = 'S'
     C                   endif
     C                   endif
     *
     *  If selected item is a Contract, Alias, SSB or Breakdown item . . .
     *    Then get corresponding Base item.
     *
     C                   if        ittype = 'C'  or
     C                             ittype = 'A'  or
     C                             ittype = 'S'  or
     C                             ittype = 'B'  or
510aAC                             ittype = 'R'
     C                   call      'GETBASE'
     C                   parm      w1whse        $gwhse
     C                   parm      w1item        $gitem
     C                   parm      ' '           #bitem
     C                   parm                    #bityp            1
     C                   parm                    #bdesc
     C                   parm                    #bpdsc
     C                   parm                    #bwhdp
     C                   parm                    #bstyp
     C                   parm                    #bum1             2
     C                   parm                    #bum2
     C                   parm                    #bumq2
     C                   parm                    #bum3
     C                   parm                    #bumq3
     C                   parm      ' '           #bcitm           15
     C                   parm                    #bctyp            1
     C                   parm                    #bcdsc           30
     C                   parm                    #bcpds           15
     C                   parm                    #bcwdp            5
     C                   parm                    #bcstp            1
     C                   parm                    #bcum1            2
     C                   parm                    #bcum2            2
     C                   parm                    #bcuq2            3 0
     C                   parm                    #bcum3            2
     C                   parm                    #bcuq3            3 0
     C                   parm                    #brtn
     C                   endif
417aA*   Get slot item.
417aAC                   call      @getsi
417aAC                   parm      w1whse        $gwhse
417aAC                   parm      w1item        $gitem
417aAC                   parm      ' '           #sitem           15
417aAC                   parm                    #sityp            1
417aAC                   parm                    #sdesc           30
417aAC                   parm                    #spdsc           15
417aAC                   parm                    #srtn            10
417aAC                   parm                    #smsg            60
     *
     *   Get short UOM descriptions for base item.
     *
     C                   if        #bum1 <> #oum1
     C     #bum1         chain     unmesr                             77
     C                   if        not *in79
     C                   eval      #bsu1 = umshrt
     C                   else
     C                   movel     #bum1         #bsu1
     C                   endif
     C                   endif
     *
     C                   if        #bum2 <> #oum2
     C     #bum2         chain     unmesr                             77
     C                   if        not *in79
     C                   eval      #bsu2 = umshrt
     C                   else
     C                   movel     #bum2         #bsu2
     C                   endif
     C                   endif
     *
     C                   if        #bum3 <> #oum2
     C     #bum3         chain     unmesr                             77
     C                   if        not *in79
     C                   eval      #bsu3 = umshrt
     C                   else
     C                   movel     #bum3         #bsu3
     C                   endif
     C                   endif
     *
     *   Create label for selected item
     *
     *     If selected item is a SSB item . . .
     *        Then display the breakdown 1 UOM.
     *        Otherwise use the normal UOM.
     *
     *     Note: Except for the description, the SSB fields
     *           should be identical to its Base item's fields.
     *
     C                   movea     lbl(1)        a22
     C                   if        #otype = 'S'
     C                   movea     #osu2         a22(16)
     C                   else
     C                   movea     #osu1         a22(16)
     C                   endif
     C                   movea     a22           w2lbl1
     C     w2lbl1        cat       ')':0         w2lbl1
     C                   move      ':'           w2lbl1
     *
     *   Create description for selected item
     *
     C                   movea     typ(1)        a10
     C                   movea     #otype        a10(8)
     C                   movea     a10           temp10
     *
     C     #oitem        cat       temp10:1      w2head
     C     w2head        cat       '-':1         w2head
     C     w2head        cat       #odesc:1      w2head
     *
     *   Create label and description for corresponding item.
     *
     C                   select
     *
     *     If selected item is a Base item . . .
     *        Then display its corresponding SSB item (if any)
     *        Otherwise display nothing.
     *
     C                   when      #otype = ' '
     C                   if        #bityp = 'S'
     C                   movea     lbl(3)        a22
     C                   movea     #bsu2         a22(11)
     C                   movea     a22           w2lblx
     C     w2lblx        cat       ')':0         w2lblx
     C                   move      ':'           w2lblx
     *
     C                   movea     typ(1)        a10
     C                   movea     #bityp        a10(8)
     C                   movea     a10           temp10
     *
417aD**         #BITEM    CAT  TEMP10:1  W2HEDX
417aMC     #sitem        cat       temp10:1      w2hedx
     C     w2hedx        cat       '-':1         w2hedx
     C     w2hedx        cat       #bdesc:1      w2hedx
     C                   endif
     *
     *     If selected item is a Breakdown item . . .
     *        Then display its corresponding Base item.
     *             Note: UOM is not applicable in this situation.
     *
     C                   when      #otype = 'B'
510aAC                   if        #bityp = ' '
510aAC                   movea     lbl(2)        a22
510aAC                   movea     'N/A'         a22(12)
510aAC                   movea     a22           w2lblx
510aAC     w2lblx        cat       ')':0         w2lblx
510aAC                   move      ':'           w2lblx
     *
510aAC                   movea     typ(1)        a10
510aAC                   movea     #bityp        a10(8)
510aAC                   movea     a10           temp10
     *
510aAC     #bitem        cat       temp10:1      w2hedx
510aAC     w2hedx        cat       '-':1         w2hedx
510aAC     w2hedx        cat       #bdesc:1      w2hedx
510aAC                   else
     C                   movea     lbl(2)        a22
     C                   movea     'N/A'         a22(12)
     C                   movea     a22           w2lblx
     C     w2lblx        cat       ')':0         w2lblx
     C                   move      ':'           w2lblx
     *
     C                   movea     typ(1)        a10
     C                   movea     #bityp        a10(8)
     C                   movea     a10           temp10
     *
417aD**         #BITEM    CAT  TEMP10:1  W2HEDX
417aMC     #sitem        cat       temp10:1      w2hedx
     C     w2hedx        cat       '-':1         w2hedx
     C     w2hedx        cat       #bdesc:1      w2hedx
510aAC                   endif
     *
510aA*     If selected item is a Repack item    . . .
510aA*        Then display its corresponding Base item.
510aA*
510aAC                   when      #otype = 'R'
510aAC                   movea     lbl(2)        a22
510aAC                   movea     #bsu1         a22(12)
510aAC                   movea     a22           w2lblx
510aAC     w2lblx        cat       ')':0         w2lblx
510aAC                   move      ':'           w2lblx
510aA*
510aAC                   movea     typ(1)        a10
510aAC                   movea     #bityp        a10(8)
510aAC                   movea     a10           temp10
510aA*
510aAC     #bitem        cat       temp10:1      w2hedx
510aAC     w2hedx        cat       '-':1         w2hedx
510aAC     w2hedx        cat       #bdesc:1      w2hedx
     *
     *     Otherwise . . .
     *        Then display its corresponding Base item w/UOM.
     *             Note: UOM of Base should match UOM of selected item.
     *
     C                   other
     C                   movea     lbl(2)        a22
     C                   movea     #bsu1         a22(12)
     C                   movea     a22           w2lblx
     C     w2lblx        cat       ')':0         w2lblx
     C                   move      ':'           w2lblx
     *
     C                   movea     typ(1)        a10
     C                   movea     #bityp        a10(8)
     C                   movea     a10           temp10
     *
417aD**         #BITEM    CAT  TEMP10:1  W2HEDX
417aMC     #sitem        cat       temp10:1      w2hedx
     C     w2hedx        cat       '-':1         w2hedx
     C     w2hedx        cat       #bdesc:1      w2hedx
     *
     C                   endsl
     *
     *   Get warehouse quantity record for appropriate item
     *
     *     If selected item is Base, Breakdown or SSB item . . .
     *        Then get record for that item.
     *        Otherwise get record for corresponding Base item.
     *
     C                   if        #otype = ' '  or
     C                             #otype = 'B'  or
     C                             #otype = 'C'  or
510aAC                             #otype = 'R'
     C     itkey         chain     itemqty                            78
     C                   else
     C     itkeyb        chain     itemqty                            78
     C                   endif
     C                   if        *in78
     C                   eval      w2hedx = *blanks
     C                   movel     desc(3)       w2hedx
     C     '-'           cat       w2hedx:1      w2hedx
     C     w1item        cat       w2hedx:1      w2hedx
     C                   goto      endfl2
     C                   endif
     *
     *   Calculate available quantities.
     *
     C                   eval      w2avl1 = iqstk1 - iqalc1
650a C                   if        iqhld1 > 0
     C                   eval      w2avl1 = w2avl1 - iqhld1
650a C                   endif
     *
     C                   eval      w2avl2 = iqstk2 - iqalc2
650a C                   if        iqhld2 > 0
     C                   eval      w2avl2 = w2avl2 - iqhld2
650a C                   endif
     *
     C                   eval      w2avl3 = iqstk3 - iqalc3
650a C                   if        iqhld3 > 0
     C                   eval      w2avl3 = w2avl3 - iqhld3
650a C                   endif
     *
     C     endfl2        endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
     C     zzinz         begsr
     *
     *  Define key for item file.
     *
     C     itkey         klist
     C                   kfld                    w1whse
     C                   kfld                    w1item
     *
413 A*  Define key for base item.
     *
     C     itkeyb        klist
     C                   kfld                    w1whse
417aMC                   kfld                    #sitem
417aD**                   KFLD           #BITEM
     *
     C                   eval      $lprg = #prog
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZINZ2   Program initialization. Called from main line.
     *
     C     zzinz2        begsr
     *
     *   Select first screen to display.
     *
     C                   select
     C                   when      $pitem = *blanks
210 D*R         #USER     CHAINPIRUSER              79
210 D*R         *IN79     IFEQ *ON
210 D*R                   Z-ADD1         W1WHSE
210 D*R                   ELSE
210 D*R                   Z-ADDUSWHSE    W1WHSE
210 D*R                   ENDIF
210 A*
210 AC                   call      'GETWHSE'
210 AC                   parm                    #user
210 AC     w1whse        parm      0             #whse             3 0
210 A*
     C                   exsr      scr01i
     *
     C                   other
     C                   eval      w1whse = $pwhse
     C                   eval      w1item = $pitem
     C                   exsr      scr02i
     C                   endsl
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD    Update record.
     *
     C     zzupd         begsr
     C                   eval      error = *off
     C                   exsr      scr02i
     C     endupd        endsr
     *----------------------------------------------------------------
     *
     *  ZZUPD2   Update for screen 2.
     *
     C     zzupd2        begsr
     C                   eval      error = *off
     C                   eval      nxtscr = 'EOJ'
     C     endup2        endsr
     *----------------------------------------------------------------*********
     *
     *  COMPILE TIME TABLES
     *
**
* * INVALID WAREHOUSE * *
* * INVALID ITEM * *
* * QTY RECORD NOT FOUND * *
**
Selected item (
Base item (
SSB item (
**
(Type ' ')
