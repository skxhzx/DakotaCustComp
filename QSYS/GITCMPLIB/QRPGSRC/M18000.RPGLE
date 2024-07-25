      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2015 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  M18000     TruckBuilder colors
     *  11 April 2015
     *  Dave Sommerville
     *
     *  Revisions:
     *
700 A*    04/11/15  DAS  7.00
     *      - Created.
     *
700aA*    05/13/15  LMC  7.00a
     *      - Added Cube Routine
     *
740 A*    02/21/20  KDE  7.40
     *      - Added Categories and Classes
     *
750 A*    10/01/21  KDE  7.50
     *      - Added section for Mixed Zone Pallets
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Notes:
     *
     *   MRC limits a return variable to 2000 characters.
     *
     *   We are assuming that the colors won't go over 2000 characters.
     *
     *   See program DDOPTSGET on how to handle a return string
     *   greater than 2000 characters.
     *
     *   The logic used in this program is based on DDOPTSGET, so
     *   some of the logic may seem like overkill.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Ftrkcomp   if   e           k disk
740 Afitemcat   if   e           k disk
740 Afclass     if   e           k disk
     Fpircolorsdif   e           k disk

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pSessId     Session Id
     *      pUser       User
     *      pPgm        Program
     *      pWhse       Warehouse
     *      pSet        Set
     *
     *    Returned Parameters
     *      pJSON       JSON String
     *
     *----------------------------------------------------------------

     D m18000          pr                  extpgm('M18000')
     D  pSessId                      40    varying
     D  pUser                        10    varying
     D  pPgm                         20
     D  pWhse                         3p 0
     D  pSet                         10
     D  pJSON                      2000    varying

     D m18000          pi
     D  pSessId                      40    varying
     D  pUser                        10    varying
     D  pPgm                         20
     D  pWhse                         3p 0
     D  pSet                         10
     D  pJSON                      2000    varying

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D forever         s               n
     D full            s               n

     D  pCallNum       s              1p 0

     D debug1          s           1000    varying
     D debug2          s           1000    varying

     D currStr         s           2000    varying
     D errStr          s             50    varying
     D largeStr        s           2000    varying
     D prvStr          s           6000    varying

     D clr             s              7    varying
     D cod             s             10    varying
     D delimiter       s              1    varying
     D delimiter2      s              1    varying
     D dsc             s            500    varying
     D opt             s             40    varying
     D val             s            400    varying

     D startPos        s              5p 0
     D endPos          s              5p 0
     D outLen          s              5p 0
     D maxLen          s              5p 0
     D len             s              5p 0
     D remainLen       s              5p 0

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /Copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free
         *inlr = *on;

         pCallNum = 1;

         // Initialize max lengths

         outLen = %size(pJSON) - 2;
         maxLen = %size(largeStr) - 2;

         // Initialize overflow string

         errStr = '{"opt":"OVRFLOW"}';

         // Build large string

         largeStr = '{"recs":[';
         delimiter = '';

         exsr CompColors;
750 A    exsr MixedColor;
         exsr AxleColors;
700aA    exsr CubeColors;
740 A    exsr CatColors;
740 A    exsr ClsColors;

         if not full;
           exsr Append;
           largeStr += ']}';
         endif;

         // Extract section for call number

         startPos = ((pCallNum - 1) * outLen) + 1;
         endPos = pCallNum * outLen;
         if endPos > %len(largeStr);
           endPos = %len(largeStr);
         endif;
         len = endPos - startPos + 1;

         if len > 0;
           pJSON = %subst(largeStr: startPos: len);
         else;
           pJSON = '';
         endif;

         len = %len(largeStr);
         select;
           when len > 1000;
             debug1 = %subst(largeStr: 1: 1000);
             debug2 = %subst(largeStr: 1001: len-1000);
           when len > 0;
             debug1 = %subst(largeStr: 1: len);
         endsl;

       return;
      /end-free

     *----------------------------------------------------------------
     *  Append    Append to large string
     *----------------------------------------------------------------

      /free
       begsr Append;

         remainLen = maxLen - %len(largeStr) - 2;

         // If everything fits, append previous string

         if (%len(prvStr)+%len(currStr)) <= remainLen;
           largeStr += prvStr;
           prvStr = currStr;
           currStr = '';
           leavesr;
         endif;

         // Otherwise we have overflow condition.
         // We should at least be able to append the error string,
         // but try to include the previous string as well.
         // End result should be screen with the last field row
         // showing an Overflow message.

         full = *on;

         if (%len(prvStr)+%len(errStr)) > remainLen;
           largeStr += errStr;
         else;
           largeStr += prvStr + errStr;
         endif;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  JsonComp1    Add first part of Compartment to JSON string
     *----------------------------------------------------------------

      /free
       begsr JsonComp1;

         currStr = delimiter
                 + '{"opt":"' + opt + '",'
                 +  '"dsc":"' + dsc + '",';

         delimiter = ',';
       endsr;
      /end-free

     *----------------------------------------------------------------
     *  JsonComp2    Add second part of Compartment to JSON string
     *----------------------------------------------------------------

      /free
       begsr JsonComp2;

         currStr += delimiter2
                 +  '{"cod":"' + cod + '",'
                 +   '"dsc":"' + dsc + '",'
                 +   '"clr":"' + clr + '"}';

         delimiter2 = ',';
       endsr;
      /end-free

     *----------------------------------------------------------------
     *  AxleColors - Axle colors
     *----------------------------------------------------------------

      /free
       begsr AxleColors;

         opt = 'AXLE';
         dsc = 'Axle colors';
         exsr JsonComp1;

         currStr += '"colors":[';
         delimiter2 = '';

         cod = 'AX_OK';
         dsc = 'Axle Okay';

         chain (tpwhse: 'AXLE': pSet: cod) pircolorsd;
         if %found(pircolorsd);
           clr = %trimr(clrdcolor);
         else;
           clr = '';
         endif;

         exsr JsonComp2;

         cod = 'AX_WARN';
         dsc = 'Axle Warning';

         chain (tpwhse: 'AXLE': pSet: cod) pircolorsd;
         if %found(pircolorsd);
           clr = %trimr(clrdcolor);
         else;
           clr = '';
         endif;

         exsr JsonComp2;

         cod = 'AX_OVER';
         dsc = 'Axle Over Limit';

         chain (tpwhse: 'AXLE': pSet: cod) pircolorsd;
         if %found(pircolorsd);
           clr = %trimr(clrdcolor);
         else;
           clr = '';
         endif;

         exsr JsonComp2;

         currStr += ']}';

         exsr Append;

       endsr;
      /end-free

