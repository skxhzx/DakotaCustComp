      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2003 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   799 Roosevelt Rd.  Bldg 6, Suite 108
     *   Glen Ellyn, IL  60137
     *   (708) 790-8383
     *----------------------------------------------------------------
     *
     *  GETICAT   Get item Category values
     *  19 October  2005
     *  Jeffrey Jahnke
     *
     *----------------------------------------------------------------
     *
     *  Revisions
     *
     *    10/19/05  JCJ  5.0
     *      - Created
510aA*    12/08/06  RH   5.10a
     *      - Fix: Default HACCP 2=optional if not record in ITEMCAT
     *      - Enh: Add client code.
520aA*    04/17/08  DAS  5.20a
     *      - Fix: Revised so if an itemfld record is not found to
     *        look for a blank category code definition.
520bA*    03/11/09  DAS  5.20b
     *      - Removed file ITEMFLD.
     *      - Replaced chain to ITEMFLD with call to GETITEMFLD.
     *
     *----------------------------------------------------------------
     *  Client Custom Revisions
CTL A*    12/08/06  RH   CTL
     *      - Enh: Default to 1 No HACCP if not record in ITEMCAT
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

520bDF*temfld   if   e           k disk
     Fitemcat   if   e           k disk

510aA*----------------------------------------------------------------
510aA*  Customer id
510aA*
510aAD @getcl          c                   const('GETCLIENT')
510aAD*
510aA /COPY QCOPYSRC,ID#CITYLIN
     *----------------------------------------------------------------
     *
     *  Input parameters
     *
     *     $PWHS     -  warehouse
     *     $PITEM    -  item
     *
     *  Output parameters
     *
     *     $PCODE    -  Category Code
     *      $PHHDR   -  Header (1=No, 2=Optional, 3=Force)
     *      $PHDTL   -  Detail (1=No, 2=Optional, 3=Force)
     *      $PHCAT   -  Unique (1=No, 2=Optional, 3=Force)
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D $pwhse          s              3  0
     D $pitem          s             15
     D $pcode          s             10
     D $pwhs           s              3
     D $phhdr          s              1
     D $phdtl          s              1
     D $phcat          s              1

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pwhs
     C                   parm                    $pitem
     C                   parm                    $pcode
     C                   parm                    $phhdr
     C                   parm                    $phdtl
     C                   parm                    $phcat

     C     key1          klist
     C                   kfld                    $pwhse
     C                   kfld                    $pitem

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

     *   Call user added initialization routine.
     *
     C                   exsr      zzinz
     * initialize return parms
520aA*
520aA*   Note: The default values can now be handled by creating a
520aA*         blank (' ') category code.

     C                   eval      $pcode = '*NOTFOUND*'
CTL AC                   if        Client = cityline
     C                   eval      $phhdr = '1'
     C                   eval      $phdtl = '1'
     C                   eval      $phcat = '1'
510aAC                   else
510a C                   eval      $phhdr = '2'
510a C                   eval      $phdtl = '2'
510a C                   eval      $phcat = '2'
CTL AC                   endif
     C                   move      $pwhs         $pwhse

     * get item category code

520bDC**   key1          chain     itemfld
520aDC**                 if        %found(itemfld)
520bDC**                 if        not %found(itemfld)
520bDC**                 eval      $pcode = ' '
520bDC**                 else
520bDC**                 eval      $pcode = ifcat
520bDC**                 endif
520bA
520bAC                   call      'GETITEMFLD'
520bAC                   parm      $pwhse        $giwhse           3 0
520bAC                   parm      $pitem        $giitem          15
520bAC                   parm                    $gicat           10
520bAC                   eval      $pcode = $gicat

     * get item category info

     C     $pcode        chain     itemcat
 1B  C                   if        %found(itemcat)
     C                   eval      $phhdr = ichhdr
     C                   eval      $phdtl = ichdtl
     C                   eval      $phcat = ichcat
 1E  C                   endif
520aDC**                 endif

     C                   return
     *----------------------------------------------------------------
     *
510a *  *INZSR  Initialization subrotine
     *
     C     *inzsr        begsr
     *
510a *   Call user added initialization routine.
510a C                   exsr      zzinz
     C                   endsr
     *----------------------------------------------------------------
     *
510a *  ZZINZ    Extra program initialization. Called from *INZSR.
     *
510a C     zzinz         begsr
     *
510aA*
510aA* Get client id.
510aA*
510aAC                   call      @getcl
510aAC                   parm                    client           10
510aA*
510a *
510a *
510a C                   endsr
