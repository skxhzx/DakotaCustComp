      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2015 BFC Software, Inc. - All Rights Reserved
     *----------------------------------------------------------------
     *
     *  OR737S    Staging - Export returns as adjustments
     *  23 June, 2015
     *  Rod Roller
     *
     *----------------------------------------------------------------
     *  Revisions
     *
700  *    06/23/15  RTR  7.00
     *      - Created using RN235S and OR736
     *      - Removed mod marks and deleted lines except for client code.
710b *    05/19/17  RTR  7.10b
     *      - Added EXPSADJL code.
710c *    06/30/17  RTR  7.10c
     *      - Fixes for weight and license.
730a *    12/20/19  RTR  7.30c
     *      - Fix for wrong corresponding item change in 710c.
740a *    11/06/20  RTR  7.40a
     *      - Remove 730a mod.
     *      - Fix date/time
750b *    07/28/21  LMC  7.50b
     *      - Lets process each licnese
     *      - NOTE: please review carefully if you want to send the
     *        return for the putaway to the host.
     *        MOD 740a implies you do want to. And for lot tracking
     *        we would need to send the putaway return as an adjustment
760aA*    06/01/22  LMC  7.60a
     *      - Clients using host software FRESHBYTE need to have the  ted
     *        lot number send in the host lot code field IELTHSTLOT
     *        the lot number is stored in the licinfo file.
     *
     *----------------------------------------------------------------
     *  Notes -
     *
     *----------------------------------------------------------------
     * Indicators
     *
     *----------------------------------------------------------------
     * File Specs
     *
     Forrtn4    uf   e           k disk
750aAfoptions   if   e           k disk
     Fexpsadj   o  a e           k disk
710bAFexpsadjl  o  a e           k disk
750aAfexpsadjlt o  a e           k disk

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------
      /copy qcopysrc,c#stdsql

     *----------------------------------------------------------------
     *  Redefinition data structures
     *
     D $cerm           ds
     D  xcerm                  1     60
     D  $cmsg                  1      4

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------
     D $pwhse          s              3  0
     D $pWhse3A        s              3
     D $pBatId         s             11
     D $pReturn        s             10
     D $pMessage       s            200
     D batId           s             11
     D forever         s               n
     D haveBatId       s               n
     D rtnCode         s             10
     D rtnMessage      s            200
710cAd shipweight      s              7s 2
     D stamp           s               z
     D stampUC         s               z
710cAD wrkItem         s             15a
     D wrkLbl          s              7s 0
     D wrkTrn          s              7s 0
     D wrkWhdp         s              5a
     D wrkDisp         s             12a
     D wrkLcns         s             15a
760aAD wrkLot          s             30a
740aAd wrkdte          s              8s 0
740aAd wrktim          s              6s 0
750aAD wrkrcvqty       s              5s 0
750aAD wrkttllbs       s              9s 2
750aAd hostopts        s             20a
750aAd hostoptint      s             20a
750aAd hostoptlot      s             20a
750aAd NetSuite        c                   const('NETSUITE')

     D currtimestamp   s               z
     D zeroUploadDate  s              8s 0

760aA*----------------------------------------------------------------
760aA*  Constants
760aA*
760aAD freshbyte       c                   const('FRESHBYTE')
     *----------------------------------------------------------------
     * Data structure
     *
     *----------------------------------------------------------------
     *  *RETURNS -  Customer Returns options
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPRQCH  -  Allow changes to return quantity. (Y,N).
     *    OPRQEC  -  Allow changes to qty if return exported. (Y/N)
     *    OPRFLB  -  Force return label entry. (Y/N)
     *    OPREXQ  -  Export Quick returns.(Y/N)
     *    OPRULB  -  Use label for putaway.(Y/N)
     *    OPREAD  -  Export as adjustments. (Y/N)
     *    OPREAC  -  Adjustment code to use.
     *
     * Data structure
     *
     D oprdta          ds
     D  oprqch                 1      1
     D  oprqec                 2      2
     D  oprflb                 3      3
     D  oprexq                 4      4
     D  oprulb                 5      5
     D  opread                 6      6
     D  opreac                 7      8
     D  oprend               117    117
     D  oprdata                1    117
     *----------------------------------------------------------------
     *  Program info data structure
     *
      /COPY *libl/qcopysrc,C#PGMINFDS

     *----------------------------------------------------------------
     *  Prototypes
     *----------------------------------------------------------------

     D GetBatId        pr                  extpgm('GETBATID')
      * Input
     D   pWhse                        3p 0 const
     D   pType                       10    const
     D   pStatus                      1    const
      * Output
     D   pBatId                      11
     D   pReturn                     10
     D   pMessage                   200

