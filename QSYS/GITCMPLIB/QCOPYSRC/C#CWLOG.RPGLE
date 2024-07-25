      *===================================================================
      *
      *  Name .......... C#CWLOG
      *  Description ... Dakota realtime interface layout for  CWLOG
      *  Created by .... Lynn McMahon
      *
      *===================================================================
      *
      * Revisions
      *
650aA *   03/07/13  LMC  6.50
      *     - Created.
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
     D $cwlog          ds                  inz

     D  $cwver#                       2s 0 Inz(1)

     D  $cwWhse                       3  0
     D  $cwSelOrd                     7S 0
     D  $cwSelSeq                     5S 0
     D  $cwItem                      15
     D  $cwSelLbl#                    7S 0
     D  $cwSelTrn#                    7S 0
     D  $cwSelCSeq                    3S 0
     D  $cwscan                     100
     D  $cwentflg                     3s 0
     D  $cwWgtlbs                    11s 3
     D  $cwstat                       1
     D  $cwADDTS                       Z
     D  $cwADDUC                       Z
     D  $cwADDPGM                    10
     D  $cwADDEMP                     5S 0
     D  $cwADDUSR                    10
     D  $cwADDJOB                    10
     D  $cwADDNBR                     6
     D  $cwCHGTS                       Z
     D  $cwCHGUC                       Z
     D  $cwCHGPGM                    10
     D  $cwCHGEMP                     5S 0
     D  $cwCHGUSR                    10
     D  $cwCHGJOB                    10
     D  $cwCHGNBR                     6


