     Hoption(*srcstmt : *nodebugio)
     *----------------------------------------------------------------
     *   Copyright (C) 2003 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  UPDSLTPOS    Update Slot Position file
     *  31 October 2003
     *  Max Blacknik
     *
     *----------------------------------------------------------------
     *  Revisions
     *
417 A*    11/10/03  MLB  4.17
     *      - Created.
417aA*    12/13/03  DAS  4.17a
     *      - Converted to ILE.
     *      - Added standard variables.
     *      - Changed 'forevr' to 'forever'
     *      - Added *PULL and *PUSH commands.
417bA*    12/14/03  MLB  4.17b
     *      - Added *PUSH2 command.
417cA*    12/14/03  DAS  4.17c
     *      - Revised to not update increment/decrement pos = 0
     *      - Added *UPDLOC0 to update all pallet position to 0.
417dA*    12/16/03  DAS  4.17d
     *      - Revised MOVBCK routine to not check for overflow.
     *        Re: Field $lspos is used in MOVBCK for the maximun pallet
     *        positions in the slot, but is used in UPDLOC for the
     *        new pallet position. However, both routines are called
     *        from the PUSH2 routine.
500 A*    09/03/04  DAS  5.00
     *      - Added command *RTNALL.
     *      - Added file SLOTPOS2.
500bA*    09/13/05  DAS/RH  5.00b
     *      - Reverse 5.00 changes, this version should not be used
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions:
     *
     *----------------------------------------------------------------
     *  Indicator usage
     *
     *  79        Chain indicator
     *  99        Universal record indicator (Very temporary usage)
     *
     *----------------------------------------------------------------
     *  File Specs
     *
     Fslotpos   uf a e           k disk
     Fslotpos1  uf   e           k disk
     F                                     rename(sprec:sprec1)
500 AFslotpos2  if   e           k disk
500 AF                                     rename(sprec:sprec2)
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D a2              s              1    dim(2)
     D a10             s              1    dim(10)
     D a75             s              1    dim(75)
     D fkey            s             50    dim(10)
     D ukey            s             50    dim(10)
     D $podsc          s             63    dim(3)
     D desc            s             20    dim(1) ctdata perrcd(1)
     *----------------------------------------------------------------
     *  Program parameters
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
     D  $lwhdp                22     26
     D  $laisl                27     29
     D  $lloc                 30     31p 0
     D  $lrlvl                32     33  0
     D  $lhand                34     35
     D  $lpos                 36     37p 0
     D  $lpdsp                38     49
     D  $lvdsp                50     61
     D  $lpllc                62     62
     D  $lspos                63     64p 0
     *
     D $ldata          ds
     D  $ldend                 1    100

417aA*----------------------------------------------------------------
417aA*  Standard variables
417aA*----------------------------------------------------------------
417aA
417aA /Copy qcopysrc,c#stdvar

417aA*----------------------------------------------------------------
417aA*  Variables
417aA*----------------------------------------------------------------
417aA
417aAD savpos          s                   like($lpos)

     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     D                 ds
     D  $ec                    1      2p 0
     *
     *----------------------------------------------------------------
     *  Message control
     *
     D #msgf           c                   const('PIRMSGF   ')
     *
     D                 ds
     D  #msgdt                 1    128
     D  $md                    1    128
     D                                     DIM(128)
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
     *
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $LCMD   *ADDPOS  - Add new pallet position.
     *              *GETMXPL - Retrieve maximum pallets in slot.
     *              *UPDLOC  - Update pallet location and position.
417cA*              *UPDLOC0 - Update pallet position to 0.
     *              *MOVBACK - Move pallets in location Back.
     *              *MOVEFWD - Move pallets in location Forward.
417aA*              *PULL    - Pull pallet out of slot.
417aA*              *PUSH    - Push pallet into slot.
417bA*              *PUSH2   - Push pallet into slot - Update location.
500 A*              *RTNALL  - Return all pallets to slot.
     *      $LPRG   Program to send messages back to.
     *      $LUKY   Contains key to be verified.
     *      $LDATA  Future in/out work fields.
     *
     *    Returned Parameters
     *      $LDATA  Future in/out work fields.
     *      $LUKY   Contains first key selected.
     *      $LRTN   blank    - No problem encountered.
     *              *OK      - Update operation completed successfully
     *              *CANCEL  - CMD12 was entered
     *              *ERROR   - Error occured. Message in $LERM
     *              *PGMQ    - Error occured. Message sent to pgmq.
     *      $PERM   Error message or pointer to message in pgmq.
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $lparm
     C                   parm                    $ldata
     *
     *----------------------------------------------------------------
     *  Main line
     *
     C                   eval      $lrtn = *blanks
     C                   eval      $lerm = *blanks
     *
     C                   exsr      zzinit
     *
     C     $lcmd         caseq     '*ADDPOS '    addpos
     C     $lcmd         caseq     '*GETMXPL'    getmxp
     C     $lcmd         caseq     '*UPDLOC '    updloc