750aA /copy qcopysrc,p.getopint
740cA* Prototype for NetSuite API Call
740cA /copy *libl/qcopysrc,p.intapins

750aA*----------------------------------------------------------------
750aA*  File data structures
750aA*----------------------------------------------------------------
750aAd llrecx        e ds                  extname(LICLOG) inz(*EXTDFT)
750aAd lbrecx        e ds                  extname(LABEL) inz(*EXTDFT)

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      $pWhse  - Warehouse
     *      $pBatId - Batch id
     *      $pReturn  - Sequence number
     *
     *    Returned Parameters
     *      $pReturn  - Return code
     *      $pMessage - Return message
     *
     *----------------------------------------------------------------
     *  Let the show begin .....
     *
     C     *entry        plist
     C                   parm                    $pWhse3A
     c                   parm                    $pBatId
     c                   parm                    $pReturn
     c                   parm                    $pMessage

     c                   eval      $pWhse = %dec($pWhse3A: 3: 0)
     c                   eval      $pReturn = '*OK'
     c                   eval      $pMessage = ' '
     C                   eval      *inlr = *on
      /free
        // Get options record for returns.
        exec sql select opdata into :oprdata from options
                  where opwhse = :$pwhse
                    and opcode = '*RETURNS';
      /end-free

     *----------------------------------------------------------------
     * Main line
     *
     *  Add customer returns to export file.
     *
      /free
         // If option flag not set to send as adjustments, exit now.
         if opread <> 'Y';
           return;
         endif;

         if $pBatId <> *blanks;
            BatId = $pBatId;
            haveBatId = *on;
         else;
            BatId = *blanks;
            haveBatId = *off;
         endif;

         setll ($pWhse: zeroUploadDate) orrtn4;

         dow forever = forever;

           reade ($pWhse: zeroUploadDate) orrtn4;
           if %eof(orrtn4);
             leave;
           endif;

           // if impact inventory = 'N', skip record.
           if oriinv <> 'Y'
750aA       or orcitm <> ' ' and
               hostopts <> NetSuite;
740aD       //or orcitm <> *blanks;
730aD     //or orcitm <> *blanks;
740aA        orudte = wrkdte;
740aA        orutim = wrktim;
740aA        update orrec;
             iter;
           endif;

           // If no batch id yet, get one.
           if not haveBatId;
             exsr zzzGetBatId;
             if batId = *blank;
               leave;
             endif;
             haveBatId = *on;
             $pBatId = batId;
           endif;

           // Write adjustment record.
           exsr filie;
           write ierec;

710bA      // Create license record for adjustment
710bA      exsr zzcrtlic;

     *    Write license records
750aAc                   exsr      zzcrtliclt
750aA
750aA /free
750aA   if (hostopts = NetSuite
750aA    or hostoptint = 'NetSuite'
750aA    or hostSys = NetSuite)
750aA    and BatID <> *blanks;
750aA     ApiNS.Whse = %editc($pwhse:'X');
750aA     ApiNS.Batch = BatId;
750aA     ApiNS.Type = 'EXPADJUST ';
750aA     IntApiNS(ApiNS.Whse: ApiNS.Batch: ApiNS.Type:
750aA              ApiNS.Ret: ApiNS.Msg);
750aA     if ApiNS.Ret <> '*OK';
750aA     endif;
750aA     havebatid = *off;
750bA     batid = ' ';
750aA   endif;
750aA /end-free

           // Update customer return file with upload date and time.
