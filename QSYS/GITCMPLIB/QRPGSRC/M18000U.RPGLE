      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2015 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *
     *  M18000U    TruckBuilder colors update
     *  14 April 2015
     *  Dave Sommerville
     *
     *  Revisions:
     *
700 A*    04/14/15  DAS  7.00
     *      - Created.
     *
700aA*    05/13/15  LMC  7.00a
     *      - Revised for CUBE.
     *      - Added pCalls for controlling copy function.
     *
720 A*    05/16/18  KDE  7.20
     *      - Revised to call DD410 to update colors as changed
     *
740 A*    02/21/20  KDE  7.40
     *      - Revised to include Class and Category
     *
750 A*    10/01/21  KDE  7.50
     *      - Revised to update Mixed Zone Pallet Color
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * Notes:
     *
     *   When the PIRCOLORSH/D file was created it was decided to put
     *   the compartment colors into type COMP and the axle colors
     *   into type AXLE.
     *
     *   Later it was decided that it would be better to have a single
     *   TruckBuilder Colors maintenance program instead of one for
     *   TruckBuilder Compartment Colors and one for Axle Colors.
     *   But in the file the colors would still be assigned to types
     *   COMP and AXLE.
700aA*   We now have added CUBE.
     *
     *   Therefore, program M18000 is designed to only show the COMP
     *   records in the list display, but the entry screen will
     *   include both Compartment and Axle colors. Thus, this program
     *   will do 2 loops, one to update the COMP records and one to
     *   update the AXLE records.
700aA*   A third loop is added to update the CUBE records.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     * JSON String Notes:
     *
     *   MRC limits an External Program parameter to 999 characters.
     *
700aM*   The JSON string will consist of 3 arrays, COMP, AXLE and CUBE
     *   and will look like the following:
     *
     *   {"COMP":[{"c":"aaa","v":"bbb"},{"c":"aaa","v":"bbb"},...],
700aM*    "AXLE":[{"c":"aaa","v":"bbb"},{"c":"aaa","v":"bbb"},...],
700aA*    "CUBE":[{"c":"aaa","v":"bbb"},{"c":"aaa","v":"bbb"},...]}
     *
     *   were aaa is the code and bbb is the value.
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     Fpircolorshuf a e           k disk
     Fpircolorsduf a e           k disk

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pSessId     Session Id
     *      pUser       User
     *      pPgm        Program
     *      pObjLoc     Object location
     *      pWhse       Warehouse
     *      pFromSet    From set
     *      pSet        Set
     *      pDesc       Description
700aA*      pCalls      Number of times called - used for copy - first only
     *      pJSON       JSON String
     *
     *    Returned Parameters
     *      pErrMsg     Error message
     *
     *----------------------------------------------------------------

     D m18000u         pr                  extpgm('M18000U')
     D  pErrMsg                      99
     D  pSessId                      40
     D  pUser                        10
     D  pPgm                         20
     D  pObjLoc                      10
     D  pACD                          1
     D  pWhse                         3p 0
     D  pFromSet                     10
     D  pSet                         10
     D  pDesc                        30
700aAD  pCalls                        1
     D  pJSON                       999    varying

     D m18000u         pi
     D  pErrMsg                      99
     D  pSessId                      40
     D  pUser                        10
     D  pPgm                         20
     D  pObjLoc                      10
     D  pACD                          1
     D  pWhse                         3p 0
     D  pFromSet                     10
     D  pSet                         10
     D  pDesc                        30
700aAD  pCalls                        1
     D  pJSON                       999    varying

720 A*----------------------------------------------------------------
720 A*  Sub-Procedure Prototypes
720 A*----------------------------------------------------------------
720 AD dd410           pr                  extpgm('DD410')
720 AD  pCmd                         10    const
720 AD  pWhse                         3p 0
720 AD  pRtid                         5
720 AD  pGroup                        1
720 AD  pRow                          3p 0
720 AD  pCol                          2p 0
720 AD  pRtnCode                     10
720 AD  pRtnMsg                     100

     *----------------------------------------------------------------
     *  Variables
     *----------------------------------------------------------------

     D val             s            400    varying
     D delimiter       s              1    varying
     D cod             s             10    varying
     D curType         s             10    varying
     D scanStr         s             10    varying

     D aryBeg          s              5p 0
     D aryEnd          s              5p 0
     D codBeg          s              5p 0
     D codEnd          s              5p 0
     D codLen          s              5p 0
     D codPos          s              5p 0
     D valBeg          s              5p 0
     D valEnd          s              5p 0
     D valLen          s              5p 0
     D valPos          s              5p 0

