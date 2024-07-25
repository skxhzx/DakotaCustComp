     H DFTACTGRP(*NO)
    F*----------------------------------------------------------------
   F*   Copyright (C) 2016 BFC Software, Inc. - All Rights Reserved
    F*   BFC Software, Inc.
   F*----------------------------------------------------------------
   *!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   * PLEASE COMPILE WITH DEFAULT ACTIVATION GROUP (*NO).
   *!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  F*----------------------------------------------------------------
    F*  RH565    Item Total Qty Picked by Route
    F*  01 August, 2016
    F*  Thomas Bryant
    F*
    F*----------------------------------------------------------------
    F*  Revisions:
    F*
700 A *  08/01/16  TAB  7.00 Project# 01615
    F*    - Created
    F*  09/08/16  TAB  7.00a
    F*    - Added second detail line for catch weight per Max
    F*  10/27/16  TAB  7.00b
    F*    - Changed catch weight reoutin to sub-routin to catch all
    F*      records in ORDC1 file for printing.
    F*  11/28/16  TAB  7.00c
    F*    - Catch weights not printing correctly due to original design
    F*      not taking in account that multiple labels for item could be
    F*      in file. Added new label array to remedy issue.
    F*
    F*----------------------------------------------------------------
     F*
     *=====================================================================
     *   F I L E    S P E C I F C A T I O N S                           ===
     *=====================================================================
     FPirItem   IF   E           K Disk
     * Item Master file             ----------------------------------
     Flabel32c  IF   E           K Disk    prefix(l32)
     * Join file for Label Printing ----------------------------------
     FWarehs    IF   E           K disk
     * Warehouse Description file   ----------------------------------
     FOrdC1     IF   E           K Disk
     * Order Detail Catch Weight    ----------------------------------
     FReports   IF   E           K Disk
     * Report Description File      ----------------------------------
     FRH565PR   O    E             Printer UsrOpn OflinD(*In10)
     * Printer File                 ----------------------------------
     *=====================================================================
     * Data Structures & Variables
     *=====================================================================
     *Working storage data fields
     D $RptID          S             10    Inz('RH565PR')
     D $Title2         S             30
     D $WarehsD        S              3  0                                      Numeric Warehouse ID
     D $PstrW          S             60                                         String Data
     D $PlenW          S              3  0                                      String Length
     D $HoldItem       S             15                                         Hold Item ID
     D $HoldLabl       S              7  0                                      Hold Item ID
700cAD LabelArry       S              7  0 Dim(100) Inz                         Label Array
700cAD LC              S              3  0                                      Array Counter
     D FirstRecord     S               N   Inz('1')
700aAD CatWgtCount     S              2  0
     D WpDev           S             10                                         Printer Device
     D WpForm          S             10                                         Form Type
     D CmdLength       s             15  5 Inz(0)
     D CmdString       s            500    Inz(*Blanks)
     *----------------------------------------------------------------*
     *----------------------------------------------------------------*
     *----------------------------------------------------------------*
     *  Customer ID                                                   *
     *----------------------------------------------------------------*
     *----------------------------------------------------------------*
SOF A /copy qcopysrc,id#sofo
     *----------------------------------------------------------------*
     *  Passed Parms Prototype Definition                             *
     *----------------------------------------------------------------*
     D MainParms       PR                  Extpgm('RH565')
     D                                3a
     D                                5a
     D                                5a
     D                                8a

     D getClient       pr                  extpgm('GETCLIENT')
     D  client                       10
     D  clientloc                    10

     *----------------------------------------------------------------*
     D MainParms       PI
     D  $PWHSE                        3a                                        BFC Warehouse
     D  $PRTE                         5a                                        Customer Route No
     D  $PRTID                        5a                                        BFC Route ID
     D  $PRTN                         8a                                        BFC Return Code
     *----------------------------------------------------------------*
     *  External Program for Centering Text                           *
     *----------------------------------------------------------------*
     D Center          PR                  Extpgm('CENTER')
     D  $Pstr                        60                                         String Data
     D  $Plen                         3  0                                      String Length
     *----------------------------------------------------------------*
     *  External QCMDEXC Procedure                                    *
     *----------------------------------------------------------------*
     D $Command        PR                  Extpgm('QCMDEXC')
     D  Command                    5000    options(*varsize)
     d  Length                       15  5
     *----------------------------------------------------------------*
     D$dsLABEL       E DS                  Extname(LABEL)
     *----------------------------------------------------------------*
     *  Variables
     *----------------------------------------------------------------
     d client          s             10
     d clientloc       s             10
     d printreport     s               n   inz('0')
     *================================================================*
     *   M A I N L I N E   L O G I C                                  *
     *================================================================*

      /Free
         // Set SQL default parms