740aD      //orudte = %dec(%date():*iso);
740aD      //orutim = %dec(%time():*iso);
740aM      orudte = wrkdte;
740aM      orutim = wrktim;
           update orrec;

         enddo;

         // Pass back batch ID if new.
         $pBatId = batId;
      /end-free

     *----------------------------------------------------------------
     *
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *
     *----------------------------------------------------------------
     *
     *  *INZSR  Initialization subroutine
     *
     C     *inzsr        begsr
     *
     * Get client id.
     *
     C                   call      'GETCLIENT'
     C                   parm                    client           10
     C                   parm                    clientloc        10
750aAc                   parm                    cliInit           3
750aAc                   parm                    hostSys          10
     *
750aAc     keyop         klist
750aAc                   kfld                    $pwhse
750aAc                   kfld                    opcode
     *
750aA*  Get Host ERP from OPTIONS
750aAc                   eval      opwhse = 1
750aAc                   eval      opcode = '*HOST   '
750aAc     keyop         chain     options
750aAc                   if        not %found(options)
750aAc                   eval      hostopts = '*NONE'
750aAc                   else
750aAc                   movel     opdata        hostopts
750aAc                   endif
750aA *  Get Host ERP from OPTIONINT
750aA /free
750aA   // Get debug flag
750aA   optint.type = 'Interface   ';
750aA   optint.cat  = 'General Options     ';
750aA   optint.name = 'Host ERP System     ';
750aA   GetOptInt(optint.type: optint.cat: optint.name: optint.valt:
750aA             optint.valn: optint.vala: optint.return);
750aA   if optint.return = '*OK';
750aA     hostoptint = optint.vala;
750aA   else;
750aA     hostoptint = '*NONE';
750aA   endif;
750aA
750aA *  Get Item Serial Type from OPTIONINT
750aA   // Get debug flag
750aA   optint.type = 'Interface   ';
750aA   optint.cat  = 'NetSuite Options    ';
750aA   optint.name = 'Item Serial Type    ';
750aA   GetOptInt(optint.type: optint.cat: optint.name: optint.valt:
750aA             optint.valn: optint.vala: optint.return);
750aA   if optint.return = '*OK';
750aA     hostoptlot = optint.vala;
750aA   else;
750aA     hostoptlot = '*UNDEFINED';
750aA   endif;
750aA /free
740aA
740aAc                   eval      wrkdte = %dec(%date():*iso)
740aAc                   eval      wrktim = %dec(%time():*iso)
     C                   endsr
     *----------------------------------------------------------------
     *
     *  FILIE    Fill export fields.
     *
     C     filie         begsr
     *
     *  Initialize record
     *
     C                   clear                   ierec
     *
     *  Move fields from item adjustment file to export file.
     *
     C                   eval      iewhse = orwhse
730aDC**                 if        orcitm <> *blanks
730aDC**                 eval      ieitem = orcitm
730aDC**                 else
     C                   eval      ieitem = oritem
730aDC**                 endif
     C                   eval      iedate = orrdte
     C                   eval      ietime = orrtim
     C                   eval      ieby = orrusr
     C                   eval      iewhdp = *blanks
     C                   eval      iedisp = *blanks
710cDC**                 eval      iecwta = orcwtr
710cAC                   exsr      zzzGetWeight
710cAC                   eval      iecwta = orqty1 * shipweight
     C                   eval      ieqty1 = orqty1
     C                   eval      ieqty2 = orqty2
     C                   eval      ieqty3 = orqty3
     C                   eval      iecode = opreac
     C                   eval      iememo = %char(orord)

     C                   exsr      zzzGetStamps
     C                   eval      iebatid = BatId
     C                   eval      iestatus = 'R'
     C                   eval      ieststs = stamp
     C                   eval      iestsuc = stampuc
     C                   eval      ieaddts = stamp
     C                   eval      ieadduc = stampuc
     *
     C                   endsr

