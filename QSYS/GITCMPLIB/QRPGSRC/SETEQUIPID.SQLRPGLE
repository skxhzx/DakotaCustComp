      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     * Copyright (C) 2018 BFC Software, Inc. - All Rights Reserved
     * BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  SETEQUIPID   Set Equipment Id for MAC Addres
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
     d $pPgm           s             10
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
     *    $pDevType - Device Type (ANDHND - Android Device, BLUPRT - Bluetooth printer)
     *    $pMacAdr - Device Mac Address
     *
     *   Output
     *
     *    $pMacAdr -  Device Max Address
     *    $pMessage - Sends *OK if all good, otherwise message describing failure
     *
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    $pwhse
     C                   parm                    $puser
     C                   parm                    $pDevType
     C                   parm                    $pMacAdr
     C                   parm                    $pPgm
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
            $pMessage = 'Employee not found for User';
            return;
          endif;

          // verify device type
          if $pDevType <> 'ANDHND' and $pDevType<>'BLUPRT';
            $pMessage = 'Invalid Device Type Sent';
            return;
          endif;

          // Verify warehouse sent
      /end-free
     C                   call(e)   'VFYWHSE'
     C                   parm      '*VERIFY'     $vcommand         8
     C                   parm      '*NONE'       $vprg            10
     C                   parm      $pWhse        $vwhse            3 0
     C                   parm      ' '           $vdesc           30
     C                   parm      ' '           $vreturn         10
     C                   parm      ' '           $vmessage        60
     C                   parm      ' '           $vmsgk            4
     C                   if        $vreturn <> '*OK'
      /end-free
            $pMessage = 'Warehouse not valid';
            return;
          endif;

          // If blank Mac Address is sent then simply clear any record
          // in EQUIPID for passed user
          if $pMacAdr = *blanks;
            exec sql delete from equipid where eqbwhse=:$pWhse and
                         eqblusr=:$pUser and eqbtype=:$pDevType;
            $pMacAdr = *blanks;
            $pMessage = '*OK';
            return;
          endif;

          // See if at least one record exist for sent Type and MAc Address
          exec sql select * into :eqbrec
                    from equipid
             where eqbwhse=:$pWhse and eqbid=:$pMacAdr and
                   eqbtype=:$pDevType fetch first row only;
          if sqlstt = '00000';
            // if record was found we will ensure user is set
            // for this device and write to history log
            // Delete any records in id file for this user not equal this device
            exec sql delete from equipid where eqbwhse=:$pWhse and
                        eqbid<>:$pMacAdr and eqbtype=:$pDevType
                        and eqblUsr=:$pUser;
            // Delete any excess records for this device id to ensure we only
            // have one represented in the equipid file to update.  Log file will
            // reflect all switching between users.
            exec sql delete from equipid as a where a.eqbwhse=:$pWhse and
                        a.eqbid=:$pMacAdr and a.eqbtype=:$pDevType
                        and a.eqblUsr=(select max(b.eqblusr) from equipid as b
                        where b.eqbwhse=a.eqbwhse and b.eqbtype=a.eqbtype
                          and b.eqbid=a.eqbid) and (select count(*) from
                           equipid as c where c.eqbwhse=a.eqbwhse and
                           c.eqbtype=a.eqbtype and c.eqbid=a.eqbid)>1;
            // the fetch first only is for protection but with the deletes
            // prior to this update we should never have more than one record
            // in EquipId to update
            exec sql update equipid set eqblusr=:$pUser, eqblemp=:Wrkemp
                  where eqbwhse=:$pWhse and eqbid=:$pMacAdr and
                        eqbtype=:$pDevType fetch first row only;
            if sqlStt = '00000';
              exsr wrtHLog;
            endif;
          else;
            // otherwise we will generate record for id
            // pointing to this user and write history log record
            exec sql delete from equipid where eqbwhse=:$pWhse and
                        eqbid<>:$pMacAdr and eqblUsr=:$pUser and
                        eqbtype=:$pDevType;
            exec sql insert into equipid
                    values(:$pWhse,:$pMacAdr,' ',:$pDevType,:$pUser,:wrkemp);
            if sqlstt = '00000';
              exsr wrtHLog;
            endif;
          endif;

       return;

       begsr  wrtHlog;
         // Write History log for Device assignments
         ts = %timestamp();
         exec sql insert into equipidh
             values(:$pWhse,:$pMacAdr,:$pDevType,:$pUser,:wrkemp,:$pPgm,:ts);
       endsr;

      /end-free
