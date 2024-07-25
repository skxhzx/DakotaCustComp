      /copy *libl/qcopysrc,hspecs
     *----------------------------------------------------------------
     *   Copyright (C) 2017 BFC Software, Inc. - All Rights Reserved
     *   BFC Software, Inc.
     *   (630) 562-0375
     *----------------------------------------------------------------
     *
     *  M23900     Class Rules  Validation/update
     *  12 June 2017
     *  Lynn McMahon
     *
     *----------------------------------------------------------------
     *  Revisions
     *
710 A*    06/12/17  LMC  7.10
     *      - Created
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  File Specs
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Table and array definitions
     *----------------------------------------------------------------


     *----------------------------------------------------------------
     * Clients
     *----------------------------------------------------------------

      /copy qcopysrc,p.getclien
     D client          s             10
     D clientloc       s             10

     *----------------------------------------------------------------
     *  Standard SQL variables and constants
     *----------------------------------------------------------------

      /copy qcopysrc,c#stdsql


     *----------------------------------------------------------------
     * DRI Programs
     *----------------------------------------------------------------


      /COPY *libl/qcopysrc,C#DRIPARMP
      /COPY *libl/qcopysrc,C#DRIPARMS

     *----------------------------------------------------------------
     * Variables
     *----------------------------------------------------------------

     D error           s               n
     D forevr          s               n

     *----------------------------------------------------------------
     *  Translation strings
     *----------------------------------------------------------------

     D   xupper        C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     D   xlower        C                   'abcdefghijklmnopqrstuvwxyz'

     *----------------------------------------------------------------
     *  Program info data structure
     *----------------------------------------------------------------

     D/copy qcopysrc,c#pgminfds


     *----------------------------------------------------------------
     *  Parameters
     *----------------------------------------------------------------

     D  pMessage       s             99
     D  pobjloc        s             10
     D  psubcmd        s             10
     D  pclass1        s             10
     D  pclass2        s             10
     D  plvlabv        s              2  0
     D  plvlblw        s              2  0
     D  ploclr         s              2  0
     D  plocbhd        s              3  0

     *----------------------------------------------------------------
     * Prototypes
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Files
     *----------------------------------------------------------------

     D carrec        E Ds                  Extname(classrule)

     *----------------------------------------------------------------
     *  Parameters
     *
     *    Input Parameters
     *      pObjLoc     Object Location
     *      pSubCmd     Sub Command
     *      pClass1     Class One
     *      pClass2     Class Two
     *      pLvlAbv     Level Above
     *      pLvlBlw     Level Below
     *      pLocLR      Location Left/Right
     *      pLocBhd     Location Behind
     *
     *    Returned Parameters
     *      pMessage   Return error message
     *
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  Let the show begin .....
     *----------------------------------------------------------------

     C     *entry        plist
     C                   parm                    pMessage
     C                   parm                    pObjLoc
     C                   parm                    pSubCmd
     C                   parm                    pClass1
     C                   parm                    pClass2
     C                   parm                    pLvlAbv
     C                   parm                    pLvlBlw
     C                   parm                    pLocLR
     C                   parm                    pLocBhd

     *----------------------------------------------------------------
     *  Main line
     *----------------------------------------------------------------

      /free

        *inlr = *on;

        pMessage = '';
        error = *off;

        // Convert fields to uppercase

        pClass1 = %xlate(xlower: xupper: pClass1);
        pClass2 = %xlate(xlower: xupper: pClass2);


        Select;
          When pObjLoc = '*FLDVALID';
            Select;
              When pSubCmd = 'A';
                exsr EditAdd;
              When pSubCmd = 'U';
                exsr EditUpd;
              When pSubCmd = 'D';
                exsr EditDlt;
            endsl;

          When pObjLoc = '*AFTERACT';
            Select;
              When pSubCmd = 'A';
                exsr Add;
              When pSubCmd = 'U';
                exsr Update;
              When pSubCmd = 'D';
                exsr Delete;
            endsl;
        endsl;
        return;

      /end-free

     *----------------------------------------------------------------
     *          SUBROUTINES IN ALPHABETICAL ORDER
     *----------------------------------------------------------------

     *----------------------------------------------------------------
     *  *Inzsr  Initialization subroutine
     *----------------------------------------------------------------

      /free
       begsr *Inzsr;

         getclient(client: clientLoc);

      /end-free

      /free
       endsr;
      /end-free

     *----------------------------------------------------------------
     *  EditAdd           Edits for Add function
     *----------------------------------------------------------------

      /free
       begsr EditAdd;
         // Class1 & Class2 cannot be the same
         if pClass1 = pClass2;
           error = *on;
           pMessage = 'Error: Class One and Class Two'
                    + ' cannot be the same';
           leavesr;
         Endif;
         // Cannot already exist
         exec sql select * into :carrec
            from classrule
            where carcl1 = :pclass1
             and carcl2 = :pclass2;

         If sqlstt = sqlSuccess;
           error = *on;
           pMessage = 'Error: Rules already Exist'
               + ' for Class Combination '
               + '(' + %trimr(pClass1) + ' ' + %trimr(pClass2) + ')';
           leavesr;
         Endif;
         // levels or location must be set
         if pLvlAbv = 0 and
            pLvlBlw = 0 and
            pLocLR = 0  and
            pLocBhd = 0;
           error = *on;
           pMessage = 'Error: All level and locations'
                    + ' rules cannot be zero';
           leavesr;
         Endif;
       endsr;
      /end-free

     *----------------------------------------------------------------
     *  EditDlt           Edits for Delete Function
     *----------------------------------------------------------------

      /free
       begsr EditDlt;
       endsr;
      /end-free

     *----------------------------------------------------------------
     *  EditUpd           Edits for Update Function
     *----------------------------------------------------------------

      /free
       begsr EditUpd;
         // levels or location must be set
         if pLvlAbv = 0 and
            pLvlBlw = 0 and
            pLocLR = 0  and
            pLocBhd = 0;
           error = *on;
           pMessage = 'Error: All level and locations'
                    + ' rules cannot be zero';
           leavesr;
         Endif;
       endsr;
      /end-free


     *----------------------------------------------------------------
     *  Add               Adds the reverse of the class rule entered
     *----------------------------------------------------------------

      /free
       begsr Add;
         // The original class rule is added by gui, then we will
         // add the reverse.
         exec sql insert into classrule
                values(:pClass2,
                       :pClass1,
                       :pLvlBlw,
                       :pLvlAbv,
                       :pLocLR,
                       :pLocBhd);

         If sqlstt = sqlSuccess;
           error = *on;
           pMessage = 'Error: Reverse was not written';
           leavesr;
         Endif;
       endsr;
      /end-free

     *----------------------------------------------------------------
     *  Update            Update the reverse class rule entered
     *----------------------------------------------------------------

      /free
       begsr Update;
         // The original class rule is updated by gui, then we will
         // update the reverse.
         exec sql update classrule set
                    carabv = :plvlblw,
                    carblw = :plvlabv,
                    carllr = :ploclr,
                    carlbh = :plocbhd
                  where carcl1 = :pclass2
                    and carcl2 = :pclass1;

         If sqlstt <> sqlSuccess;
           error = *on;
           pMessage = 'Error: Reverse was not written';
           leavesr;
         Endif;
       endsr;
      /end-free

     *----------------------------------------------------------------
     *  Delete            Delete the reverse class rule
     *----------------------------------------------------------------

      /free
       begsr Delete;
         // The original class rule is deleted by gui, then we will
         // delete the reverse.

         exec sql delete from classrule
                  where carcl2 = :pclass1
                    and carcl1 = :pclass2;

         If sqlstt <> sqlSuccess;
           error = *on;
           pMessage = 'Error: Reverse was not written';
           leavesr;
         Endif;
       endsr;
      /end-free

     *----------------------------------------------------------------
     *----------------------------------------------------------------
     *                     DRI SUBROUTINES
     *----------------------------------------------------------------
     *----------------------------------------------------------------


     O*----------------------------------------------------------------
     O*  COMPILE TIME TABLES
     O*----------------------------------------------------------------
