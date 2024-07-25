      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     * Copyright (C) 2018 BFC Software, Inc. - All Rights Reserved
     * BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  GETEQUIPID   Get Equipment Id for MAC Addres
     *  12 May 2021
     *  Kenneth Elder
     *
     *  Revisions
     *
750 A*    05/12/21  KDE  7.50
     *      - Created.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Client Custom Revisions: Aderson DuBose
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     *----------------------------------------------------------
     *  SQL record layouts referenced
     *----------------------------------------------------------

     D eqbrec        E Ds                  Extname(EquipId)

     *----------------------------------------------------------------
     *  Customer id
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D $pWhse          s              3p 0
     d $pUser          s             10
     d $pDevType       s             10
     d $pMacAdr        s             20
     d $pMessage       s             60
     d wrkEmp          s              5  0
     d ts              s               z

     *----------------------------------------------------------------
     *  Called Programs Prototypes
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Parameters
     *
     *   Input
     *
     *    $pwhse  - Warehouse
     *    $puser  - User Id
     *    $pDevType - Device Type (Android - ANDHND, Bluetooth Printer - BLUPRT)
     *
     *   Output
     *
     *    $pMacAdr - Return address if bluetooth printer
     *    $pMessage - Sends *OK if all good, otherwise message describing failure
     *
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pwhse
     C                   parm                    $puser
     C                   parm                    $pDevType
     C                   parm                    $pMacAdr
     C                   parm                    $pmessage

     *----------------------------------------------------------------
     *  Main Line
     *----------------------------------------------------------------

      /free

       *inlr = *on;

          // get Employee number
          exec sql select usemp# into :wrkemp
                    from piruser
             where uscode=:$pUser;
          if sqlstt <> '00000';
            $pMessage = 'User is invalid';
            return;
          endif;

          // Return mac address for current user id sent
          exec sql select * into :eqbrec
                    from equipid
               where eqbwhse=:$pWhse and eqblusr=:$pUser and eqbtype=:$pDevType;
          if sqlstt = '00000';
            $pMacAdr = eqbid;
            $pMessage = '*OK';
          else;
            $pMacAdr = 'NOT FOUND';
            $pMessage = 'Device type ' + %trim($pDevType) + ' not assigned for'
                      + ' user ' + %trim($pUser);
          endif;

       return;

      /end-free