710bA*----------------------------------------------------------------
710bA*  ZZCRTLIC   Create license export record
710bA*----------------------------------------------------------------
710bA /free
710bA   begsr zzcrtlic;
710bA
710bA     // get trans # from label file
710bA
730aA   //if orcitm <> *blanks;
730aA   //  exec sql select lbitem,lbtrn#,lblbl# into :wrkItem,:wrkTrn,:wrkLbl
730aA   //             from label
730aA   //            where lbpbat = :orpbat
730aA   //              and lbitem = :orcitm;
730aA   //else;
710bA       exec sql select lbitem,lbtrn#,lblbl# into :wrkItem,:wrkTrn,:wrkLbl
710bA                  from label
710bA                 where lbpbat = :orpbat
710bA                   and lbitem = :oritem;
730aA   //endif;
710bA     if sqlstt <> sqlsuccess;
710bA       wrkItem = *blanks;
710bA       wrkTrn = 0;
710bA       wrkLbl = 0;
710bA     endif;
710bA
710bA     // get license from liclog
710bA     exec sql select lllcns,lldisp into :wrkLcns,:wrkDisp
710bA                from liclog
710bA               where llitem   = :wrkItem
710bA                 and lllbl#   = :wrkLbl
710bA                 and lltrn#   = :wrkTrn
710bA                 and llaction = 'RCV';
710bA     if sqlstt <> sqlsuccess;
710bA       wrkLcns = *blanks;
710bA     endif;
710bA
710bA     // write license record
710bA     clear ielrec;
710bA     ielwhse = orwhse;
710bA     ielbatid = batid;
710bA     ielitem = wrkItem;
710bA     ielstatus = 'R';
710bA     ielststs = stamp;
710bA     ielstsuc = stampuc;
710bA     ieladdts = stamp;
710bA     ieladduc = stampuc;
710bA     ieltext = *blanks;
710bA     ieldate = orrdte;
710bA     ieltime = orrtim;
710bA     ielwhdp = wrkWhdp;
710bA
710bA     iellcns = wrkLcns;
710bA     ielolcns = *blanks;
710bA     ieldisp = wrkDisp;
710cD   //ielcwta = orcwtr;
710cM     ielcwta = iecwta;
710bA     ielqty1 = orqty1;
710bA     ielqty2 = orqty2;
710bA     ielqty3 = orqty3;
710bA     ielbrd = 'NB';
710bA   //ielstat = adjstat;
710bA   //exsr findLicExp;                      // Get exp date
710bA   //ielexpd = wrkExpDate;
710bA   //exsr findLicOrig;                     // Get country/state
710bA   //ieloco = wrkOrgCntry;
710bA   //ielost = wrkOrgState;
710bA     write ielrec;
710bA
710bA   endsr;
710bA /end-free

