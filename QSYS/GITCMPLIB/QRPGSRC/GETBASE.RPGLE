      /COPY QCOPYSRC,HSPECS
     *----------------------------------------------------------------
     *   Copyright (C) 1999 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  GETBASE   Get Base item information.
     *  31 May 1999
     *  Dave Sommerville
     *
     *  Revisions
     *
650aA*    03/15/13  KDE  6.50a
     *      - Enh: Added code to allow base item to be passed when
     *        Repack Item.  Repack Items will no longer be stored
     *        in ITEMLNK.  Therefore the code change allows this
     *        program to pass base item from KITCOMP when called
     *        Also converted to ILE
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fpiritem   if   e           k disk
     Fitemlnk   if   e           k disk
     Fkitcomp   if   e           k disk
     *----------------------------------------------------------------
     *
     *  Input parameters
     *
     *     $PWHSE   -  Warehouse
     *     $PITEM   -  Contract, Alias, Same Slot Breakdown or Different
     *                 Slot Breakdown item number.
     *
     *  Output parameters
     *
     *     $PBITM   - Base item number
     *     $PITYP   - Base item type
     *     $PDESC   - Base description
     *     $PPDSC   - Base pack description
     *     $PWHDP   - Base department
     *     $PSTYP   - Base section
     *     $PUM     - Base unit of measure code
     *     $PUM2    - Base breakdown 1 unit of measure code
     *     $PUMQ2   - Base breakdown 1 quantity
     *     $PUM3    - Base breakdown 2 unit of measure code
     *     $PUMQ3   - Base breakdown 2 quantity
     *     $PCBIT   - Contract Base item number
     *     $PCBTY   - Contract Base item type
     *     $PCBDS   - Contract Base description
     *     $PCBPD   - Contract Base pack description
     *     $PCBWD   - Contract Base department
     *     $PCBST   - Contract Base section
     *     $PCBU1   - Contract Base unit of measure code
     *     $PCBU2   - Contract Base breakdown 1 unit of measure code
     *     $PCBQ2   - Contract Base breakdown 1 quantity
     *     $PCBU3   - Contract Base breakdown 2 unit of measure code
     *     $PCBQ3   - Contract Base breakdown 2 quantity
     *     $PRTN    - *OK      -  Base item found
     *                *ERROR   -  Base item not found
     *
     *----------------------------------------------------------------
     *
     *  Variables
     D forevr          s              1
     D kyitem          s                   like($pitem)
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pwhse            3 0
     C                   parm                    $pitem           15
     C                   parm                    $pbitm           15
     C                   parm                    $pityp            1
     C                   parm                    $pdesc           30
     C                   parm                    $ppdsc           15
     C                   parm                    $pwhdp            5
     C                   parm                    $pstyp            1
     C                   parm                    $pum1             2
     C                   parm                    $pum2             2
     C                   parm                    $pumq2            3 0
     C                   parm                    $pum3             2
     C                   parm                    $pumq3            3 0
     C                   parm                    $pcbit           15
     C                   parm                    $pcbty            1
     C                   parm                    $pcbds           30
     C                   parm                    $pcbpd           15
     C                   parm                    $pcbwd            5
     C                   parm                    $pcbst            1
     C                   parm                    $pcbu1            2
     C                   parm                    $pcbu2            2
     C                   parm                    $pcbq2            3 0
     C                   parm                    $pcbu3            2
     C                   parm                    $pcbq3            3 0
     C                   parm                    $prtn             8
     *----------------------------------------------------------------
     *  Main line
     *
     *    Initialize return parameters.
     *
