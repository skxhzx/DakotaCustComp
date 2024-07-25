      *===================================================================
      *
      *  Name .......... C#UCIINFO
      *  Description ... Dakota realtime interface layout for *UCIINFO
      *  Created by .... Lynn McMahon
      *
      *===================================================================
      *
      * Revisions
      *
640 A *   09/11/12  LMC  6.40
      *     - Created.
      *
650aA *   12/03/12  LMC  6.50a
      *     - Added new field.
      *
700aA *   06/15/16  MR   7.00a
      *     - Added new field - $uiToLcns
      *
720aA *   07/14/16  DAS  7.20a
      *     - Changed version to 3.
      *     - Included $uiToLcns under version 3.
      *     - Added new fields.
      *     - Getting close to 512 max for $uciinfo data structure.
      *     - Maxed out $uciinfo - Adding the timestamp for partials
      *       into $uciinfo2.
      *
      *===================================================================
      *
      * Notes
      *
416 A *   - When adding new fields ...
      *
      *       1) Increment the version number
      *       2) Always add new fields to the end of the layout.
      *
      *===================================================================
     D $uciinfo        ds                  inz

650aDD* $uiver#                       2s 0 Inz(1)
650aMD  $uiver#                       2s 0 Inz(2)

     D  $uiWhse                       3  0
     D  $uiItem                      15
     D  $uiuci                      100
     D  $uiUciLcns                   15
     D  $uiLcns                      15
     D  $uiSeq                        2s 0
     D  $uiserial                    20
     D  $uiWgtlbs                    11s 3
     D  $uiWgtKgs                    11s 3
     D  $uiSelTrn#                    7S 0
     D  $uiSelLbl#                    7S 0
     D  $uiSelOrd                     7S 0
     D  $uiSelSeq                     5S 0
     D  $uiSelCSeq                    3S 0
     D  $uiSelTrax                   10
     D  $uiCrtBy                      1
     D  $UIADDTS                       Z
     D  $UIADDUC                       Z
     D  $UIADDPGM                    10
     D  $UIADDEMP                     5S 0
     D  $UIADDUSR                    10
     D  $UIADDJOB                    10
     D  $UIADDNBR                     6
     D  $UICHGTS                       Z
     D  $UICHGUC                       Z
     D  $UICHGPGM                    10
     D  $UICHGEMP                     5S 0
     D  $UICHGUSR                    10
     D  $UICHGJOB                    10
     D  $UICHGNBR                     6

      *---------------------
650aA * Version 2 additions
      *---------------------

650aAD  $uiRtnTrn#                    7S 0

      *---------------------
700aA * Version 3 additions
      *---------------------

700aAD  $uiToLcns                    15
720aAD  $uiaOLcns                    15
720aAD  $uiaOSeq                      2s 0
720aAD  $uiaUTyp                      1
720aAD  $uiaGTIN                     14s 0
720aAD  $uiaEntD                      8s 0
720aAD  $uiaExpD                      8s 0
720aAD  $uiaLot                      30

720aMD $uciinfo2       ds                  inz
720aAD  $uiaPartlTS                    z
720aAD  $uiSlotItm                   15
720aAD  $uiaSlUTyp                    1
720aAD  $uiAction                    10
720aAD  $uiTran#                      7s 0
720aAD  $uiETrn#                      7s 0
720aAD  $uiLbl#                       7s 0
720aAD  $uiscan                       1
720aAD  $uiucichg                     1
720aAD  $uifuci                     100
720aAD  $uiItemchg                    1
720aAD  $uiFItem                     15
720aAD  $uiFItype                     1
720aAD  $uifutyp                      1
720aAD  $uifsitem                    15
720aAD  $uifsitype                    1
720aAD  $uifsutyp                     1
720aAD  $uilcnschg                    1
720aAD  $uientchg                     1
720aAD  $uifentd                      8s 0
720aAD  $uiexpchg                     1
720aAD  $uifexpd                      8s 0
720aAD  $uiexccode                    8
720aAD  $uiexcstat                    2
720aAD  $uiexcuser                   10
720aAD  $uiexcts                       z
720aAD  $uiexpflag                    1
720aAD  $uiexpts                       z
720aAD  $uiexpuc                       z
720aAD  $uiexpjusr                   10
720aAD  $uiexpjob                    10
720aAD  $uiexpnbr                     6
720aAD  $uifLcns                     15
720aAD  $uifSeq                       2s 0
720aAD  $uiaLcns                     15
