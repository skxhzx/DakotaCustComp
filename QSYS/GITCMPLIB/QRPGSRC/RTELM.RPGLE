      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2007 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  RTELM     Get/Set route door loading method
     *  26 Marcy 2007
     *  Dave Sommerville
     *
     *  Revisions
     *
510 A*    03/26/07  DAS  5.10
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Frtelm     uf a e           k disk
     Foptions   if   e           k disk

     *----------------------------------------------------------------
     *  *DOCDOOR -  Dock Door options
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPATYP  -  Dock door assignment. 1=Auto, 2=Manual.
417 A*                                     0=No assignment.
     *    OPLTYP  -  Dock door loading. 1=Single door, 2=By Department.
     *
     * Data structure
     *
     D opdata          ds
     D  opatyp                 1      1
     D  opltyp                 2      2

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D                sds
     D  #prog            *proc
     D  #job                 244    253
     D  #user                254    263
     D  #jobn                264    269
     D  #jobdt               276    281  0
     D  #jobtm               282    287  0

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D error           s               n

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pcmd    *GET  -  Get door loading method.
     *               *SET  -  Set door loading method.
     *      $pwhse   Warehouse
     *      $prtid   Route id
     *      $pltype  Loading method type
     *
     *    Returned Parameters
     *      $ptype   Loading method type
     *      $patype  Assigment type
     *      $prtn   blank    - No problem encountered.
     *              *ERROR   - Error occured. Message in $PERM
     *      $perm   Error message or pointer to message in pgmq.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pcmd             8
     C                   parm                    $pwhse            3 0
     C                   parm                    $prtid            5
     C                   parm                    $pltype           1
     C                   parm                    $patype           1
     C                   parm                    $prtn             8
     C                   parm                    $perm            60

     C                   eval      $patype = ' '
     C                   eval      $prtn = ' '
     C                   eval      $perm = ' '

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------


     C                   select
     C                   when      $pcmd = '*GET'
     C                   exsr      gettype
     C                   when      $pcmd = '*SET'
     C                   exsr      settype
     C                   other
     C                   eval      $prtn = '*ERROR'
     C                   eval      $perm = 'Invalid command sent '
     C                                   + '(' + %trim($pcmd) + ')'
     C                   endsl

     C                   return

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

     C     *inzsr        begsr

     *  Define key for RTELM file.

     C     keyrl         klist
     C                   kfld                    $pwhse
     C                   kfld                    $prtid

     *  Define key for OPTIONS file.

     C     keyop         klist
     C                   kfld                    opwhse
     C                   kfld                    opcode

     C                   endsr

     *----------------------------------------------------------------
     *  gettype  Get type for route.
     *----------------------------------------------------------------

     C     gettype       begsr

     *  Get defaults from options file.

     C                   eval      opwhse = $pwhse
     C                   eval      opcode = '*DOCDOOR'
     C     keyop         chain     options
     C                   if        not %found
     C                   eval      $prtn = '*ERROR'
     C                   eval      $perm = '*DOCDOOR record not found'
     C                   else
     C                   eval      $pltype = opltyp
     C                   eval      $patype = opatyp
     C                   endif

     *  Now get override from RTELM file.

     C     keyrl         chain(n)  rtelm
     C                   if        %found
     C                   eval      $pltype = rltype
     C                   endif

     C     endgettype    endsr

     *----------------------------------------------------------------
     *  settype  Set type in RTELM file.
     *----------------------------------------------------------------

     C     settype       begsr

     *  Get RTELM record.

     C     keyrl         chain     rtelm

     *  If not found, add it.

     C                   if        not %found
     C                   eval      rlwhse = $pwhse
     C                   eval      rlrtid = $prtid
     C                   eval      rltype = $pltype
     C                   write(e)  rlrec
     C                   if        %error
     C                   eval      $prtn = '*ERROR'
     C                   eval      $perm = 'Error creating RTELM record'
     C                   endif
     C                   goto      endsettype
     C                   endif

     *  Otherwise, just update record.

     C                   eval      rltype = $pltype
     C                   update(e) rlrec
     C                   if        %error
     C                   eval      $prtn = '*ERROR'
     C                   eval      $perm = 'Error updating RTELM record'
     C                   endif

     C     endsettype    endsr
