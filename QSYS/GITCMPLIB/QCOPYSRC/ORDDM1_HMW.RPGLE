      *===================================================================
      *
      *  Name .......... ORDDM1_HMW
      *  Description ... Order Detail Misc. Field 1 - HM Wagner
      *  Created by .... Max Blacknik
      *
      *===================================================================
      *
      * Revisions
      *
640 A *   08/10/12  MLB  6.40
      *     - Created.
      *
      *===================================================================
      *
      * Notes
      *
      *===================================================================

     D orddm1_hmw      ds

     D  hmwdm1_base                  40
     D*                                    text('Detail Misc 1 Field')

     Dhmwdm1_omsubsts                 3    overlay(hmwdm1_base:1)
     D*                                    text('AFS Sub Status:SUB,PAR,OUT,""')
     D*                                    text('SUB=Subbed item attached')
     D*                                    text('PAR=Partial qty shipped')
     D*                                    text('OUT=Item outted')
     D*                                    text('blanks=shipped 100%')
