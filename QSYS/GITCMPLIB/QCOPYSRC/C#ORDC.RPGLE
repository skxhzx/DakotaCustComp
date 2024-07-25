      *===================================================================
      *
      *  Name .......... C#ORDC
      *  Description ... Dakota realtime interface layout for  ORDC
      *  Created by .... Dave Sommerville
      *
      *===================================================================
      *
      * Revisions
      *
650 A *   11/19/13  DAS  6.50
      *     - Created.
      *
650aA *   04/23/14  DAS  6.50a
      *     - Changed version number to 2.
      *     - Added fields for ordcflg fields
      *
      *===================================================================
      *
      * Notes
      *
      *   - When adding new fields ...
      *
      *       1) Increment the version number
      *       2) Always add new fields to the end of the layout.
      *
      *===================================================================
     D $ordc           ds                  inz
650aMD  $ocver#                       2s 0 Inz(2)

     D  $ocwhse                       3s 0
     D   $ocwhsee                     1
     D   $ocwhseu                      n
     D  $ocord                        7s 0
     D   $ocorde                      1
     D   $ocordu                       n
     D  $ocseq#                       5s 0
     D   $ocseq#e                     1
     D   $ocseq#u                      n
     D  $ocitem                      15
     D   $ociteme                     1
     D   $ocitemu                      n
     D  $ocseq                        3s 0
     D   $ocseqe                      1
     D   $ocsequ                       n
     D  $occwgt                       7s 2
     D   $occwgte                     1
     D   $occwgtu                      n
     D  $octran                       7s 0
     D   $octrane                     1
     D   $octranu                      n
     D  $oclbl#                       7s 0
     D   $oclbl#e                     1
     D   $oclbl#u                      n
650aAD  $ocfcod                       2
650aAD   $ocfcode                     1
650aAD   $ocfcodu                      n
650aAD  $ocfflg                       1
650aAD   $ocfflge                     1
650aAD   $ocfflgu                      n
650aAD  $rtnshort                    10