750aA*----------------------------------------------------------------
750aA*  ZZCRTLICLT   Create license export records
750aA*----------------------------------------------------------------
750aA /free
750aA   begsr zzcrtliclt;
750aA
750aA     // get tran #s from label file
750aA     if orcitm <> *blanks;
750aA       wrkItem = orcitm;
750aA     else;
750aA       wrkItem = oritem;
750aA     endif;
750aA
750aA     // read label records for returned licenses
750aA     exec sql declare lbcsr cursor for
750aA               select * from label
750aA                where lbpbat = :orpbat
750aA                  and lbitem = :wrkItem;
750aA
750aA     exec sql open lbcsr;
750aA     if sqlstt = '24502';
750aA       exec sql close lbcsr;
750aA       exec sql open lbcsr;
750aA     endif;
750aA
750bA     dow forever = forever;
750aA     exec sql fetch next from lbcsr into :lbrecx;
750aA     if sqlstt <> sqlSuccess;
750bA       leave;
750aA     endif;
750aA
750aA     // get license from liclog
750aA     //exec sql select lllcns,lldisp into :wrkLcns,:wrkDisp
750aA     //           from liclog
750aA     //          where llitem   = :wrkItem
750aA     //            and lllbl#   = :lblbl#
750aA     //            and lltrn#   = :lbtrn#
750aA     //            and llaction = 'RTN';
750aA     //if sqlstt <> sqlsuccess;
750aA     //  wrkLcns = *blanks;
750aA     //endif;
750aA
750bA     // get license from licinfo
760aD     //exec sql select lnlcns,lnrcvqty,lnttllbs
760aD                //into :wrkLcns,:wrkrcvqty,:wrkttllbs
760aM     exec sql select lnlcns,lnrcvqty,lnttllbs,lnlot
760aM                into :wrkLcns,:wrkrcvqty,:wrkttllbs,:wrklot
750bA                from licinfo
750bA               where lnitem   = :wrkItem
750bA                 and lnrcvlbl#   = :lblbl#
750bA                 and lnrcvtrn#   = :lbtrn#;
750bA     if sqlstt <> sqlsuccess;
750bA       wrkLcns = *blanks;
760aA       wrkLot  = *blanks;
750bA     endif;
750bA
750aA     // write license record
750aA     clear ieltrec;
750aA     ieltwhs    = orwhse;
750aA     ieltbatid  = batid;
750aA     ieltstatus = 'R';
750aA     ieltststs  = stamp;
750aA     ieltstsuc  = stampuc;
750aA     ielttext   = *blanks;
750bD     //ieltitem   = orItem;
750bM     ieltitem   = wrkitem;
750aA     //ieltwgt    = orcwtr;
750aA     ieltwgt    = wrkttllbs;
750aA     ieltmemo   = %char(orord);
760aA     if hostsys = freshbyte;
760aA       ielthstlot = wrklot;
760aA     else;
750aA       ielthstlot = wrklcns;
760aA     endif;
750bA     select;
750bA       when lbutyp = 'N';
750bA         ieltqty1   = wrkrcvqty;
750bA       when lbutyp = '1';
750bA         ieltqty2   = wrkrcvqty;
750bA       when lbutyp = '2';
750bA         ieltqty3   = wrkrcvqty;
750bA       other;
750bA         ieltqty1   = wrkrcvqty;
750bA     endsl;
750bA
750aA     //ieltqty1   = orqty1;
750aA     //ieltqty2   = orqty2;
750aA     //ieltqty3   = orqty3;
750aA     ieltadate  = orrdte;
750aA     ieltatime  = orrtim;
750aA     ieltby     = orrusr;
750aA     ieltadjcd  = 'RT';
750aA     ieltlcns   = wrkLcns;
750aA     ieltolcns  = wrkLcns;
750aA     ieltaddts  = stamp;
750aA     ieltadduc  = stampuc;
750aA
750aA     write ieltrec;
750aA
750bA     enddo;
750aA   endsr;
750aA /end-free

     *----------------------------------------------------------------
     *  zzzGetStamps   Get timestamps
     *----------------------------------------------------------------

     c     zzzGetStamps  begsr
      /free

        exec sql
          values (current_timestamp,
                  current_timestamp-current_timezone)
          into :stamp, :stampUC;

        if sqlstt <> sqlSuccess;
          clear stamp;
          clear stampUC;
        endif;

      /end-free
     c                   endsr

     *----------------------------------------------------------------
     *  zzzGetBatId    Get batch id
     *----------------------------------------------------------------

     c     zzzGetBatId   begsr
      /free

        monitor;
          GetBatId($pWhse: 'EXPADJUST': 'W':
                   batId: rtnCode: rtnMessage);
        on-error;
          clear batId;
          clear rtnCode;
          clear rtnMessage;
        endmon;

      /end-free
     c                   endsr
710cA*----------------------------------------------------------------
710cA*  zzzGetWeight   Get item case weight
710cA*----------------------------------------------------------------
710cA /free
710cA  begsr zzzGetWeight;
710cA
710cA   exec sql
710cA     select itswgt into :shipweight from piritem
710cA      where itwhse = :orwhse
710cA        and ititem = :oritem;
710cA
710cA   if sqlstt <> sqlSuccess;
710cA     shipweight = 0;
710cA   endif;
710cA
710cA  endsr; // zzzGetWeight
710cA /end-free
