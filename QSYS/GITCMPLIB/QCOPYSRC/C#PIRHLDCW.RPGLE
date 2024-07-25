      *===================================================================
      *
      *  Name .......... C#PIRHLDCW
      *  Description ... PIRHOLD Catch Weight Entry  info data structure
      *  Created by .... Lynn McMahon
      *===================================================================
      *
      * Revisions
      *
700aA *   08/20/15  LMC  7.00
      *     - Created.
      *
      *===================================================================
      *   Type will be PODTLCW
      *   key field will be PO/POSEQ/ITEM/CW Seq#
      *===================================================================

     *----------------------------------------------------------------
     * Begin C#PIRHLDCW  - File information data structure - PIRHOLD CW
     *----------------------------------------------------------------

     D pirhldcwds      ds
     D  cwentered              1    100
     D  weight               101    107S 0 inz(0)
     D  weightd              101    107S 2 inz(0)
     D* reload               108    108
     D  weighta              109    116
     D  cwseq#               117    120S 0 inz(0)
     D  svaddw               121    127s 0 inz(0)
     d  cwtck                128    128
     D* svcw#                129    135s 0 inz(0)
     d* cweck                136    136
     D* svtcw                137    145s 2 inz(0)
     d* twtck                146    146

     *** End C#FILE15DS ***