650aD*                    CLEAR$PBITM
650aD*                    CLEAR$PITYP
     C                   clear                   $pdesc
     C                   clear                   $ppdsc
     C                   clear                   $pstyp
     C                   clear                   $pum1
     C                   clear                   $pum2
     C                   clear                   $pumq2
     C                   clear                   $pum3
     C                   clear                   $pumq3
     C                   clear                   $pcbit
     C                   clear                   $pcbty
     C                   clear                   $pcbds
     C                   clear                   $pcbpd
     C                   clear                   $pcbst
     C                   clear                   $pcbu1
     C                   clear                   $pcbu2
     C                   clear                   $pcbq2
     C                   clear                   $pcbu3
     C                   clear                   $pcbq3
     C                   eval      $prtn = '*OK     '
     *
     *    Get corresponding base item.
     *
     C                   eval      kyitem = $pitem
     C                   dow       forevr = forevr
     *
     *      Get corresponding base item from link file
     *
650aAC                   if        $pityp = 'R'  and
650aAC                             $pbitm = ' '
650aA*      IF Repack Item and component is not passed then read
650aA*         first component and pass back
650aAC     keykit        setll     kitcomp
650aAC     keykit        reade     kitcomp                                79
650aAC                   if        not *in79
650aAC                   eval      ilitm2 = kccitm
650aAC                   eval      $pbitm = kccitm
650aAC                   else
650aAC     keyil         chain     itemlnk                            79
650aAC                   if        *in79
650aAC                   eval      $prtn = '*ERROR  '
650aAC                   leave
650aAC                   endif
650aAC                   endif
650aAC                   else
650aAc                   if        $pityp <>'R'
     C     keyil         chain     itemlnk                            79
     C                   if        *in79
     C                   eval      $prtn = '*ERROR  '
     C                   leave
     C                   endif
     C                   eval      $pbitm = ilitm2
650aAc                   else
650aAc                   eval      ilitm2 = $pbitm
650aAc                   endif
650aAC                   endif
     *
     *      Get corresponding base item from item file.
     *
     C     keyit         chain     piritem                            78
     C                   if        *in78
     C                   eval      $prtn = '*ERROR  '
     C                   leave
     C                   endif
     C                   eval      $pityp = ittype
     C                   eval      $pdesc = itdesc
     C                   eval      $ppdsc = itpdsc
     C                   eval      $pwhdp = itwhdp
     C                   eval      $pstyp = itstyp
     C                   eval      $pum1 = itum1
     C                   eval      $pum2 = itum2
     C                   eval      $pumq2 = itumq2
     C                   eval      $pum3 = itum3
     C                   eval      $pumq3 = itumq3
     *
     *      Get corresponding Contract base item from item file.
     *
     C                   eval      $pcbit = ilitm3
     C                   if        ilitm3 <> *blanks
     C     keyit         chain     piritem                            78
     C                   if        *in78
     C                   eval      $prtn = '*ERROR  '
     C                   leave
     C                   endif
     C                   eval      $pcbty = ittype
     C                   eval      $pcbds = itdesc
     C                   eval      $pcbpd = itpdsc
     C                   eval      $pcbwd = itwhdp
     C                   eval      $pcbst = itstyp
     C                   eval      $pcbu1 = itum1
     C                   eval      $pcbu2 = itum2
     C                   eval      $pcbq2 = itumq2
     C                   eval      $pcbu3 = itum3
     C                   eval      $pcbq3 = itumq3
     C                   endif
     *
     C                   leave
     C                   enddo
     *
     C                   return
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
     C                   eval      forevr = *off
     *
     *  Define key for PIRITEM file.
     *
     C     keyit         klist
     C                   kfld                    $pwhse
     C                   kfld                    ilitm2
     *
     *  Define key for KITCOMP file.
     *
     C     keykit        klist
     C                   kfld                    $pwhse
     C                   kfld                    $pitem
     *
     *  Define key for PIRITEM file.
     *
     C     keyit3        klist
     C                   kfld                    $pwhse
     C                   kfld                    ilitm3
     *
     *  Define key for ITEMLNK file.
     *
     C     keyil         klist
     C                   kfld                    $pwhse
     C                   kfld                    kyitem
     *
     C                   endsr