720 Ad dragGroup       s              1
720 Ad dragRtid        s              5
720 AD dragRow         s              3  0
720 AD dragCol         s              2  0
720 AD dropGroup       s              1
720 AD dropRow         s              3  0
720 AD dropCol         s              2  0
720 AD rtnCode         s             10
720 AD rtnMsg          s            100
     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

      /Copy qcopysrc,c#pgminfds

     *----------------------------------------------------------------
     *  Standard variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdvar

     *----------------------------------------------------------------
     *  Translation strings
     *----------------------------------------------------------------

     D   xupper        C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     D   xlower        C                   'abcdefghijklmnopqrstuvwxyz'

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free
         *inlr = *on;

         pACD = %xlate(xlower: xupper: pACD);
         pFromSet = %xlate(xlower: xupper: pFromSet);
         pSet = %xlate(xlower: xupper: pSet);

         curType = 'COMP';
         exsr AAAUpdate;

740 A    curType = 'CAT';
740 A    exsr AAAUpdate;

740 A    curType = 'CLS';
740 A    exsr AAAUpdate;

         curType = 'AXLE';
         exsr AAAUpdate;

750 A    curType = 'MIX';
750 A    exsr AAAUpdate;

700aA    curType = 'CUBE';
700aA    exsr AAAUpdate;

         return;
      /end-free

     *----------------------------------------------------------------
     *  AAAUpdate    Process update
     *----------------------------------------------------------------

      /free
       begsr AAAUpdate;

         select;

           when pACD = 'A' and pFromSet <> '';
             exsr CopyRec;
700aA        exsr ChangeRec;

           when pACD = 'A';
             exsr AddRec;

           when pACD = 'U';
             exsr ChangeRec;

           when pACD = 'D';
             exsr DeleteRec;

         endsl;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  AddRec      Add record
     *----------------------------------------------------------------

      /free
       begsr AddRec;

         clrhwhse = pWhse;
         clrhtype = curType;
         clrhset = pSet;
         clrhdesc = pDesc;

         write(e) clrhrec;
         if %error;
           if pACD = 'A';
             exsr ChangeRec;
           else;
             pErrMsg = 'Error updating(2) PIRCOLORSH for '
                     + %char(pWhse) + '/' + %trim(curType) + '/'
                     + %trim(pDesc);
           endif;
         endif;

         exsr UpdateColors;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  CopyRec     Copy record
     *----------------------------------------------------------------

      /free
       begsr CopyRec;

700aA    // only do copy if pCalls = 1.
700aA    // We call the stored procedure multiple times because of the json
700aA    // string limitaion size.
700aA    if pCalls = '1';
           // Set cannot be the same

           if pFromSet = pSet;
             pErrMsg = 'From/New set cannot be the same';
             return;
           endif;

           // Copy Header

           chain (pWhse: curType: pFromSet) pircolorsh;
           if not %found(pircolorsh);
             pErrMsg = 'Set ' + %trim(pFromSet) + ' not found';
             return;
           endif;

           clrhset = pSet;
           clrhdesc = pDesc;
           write(e) clrhrec;
           if %error();
             pErrMsg = 'Error writing record for set ' + pSet;
             return;
           endif;

           // Copy Detail

           setll (pWhse: curType: pFromSet) pircolorsd;

           dow forever = forever;

             reade(n) (pWhse: curType: pFromSet) pircolorsd;

             if %eof(pircolorsd);
               leave;
             endif;

             clrdset = pSet;
             write(e) clrdrec;
             if %error();
             endif;

           enddo;

