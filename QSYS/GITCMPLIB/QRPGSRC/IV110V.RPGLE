      /copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *  IV110V   Define scope of inventory - Grab all vslots
     *  12 April 2008
     *  Dave Sommerville
     *----------------------------------------------------------------
     *  Revisions
530 A*    11/23/09  MLB  5.30
     *      - Fix: Revised pgm to add check to verify that slot being
     *        added is not already in INVSLOT file.
     *      - Added INVSLOT4 to program.
      *
     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Finvslot   uf a e           k disk
530 AFinvslot4  if   e           k disk
530 AF                                     rename(ivsrec:ivsrec4)
     Fvslot1    if   e           k disk
     Fvslot2    if   e           k disk
     F                                     rename(vsrec:vsrec2)
     Fslot2     if   e           k disk

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D forever         s               n

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $ppexp  - Export scope items only flag.
     *      $padj   - Adjustment code
     *
     *    Returned Parameters
     *      none
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $ppexp            1
     C                   parm                    $padj             2

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     *  Make sure VSLOT contains base slots for all virtuals in VSLOT.

     C     *loval        setll     invslot
     C                   dow       forever = forever
     C                   read      invslot
     C                   if        %eof
     C                   leave
     C                   endif

     *    See if slot is a virtual slot by looking in VSLOT file.
     *      If not, get next record.

     C     keyvs1        chain     vslot1
     C                   if        not %found
     C                   iter
     C                   endif

     *    Otherwise, get corresponding physical slot
     *      and try and add it to INVSLOT.

     C     keysl2p       chain     slot2
     C                   if        not %found
     C                   iter
     C                   endif
530 A *    Verify physical slot is not in the file.
530 AC     keyinv4       setll     invslot4
530 AC                   if        %equal(invslot4)
530 AC                   iter
530 AC                   endif

     C                   eval      ivswhs = slwhse
     C                   eval      ivswhd = slwhdp
     C                   eval      ivsasl = slaisl
     C                   eval      ivsloc = slloc
     C                   eval      ivslvl = slrlvl
     C                   eval      ivshnd = slhand
     C                   eval      ivsstp = slstyp
     C                   eval      ivsdsp = sldisp
     C                   eval      ivssta = slstat
     C                   eval      ivsitm = slitem
     C                   eval      ivssid = slside
     C                   eval      ivspex = $ppexp
     C                   eval      ivsadj = $padj
     C                   eval      ivsdsg = sldesg
     C                   eval      ivspck = slpick

     C                   write(e)  ivsrec

     C                   enddo

     *  Now, make sure INVSLOT has all virtuals the correspond to physical.

     C     *loval        setll     invslot
     C                   dow       forever = forever
     C                   read      invslot
     C                   if        %eof
     C                   leave
     C                   endif
     C                   eval      kypdsp = ivsdsp

     *    Use INVSLOT slot as a physical slot and loop through
     *    VSLOT2 file. When a record is found try to add it
     *    to INVSLOT.

     C     keyvs2        setll     vslot2
     C                   dow       forever = forever
     C*                  read      vslot2
     C     keyvs2        reade     vslot2
     C                   if        %eof
     C                   leave
     C                   endif

     C     keysl2v       chain     slot2
     C                   if        not %found
     C                   iter
     C                   endif
530 A *    Verify physical slot is not in the file.
530 AC     keyinv4       setll     invslot4
530 AC                   if        %equal(invslot4)
530 AC                   iter
530 AC                   endif

     C                   eval      ivswhs = slwhse
     C                   eval      ivswhd = slwhdp
     C                   eval      ivsasl = slaisl
     C                   eval      ivsloc = slloc
     C                   eval      ivslvl = slrlvl
     C                   eval      ivshnd = slhand
     C                   eval      ivsstp = slstyp
     C                   eval      ivsdsp = sldisp
     C                   eval      ivssta = slstat
     C                   eval      ivsitm = slitem
     C                   eval      ivssid = slside
     C                   eval      ivspex = $ppexp
     C                   eval      ivsadj = $padj
     C                   eval      ivsdsg = sldesg
     C                   eval      ivspck = slpick

     C                   write(e)  ivsrec

     C                   enddo

     C                   enddo

     *  Bye, Bye

     C                   eval      *inlr = *on
     C                   return

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

     C     *inzsr        begsr
530 A*  Define key for SLOT2 (virtual)
530 A
530 AC     keyinv4       klist
530 AC                   kfld                    slwhse
530 AC                   kfld                    slwhdp
530 AC                   kfld                    sldisp

     C     *like         define    ivsdsp        kypdsp
     *  Define key for VSLOT1 (virtual slot)

     C     keyvs1        klist
     C                   kfld                    ivswhs
     C                   kfld                    ivswhd
     C                   kfld                    ivsdsp

     *  Define key for VSLOT2 (physical slot)

     C     keyvs2        klist
     C                   kfld                    ivswhs
     C                   kfld                    ivswhd
     C                   kfld                    kypdsp
520aDC*                  kfld                    ivsdsp

     *  Define key for SLOT2 (virtual)

     C     keysl2v       klist
     C                   kfld                    vswhse
     C                   kfld                    vswhdp
     C                   kfld                    vsdisp

     *  Define key for SLOT2 (physical)

     C     keysl2p       klist
     C                   kfld                    vswhse
     C                   kfld                    vswhdp
     C                   kfld                    vspdis

     C                   endsr
