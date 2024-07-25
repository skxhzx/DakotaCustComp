      *===================================================================
      *
      *  Name .......... C#PIRHLDCT
      *  Description ... PIRHOLD Catch Weight Total  info data structure
      *  Created by .... Lynn McMahon
      *===================================================================
      *
      * Revisions
      *
700aA *   01/12/16  LMC  7.00
      *     - Created.
      *
      *===================================================================
      *   Type will be PODTLCT
      *   key field will be PO/POSEQ/ITEM
      *===================================================================

     *----------------------------------------------------------------
     * Begin C#PIRHLDCT  - File information data structure - PIRHOLD CT
     *----------------------------------------------------------------

     D pirhldctds      ds
     D  svcw#                  1      7s 0 inz(0)
     d  cweck                  8      8
     D  svtcw                  9     17s 2 inz(0)
     d  twtck                 18     18
     d  cntflag               19     19
     d  varflag               20     20

     *** End ***