700aA    endif;
       endsr;
      /end-free

     *----------------------------------------------------------------
     *  ChangeRec   Change record
     *----------------------------------------------------------------

      /free
       begsr ChangeRec;

         chain (pWhse: curType: pSet) pircolorsh;

         if not %found(pircolorsh);
           if pACD <> 'A';
             exsr AddRec;
           else;
             pErrMsg = 'Error adding(2) PIRCOLORSH for '
                     + %char(pWhse) + '/' + %trim(curType) + '/'
                     + %trim(pDesc);
           endif;
           leavesr;
         endif;

         clrhdesc = pDesc;

         update(e) clrhrec;
         if %error;
           pErrMsg = 'Error updating PIRCOLORSH for '
                   + %char(pWhse) + '/' + %trim(curType) + '/'
                   + %trim(pDesc);
         endif;

         exsr UpdateColors;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  DeleteRec   Delete record
     *----------------------------------------------------------------

      /free
       begsr DeleteRec;

         // Delete Header

         chain (pWhse: curType: pSet) pircolorsh;

         if not %found(pircolorsh);
           leavesr;
         endif;

         delete(e) clrhrec;
         if %error;
           pErrMsg = 'Error deleting PIRCOLORSH for '
                   + %char(pWhse) + '/' + %trim(curType) + '/'
                   + %trim(pDesc);
         endif;

         // Delete Detail

         setll (pWhse: curType: pSet) pircolorsd;

         dow forever = forever;

700aD      //reade(n) (pWhse: curType: pSet) pircolorsd;
700aM      reade (pWhse: curType: pSet) pircolorsd;

           if %eof(pircolorsd);
             leave;
           endif;

           delete(e) clrdrec;
           if %error();
           endif;

         enddo;

       endsr;
      /end-free

     *----------------------------------------------------------------
     *  UpdateColors    Update colors
     *----------------------------------------------------------------

      /free
       begsr UpdateColors;

         if %len(pJSON) = 0;
           leavesr;
         endif;

         // Delete existing records for type

         setll (pWhse: curType: pSet) pircolorsd;

         dow forever = forever;

700aD      //reade(n) (pWhse: curType: pSet) pircolorsd;
700aM      reade (pWhse: curType: pSet) pircolorsd;

           if %eof(pircolorsd);
             leave;
           endif;

           delete(e) clrdrec;
           if %error();
           endif;

         enddo;

         // Get array start and end for type

700aA    i = 1;
         scanStr = '"' + curType + '":[';
         aryBeg = %scan(scanStr: pJSON: i);
         if aryBeg = 0;
           leavesr;
         endif;

         aryEnd = %scan(']': pJSON: aryBeg);
         if aryEnd = 0;
           leavesr;
         endif;

         i = aryBeg;

         dow forever = forever;

           // Get next code

           codPos = %scan('"c"': pJSON: i);
           if codPos = 0 or codPos > aryEnd;
             leave;
           endif;

           // Calculate beginning of option code

           codBeg = codPos + 5;

           // Get end of option code

           codEnd = %scan('",': pJSON: codBeg);
           if codEnd = 0;
             leave;
           endif;

           // Calculate length of option code

           codLen = codEnd - codBeg;

           // Get option code

           cod = %subst(pJSON: codBeg: codLen);

           // Calculate beginning of value

           valBeg = codEnd + 7;
           if valBeg > aryEnd;
             leave;
           endif;

           // Get end of value

           valEnd = %scan('"}': pJSON: valBeg);
           if valEnd = 0 or valEnd > aryEnd;
             leave;
           endif;

           // Calculate length of value

           valLen = valEnd - valBeg;

           // Get code value

           val = %subst(pJSON: valBeg: valLen);

           // Add record

           clrdwhse = pWhse;
           clrdtype = curType;
           clrdset = pSet;
           clrdcode = cod;
           clrdcolor = val;
           write(e) clrdrec;
           if %error();
           endif;

           i = valEnd;

         enddo;
720 A
720 A    // Update Colors for Route Detail
720 A
720 A    dragRtid = *blanks;
720 A    dragGroup = *blanks;
720 A    dragRow = 0;
720 A    dragCol = 0;
720 A    rtnCode = *blanks;
720 A    rtnMsg = *blanks;
720 A
720 A    if curType = 'COMP'
740 A       or curType = 'CAT'
740 A       or curType = 'CLS'
750 A       or curType = 'MIX'
750 A       or curType = 'CUBE';
720 A       dd410 ('*COLORS': pWhse: dragRtid: dragGroup: dragRow: dragCol:
720 A              rtnCode: rtnMsg);
720 A    endif;

       endsr;
      /end-free