417cAC     $lcmd         caseq     '*UPDLOC0'    updloc0
     C     $lcmd         caseq     '*MOVBACK'    movbck
     C     $lcmd         caseq     '*MOVEFWD'    movfwd
417aAC     $lcmd         caseq     '*PULL'       pull
417aAC     $lcmd         caseq     '*PUSH'       push
417bAC     $lcmd         caseq     '*PUSH2'      push2
500 AC     $lcmd         caseq     '*RTNALL'     rtnall
     C                   endcs
     *
     C                   return
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
     *   Define key for SLOTDEF
     *
     C     spkey         klist
     C                   kfld                    $lwhse
     C                   kfld                    $lwhdp
     C                   kfld                    $laisl
     C                   kfld                    $lloc
     C                   kfld                    $lrlvl
     C                   kfld                    $lhand
     C                   kfld                    $lpos
     *
     *  Define Full key for SLOTPOS1 file.
     *
     C     spky1a        klist
     C                   kfld                    $lwhse
     C                   kfld                    $lwhdp
     C                   kfld                    $laisl
     C                   kfld                    $lloc
     C                   kfld                    $lrlvl
     C                   kfld                    $lpos
     *
     *  Define partial key for SLOTPOS1 file.
     *
     C     spkey1        klist
     C                   kfld                    $lwhse
     C                   kfld                    $lwhdp
     C                   kfld                    $laisl
     C                   kfld                    $lloc
     C                   kfld                    $lrlvl
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ADDPOS   Add new pallet position.
     *
     C     addpos        begsr
     *
     C     spkey         setll     slotpos                                79
     *
     C                   select
     *    Record NOT found in file. - Add record. Return *OK.
     C                   when      not *in79
     *
     C                   eval      spwhse = $lwhse
     C                   eval      spwhdp = $lwhdp
     C                   eval      spaisl = $laisl
     C                   eval      sploc = $lloc
     C                   eval      sprlvl = $lrlvl
     C                   eval      sphand = $lhand
     C                   eval      spdisp = $lpdsp
     C                   eval      spvdsp = $lvdsp
     C                   eval      sppos = $lpos
     C                   eval      sppllc = $lpllc
     C                   eval      $lrtn = '*OK     '
     *
     C                   write     sprec                                78
     C                   if        *in78
     C                   eval      $lrtn = '*ERROR  '
     C                   movel     desc(1)       errmsg
     C                   endif
     *
     *    Record found in file. - Return error.
     C                   when      *in79
     C                   eval      $lrtn = '*ERROR  '
     *
     C                   endsl
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  GETMXP   Get maximum pallets in slot.
     *
     C     getmxp        begsr
     *
     C     spkey1        setll     slotpos1
     C     spkey1        reade(n)  slotpos1                               79
     *
     C                   select
     C                   when      *in79
     C                   eval      $lspos = *zeros
     *
     C                   other
     *
     C                   eval      $lspos = sppos
     C                   endsl
     C                   eval      $lrtn = '*OK     '
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  MOVBCK   Move pallets in slot back 1 position.
     *
     C     movbck        begsr
     *
     C     spkey1        setll     slotpos1
417aMC                   dow       forever = forever
500 MC     spkey1        reade     slotpos1                             7879
     *
     C                   select
     C                   when      *in79
     C                   leave
500 A*
500 A*    Skip locked records.
500 AC                   when      *in78
500 AC                   iter
     *
     *    Skip pallets that are on the floor.
     C                   when      sppllc = 'F'
     C                   iter
417cA*
417cA*    Skip pallets with a position of 0.
417cAC                   when      sppos = 0
417cAC                   iter
     *
     C                   other
     *
     C                   add       1             sppos
     C                   update    sprec1
417dDC**                 if        sppos > $lspos
     *    Log Exception
417dDC**                 eval      $lrtn = '*ERROR  '
417dDC**                 endif
     C                   endsl
     C                   enddo
     *
     C                   endsr
500 A*
500 A*----------------------------------------------------------------
500 A*
500 A*  MOVBCKF  Move pallets on floor back 1 position.
500 A*
500 AC     movbckf       begsr
     *
     C     spkey1        setll     slotpos1
     C                   dow       forever = forever
     C     spkey1        reade     slotpos1                               79
     *
     C                   select
     C                   when      *in79
     C                   leave
     *
     *    Skip pallets that are is slot
     C                   when      sppllc = 'S'
     C                   iter
     *
     *    Skip pallets with a position of 0.
     C                   when      sppos = 0
     C                   iter
     *
     C                   other
     *
     C                   add       1             sppos
     C                   update    sprec1
     *    Log Exception
     C                   endsl
     C                   enddo
     *
     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  MOVFWD   Move pallets in slot forward 1 position.
     *
     C     movfwd        begsr
     *
     C     spky1a        setgt     slotpos1
