     H COPYRIGHT('(c) Copyright BFC Software, Inc - 2009')

     *----------------------------------------------------------------
     *   Copyright (C) 2009 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   245 W. Roosevelt Rd.  Bldg 8, Suite 51
     *   West Chicago, IL  60185
     *   (630) 562-0375
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  DK105     Create new pass for dock door matrix
     *  14 February 2002
     *  Dave Sommerville
     *
     *----------------------------------------------------------------
     *  Revisions
     *
     *    02/14/02  DAS  4.16
     *      - Created.
416aA*    04/09/02  MLB  4.16a
     *      - Revised program to receive load type option from calling proram.
416bA*    04/10/02  MLB  4.16b
     *      - Revised program to initialize DMOVRF to 'N'.
     *
520 A*    09/22/09  MLB  5.20
     *      - Enh: Revised program to receive assignment type into the
     *        program to be used when adding entries to the dock door
     *        matrix.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fdocdoor   if   e           k disk
416aAFdocdoor1  if   e           k disk
416aAF                                     rename(ddrec:ddrec1)
     Fdocmtrx   o    e           k disk

     *----------------------------------------------------------------
     *  Constants
     *----------------------------------------------------------------

415aAD forever         s               n

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
     *  Parameters
     *
     *    Input Parameters
     *      $pwhse  -  Warehouse number
     *      $pdate  -  History date
     *      $ptime  -  History time
     *      $ppass  -  Pass number to create
     *      $pltyp  -  Dock door loading. 1=Single door, 2=By Department.
520 A*      $pwhdp  -  Dock door department.
520 A*      $patyp  -  Matrix assignment type. A=Automatic, M=Manual.
     *
     *    Returned Parameters
     *      None
     *
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pwhse            3 0
     C                   parm                    $pdate            8 0
     C                   parm                    $ptime            6 0
     C                   parm                    $ppass            3 0
416aAC                   parm                    $pltyp            1
416aAC                   parm                    $pwhdp            5
520 AC                   parm                    $patyp            1

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

     *  Initializ data matrix fields.

     C                   clear                   dmrec
     C                   eval      dmwhse = $pwhse
     C                   eval      dmhdte = $pdate
     C                   eval      dmhtim = $ptime
520 AC                   eval      dmatyp = $patyp
     C                   eval      dmpass = $ppass

     *  Loop through door records.

     *  Note: - When load type is 1=Single door, we create records in the
     *          dock matrix file for every door, regardless of the depart-
     *          ment the door is attached
     *        - When load type is 2=By dept., we create dock matrix file
     *          records only for the doors in the department selected.

416aAC                   select
416aAC                   when      $pltyp = '1'
     C     keydd         setll     docdoor
416aAC                   when      $pltyp = '2'
416aAC     keydd1        setll     docdoor1
416aAC                   endsl

 1B  C                   dow       forever = forever

416aAC                   select
416aAC                   when      $pltyp = '1'
     C     keydd         reade     docdoor
416aAC                   when      $pltyp = '2'
416aAC     keydd1        reade     docdoor1
416aAC                   endsl

 2B  C                   if        %eof
 1L  C                   leave
 2E  C                   endif

     *    Create corresponding matrix record.

     C                   eval      dmdoor = dddoor
     C                   eval      dmwhdp = ddwhdp
     C                   eval      dmmaxc = ddmaxc
     C                   if        ddstat = 'I'
     C                   eval      dmstat = '4'
     C                   else
     C                   eval      dmstat = '1'
     C                   endif
416bAC                   eval      dmovrf = 'N'

     C                   write(e)  dmrec
     C                   if        %error
     C                   endif

     C                   enddo

     *  Bye, Bye

     C                   eval      *inlr = *on

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *INZSR  Initialization subrotine
     *----------------------------------------------------------------

     C     *INZSR        BEGSR

     * Key definitions

     *  Define key for DOCDOOR file.

     C     keydd         klist
     C                   kfld                    $pwhse

     *  Define key for DOCDOOR1 file.

     C     keydd1        klist
     C                   kfld                    $pwhse
     C                   kfld                    $pwhdp

     C                   ENDSR
