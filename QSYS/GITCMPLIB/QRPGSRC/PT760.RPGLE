     H/copy qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2000 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  PT760     Remove item adjustment LABEL records - Post
     *  17 April 2000
     *  Max Blacknik
     *
520aA*    10/10/07  LMC  5.20a  P#00023
     *      - Enh: Added purging to history files instead of just
     *             deleting the records
     *             NOTE - if this is moved to client site, make sure
     *             positions 33-35 of opdata in options is initilized.
520bA*    05/13/08  GJA  5.20a  P#00023
     *      - Enh: Added option for extended history
     *----------------------------------------------------------------
     * Indicators
     *
     *  79        - EOF for LABEL10
     *
     *----------------------------------------------------------------
     * File Specs
     *
     FLabel10   up   e             disk
520aAFLabelh    o  a e             disk
     F                                     rename(lbrec:lbrech)
520bAFoptions   if   e           k disk
     *----------------------------------------------------------------
     *  Table and array definitions
     *
     D desc            s             50    dim(1) ctdata perrcd(1)
     *----------------------------------------------------------------
     *  Data structure for error message parameters
     *
     D $mdt            ds
     D  errmsg                 1     50
     *
     D  errecs                 1      3p 0
     D  erdesc                 4     48
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
520bA*----------------------------------------------------------------
520bA*  *SYSTEM  -  System options.
520bA*----------------------------------------------------------------
520bA*
520bA* Fields
520bA*
520bA*    OPEPM   -  Using EPM module (Y,N).
520bA*    OPRF    -  Using RF module (Y,N).
520bA*    OPCAPC  -  Capture catch weights at pick closing (Y,N).
520bA*    OPLETD  -  Print letdown labels (Y,N).
520bA*    OPWRNC  -  Perform catch weight variance check (Y,N).
520bA*    OPRG1C  -  Catch weight low variance percentage.
520bA*    OPRG2C  -  Catch weight high variance percentage.
520bA*    OPIMPI  -  Import Item fields (Y,N).
520bA*    OPICW   -  Individual catch weight entry (Y,N).
520bA*    OPMPCK  -  Allow multiple pick slots for fixed items (Y/N).
520bA*    OPRCDY  -  Number of days to keep receiving logs.
520bA*    OPMPCK  -  Number of days to keep picking logs.
520bA*    OPRTHS  -  Number of weeks - exported routes to keep.
520bA*    OPCRHS  -  Number of weeks - exported customer rtns to keep.
520bA*    OPPOHS  -  Number of weeks - exported p/o's to keep.
520bA*    OPIAHS  -  Number of weeks - exported inventory adj. to keep.
520bA*    OPMSHS  -  Number of weeks - exported misc. trans. to keep.
520bA*    OPISHS  -  Number of weeks - extra history files to keep.
520bA*
520bA* Data structure
520bA*
520bAD opdata          ds
520bAD  opepm                  1      1
520bAD  oprf                   2      2
520bAD  opcapc                 3      3
520bAD  opletd                 4      4
520bAD  opwrnc                 5      5
520bAD  oprg1c                 6      8  1
520bAD  oprg2c                 9     11  1
520bAD  opimpi                12     12
520bAD  opicw                 13     13
520bAD  opmpck                14     14
520bAD  oprcdy                15     15  0
520bAD  oppkdy                16     16  0
520bAD  oprths                17     19  0
520bAD  opcrhs                20     22  0
520bAD  oppohs                23     25  0
520bAD  opiahs                26     28  0
520bAD  opmshs                29     31  0
520bAD  opishs                33     35  0
520bAD  optend               117    117
     *-----VARIABLES--------------------------------------------------
     D $kdate          s              8  0
     D $kwhse          s              3  0
     D $msgf           s             10
520bAd kycode          s                   like(opcode)
520bAd kywhse          s                   like(opwhse)
     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $PPRG   - Program to send message back to.
     *      $PWHSE  - Warehouse
     *      $PDATE  - Export date
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------
     *
     C     *entry        plist
     C                   parm                    $pprg            10
     C                   parm                    $pwhse            3
     C                   parm                    $pdate            8
     C                   move      $pwhse        $kwhse
     C                   move      $pdate        $kdate
     *----------------------------------------------------------------
     * Main line
     *
     *  Although the following conditions are tested by open query
     *  in the preceding CL program, this is tested here again for
     *  additional safety.
     *
     C                   if        lbwhse <> $kwhse  or
     C                             lbrdte >= $kdate
     C                   goto      bottom
     C                   endif
     *
     *  Delete exported item adjustment label records.
     *
     C                   add       1             errecs
520aA* ONLY WRITE HISTORY IF ADDITIONAL HISTORY IS SET IN OPTIONS
520aAC                   if        opishs <> 0
520aAC                   write     lbrech
520aAC                   endif
     C                   delete    lbrec                                79
     *
     C     bottom        tag
     *
     *LR                   EXSR ZM0750
     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
     C                   eval      errecs = 0
     C                   movel     desc(1)       erdesc
     *
520bA*
520bA*    Define full key for file OPTIONS.
520bA*
520bAC                   eval      kywhse = *zeros
520bAC                   eval      kycode = '*SYSTEM '
520bAC     keyop         klist
520bAC                   kfld                    kywhse
520bAC                   kfld                    kycode
520bA*
520bA*    Retrieve System options.
520bA*
520bAC     keyop         chain     options                            79
520bAC                   if        *in79
520bAC                   eval      opishs = 0
520bAC                   endif
     C                   endsr
     *---------------------------------------------------------------
     *
     *  SUBROUTINE ZMxxxx  Control message display subfile
     *
     *    ZMSMSG  Send program message to a different program msgq
     *
     C     zmsmsg        begsr
     C                   if        $msgf = *blanks
     C                   eval      $msgf = #msgf
     C                   endif
     C                   call      'PUTMSG'
     C                   parm                    $msgf
     C                   parm                    #msgid            7
     C                   parm                    #msgtp            7
     C                   parm                    #msgdt
     C                   parm      $pprg         #pgmq2           10
     C                   parm                    #msgk             4
     C                   eval      #msgdt = *blanks
     C                   eval      $msgf = *blanks
     C                   endsr
     *----------------------------------------------------------------
     *    ZMnnnn  Build and send message nnnn to this program
     *----------------------------------------------------------------
     *     PIR0750  Records removed.
     *
     C     zm0750        begsr
     C                   eval      #msgid = 'PIR0750'
     C                   eval      #msgtp = '*DIAG  '
     C                   movea     errmsg        $md(1)
     C                   exsr      zmsmsg
     C                   endsr
     *----------------------------------------------------------------
     *
     *  Compile time tables
     *
**
label adjustment records
