      /copy *libl/qcopysrc,hspecs
650bAH DFTACTGRP(*NO) ACTGRP(*CALLER)
      *----------------------------------------------------------
      *   Copyright (C) 2014 BFC Software, Inc. - All Rights Rese
      *   BFC Software, Inc.
      *----------------------------------------------------------
      *
      *  opnReplen   Retrieve and Return Open MFG Line Replenishments
      *  17 June 2014
      *  Kenneth Elder
      *
      *  Revisions:
      *
     *    06/17/14  KDE  6.50
     *      - Created.
     *
700 A*    10/05/15  KDE  7.00
     *      - When deleting breakdown replen it is also
     *        deleting the case replen.
     *
700bC*    01/17/16  DLS  7.00b
     *      - Changed to use a max of 11 replenishments in JSON string.
      *----------------------------------------------------------

      *----------------------------------------------------------
      * File Specs
      *----------------------------------------------------------
     Foptions   if   e           k disk
     Fplined    if   e           k disk
     fitemprd   if   e           k disk
     Fpiritem   if   e           k disk
     F                                     rename(itrec:itrec1)
     Fbfcdbgflg if   e           k disk    usropn
     Fbfcdebug  o    e           k disk

      *----------------------------------------------------------
      *  Program information data structure
      *----------------------------------------------------------
      /copy qcopysrc,c#stdvar
      /COPY *libl/qcopysrc,C#SLOT