417aMC                   dow       forever = forever
     C     spkey1        readpe    slotpos1                               79
     *
     C                   select
     C                   when      *in79
     C                   leave
     *
     *    Skip pallets that are on the floor.
     C                   when      sppllc = 'F'
     C                   iter
417cA*
417cA*    Skip pallets with a position of 0.
417cAC                   when      sppos = 0
417cAC                   iter
     *
     C                   other
     *
     C                   eval      sppos = sppos - 1
     C                   update    sprec1                               78
     C                   select
     C                   when      *in78
     *    Log Exception
     C                   eval      $lrtn = '*ERROR  '
     C                   when      sppos <= 0
     *    Log Exception
     C                   eval      $lrtn = '*ERROR  '
     C                   endsl
     C                   endsl
     C                   enddo
     *
     C                   endsr

417aA*----------------------------------------------------------------
417aA*  PULL     Pull pallet out of slot.
417aA*----------------------------------------------------------------
417aA
417aAC     pull          begsr

500 A*  First, move existing floor pallets backward.
500 A
500 AC                   exsr      movbckf

500 M*  Then, pull pallet out of slot.

     C                   eval      $lpllc = 'F'
     C                   eval      $lpos  = 1
     C                   exsr      updloc

417dM*  Next, move existing slot pallets forward.

     C                   exsr      movfwd

     C                   endsr

417aA*----------------------------------------------------------------
417aA*  PUSH     Push pallet into slot.
417aA*----------------------------------------------------------------
417aA
417aAC     push          begsr

417dM*  First, move existing slot pallets back.

     C                   exsr      movbck

     *  Next, add new pallet.

     C                   eval      $lpllc = 'S'
     C                   eval      $lpos  = 1
     C                   exsr      addpos

     C                   endsr

417bA*----------------------------------------------------------------
417bA*  PUSH2    Push pallet into slot, then update location.
417bA*----------------------------------------------------------------
417bA
417bAC     push2         begsr

417bA*  First, move existing pallets back.

417bAC                   exsr      movbck

417bA*  Next, update pallet location, position.

417bAC                   exsr      updloc

417bAC                   endsr

500 A*----------------------------------------------------------------
500 A*  RTNALL   Return all floor pallets back to slot.
500 A*----------------------------------------------------------------
500 AC     rtnall        begsr

     *  Loop until no more floor pallets are found.

     C     spkey1        setll     slotpos2
     C                   dow       forever = forever
     C     spkey1        reade     slotpos2

     C                   select
     C                   when      %eof(slotpos2)
     C                   leave

     *      Skip pallets that are in the slot.

     C                   when      sppllc = 'S'
     C                   iter

     *      Push pallet into slot.

     C                   other

     C                   eval      $lpos = sppos
     C                   eval      $lpllc = 'S'
     C                   eval      $lspos = 1
     C                   exsr      push2
     C     spkey1        setll     slotpos2

     C                   endsl

     C                   enddo

     C                   endsr

     *----------------------------------------------------------------
     *
     *  UPDLOC   Update pallet location and position.
     *
     C     updloc        begsr
     *
     C     spky1a        setll     slotpos1
417aMC                   dow       forever = forever
     C     spky1a        reade     slotpos1                               79
     *
     C                   select
     C                   when      *in79
     C                   leave
     *
     *    Moving pallet to floor. Update only pallets in slot.
     C                   when      $lpllc = 'F'  and
     C                             sppllc <> 'S'  or
     *
     *    Moving pallet to slot. Update only pallets on floor.
     C                             $lpllc = 'S'  and
     C                             sppllc <> 'F'
     C                   iter
     *
     C                   other
     *
     C                   eval      sppos = $lspos
     C                   eval      sppllc = $lpllc
     C                   update    sprec1                               78
     C                   select
     C                   when      *in78
     *    Log Exception
     C                   eval      $lrtn = '*ERROR  '
     C                   endsl
     C                   endsl
     C                   enddo
     *
     C                   endsr

417cA*----------------------------------------------------------------
417cA*  UPDLOC0  Update pallet position to 0.
417cA*----------------------------------------------------------------
417cA
417cAC     updloc0       begsr

     C     spkey1        setll     slotpos1

     C                   dow       forever = forever
     C     spkey1        reade     slotpos1
     C                   if        %eof
     C                   leave
     C                   endif

     *    Moving pallet to floor. Update only pallets in slot.
     *    Moving pallet to slot. Update only pallets on floor.

     C                   if        $lpllc = 'F' and sppllc <> 'S'
     C                             or $lpllc = 'S' and sppllc <> 'F'
     C                   iter
     C                   endif

     *    Set position to zero.                             .

     C                   eval      sppos = 0
     C                   eval      sppllc = $lpllc
     C                   update(e) sprec1
     C                   if        %error
     C                   eval      $lrtn = '*ERROR  '
     C                   endif

     C                   enddo

     C                   endsr
     *
     *----------------------------------------------------------------
     *
     *  ZZINIT   Initialize fields.
     *
     C     zzinit        begsr
     *
     C                   endsr
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**
Slot Position file