750 A*----------------------------------------------------------------
750 A*  MixedColor - Mixed Pallet Color Section
750 A*----------------------------------------------------------------

      /free
       begsr MixedColor;

         opt = 'MIX ';
         dsc = 'Mixed Pallet Color';
         exsr JsonComp1;

         currStr += '"colors":[';
         delimiter2 = '';

         cod = '     ';
         dsc = ' ';

         chain (tpwhse: 'MIX ': pSet: cod) pircolorsd;
         if %found(pircolorsd);
           clr = %trimr(clrdcolor);
         else;
           clr = '';
         endif;

         exsr JsonComp2;

         currStr += ']}';

         exsr Append;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  CompColors - Compartment colors
     *----------------------------------------------------------------

      /free
       begsr CompColors;

         opt = 'COMP';
         dsc = 'Compartment colors';
         exsr JsonComp1;

         currStr += '"colors":[';
         delimiter2 = '';

         setll (pWhse) trkcomp;

         dow forever = forever;

           reade (pWhse) trkcomp;
           if %eof(trkcomp);
             leave;
           endif;

           cod = tpcode;
           dsc = %trimr(tpdesc);

           chain (tpwhse: 'COMP': pSet: tpcode) pircolorsd;
           if %found(pircolorsd);
             clr = %trimr(clrdcolor);
           else;
             clr = '';
           endif;

           exsr JsonComp2;

         enddo;

         currStr += ']}';

         exsr Append;

       endsr;
      /end-free

740 A*----------------------------------------------------------------
740 A*  CatColors - Category colors
740 A*----------------------------------------------------------------

      /free
740 A  begsr Catcolors;

         opt = 'CAT';
         dsc = 'Category colors';
         exsr JsonComp1;

         currStr += '"colors":[';
         delimiter2 = '';

         setll (*loval) itemcat;

         dow forever = forever;

           read itemcat;
           if %eof(itemcat);
             leave;
           endif;

           cod = iccode;
           dsc = %trimr(icdesc);

           chain (pwhse: 'CAT': pSet: iccode) pircolorsd;
           if %found(pircolorsd);
             clr = %trimr(clrdcolor);
           else;
             // only return categories setup
             iter;
           endif;

           exsr JsonComp2;

         enddo;

         currStr += ']}';

         exsr Append;

       endsr;
      /end-free

740 A*----------------------------------------------------------------
740 A*  ClsColors - Class colors
740 A*----------------------------------------------------------------

      /free
740 A  begsr ClsColors;

         opt = 'CLS';
         dsc = 'CLass colors';
         exsr JsonComp1;

         currStr += '"colors":[';
         delimiter2 = '';

         setll (*loval) class;

         dow forever = forever;

           read class;
           if %eof(class);
             leave;
           endif;

           cod = cacode;
           dsc = %trimr(cadesc);

           chain (pwhse: 'CLS': pSet: cacode) pircolorsd;
           if %found(pircolorsd);
             clr = %trimr(clrdcolor);
           else;
             // only return categories setup
             iter;
           endif;

           exsr JsonComp2;

         enddo;

         currStr += ']}';

         exsr Append;

       endsr;
      /end-free

700aA*----------------------------------------------------------------
700aA*  CubeColors - Class colors
700aA*----------------------------------------------------------------

700aA /free
700aA  begsr CubeColors;

         opt = 'CUBE';
         dsc = 'Cube colors';
         exsr JsonComp1;

         currStr += '"colors":[';
         delimiter2 = '';

         cod = 'CUBE_MAX';
         dsc = 'Exceeds Maximum';

         chain (tpwhse: 'CUBE': pSet: cod) pircolorsd;
         if %found(pircolorsd);
           clr = %trimr(clrdcolor);
         else;
           clr = '';
         endif;

         exsr JsonComp2;

         cod = 'CUBE_MIN';
         dsc = 'Under Minimum';

         chain (tpwhse: 'CUBE': pSet: cod) pircolorsd;
         if %found(pircolorsd);
           clr = %trimr(clrdcolor);
         else;
           clr = '';
         endif;

         exsr JsonComp2;


         currStr += ']}';

         exsr Append;

700aA  endsr;
700aA /end-free