700cA      Exec SQL
700cA        Set Option Commit=*none, Dlyprp=*Yes,
700cA                   Closqlcsr = *ENDMOD;

             if printreport;
               Eval *In10 = *On;
               ExSR OpnPrt;
               ExSR $PrintHead;
               ExSR $PrintDetl;
               Write Skip1;
               Write Foot1;
               ExSR ClsPrt;
             Endif;
               Eval *InLR = *On;
               Return;
        //* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
        //   $PrintHead --  Subrotine to print report headings
        //* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
               BegSR $PrintHead;

                     Select;
                      When *In10;
                      Chain ($RptID) Reports;
                           If %Found(Reports);
                           Eval $PstrW = RPDESC;
                           Eval $PlenW = 40;
                           Callp Center($PstrW:$PlenW);
                           Eval Title = $PstrW;
                           EndIf;
                      Chain ($WarehsD) Warehs;
                           If %Found(Warehs);
                           Eval $PstrW = WHDESC;
                           Eval $PlenW = 30;
                           Callp Center($PstrW:$PlenW);

                           EndIf;
                           Eval $PstrW = $Title2;
                           Eval $PlenW = 30;
                           Callp Center($PstrW:$PlenW);
                           Eval Route = $PstrW;
                           Write Head1;
                           Write Head2;
                           Write Columns;
                           Eval *In10 = *Off;

                      Other;
                     EndSL;

               EndSR;
        //* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
        //   $PrintDetl --  Subrotine to print report detail lines
        //* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
               BegSR $PrintDetl;

        //------------- Setup and Initialize Array ----------------------

700cA             Clear LabelArry;
700cA             Eval LC = 0;

        //------------- Declare and Open SQL file  ----------------------
                    EXEC SQL Declare LabelR Cursor for
                             Select * from LABEL
                             Where (LBTYPE = 'O' or LBTYPE = 'B') and
                                    LBWHSE = :$WarehsD and
                                    LBRTE  = :$PRTID
                             Order by LBWHSE, LBRTE, LBITEM, LBTYPE;

                    EXEC SQL Open LabelR;
        //------------- Start fetching records for printing  ------------
                    DoU 0 <> 0;

                    EXEC SQL Fetch LabelR into :$dsLABEL;

                       If SQLCOD <> 0;
                          Leave;
                       EndIF;

                       If FirstRecord;
                          Eval $HoldItem = LBITEM;
700bA                     Eval $HoldLabl = LBLBL#;
700cA                     Eval LC = 1;
700cA                     Eval LabelArry(LC) = $HoldLabl;
                          Eval FirstRecord = *Off;
700aA                     Eval CatWgtCount = 0;
                       EndIF;

                       Select;
                       When $HoldLabl <> LBLBL# and
                            $HoldItem = LBITEM;
700bA                       Eval $HoldLabl = LBLBL#;
                            Eval LC = (LC +1);
700cA                       Eval LabelArry(LC) = $HoldLabl;

                       When $HoldItem <> LBITEM;
                            Eval PRITEM = $HoldItem;
                            Chain ($WarehsD:$Holditem) PirItem;
                            Write Detail1;
700bA                       ExSR CatWgt;
                            Clear Detail1;
                            ExSR $PrintHead;
                            Eval $HoldItem = LBITEM;