510bA /COPY *libl/qcopysrc,C#LICINFO
      /COPY *libl/qcopysrc,C#DRIPARMP
      /COPY *libl/qcopysrc,C#DRIPARMS

     D pssrflag        s               n

     D                sds
     D  #pgm                   1     10
     D  #prog                  1     10
     D  #status               11     15
     D  #stmt                 21     28  0
     D  #routine              29     36
     D  #parms                37     39
     D  #pgmmsg               91    170
     D  #job                 244    253
     D  #user                254    263
     D  #jobnbr              264    269
     D  #jobn                264    269
     D  #jobdate             276    281  0
     D  #jobtime             282    287  0
     D  #curruser            358    367

      *** End C#PGMINFDS ***

      *----------------------------------------------------------
      *  Prototypes
      *----------------------------------------------------------
      /copy qcopysrc,p.wrtsessl

     D usleep          pr            10u 0 extproc('usleep')
     D  Interval                     10u 0 value

      *----------------------------------------------------------
      *  Input Parms
      *----------------------------------------------------------

     D  pWhse          s              3p 0
     D  pMfgNo         s              3p 0
     D  pItem          s             15    varying
     D  pFunc          s              1    varying
     D  ritem          s             15    varying
     D  rtslt          s             12    varying
     D  rqty           s              3  0
     D  pOutStr        s           1536    varying

      *----------------------------------------------------------
      *  Variables
      *----------------------------------------------------------
     *
     *  Data Structure to hold open MFG replenishments
     *
     D                 ds
     D aryOpnRpl                     91    dim(15)
     D  rtnitem                      15    overlay(aryOpnRpl:*next)
     D  rtniDsc                      30    overlay(aryOpnRpl:*next)
     D  rtnQty                        3p 0 overlay(aryOpnRpl:*next)
     D  rtnFslt                      12    overlay(aryOpnRpl:*next)
     D  rtnTslt                      12    overlay(aryOpnRpl:*next)
     D  rtnType                       1    overlay(aryOpnRpl:*next)
     D  rtnUOM2                       4    overlay(aryOpnRpl:*next)

     D itemdesc        s             40
     D wherelabel      s            300
     DreturnStatus     S             10I 0
     D Ok              c                   0
     D sqlSuccess      c                   '00000'
     D SqlStmt         s           2000    inz(' ')
     D len             s              3  0
     D whse            s              3  0
     D outWgt          s              9  0
     D SkipFirstRead   s               n
     D rc              s              3  0 inz(0)
     D lstary          s              3  0 inz(0)
     D logText         s            100
     D Numbers         S             11    Inz(' 0123456789')
     D Non_Num_Posn    S              2  0 Inz(*Zero)
     D dbgflgExists    s               n
     D debug           s               n
     D drierr          s               n
     D mfgLine         s               n
     d TodayJul        s              5
     d wrkMfgno        s              2  0
     d bugstate        s              5  0
     d jultoDay        s             12
     D saveVer#        s                   like($slver#)
     d stkAisle        s             12
     d wkError         s               n
     d wkRerr2         s             50

      *----------------------------------------------------------------
      *  Data structure for error message parameters
      *------------------------------------------------------------------
     D $MDT            DS
     D  ERRMSG                 1     50
     D                 DS
     D  $EC                    1      2P 0

     *----------------------------------------------------------------
     *  *PROD  -  Production Option Settings
     *----------------------------------------------------------------
     *
     * Fields
     *
     *    OPLBRP  -  Reprint production labels
     *    OPLBDL  -  Delete Production labels
     *    OPVARM  -  Use Variable Measure for generated GTIN
     *    OPIMPGTIN  Import GTIN's from Customer
     *    OPGENGTIN  Generate GTIN's from customer item number
     *    OPPRDDTE-  Include Production date in GS1
     *    OPPCKDTE-  Include Package date in GS1
     *    OPEXPDTE-  Include Expiration Date in GS1
     *    OPNETLBS-  Include Net pounds in GS1
     *    OPLBSDEC-  Number of decimals for Net pounds
     *    OPNETKG -  Include Net kilograms in GS1
     *    OPKGDEC -  Number of decimals for Net kilograms
     *
     *----------------------------------------------------------------

     D opdata          ds
     D  oplbrp                 1      1
     D  oplbdl                 2      2
     D  opvarm                 3      3
     D  opimpgtin              4      4
     D  opgengtin              5      5
     D  opprddte               6      6
     D  oppckdte               7      7
     D  opexpdte               8      8
     D  opnetlbs               9      9
     D  oplbsdec              10     10  0
     D  opnetkg               11     11
     D  opkgdec               12     12  0
     D  optend               117    117

      *----------------------------------------------------------
      *  Standard SQL variables and constants
      *----------------------------------------------------------

      *copy qcopysrc,c#stdsql

      *----------------------------------------------------------
      *  SQL record layouts referenced
      *----------------------------------------------------------

     D prrec         E Ds                  Extname(Prplfil)
     D itrec         E Ds                  Extname(Piritem)

     *----------------------------------------------------------------
     * Parameters
     *
     *    Input Parameters
     *      pSessId      Session Id of caller
     *      pUser        User making call
     *      pPgm         Dictionary and Program calling
     *      pWhse        Warehouse hard wired to user
     *      pMfgNo       MFG Line being passed
     *      pItem        Raw MAterial that MFG Lie needs
     *      pFunc        Function to perform
     *      pOutStr      Return string with JSON data
     *
     *    Returned Parameters
     *      pOutStr      Output string
     *
     *----------------------------------------------------------------

     c     *entry        plist
     c                   parm                    pSessId          40
     c                   parm                    pUser            10
     c                   parm                    pPgm             20
     c                   parm                    pWhse
     c                   parm                    pMfgNo
     c                   parm                    pItem
     c                   parm                    pFunc
     c                   parm                    ritem
     c                   parm                    rtslt
     c                   parm                    rqty
     c                   parm                    pOutStr

      /free

          exsr init;
          if mfgLine;
             select;
                when PFunc = 'R';
                   exsr bldOpnReplen;
                   exsr crtJSON;
                when PFunc = 'D' or PFunc = 'E';
                   exsr delReplen;
                   exsr bldOpnReplen;
                   exsr crtJSON;
                other;
                   pOutStr = '{"err":"Invalid Function Received"}';
             endsl;
          else;
             pOutStr = '{"err":"Invalid MFG Line (Plined)"}';
          endif;

        *inlr = *on;

       //---------------------------------------------------------
       // Init  -  Do some one time things
       //---------------------------------------------------------

          begsr Init;

             open(e) bfcdbgflg;
             if %error;
               dbgflgExists = *off;
             else;
               dbgflgExists = *on;
             endif;

             if dbgflgExists;
               chain(e) (#pgm) bfcdbgflg;
               if %found(bfcdbgflg);
                 debug = (bdfflag = 1);
               else;
                 debug = *off;
               endif;
             endif;

             pOutStr = '{}';

                         #curruser = pUser;

             // get current MFG line record for definition
             chain (pWhse:pMfgNo) plined;
             if %found(plined);
                stkAisle = inRcvAisl;
                mfgLine = *on;
             else;
                stkAisle = ' ';
                mfgLine = *off;
             endif;

      /end-free
     *
     *   Get default values for the user.
     *

     C                   call      'GETUSER'
     C                   parm                    #curruser
     C                   parm      0             #whse             3 0
     C                   parm      0             #emp#             5 0
     C                   parm                    #fnam            15
     C                   parm                    #init             1
     C                   parm                    #lnam            20
     C                   parm                    #whdp             5
     C                   parm                    #styp             1
     C                   parm                    #shft             6
     C                   parm                    #crew             6
     C                   parm      0             #nhrs             3 1
     C                   parm                    #rtn              8
      /free
          endsr;

       //---------------------------------------------------------
       // bldOpnReplen - Build JSON string with open Replenishments
       //---------------------------------------------------------

       begsr bldOpnReplen;

           exsr clrOpnReplen;
           clear aryOpnRpl;
           rc = 1;
           wrkmfgno = pmfgno;

           // select Prioritiy Replenishments where warehouse,
           // To Aisle and To Level match to represent passed
           // MFG Line

           wherelabel = 'where prWhse = ' + sq + %char(pWhse) + sq;

           wherelabel = %trim(wherelabel) +
                     ' and prtail = ' + sq + stkAisle + sq;

           wherelabel = %trim(wherelabel) +
                     ' and prflag <> ' + sq + 'D' +sq;

           wherelabel = %trim(wherelabel) +
                     ' and prtlvl = ' + sq + %char(pMfgNo) + sq;

           sqlStmt = 'Select * from prplfil ' +
                     whereLabel;

                     sqlStmt = %trim(sqlStmt) + ' order by pritem ';

                     sqlStmt = %trim(sqlStmt);

                    exec sql PREPARE sel FROM :SqlStmt;

                    exec sql DECLARE OpnReplen SCROLL CURSOR FOR SEL;

                    exec sql OPEN OpnReplen;

             exec sql
               FETCH NEXT FROM OpnReplen INTO :prrec;

             dow Sqlstt = sqlSuccess;

700b               if rc > 11;
                      leave;
                   endif;

                exsr bldOpnArray;

                exec sql
                  FETCH NEXT FROM OpnReplen INTO :prrec;

             enddo;


               // Close SQL cursor, end program
                 Exec Sql Close OpnReplen;

         endsr;

       //---------------------------------------------------------
       // bldOpnArray - Create array of open replenishments
       //---------------------------------------------------------

          begsr bldOpnArray;

             exsr rtvitem;
             rtnitem(rc) = pritem;
             rtnqty(rc) = prqty;
             rtnfslt(rc) = prfdis;
             rtntslt(rc) = prtdis;
             rtnidsc(rc) = itdesc;
             rtntype(rc) = prtype;
             if prtype = 'E';
                rtnUOM2(rc) = '(' + %trim(itum2) + ')';
             else;
                rtnUOM2(rc) = ' ';
             endif;
             rc = rc +1;

          endsr;

       //---------------------------------------------------------
       // crtJSON - Create the open replenishment JSON string
       //---------------------------------------------------------

          begsr crtJSON;
          // First two parms will always go back
          pOutStr = '{'
                 +  '"whse":"'  + %char(pwhse) + '",'
                 +  '"mfgno":"'  + %trimr(%char(pmfgno)) + '"';
          // next loop will send back open replens if they exist
                 rc = 1;
                 if rtnitem(rc) <> ' ';

        // loops through open replenishments to return to user

                 dow rtnitem(rc) <> ' ';

                    pOutStr = %trim(pOutStr) + ','
        +  '"item' + %char(rc) + '":"'  + %trimr(rtnitem(rc)) + '      ",'
        +  '"idsc' + %char(rc) + '":"'  + %trimr(rtnidsc(rc)) +         '",'
        +  '"qty' + %char(rc) + '":"'  + %trimr(%char(rtnqty(rc)))
        +     %trim(rtnUOM2(rc)) + ' ",'
        +  '"itype' + %char(rc) + '":"'  + %trimr(rtnType(rc)) + '",'
        +  '"fslt' + %char(rc) + '":"'  + %trimr(rtnfslt(rc)) + '",'
        +  '"tslt' + %char(rc) + '":"'  + %trimr(rtntslt(rc)) + '"';
                       rc = rc + 1;

700b                   if rc > 11;
                          leave;
                       endif;

                    enddo;


                 endif;

          // Close off the JSON string
          pOutStr = %trim(pOutStr) + '}';
          endsr;


       //---------------------------------------------------------
       // clrOpnReplen - Clear Array
       //---------------------------------------------------------

          begsr clrOpnReplen;

             rc = 1;
700b         dow rc < 12;
                rtnitem(rc) = ' ';
                rtnidsc(rc) = ' ';
                rtnqty(rc) = 0;
                rtnfslt(rc) = ' ';
                rtntslt(rc) = ' ';
                rc = rc + 1;
             enddo;

          endsr;

       //---------------------------------------------------------
       // delReplen - Delete requested priority replenishment
       //---------------------------------------------------------

         begsr delReplen;
           // check to see if a license or quantity exist for to slot
           // if nothing exist then physically delete slot

                         pritem = ritem;
                         exsr rtvitem;
                         savever# = $slver#;
                         exsr clr$slot;
                         $slver# = savever#;
                         $slwhseu = *on;
                         $slwhse  = pWhse;
                         $slwhdpu = *on;
                         $slwhdp  = itwhdp;
                         $slitemu = *on;
                         $slitem  = ititem;
                         $saitemu = *on;
                         $saitem  = rItem;
                         $sldispu = *on;
                         $sldisp  = rtslt;

                         $dricommand = '*SLOT';
650gA                    $drisubcmd  = '%GET';
                         $drisys2upd = 'D';
                         exsr zzdricop;
                      // if no errors check to see if slot can
                      // be deleted.  The slot could have more than
                      // this one replenishment
                         if not drierr
                            and $saToLcns = '*NONE'
                             and $slstk1=0 and $slstk2=0 and $slstk3=0;
                         exsr clr$slot;
                         $slwhseu = *on;
                         $slwhse  = pWhse;
                         $slwhdpu = *on;
                         $slwhdp  = itwhdp;
                         $sldispu = *on;
                         $sldisp  = rtslt;

                         $saActionU = *on;
                         $saAction = 'PRD';
                         $saETrn#U = *on;
                         $saETrn# = 0;

                         $dricommand = '*SLOT';
                         $drisubcmd  = '%DELETEX';
                         $drisys2upd = 'D';
                         exsr zzdricop;
                         endif;

               // mark the replenishment for deletion
                 if PFunc = 'D';
                         exec sql
                          delete from PRPLFIL
                where prtdis = :rtslt and prqty = :rqty and pritem = :ritem
                   and prflag = 'S' and prtype<>'E';
                 else;
                         exec sql
                          delete from PRPLFIL
                where prtdis = :rtslt and prqty = :rqty and pritem = :ritem
                   and prflag = 'S' and prtype='E';
                 endif;
         endsr;

       //---------------------------------------------------------
       // rtvItem - Retrieve description for the open
       //           replenishment
       //---------------------------------------------------------

         begsr rtvItem;

        // get item description
             exec sql
              select *
               into :itrec
                from piritem
                 where ititem = :pritem;

          if Sqlstt <> sqlSuccess;
             itemdesc = '** Invalid Item **';
          else;
             // make sure this is a production defined raw material
             chain (pWhse:pItem) itemprd;
             If not %found(itemprd) or ipprdflg<>'R';
                itemdesc = '** item not raw material **';
             else;
                itemdesc = itdesc;
             endif;
          EndIf;

         endsr;


      /end-free
     *----------------------------------------------------------------
     *  zzdriCop   Call DRICOP
     *----------------------------------------------------------------

     c     zzDriCop      begsr
     *
     c                   eval      wkError = *off
     *
     c                   select
     *
     C                   when      $dricommand = '*SLOT'
     C                   eval      $dridata = $slot
     C                   eval      $dridata2 = $slot2

     c                   endsl
     *
     c                   select
     *
     c                   when      $dricommand = '*SLOT'
     c                   call(e)   'DRICOP'
     c                   parm                    $dricommand
     c                   parm                    $drisubcmd
     c                   parm                    $drisys2upd
     c                   parm      #prog         $driprogram
     c                   parm      ' '           $drireturn
     c                   parm      ' '           $drimessage
     c                   parm                    $dridata
     c                   parm                    $dridata2

     c                   other
     c                   call(e)   'DRICOP'
     c                   parm                    $dricommand
     c                   parm                    $drisubcmd
     c                   parm                    $drisys2upd
     c                   parm      #prog         $driprogram
     c                   parm      ' '           $drireturn
     c                   parm      ' '           $drimessage
     c                   parm                    $dridata

     c                   endsl

     c                   select

     c                   when      %error
     c                   eval      wkError = *on
     c                   if        $drimessage <> *blanks
     c                   eval      wkrerr2 = $drimessage
     c                   endif
     c                   eval      errmsg    = 'Error occured on call to '
     c                                       + 'DRICOP'
     c                                       + '/' + %trim($drisubcmd)
     c                                       + ' from ' + #prog

     c                   when      $drireturn <> '*OK'
     c                   eval      wkError = *on
     c                   if        $drimessage <> *blanks
     c                   eval      wkrerr2 = $drimessage
     c                   endif

     c                   endsl

     c                   select
     c                   when      $dricommand = '*SLOT'
     c                   eval      $slot = $dridata
     C                   eval      $slot2 = $dridata2
     c                   endsl

     c                   endsr

     *----------------------------------------------------------------
     *  clr$slot  Clear $slot data structure fields
     *----------------------------------------------------------------

     C     clr$slot      begsr
     C                   eval      savever# = $slver#
     C                   clear                   $slot
     C                   eval      $slver# = savever#
     C                   endsr