700bA                       Eval $HoldLabl = LBLBL#;
700cA                       Eval LC = 1;
700cA                       Eval LabelArry(LC) = $HoldLabl;

                       Other;
                       EndSL;

        //------------- Accumalate Totals for printing  -----------------
                       Select;
                       When LBUTYP = 'N';
                            Eval TQtyO1 = (TQtyO1 + LBQALC);
                            Eval TQtyP1 = (TQtyP1 + LBQPCK);

                       When LBUTYP = '1';
                            Eval TQtyO2 = (TQtyO2 + LBQALC);
                            Eval TQtyP2 = (TQtyP2 + LBQPCK);

                       When LBUTYP = '2';
                            Eval TQtyO3 = (TQtyO3 + LBQALC);
                            Eval TQtyP3 = (TQtyP3 + LBQPCK);

                       Other;
                       EndSL;

                       SetLL ($WarehsD:LBLBL#) OrdC1;
                             DoU %Eof(OrdC1);
                               ReadE ($WarehsD:LBLBL#) OrdC1;
                             If %EoF(OrdC1);
                               Leave;
                             EndIF;

                             Eval TWGTP =(TWGTP + OCCWGT);

                             EndDo;

                    EndDo;

        //------------- Print last accumalated data ---------------------
                            Eval PRITEM = $HoldItem;
                            Chain ($WarehsD:$Holditem) PirItem;
                            Write Detail1;
700aA                       ExSR CatWgt;
                            Clear Detail1;
        //------------- Close SQL data collectot ------------------------
                    EXEC SQL Close LabelR;
               EndSR;
        //* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
        //   CatWgt     --  Catch weight sub-routine to print line
        //* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
700bA          BegSR CatWgt;
                 Eval LC=1;

                 DoU LabelArry(LC) = 0;
                     Eval $Holdlabl = LabelArry(LC);

                 SetLL ($WarehsD:$HoldLabl) OrdC1;
                 DoU %Eof(OrdC1);
                 ReadE ($WarehsD:$HoldLabl) OrdC1;

                   If %EoF(OrdC1);
                     Leave;
                   EndIF;

700bA              CatWgtCount = (CatWgtCount + 1);
700aA              Select;
 |                   When CatWgtCount = 1;
 |                     Eval CWGT1 = OCCWGT;
 |                   When CatWgtCount = 2;
 |                     Eval CWGT2 = OCCWGT;
 |                   When CatWgtCount = 3;
 |                     Eval CWGT3 = OCCWGT;
 |                   When CatWgtCount = 4;
 |                     Eval CWGT4 = OCCWGT;
 |                   When CatWgtCount = 5;
 |                     Eval CWGT5 = OCCWGT;
 |                   When CatWgtCount = 6;
 |                     Eval CWGT6 = OCCWGT;
 |                   When CatWgtCount = 7;
 |                     Eval CWGT7 = OCCWGT;
 |                   When CatWgtCount = 8;
 |                     Eval CWGT8 = OCCWGT;
 |                   When CatWgtCount = 9;
 |                     Eval CWGT9 = OCCWGT;
 |                   When CatWgtCount = 10;
 |                     Eval CWGT10 = OCCWGT;
 |                   When CatWgtCount = 11;
 |                     Eval CWGT11 = OCCWGT;
 |                   When CatWgtCount = 12;
 |                     Eval CWGT12 = OCCWGT;
700bA                  Write Detail2;
700bA                  Clear Detail2;
700bA                  Eval CatWgtCount = 0;
 |                   Other;
700aA              EndSL;
                 EndDo;
700cA            Eval LC = (LC+1);
700cA            EndDo;
        //------------- Check to see if more weights to print -----------
700bA              If CWGT1 <> 0;
700bA                Write Detail2;
700bA                Clear Detail2;
700bA                Eval CatWgtCount = 0;
700bA              EndIf;

700cA              Clear LabelArry;
700bA          EndSR;
        //* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
        //   ClsPrt     --  Close Printer file subroutine
        //* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
               BegSR ClsPrt;
                     Close(e) RH565PR;
                     If %Error;
                     EndIf;
        //----- Delete Printer file overrides  --------------------------

                      Eval CmdString = 'DLTOVR '
                                     + 'FILE(RH565PR) ';
                      Eval CmdLength = %len(%trim(CmdString));
                      $Command (CmdString:CmdLength);

               EndSR;
        //* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
        //   OpnPrt     --  Open Printer file subroutine
        //* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
               BegSR OpnPrt;
                      Chain ($RptID) Reports;
                      If %Found(Reports);
                         Eval WpDev  = RPDEV;
                         Eval WpForm = RPFORM;
                      EndIF;

                      If WpDev = ' ';
                         Eval WpDev = '*JOB';
                      EndIF;
                      If WpForm = ' ';
                         Eval WpForm = '*STD';
                      EndIF;
        //----- Override Printer file -----------------------------------
                      Eval CmdString = 'OVRPRTF '
                                     + 'FILE(RH565PR) '
                                     + 'OUTQ(*DEV) '
                                     + 'DEV(' + %trim(wpdev) + ') '
                                     + 'FORMTYPE(' + %trim(wpform) + ') ';
                      Eval CmdLength = %len(%trim(CmdString));
                      $Command (CmdString:CmdLength);
        //----- Open Printer File ---------------------------------------
                      Open(e) RH565PR;

                      If %Error;
                      EndIf;
               EndSR;
        //* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
        //   *InzSR     --  Intialization Subroutine
        //* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
               BegSR *InzSR;

         // Get client

                     getClient(client : clientloc);

                     Eval $Title2 = $Prte + ' / ' + $PrtID;
                     Eval $WarehsD = %Dec($Pwhse:3:0);

         // Check if report should be printed. Only print for Dpt 6 routes.
                     eval printreport = '0';
                     setll ($WarehsD: $prtid) label32c;
                     reade ($WarehsD: $prtid) label32c;
                     if not %eof(label32c) and %subst(l32ohmisc:7:3) = '  6';
                       eval printreport = '1';
                     endif;

               EndSR;
